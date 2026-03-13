with

selections as (

    select *
    from {{ ref('fct_pivot_bracket__selections') }}

),

matches as (

    select *
    from {{ ref('dim_pivot_bracket__matches') }}

),

contests as (

    select *
    from {{ ref('dim_pivot_bracket__contests') }}

),

joined as (

    select 
        selections.selection_id,
        selections.entry_id,
        selections.user_id,
        selections.contest_id,
        selections.match_id,
        selections.selected_team_id,
        matches.tournament_id,
        matches.region_id,
        matches.round_id,
        matches.home_team_id,
        matches.away_team_id,
        matches.winner_team_id,

        matches.tournament_name,
        matches.region_name,
        matches.round_name,
        matches.round_number,
        matches.home_team_name,
        matches.away_team_name,
        matches.winning_team_name,
        matches.match_slot,

        contests.contest_name,
        contests.contest_status,
        contests.contest_type,
        contests.customer_name,
        contests.tournament_status,
        
        selections.selected_team_name,
        selections.is_correct
    
    from selections
    left join matches
        on selections.match_id = matches.match_id
    left join contests
        on selections.contest_id = contests.contest_id
   
)

select * from joined