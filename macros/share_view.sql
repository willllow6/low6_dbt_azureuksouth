{% macro share_view(view_schema, view_name, share_name) %}
  {% if target.name == "prod" %}
    {% set sql %}
      CALL {{ target.database }}.dbt_admin.grant_view_to_share('{{ view_schema }}', '{{ view_name }}', '{{ share_name }}');
    {% endset %}
    {% set table = run_query(sql) %}
  {% endif %}
{% endmacro %}
