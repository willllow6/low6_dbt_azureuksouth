# Data Lineage

Full dependency graph for the low6_dbt_azureuksouth project.

## Dependency Graph

```mermaid
graph LR

  core_user_service__referrals["core_user_service__referrals"]
  stg_core_user_service__referrals["stg_core_user_service__referrals"]
  stg_core_user_service__users["stg_core_user_service__users"]
  int_itv_spinoff__live_quiz_answers["int_itv_spinoff__live_quiz_answers"]
  int_itv_spinoff__live_quiz_attempts["int_itv_spinoff__live_quiz_attempts"]
  int_itv_spinoff__quiz_attempts_ranked["int_itv_spinoff__quiz_attempts_ranked"]
  int_itv_spinoff__quiz_attempts_unioned["int_itv_spinoff__quiz_attempts_unioned"]
  int_itv_spinoff__quizes_unioned["int_itv_spinoff__quizes_unioned"]
  itv_spinoff__achievement_stats["itv_spinoff__achievement_stats"]
  itv_spinoff__achievements["itv_spinoff__achievements"]
  itv_spinoff__active_streak_stats["itv_spinoff__active_streak_stats"]
  itv_spinoff__active_streaks["itv_spinoff__active_streaks"]
  itv_spinoff__conversion_funnel_stats["itv_spinoff__conversion_funnel_stats"]
  itv_spinoff__daily_stats["itv_spinoff__daily_stats"]
  itv_spinoff__friends_league_membership_stats["itv_spinoff__friends_league_membership_stats"]
  itv_spinoff__friends_league_memberships["itv_spinoff__friends_league_memberships"]
  itv_spinoff__quiz_attempt_stats["itv_spinoff__quiz_attempt_stats"]
  itv_spinoff__quiz_attempts["itv_spinoff__quiz_attempts"]
  itv_spinoff__referral_stats["itv_spinoff__referral_stats"]
  itv_spinoff__referrals["itv_spinoff__referrals"]
  itv_spinoff__user_stats["itv_spinoff__user_stats"]
  itv_spinoff__users["itv_spinoff__users"]
  itv_spinoff__weekly_cohort_analysis["itv_spinoff__weekly_cohort_analysis"]
  stg_itv_spinoff__achievement_categories["stg_itv_spinoff__achievement_categories"]
  stg_itv_spinoff__achievements["stg_itv_spinoff__achievements"]
  stg_itv_spinoff__daily_streaks["stg_itv_spinoff__daily_streaks"]
  stg_itv_spinoff__friends_league_memberships["stg_itv_spinoff__friends_league_memberships"]
  stg_itv_spinoff__friends_leagues["stg_itv_spinoff__friends_leagues"]
  stg_itv_spinoff__live_quiz_questions["stg_itv_spinoff__live_quiz_questions"]
  stg_itv_spinoff__live_quizes["stg_itv_spinoff__live_quizes"]
  stg_itv_spinoff__player_answers["stg_itv_spinoff__player_answers"]
  stg_itv_spinoff__players["stg_itv_spinoff__players"]
  stg_itv_spinoff__quiz_attempts["stg_itv_spinoff__quiz_attempts"]
  stg_itv_spinoff__quizes["stg_itv_spinoff__quizes"]
  stg_itv_spinoff__user_achievements["stg_itv_spinoff__user_achievements"]
  low6__live_game_iap["low6__live_game_iap"]
  low6__live_game_kpis["low6__live_game_kpis"]
  agg_pivot_bracket__entries_hourly["agg_pivot_bracket__entries_hourly"]
  agg_pivot_bracket__growth_metrics_daily["agg_pivot_bracket__growth_metrics_daily"]
  agg_pivot_bracket__selections["agg_pivot_bracket__selections"]
  dim_pivot_bracket__contests["dim_pivot_bracket__contests"]
  dim_pivot_bracket__customers["dim_pivot_bracket__customers"]
  dim_pivot_bracket__matches["dim_pivot_bracket__matches"]
  dim_pivot_bracket__users["dim_pivot_bracket__users"]
  fct_pivot_bracket__entries["fct_pivot_bracket__entries"]
  fct_pivot_bracket__selections["fct_pivot_bracket__selections"]
  int_pivot_bracket__contest_metrics_daily["int_pivot_bracket__contest_metrics_daily"]
  int_pivot_bracket__customer_metrics_daily["int_pivot_bracket__customer_metrics_daily"]
  int_pivot_bracket__entry_metrics_daily["int_pivot_bracket__entry_metrics_daily"]
  int_pivot_bracket__registration_metrics_daily["int_pivot_bracket__registration_metrics_daily"]
  mart_pivot_bracket__entries["mart_pivot_bracket__entries"]
  mart_pivot_bracket__selections["mart_pivot_bracket__selections"]
  stg_pivot_bracket__contests["stg_pivot_bracket__contests"]
  stg_pivot_bracket__customers["stg_pivot_bracket__customers"]
  stg_pivot_bracket__entries["stg_pivot_bracket__entries"]
  stg_pivot_bracket__matches["stg_pivot_bracket__matches"]
  stg_pivot_bracket__regions["stg_pivot_bracket__regions"]
  stg_pivot_bracket__rounds["stg_pivot_bracket__rounds"]
  stg_pivot_bracket__selections["stg_pivot_bracket__selections"]
  stg_pivot_bracket__teams["stg_pivot_bracket__teams"]
  stg_pivot_bracket__tournaments["stg_pivot_bracket__tournaments"]
  stg_pivot_bracket__users["stg_pivot_bracket__users"]
  agg_prizekings_comps__competition_entries_daily["agg_prizekings_comps__competition_entries_daily"]
  agg_prizekings_comps__competition_performance["agg_prizekings_comps__competition_performance"]
  agg_prizekings_comps__deposit_metrics_daily["agg_prizekings_comps__deposit_metrics_daily"]
  agg_prizekings_comps__entry_metrics_daily["agg_prizekings_comps__entry_metrics_daily"]
  agg_prizekings_comps__financial_metrics_daily["agg_prizekings_comps__financial_metrics_daily"]
  agg_prizekings_comps__growth_metrics_daily["agg_prizekings_comps__growth_metrics_daily"]
  agg_prizekings_comps__promotion_completions_daily["agg_prizekings_comps__promotion_completions_daily"]
  agg_prizekings_comps__registration_metrics_daily["agg_prizekings_comps__registration_metrics_daily"]
  agg_prizekings_comps__registrations_daily["agg_prizekings_comps__registrations_daily"]
  agg_prizekings_comps__user_activity_daily["agg_prizekings_comps__user_activity_daily"]
  dim_prizekings_comps__competitions["dim_prizekings_comps__competitions"]
  dim_prizekings_comps__prizes["dim_prizekings_comps__prizes"]
  dim_prizekings_comps__promotions["dim_prizekings_comps__promotions"]
  dim_prizekings_comps__tenants["dim_prizekings_comps__tenants"]
  dim_prizekings_comps__users["dim_prizekings_comps__users"]
  fct_prizekings_comps__competition_entries["fct_prizekings_comps__competition_entries"]
  fct_prizekings_comps__deposits["fct_prizekings_comps__deposits"]
  fct_prizekings_comps__prize_awards["fct_prizekings_comps__prize_awards"]
  fct_prizekings_comps__user_promotions["fct_prizekings_comps__user_promotions"]
  int_prizekings_comps__competition_entries_unioned["int_prizekings_comps__competition_entries_unioned"]
  int_prizekings_comps__competition_financials["int_prizekings_comps__competition_financials"]
  int_prizekings_comps__competitions_unioned["int_prizekings_comps__competitions_unioned"]
  mart_prizekings_comps__competition_entries["mart_prizekings_comps__competition_entries"]
  mart_prizekings_comps__promotion_completions["mart_prizekings_comps__promotion_completions"]
  mart_prizekings_comps__registrations["mart_prizekings_comps__registrations"]
  stg_prizekings_comps__competition["stg_prizekings_comps__competition"]
  stg_prizekings_comps__competition_entry["stg_prizekings_comps__competition_entry"]
  stg_prizekings_comps__competition_prize["stg_prizekings_comps__competition_prize"]
  stg_prizekings_comps__languages["stg_prizekings_comps__languages"]
  stg_prizekings_comps__prizes["stg_prizekings_comps__prizes"]
  stg_prizekings_comps__promotion_tenants["stg_prizekings_comps__promotion_tenants"]
  stg_prizekings_comps__promotions["stg_prizekings_comps__promotions"]
  stg_prizekings_comps__raffles["stg_prizekings_comps__raffles"]
  stg_prizekings_comps__tenants["stg_prizekings_comps__tenants"]
  stg_prizekings_comps__transactions["stg_prizekings_comps__transactions"]
  stg_prizekings_comps__translations["stg_prizekings_comps__translations"]
  stg_prizekings_comps__user_promotions["stg_prizekings_comps__user_promotions"]
  stg_prizekings_comps__user_raffle_tickets["stg_prizekings_comps__user_raffle_tickets"]
  stg_prizekings_comps__users["stg_prizekings_comps__users"]

  stg_core_user_service__referrals --> core_user_service__referrals
  stg_core_user_service__users --> core_user_service__referrals
  src_core_user_service_referrals --> stg_core_user_service__referrals
  src_core_user_service_users --> stg_core_user_service__users
  stg_itv_spinoff__live_quiz_questions --> int_itv_spinoff__live_quiz_answers
  stg_itv_spinoff__player_answers --> int_itv_spinoff__live_quiz_answers
  stg_itv_spinoff__players --> int_itv_spinoff__live_quiz_answers
  int_itv_spinoff__live_quiz_answers --> int_itv_spinoff__live_quiz_attempts
  int_itv_spinoff__quiz_attempts_unioned --> int_itv_spinoff__quiz_attempts_ranked
  int_itv_spinoff__live_quiz_attempts --> int_itv_spinoff__quiz_attempts_unioned
  stg_itv_spinoff__quiz_attempts --> int_itv_spinoff__quiz_attempts_unioned
  stg_itv_spinoff__live_quizes --> int_itv_spinoff__quizes_unioned
  stg_itv_spinoff__quizes --> int_itv_spinoff__quizes_unioned
  itv_spinoff__achievements --> itv_spinoff__achievement_stats
  itv_spinoff__users --> itv_spinoff__achievements
  stg_itv_spinoff__achievement_categories --> itv_spinoff__achievements
  stg_itv_spinoff__achievements --> itv_spinoff__achievements
  stg_itv_spinoff__user_achievements --> itv_spinoff__achievements
  itv_spinoff__active_streaks --> itv_spinoff__active_streak_stats
  itv_spinoff__users --> itv_spinoff__active_streaks
  stg_itv_spinoff__daily_streaks --> itv_spinoff__active_streaks
  itv_spinoff__users --> itv_spinoff__conversion_funnel_stats
  itv_spinoff__quiz_attempts --> itv_spinoff__daily_stats
  itv_spinoff__referrals --> itv_spinoff__daily_stats
  itv_spinoff__users --> itv_spinoff__daily_stats
  itv_spinoff__friends_league_memberships --> itv_spinoff__friends_league_membership_stats
  itv_spinoff__users --> itv_spinoff__friends_league_memberships
  stg_itv_spinoff__friends_league_memberships --> itv_spinoff__friends_league_memberships
  stg_itv_spinoff__friends_leagues --> itv_spinoff__friends_league_memberships
  itv_spinoff__quiz_attempts --> itv_spinoff__quiz_attempt_stats
  int_itv_spinoff__quiz_attempts_ranked --> itv_spinoff__quiz_attempts
  int_itv_spinoff__quizes_unioned --> itv_spinoff__quiz_attempts
  itv_spinoff__users --> itv_spinoff__quiz_attempts
  itv_spinoff__referrals --> itv_spinoff__referral_stats
  core_user_service__referrals --> itv_spinoff__referrals
  itv_spinoff__users --> itv_spinoff__user_stats
  stg_core_user_service__referrals --> itv_spinoff__users
  stg_core_user_service__users --> itv_spinoff__users
  stg_itv_spinoff__friends_league_memberships --> itv_spinoff__users
  stg_itv_spinoff__quiz_attempts --> itv_spinoff__users
  stg_itv_spinoff__user_achievements --> itv_spinoff__users
  itv_spinoff__quiz_attempts --> itv_spinoff__weekly_cohort_analysis
  src_itv_spinoff_achievement_category --> stg_itv_spinoff__achievement_categories
  src_itv_spinoff_achievement --> stg_itv_spinoff__achievements
  src_itv_spinoff_daily_streak --> stg_itv_spinoff__daily_streaks
  src_itv_spinoff_friends_league_membership --> stg_itv_spinoff__friends_league_memberships
  src_itv_spinoff_friends_league --> stg_itv_spinoff__friends_leagues
  src_itv_spinoff_live_livequizquestions --> stg_itv_spinoff__live_quiz_questions
  src_itv_spinoff_live_livequizzes --> stg_itv_spinoff__live_quizes
  src_itv_spinoff_live_playeranswers --> stg_itv_spinoff__player_answers
  src_itv_spinoff_live_players --> stg_itv_spinoff__players
  src_itv_spinoff_quiz_attempt --> stg_itv_spinoff__quiz_attempts
  src_itv_spinoff_quiz --> stg_itv_spinoff__quizes
  src_itv_spinoff_user_achievement --> stg_itv_spinoff__user_achievements
  dim_prizekings_comps__users --> low6__live_game_iap
  stg_prizekings_comps__transactions --> low6__live_game_iap
  src_itv_spinoff_quiz_attempt --> low6__live_game_kpis
  src_pivot_bracket_user_selection --> low6__live_game_kpis
  mart_prizekings_comps__competition_entries --> low6__live_game_kpis
  mart_pivot_bracket__entries --> agg_pivot_bracket__entries_hourly
  int_pivot_bracket__contest_metrics_daily --> agg_pivot_bracket__growth_metrics_daily
  int_pivot_bracket__customer_metrics_daily --> agg_pivot_bracket__growth_metrics_daily
  int_pivot_bracket__entry_metrics_daily --> agg_pivot_bracket__growth_metrics_daily
  int_pivot_bracket__registration_metrics_daily --> agg_pivot_bracket__growth_metrics_daily
  mart_pivot_bracket__selections --> agg_pivot_bracket__selections
  stg_pivot_bracket__contests --> dim_pivot_bracket__contests
  stg_pivot_bracket__customers --> dim_pivot_bracket__contests
  stg_pivot_bracket__tournaments --> dim_pivot_bracket__contests
  stg_pivot_bracket__customers --> dim_pivot_bracket__customers
  stg_pivot_bracket__matches --> dim_pivot_bracket__matches
  stg_pivot_bracket__regions --> dim_pivot_bracket__matches
  stg_pivot_bracket__rounds --> dim_pivot_bracket__matches
  stg_pivot_bracket__teams --> dim_pivot_bracket__matches
  stg_pivot_bracket__tournaments --> dim_pivot_bracket__matches
  stg_pivot_bracket__users --> dim_pivot_bracket__users
  stg_pivot_bracket__entries --> fct_pivot_bracket__entries
  stg_pivot_bracket__entries --> fct_pivot_bracket__selections
  stg_pivot_bracket__selections --> fct_pivot_bracket__selections
  stg_pivot_bracket__teams --> fct_pivot_bracket__selections
  dim_pivot_bracket__contests --> int_pivot_bracket__contest_metrics_daily
  dim_pivot_bracket__customers --> int_pivot_bracket__customer_metrics_daily
  fct_pivot_bracket__entries --> int_pivot_bracket__entry_metrics_daily
  dim_pivot_bracket__users --> int_pivot_bracket__registration_metrics_daily
  dim_pivot_bracket__contests --> mart_pivot_bracket__entries
  dim_pivot_bracket__users --> mart_pivot_bracket__entries
  fct_pivot_bracket__entries --> mart_pivot_bracket__entries
  dim_pivot_bracket__contests --> mart_pivot_bracket__selections
  dim_pivot_bracket__matches --> mart_pivot_bracket__selections
  fct_pivot_bracket__selections --> mart_pivot_bracket__selections
  src_pivot_bracket_brackets --> stg_pivot_bracket__contests
  src_pivot_bracket_customers --> stg_pivot_bracket__customers
  src_pivot_bracket_user_selection --> stg_pivot_bracket__entries
  src_pivot_bracket_matchups --> stg_pivot_bracket__matches
  src_pivot_bracket_regions --> stg_pivot_bracket__regions
  src_pivot_bracket_rounds --> stg_pivot_bracket__rounds
  src_pivot_bracket_selection_matchups --> stg_pivot_bracket__selections
  src_pivot_bracket_teams --> stg_pivot_bracket__teams
  src_pivot_bracket_tournaments --> stg_pivot_bracket__tournaments
  src_pivot_bracket_users --> stg_pivot_bracket__users
  mart_prizekings_comps__competition_entries --> agg_prizekings_comps__competition_entries_daily
  int_prizekings_comps__competition_financials --> agg_prizekings_comps__competition_performance
  mart_prizekings_comps__competition_entries --> agg_prizekings_comps__competition_performance
  dim_prizekings_comps__users --> agg_prizekings_comps__deposit_metrics_daily
  fct_prizekings_comps__deposits --> agg_prizekings_comps__deposit_metrics_daily
  dim_prizekings_comps__competitions --> agg_prizekings_comps__entry_metrics_daily
  fct_prizekings_comps__competition_entries --> agg_prizekings_comps__entry_metrics_daily
  dim_prizekings_comps__users --> agg_prizekings_comps__financial_metrics_daily
  stg_prizekings_comps__transactions --> agg_prizekings_comps__financial_metrics_daily
  agg_prizekings_comps__deposit_metrics_daily --> agg_prizekings_comps__growth_metrics_daily
  agg_prizekings_comps__entry_metrics_daily --> agg_prizekings_comps__growth_metrics_daily
  agg_prizekings_comps__financial_metrics_daily --> agg_prizekings_comps__growth_metrics_daily
  agg_prizekings_comps__registration_metrics_daily --> agg_prizekings_comps__growth_metrics_daily
  agg_prizekings_comps__user_activity_daily --> agg_prizekings_comps__growth_metrics_daily
  dim_prizekings_comps__tenants --> agg_prizekings_comps__growth_metrics_daily
  mart_prizekings_comps__promotion_completions --> agg_prizekings_comps__promotion_completions_daily
  dim_prizekings_comps__users --> agg_prizekings_comps__registration_metrics_daily
  mart_prizekings_comps__registrations --> agg_prizekings_comps__registrations_daily
  dim_prizekings_comps__competitions --> agg_prizekings_comps__user_activity_daily
  fct_prizekings_comps__competition_entries --> agg_prizekings_comps__user_activity_daily
  int_prizekings_comps__competitions_unioned --> dim_prizekings_comps__competitions
  stg_prizekings_comps__translations --> dim_prizekings_comps__competitions
  stg_prizekings_comps__competition_prize --> dim_prizekings_comps__prizes
  stg_prizekings_comps__prizes --> dim_prizekings_comps__prizes
  stg_prizekings_comps__promotion_tenants --> dim_prizekings_comps__promotions
  stg_prizekings_comps__promotions --> dim_prizekings_comps__promotions
  stg_prizekings_comps__tenants --> dim_prizekings_comps__tenants
  stg_prizekings_comps__users --> dim_prizekings_comps__users
  int_prizekings_comps__competition_entries_unioned --> fct_prizekings_comps__competition_entries
  stg_prizekings_comps__transactions --> fct_prizekings_comps__deposits
  stg_prizekings_comps__competition_entry --> fct_prizekings_comps__prize_awards
  stg_prizekings_comps__user_raffle_tickets --> fct_prizekings_comps__prize_awards
  stg_prizekings_comps__user_promotions --> fct_prizekings_comps__user_promotions
  stg_prizekings_comps__competition_entry --> int_prizekings_comps__competition_entries_unioned
  stg_prizekings_comps__user_raffle_tickets --> int_prizekings_comps__competition_entries_unioned
  stg_prizekings_comps__transactions --> int_prizekings_comps__competition_financials
  stg_prizekings_comps__competition --> int_prizekings_comps__competitions_unioned
  stg_prizekings_comps__raffles --> int_prizekings_comps__competitions_unioned
  dim_prizekings_comps__competitions --> mart_prizekings_comps__competition_entries
  dim_prizekings_comps__prizes --> mart_prizekings_comps__competition_entries
  dim_prizekings_comps__tenants --> mart_prizekings_comps__competition_entries
  fct_prizekings_comps__competition_entries --> mart_prizekings_comps__competition_entries
  dim_prizekings_comps__promotions --> mart_prizekings_comps__promotion_completions
  dim_prizekings_comps__tenants --> mart_prizekings_comps__promotion_completions
  fct_prizekings_comps__user_promotions --> mart_prizekings_comps__promotion_completions
  dim_prizekings_comps__tenants --> mart_prizekings_comps__registrations
  dim_prizekings_comps__users --> mart_prizekings_comps__registrations
  src_prizekings_comps_competition --> stg_prizekings_comps__competition
  src_prizekings_comps_competition_entry --> stg_prizekings_comps__competition_entry
  src_prizekings_comps_competition_prize --> stg_prizekings_comps__competition_prize
  src_prizekings_comps_languages --> stg_prizekings_comps__languages
  src_prizekings_comps_prizes --> stg_prizekings_comps__prizes
  src_prizekings_comps_promotion_tenants --> stg_prizekings_comps__promotion_tenants
  src_prizekings_comps_promotions --> stg_prizekings_comps__promotions
  src_prizekings_comps_raffles --> stg_prizekings_comps__raffles
  src_prizekings_comps_tenants --> stg_prizekings_comps__tenants
  src_prizekings_comps_transactions --> stg_prizekings_comps__transactions
  src_prizekings_comps_translations --> stg_prizekings_comps__translations
  src_prizekings_comps_user_promotions --> stg_prizekings_comps__user_promotions
  src_prizekings_comps_user_raffle_tickets --> stg_prizekings_comps__user_raffle_tickets
  src_prizekings_comps_users --> stg_prizekings_comps__users
```

