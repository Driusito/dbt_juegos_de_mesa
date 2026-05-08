{% snapshot budget_snapshot_check %}

    {{
        config(
          target_schema='snapshots',
          unique_key='user_id',
          strategy='check',
          check_cols=['user_type']
        )
    }}

    select * from {{ ref('stg_users') }}

{% endsnapshot %}