select
    entry_date,
    tenant_name,
    total_entries,
    first_user_entries,
    total_winning_entries
from {{ ref('int_prizekings_comps__daily_entry_metrics') }}