## Model Dependencies Table

| Model | Layer | Depends On |
|-------|-------|------------|
| `core_user_service__referrals` | core_user_service | stg_core_user_service__referrals, stg_core_user_service__users |
| `stg_core_user_service__referrals` | core_user_service | core_user_service.referrals |
| `stg_core_user_service__users` | core_user_service | core_user_service.users |
| `int_itv_spinoff__live_quiz_answers` | itv_spinoff | stg_itv_spinoff__live_quiz_questions, stg_itv_spinoff__player_answers, stg_itv_spinoff__players |
| `int_itv_spinoff__live_quiz_attempts` | itv_spinoff | int_itv_spinoff__live_quiz_answers |
| `int_itv_spinoff__quiz_attempts_ranked` | itv_spinoff | int_itv_spinoff__quiz_attempts_unioned |
| `int_itv_spinoff__quiz_attempts_unioned` | itv_spinoff | int_itv_spinoff__live_quiz_attempts, stg_itv_spinoff__quiz_attempts |
| `int_itv_spinoff__quizes_unioned` | itv_spinoff | stg_itv_spinoff__live_quizes, stg_itv_spinoff__quizes |
| `itv_spinoff__achievement_stats` | itv_spinoff | itv_spinoff__achievements |
| `itv_spinoff__achievements` | itv_spinoff | itv_spinoff__users, stg_itv_spinoff__achievement_categories, stg_itv_spinoff__achievements, stg_itv_spinoff__user_achievements |
| `itv_spinoff__active_streak_stats` | itv_spinoff | itv_spinoff__active_streaks |
| `itv_spinoff__active_streaks` | itv_spinoff | itv_spinoff__users, stg_itv_spinoff__daily_streaks |
| `itv_spinoff__conversion_funnel_stats` | itv_spinoff | itv_spinoff__users |
| `itv_spinoff__daily_stats` | itv_spinoff | itv_spinoff__quiz_attempts, itv_spinoff__referrals, itv_spinoff__users |
| `itv_spinoff__friends_league_membership_stats` | itv_spinoff | itv_spinoff__friends_league_memberships |
| `itv_spinoff__friends_league_memberships` | itv_spinoff | itv_spinoff__users, stg_itv_spinoff__friends_league_memberships, stg_itv_spinoff__friends_leagues |
| `itv_spinoff__quiz_attempt_stats` | itv_spinoff | itv_spinoff__quiz_attempts |
| `itv_spinoff__quiz_attempts` | itv_spinoff | int_itv_spinoff__quiz_attempts_ranked, int_itv_spinoff__quizes_unioned, itv_spinoff__users |
| `itv_spinoff__referral_stats` | itv_spinoff | itv_spinoff__referrals |
| `itv_spinoff__referrals` | itv_spinoff | core_user_service__referrals |
| `itv_spinoff__user_stats` | itv_spinoff | itv_spinoff__users |
| `itv_spinoff__users` | itv_spinoff | stg_core_user_service__referrals, stg_core_user_service__users, stg_itv_spinoff__friends_league_memberships, stg_itv_spinoff__quiz_attempts, stg_itv_spinoff__user_achievements |
| `itv_spinoff__weekly_cohort_analysis` | itv_spinoff | itv_spinoff__quiz_attempts |
| `stg_itv_spinoff__achievement_categories` | itv_spinoff | itv_spinoff.achievement_category |
| `stg_itv_spinoff__achievements` | itv_spinoff | itv_spinoff.achievement |
| `stg_itv_spinoff__daily_streaks` | itv_spinoff | itv_spinoff.daily_streak |
| `stg_itv_spinoff__friends_league_memberships` | itv_spinoff | itv_spinoff.friends_league_membership |
| `stg_itv_spinoff__friends_leagues` | itv_spinoff | itv_spinoff.friends_league |
| `stg_itv_spinoff__live_quiz_questions` | itv_spinoff | itv_spinoff_live.livequizquestions |
| `stg_itv_spinoff__live_quizes` | itv_spinoff | itv_spinoff_live.livequizzes |
| `stg_itv_spinoff__player_answers` | itv_spinoff | itv_spinoff_live.playeranswers |
| `stg_itv_spinoff__players` | itv_spinoff | itv_spinoff_live.players |
| `stg_itv_spinoff__quiz_attempts` | itv_spinoff | itv_spinoff.quiz_attempt |
| `stg_itv_spinoff__quizes` | itv_spinoff | itv_spinoff.quiz |
| `stg_itv_spinoff__user_achievements` | itv_spinoff | itv_spinoff.user_achievement |
| `low6__live_game_iap` | low6_reporting | dim_prizekings_comps__users, stg_prizekings_comps__transactions |
| `low6__live_game_kpis` | low6_reporting | itv_spinoff.quiz_attempt, pivot_bracket.user_selection, mart_prizekings_comps__competition_entries |
| `agg_pivot_bracket__entries_hourly` | pivot_bracket | mart_pivot_bracket__entries |
| `agg_pivot_bracket__growth_metrics_daily` | pivot_bracket | int_pivot_bracket__contest_metrics_daily, int_pivot_bracket__customer_metrics_daily, int_pivot_bracket__entry_metrics_daily, int_pivot_bracket__registration_metrics_daily |
| `agg_pivot_bracket__selections` | pivot_bracket | mart_pivot_bracket__selections |
| `dim_pivot_bracket__contests` | pivot_bracket | stg_pivot_bracket__contests, stg_pivot_bracket__customers, stg_pivot_bracket__tournaments |
| `dim_pivot_bracket__customers` | pivot_bracket | stg_pivot_bracket__customers |
| `dim_pivot_bracket__matches` | pivot_bracket | stg_pivot_bracket__matches, stg_pivot_bracket__regions, stg_pivot_bracket__rounds, stg_pivot_bracket__teams, stg_pivot_bracket__tournaments |
| `dim_pivot_bracket__users` | pivot_bracket | stg_pivot_bracket__users |
| `fct_pivot_bracket__entries` | pivot_bracket | stg_pivot_bracket__entries |
| `fct_pivot_bracket__selections` | pivot_bracket | stg_pivot_bracket__entries, stg_pivot_bracket__selections, stg_pivot_bracket__teams |
| `int_pivot_bracket__contest_metrics_daily` | pivot_bracket | dim_pivot_bracket__contests |
| `int_pivot_bracket__customer_metrics_daily` | pivot_bracket | dim_pivot_bracket__customers |
| `int_pivot_bracket__entry_metrics_daily` | pivot_bracket | fct_pivot_bracket__entries |
| `int_pivot_bracket__registration_metrics_daily` | pivot_bracket | dim_pivot_bracket__users |
| `mart_pivot_bracket__entries` | pivot_bracket | dim_pivot_bracket__contests, dim_pivot_bracket__users, fct_pivot_bracket__entries |
| `mart_pivot_bracket__selections` | pivot_bracket | dim_pivot_bracket__contests, dim_pivot_bracket__matches, fct_pivot_bracket__selections |
| `stg_pivot_bracket__contests` | pivot_bracket | pivot_bracket.brackets |
| `stg_pivot_bracket__customers` | pivot_bracket | pivot_bracket.customers |
| `stg_pivot_bracket__entries` | pivot_bracket | pivot_bracket.user_selection |
| `stg_pivot_bracket__matches` | pivot_bracket | pivot_bracket.matchups |
| `stg_pivot_bracket__regions` | pivot_bracket | pivot_bracket.regions |
| `stg_pivot_bracket__rounds` | pivot_bracket | pivot_bracket.rounds |
| `stg_pivot_bracket__selections` | pivot_bracket | pivot_bracket.selection_matchups |
| `stg_pivot_bracket__teams` | pivot_bracket | pivot_bracket.teams |
| `stg_pivot_bracket__tournaments` | pivot_bracket | pivot_bracket.tournaments |
| `stg_pivot_bracket__users` | pivot_bracket | pivot_bracket.users |
| `agg_prizekings_comps__competition_entries_daily` | prizekings_comps | mart_prizekings_comps__competition_entries |
| `agg_prizekings_comps__competition_performance` | prizekings_comps | int_prizekings_comps__competition_financials, mart_prizekings_comps__competition_entries |
| `agg_prizekings_comps__deposit_metrics_daily` | prizekings_comps | dim_prizekings_comps__users, fct_prizekings_comps__deposits |
| `agg_prizekings_comps__entry_metrics_daily` | prizekings_comps | dim_prizekings_comps__competitions, fct_prizekings_comps__competition_entries |
| `agg_prizekings_comps__financial_metrics_daily` | prizekings_comps | dim_prizekings_comps__users, stg_prizekings_comps__transactions |
| `agg_prizekings_comps__growth_metrics_daily` | prizekings_comps | agg_prizekings_comps__deposit_metrics_daily, agg_prizekings_comps__entry_metrics_daily, agg_prizekings_comps__financial_metrics_daily, agg_prizekings_comps__registration_metrics_daily, agg_prizekings_comps__user_activity_daily, dim_prizekings_comps__tenants |
| `agg_prizekings_comps__promotion_completions_daily` | prizekings_comps | mart_prizekings_comps__promotion_completions |
| `agg_prizekings_comps__registration_metrics_daily` | prizekings_comps | dim_prizekings_comps__users |
| `agg_prizekings_comps__registrations_daily` | prizekings_comps | mart_prizekings_comps__registrations |
| `agg_prizekings_comps__user_activity_daily` | prizekings_comps | dim_prizekings_comps__competitions, fct_prizekings_comps__competition_entries |
| `dim_prizekings_comps__competitions` | prizekings_comps | int_prizekings_comps__competitions_unioned, stg_prizekings_comps__translations |
| `dim_prizekings_comps__prizes` | prizekings_comps | stg_prizekings_comps__competition_prize, stg_prizekings_comps__prizes |
| `dim_prizekings_comps__promotions` | prizekings_comps | stg_prizekings_comps__promotion_tenants, stg_prizekings_comps__promotions |
| `dim_prizekings_comps__tenants` | prizekings_comps | stg_prizekings_comps__tenants |
| `dim_prizekings_comps__users` | prizekings_comps | stg_prizekings_comps__users |
| `fct_prizekings_comps__competition_entries` | prizekings_comps | int_prizekings_comps__competition_entries_unioned |
| `fct_prizekings_comps__deposits` | prizekings_comps | stg_prizekings_comps__transactions |
| `fct_prizekings_comps__prize_awards` | prizekings_comps | stg_prizekings_comps__competition_entry, stg_prizekings_comps__user_raffle_tickets |
| `fct_prizekings_comps__user_promotions` | prizekings_comps | stg_prizekings_comps__user_promotions |
| `int_prizekings_comps__competition_entries_unioned` | prizekings_comps | stg_prizekings_comps__competition_entry, stg_prizekings_comps__user_raffle_tickets |
| `int_prizekings_comps__competition_financials` | prizekings_comps | stg_prizekings_comps__transactions |
| `int_prizekings_comps__competitions_unioned` | prizekings_comps | stg_prizekings_comps__competition, stg_prizekings_comps__raffles |
| `mart_prizekings_comps__competition_entries` | prizekings_comps | dim_prizekings_comps__competitions, dim_prizekings_comps__prizes, dim_prizekings_comps__tenants, fct_prizekings_comps__competition_entries |
| `mart_prizekings_comps__promotion_completions` | prizekings_comps | dim_prizekings_comps__promotions, dim_prizekings_comps__tenants, fct_prizekings_comps__user_promotions |
| `mart_prizekings_comps__registrations` | prizekings_comps | dim_prizekings_comps__tenants, dim_prizekings_comps__users |
| `stg_prizekings_comps__competition` | prizekings_comps | prizekings_comps.competition |
| `stg_prizekings_comps__competition_entry` | prizekings_comps | prizekings_comps.competition_entry |
| `stg_prizekings_comps__competition_prize` | prizekings_comps | prizekings_comps.competition_prize |
| `stg_prizekings_comps__languages` | prizekings_comps | prizekings_comps.languages |
| `stg_prizekings_comps__prizes` | prizekings_comps | prizekings_comps.prizes |
| `stg_prizekings_comps__promotion_tenants` | prizekings_comps | prizekings_comps.promotion_tenants |
| `stg_prizekings_comps__promotions` | prizekings_comps | prizekings_comps.promotions |
| `stg_prizekings_comps__raffles` | prizekings_comps | prizekings_comps.raffles |
| `stg_prizekings_comps__tenants` | prizekings_comps | prizekings_comps.tenants |
| `stg_prizekings_comps__transactions` | prizekings_comps | prizekings_comps.transactions |
| `stg_prizekings_comps__translations` | prizekings_comps | prizekings_comps.translations |
| `stg_prizekings_comps__user_promotions` | prizekings_comps | prizekings_comps.user_promotions |
| `stg_prizekings_comps__user_raffle_tickets` | prizekings_comps | prizekings_comps.user_raffle_tickets |
| `stg_prizekings_comps__users` | prizekings_comps | prizekings_comps.users |

