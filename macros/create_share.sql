{% macro create_share(share_name, accounts) %}
  {% if target.name == "prod" %}
    {% set accounts_array = "ARRAY_CONSTRUCT('" ~ accounts | join("','") ~ "')" %}
    {% set sql %}
      CALL {{ target.database }}.dbt_admin.create_share_proc('{{ share_name }}', {{ accounts_array }});
    {% endset %}
    {% set table = run_query(sql) %}
  {% endif %}
{% endmacro %}
