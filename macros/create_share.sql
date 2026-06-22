-- macros/create_share.sql
{% macro create_share(share_name, accounts) %}
  {% if target.name == "prod" %}
    {% set sql %}
      use role accountadmin;
      CREATE SHARE IF NOT EXISTS {{ share_name }};
      GRANT USAGE ON DATABASE {{ target.database }} TO SHARE {{ share_name }};

      {% for account in accounts %}
        ALTER SHARE {{ share_name }} ADD ACCOUNTS = {{ account }};
      {% endfor %}

      use role {{ target.role }};
    {% endset %}
    {% set table = run_query(sql) %}
  {% endif %}
{% endmacro %}