## Reverse Dependencies (downstream consumers)

| Model | Consumed By |
|-------|-------------|
| `core_user_service__referrals` | itv_spinoff__referrals |
| `stg_core_user_service__referrals` | core_user_service__referrals, itv_spinoff__users |
| `stg_core_user_service__users` | core_user_service__referrals, itv_spinoff__users |
| `int_itv_spinoff__live_quiz_answers` | int_itv_spinoff__live_quiz_attempts |
| `int_itv_spinoff__live_quiz_attempts` | int_itv_spinoff__quiz_attempts_unioned |
| `int_itv_spinoff__quiz_attempts_ranked` | itv_spinoff__quiz_attempts |
| `int_itv_spinoff__quiz_attempts_unioned` | int_itv_spinoff__quiz_attempts_ranked |
| `int_itv_spinoff__quizes_unioned` | itv_spinoff__quiz_attempts |
| `itv_spinoff__achievements` | itv_spinoff__achievement_stats |
| `itv_spinoff__active_streaks` | itv_spinoff__active_streak_stats |
| `itv_spinoff__friends_league_memberships` | itv_spinoff__friends_league_membership_stats |
| `itv_spinoff__quiz_attempts` | itv_spinoff__daily_stats, itv_spinoff__quiz_attempt_stats, itv_spinoff__weekly_cohort_analysis |
| `itv_spinoff__referrals` | itv_spinoff__daily_stats, itv_spinoff__referral_stats |
| `itv_spinoff__users` | itv_spinoff__achievements, itv_spinoff__active_streaks, itv_spinoff__conversion_funnel_stats, itv_spinoff__daily_stats, itv_spinoff__friends_league_memberships, itv_spinoff__quiz_attempts, itv_spinoff__user_stats |
| `stg_itv_spinoff__achievement_categories` | itv_spinoff__achievements |
| `stg_itv_spinoff__achievements` | itv_spinoff__achievements |
| `stg_itv_spinoff__daily_streaks` | itv_spinoff__active_streaks |
| `stg_itv_spinoff__friends_league_memberships` | itv_spinoff__friends_league_memberships, itv_spinoff__users |
| `stg_itv_spinoff__friends_leagues` | itv_spinoff__friends_league_memberships |
| `stg_itv_spinoff__live_quiz_questions` | int_itv_spinoff__live_quiz_answers |
| `stg_itv_spinoff__live_quizes` | int_itv_spinoff__quizes_unioned |
| `stg_itv_spinoff__player_answers` | int_itv_spinoff__live_quiz_answers |
| `stg_itv_spinoff__players` | int_itv_spinoff__live_quiz_answers |
| `stg_itv_spinoff__quiz_attempts` | int_itv_spinoff__quiz_attempts_unioned, itv_spinoff__users |
| `stg_itv_spinoff__quizes` | int_itv_spinoff__quizes_unioned |
| `stg_itv_spinoff__user_achievements` | itv_spinoff__achievements, itv_spinoff__users |
| `dim_pivot_bracket__contests` | int_pivot_bracket__contest_metrics_daily, mart_pivot_bracket__entries, mart_pivot_bracket__selections |
| `dim_pivot_bracket__customers` | int_pivot_bracket__customer_metrics_daily |
| `dim_pivot_bracket__matches` | mart_pivot_bracket__selections |
| `dim_pivot_bracket__users` | int_pivot_bracket__registration_metrics_daily, mart_pivot_bracket__entries |
| `fct_pivot_bracket__entries` | int_pivot_bracket__entry_metrics_daily, mart_pivot_bracket__entries |
| `fct_pivot_bracket__selections` | mart_pivot_bracket__selections |
| `int_pivot_bracket__contest_metrics_daily` | agg_pivot_bracket__growth_metrics_daily |
| `int_pivot_bracket__customer_metrics_daily` | agg_pivot_bracket__growth_metrics_daily |
| `int_pivot_bracket__entry_metrics_daily` | agg_pivot_bracket__growth_metrics_daily |
| `int_pivot_bracket__registration_metrics_daily` | agg_pivot_bracket__growth_metrics_daily |
| `mart_pivot_bracket__entries` | agg_pivot_bracket__entries_hourly |
| `mart_pivot_bracket__selections` | agg_pivot_bracket__selections |
| `stg_pivot_bracket__contests` | dim_pivot_bracket__contests |
| `stg_pivot_bracket__customers` | dim_pivot_bracket__contests, dim_pivot_bracket__customers |
| `stg_pivot_bracket__entries` | fct_pivot_bracket__entries, fct_pivot_bracket__selections |
| `stg_pivot_bracket__matches` | dim_pivot_bracket__matches |
| `stg_pivot_bracket__regions` | dim_pivot_bracket__matches |
| `stg_pivot_bracket__rounds` | dim_pivot_bracket__matches |
| `stg_pivot_bracket__selections` | fct_pivot_bracket__selections |
| `stg_pivot_bracket__teams` | dim_pivot_bracket__matches, fct_pivot_bracket__selections |
| `stg_pivot_bracket__tournaments` | dim_pivot_bracket__contests, dim_pivot_bracket__matches |
| `stg_pivot_bracket__users` | dim_pivot_bracket__users |
| `agg_prizekings_comps__deposit_metrics_daily` | agg_prizekings_comps__growth_metrics_daily |
| `agg_prizekings_comps__entry_metrics_daily` | agg_prizekings_comps__growth_metrics_daily |
| `agg_prizekings_comps__financial_metrics_daily` | agg_prizekings_comps__growth_metrics_daily |
| `agg_prizekings_comps__registration_metrics_daily` | agg_prizekings_comps__growth_metrics_daily |
| `agg_prizekings_comps__user_activity_daily` | agg_prizekings_comps__growth_metrics_daily |
| `dim_prizekings_comps__competitions` | agg_prizekings_comps__entry_metrics_daily, agg_prizekings_comps__user_activity_daily, mart_prizekings_comps__competition_entries |
| `dim_prizekings_comps__prizes` | mart_prizekings_comps__competition_entries |
| `dim_prizekings_comps__promotions` | mart_prizekings_comps__promotion_completions |
| `dim_prizekings_comps__tenants` | agg_prizekings_comps__growth_metrics_daily, mart_prizekings_comps__competition_entries, mart_prizekings_comps__promotion_completions, mart_prizekings_comps__registrations |
| `dim_prizekings_comps__users` | low6__live_game_iap, agg_prizekings_comps__deposit_metrics_daily, agg_prizekings_comps__financial_metrics_daily, agg_prizekings_comps__registration_metrics_daily, mart_prizekings_comps__registrations |
| `fct_prizekings_comps__competition_entries` | agg_prizekings_comps__entry_metrics_daily, agg_prizekings_comps__user_activity_daily, mart_prizekings_comps__competition_entries |
| `fct_prizekings_comps__deposits` | agg_prizekings_comps__deposit_metrics_daily |
| `fct_prizekings_comps__user_promotions` | mart_prizekings_comps__promotion_completions |
| `int_prizekings_comps__competition_entries_unioned` | fct_prizekings_comps__competition_entries |
| `int_prizekings_comps__competition_financials` | agg_prizekings_comps__competition_performance |
| `int_prizekings_comps__competitions_unioned` | dim_prizekings_comps__competitions |
| `mart_prizekings_comps__competition_entries` | low6__live_game_kpis, agg_prizekings_comps__competition_entries_daily, agg_prizekings_comps__competition_performance |
| `mart_prizekings_comps__promotion_completions` | agg_prizekings_comps__promotion_completions_daily |
| `mart_prizekings_comps__registrations` | agg_prizekings_comps__registrations_daily |
| `stg_prizekings_comps__competition` | int_prizekings_comps__competitions_unioned |
| `stg_prizekings_comps__competition_entry` | fct_prizekings_comps__prize_awards, int_prizekings_comps__competition_entries_unioned |
| `stg_prizekings_comps__competition_prize` | dim_prizekings_comps__prizes |
| `stg_prizekings_comps__prizes` | dim_prizekings_comps__prizes |
| `stg_prizekings_comps__promotion_tenants` | dim_prizekings_comps__promotions |
| `stg_prizekings_comps__promotions` | dim_prizekings_comps__promotions |
| `stg_prizekings_comps__raffles` | int_prizekings_comps__competitions_unioned |
| `stg_prizekings_comps__tenants` | dim_prizekings_comps__tenants |
| `stg_prizekings_comps__transactions` | low6__live_game_iap, agg_prizekings_comps__financial_metrics_daily, fct_prizekings_comps__deposits, int_prizekings_comps__competition_financials |
| `stg_prizekings_comps__translations` | dim_prizekings_comps__competitions |
| `stg_prizekings_comps__user_promotions` | fct_prizekings_comps__user_promotions |
| `stg_prizekings_comps__user_raffle_tickets` | fct_prizekings_comps__prize_awards, int_prizekings_comps__competition_entries_unioned |
| `stg_prizekings_comps__users` | dim_prizekings_comps__users |
