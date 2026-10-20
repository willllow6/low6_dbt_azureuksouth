"""One-off load of the previous supplier's (Dream Team / NUK) 2025-26 game registrations
into low6_azureuksouth.adfengagecraftfantasy.dreamteam_game_registration.

The feed file is pipe-delimited with no header. Line 1 is a control line `1|<file>` and the
last line is `9|<file>|<rowcount>`; both are dropped and the row count is checked against the
footer. Columns (Data Feed Schema - DreamTeam 2026, GameRegistration sheet):
CPN | Game_Year | Game_Type | Tournament | First_Activity_Date (DD-MM-YYYY)

Usage (dbt311 env):
    python -I scripts/load_engagecraft_dreamteam_game_registrations.py <zip_or_csv> [work_dir]
"""

import gzip
import io
import os
import sys
import tempfile
import zipfile

import snowflake.connector
import yaml
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

TABLE = 'low6_azureuksouth.adfengagecraftfantasy.dreamteam_game_registration'
TABLE_STAGE = '@low6_azureuksouth.adfengagecraftfantasy.%dreamteam_game_registration'
MEMBER_PREFIX = 'NUK_DREAMTEAM_GAMEREGISTRATION_'


def read_lines(path):
    if path.lower().endswith('.zip'):
        with zipfile.ZipFile(path) as z:
            member = next(n for n in z.namelist() if os.path.basename(n).startswith(MEMBER_PREFIX))
            with z.open(member) as f:
                return os.path.basename(member), io.TextIOWrapper(f, encoding='utf-8').read().splitlines()
    with open(path, encoding='utf-8') as f:
        return os.path.basename(path), f.read().splitlines()


def clean(lines):
    header, footer, rows = lines[0], lines[-1], lines[1:-1]
    assert header.startswith('1|'), f'unexpected header: {header}'
    assert footer.startswith('9|'), f'unexpected footer: {footer}'
    expected = int(footer.split('|')[2])
    rows = [r for r in rows if r.strip()]
    assert len(rows) == expected, f'{len(rows)} data rows but footer says {expected}'
    return rows, expected


def connect():
    profile = yaml.safe_load(open(os.path.expanduser('~/.dbt/profiles.yml')))
    p = profile['low6_dbt_azureuksouth']['outputs']['dev']
    with open(os.path.expanduser(p['private_key_path']), 'rb') as f:
        key = serialization.load_pem_private_key(
            f.read(),
            password=os.environ.get('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE', '').encode() or None,
            backend=default_backend(),
        )
    der = key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    return snowflake.connector.connect(
        account=p['account'], user=p['user'], private_key=der,
        role=p['role'], warehouse=p['warehouse'], database=p['database'],
    )


def main(src, work_dir):
    source_file, lines = read_lines(src)
    rows, expected = clean(lines)
    print(f'{source_file}: {expected} data rows')

    gz_path = os.path.join(work_dir, 'dreamteam_game_registration.csv.gz')
    with gzip.open(gz_path, 'wt', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(rows) + '\n')

    con = connect()
    cur = con.cursor()
    try:
        cur.execute(f"""
            create or replace table {TABLE} (
                cpn varchar,
                game_year varchar,
                game_type varchar,
                tournament varchar,
                first_activity_date varchar,
                _source_file varchar,
                _loaded_at timestamp_ntz default sysdate()
            )
        """)
        cur.execute(f"put 'file://{gz_path.replace(os.sep, '/')}' {TABLE_STAGE} overwrite = true")
        cur.execute(f"""
            copy into {TABLE} (cpn, game_year, game_type, tournament, first_activity_date, _source_file)
            from (
                select $1, $2, $3, $4, $5, '{source_file}'
                from {TABLE_STAGE}
            )
            file_format = (
                type = csv
                field_delimiter = '|'
                field_optionally_enclosed_by = '"'
                skip_header = 0
                compression = gzip
            )
            on_error = abort_statement
            purge = true
        """)
        loaded, cpns = cur.execute(f'select count(*), count(distinct cpn) from {TABLE}').fetchone()
        print(f'{TABLE}: {loaded} rows, {cpns} distinct CPNs')
        assert loaded == expected, f'loaded {loaded} rows, expected {expected}'
    finally:
        cur.close()
        con.close()


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else tempfile.gettempdir())
