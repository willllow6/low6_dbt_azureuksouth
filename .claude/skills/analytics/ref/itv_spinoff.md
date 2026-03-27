# itv_spinoff (internal dbt models)


> These are internal dbt models used to build the mart tables. For querying data, see the mart reference files.

**32 models** | Materialization: 

## int_itv_spinoff__live_quiz_answers


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\intermediates\int_itv_spinoff__live_quiz_answers.sql` |

### Dependencies

**Refs:**
- `stg_itv_spinoff__live_quiz_questions`
- `stg_itv_spinoff__player_answers`
- `stg_itv_spinoff__players`


---

## int_itv_spinoff__live_quiz_attempts


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\intermediates\int_itv_spinoff__live_quiz_attempts.sql` |

### Dependencies

**Refs:**
- `int_itv_spinoff__live_quiz_answers`


---

## int_itv_spinoff__quiz_attempts_ranked


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\intermediates\int_itv_spinoff__quiz_attempts_ranked.sql` |

### Dependencies

**Refs:**
- `int_itv_spinoff__quiz_attempts_unioned`


---

## int_itv_spinoff__quiz_attempts_unioned


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\intermediates\int_itv_spinoff__quiz_attempts_unioned.sql` |

### Dependencies

**Refs:**
- `int_itv_spinoff__live_quiz_attempts`
- `stg_itv_spinoff__quiz_attempts`


---

## int_itv_spinoff__quizes_unioned


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\intermediates\int_itv_spinoff__quizes_unioned.sql` |

### Dependencies

**Refs:**
- `stg_itv_spinoff__live_quizes`
- `stg_itv_spinoff__quizes`


---

## itv_spinoff__achievement_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__achievement_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__achievements`


---

## itv_spinoff__achievements


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__achievements.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__users`
- `stg_itv_spinoff__achievement_categories`
- `stg_itv_spinoff__achievements`
- `stg_itv_spinoff__user_achievements`


---

## itv_spinoff__active_streak_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__active_streak_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__active_streaks`


---

## itv_spinoff__active_streaks


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__active_streaks.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__users`
- `stg_itv_spinoff__daily_streaks`


---

## itv_spinoff__conversion_funnel_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__conversion_funnel_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__users`


---

## itv_spinoff__daily_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\daily_stats\itv_spinoff__daily_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__quiz_attempts`
- `itv_spinoff__referrals`
- `itv_spinoff__users`


---

## itv_spinoff__friends_league_membership_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__friends_league_membership_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__friends_league_memberships`


---

## itv_spinoff__friends_league_memberships


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__friends_league_memberships.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__users`
- `stg_itv_spinoff__friends_league_memberships`
- `stg_itv_spinoff__friends_leagues`


---

## itv_spinoff__quiz_attempt_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\quiz_attempts\itv_spinoff__quiz_attempt_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__quiz_attempts`


---

## itv_spinoff__quiz_attempts


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\quiz_attempts\itv_spinoff__quiz_attempts.sql` |

### Dependencies

**Refs:**
- `int_itv_spinoff__quiz_attempts_ranked`
- `int_itv_spinoff__quizes_unioned`
- `itv_spinoff__users`


---

## itv_spinoff__referral_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__referral_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__referrals`


---

## itv_spinoff__referrals


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__referrals.sql` |

### Dependencies

**Refs:**
- `core_user_service__referrals`


---

## itv_spinoff__user_stats


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__user_stats.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__users`


---

## itv_spinoff__users


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__users.sql` |

### Dependencies

**Refs:**
- `stg_core_user_service__referrals`
- `stg_core_user_service__users`
- `stg_itv_spinoff__friends_league_memberships`
- `stg_itv_spinoff__quiz_attempts`
- `stg_itv_spinoff__user_achievements`


---

## itv_spinoff__weekly_cohort_analysis


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\marts\users\itv_spinoff__weekly_cohort_analysis.sql` |

### Dependencies

**Refs:**
- `itv_spinoff__quiz_attempts`


---

## stg_itv_spinoff__achievement_categories


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__achievement_categories.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.achievement_category`


---

## stg_itv_spinoff__achievements


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__achievements.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.achievement`


---

## stg_itv_spinoff__daily_streaks


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__daily_streaks.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.daily_streak`


---

## stg_itv_spinoff__friends_league_memberships


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__friends_league_memberships.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.friends_league_membership`


---

## stg_itv_spinoff__friends_leagues


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__friends_leagues.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.friends_league`


---

## stg_itv_spinoff__live_quiz_questions


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__live_quiz_questions.sql` |

### Dependencies

**Sources:**
- `itv_spinoff_live.livequizquestions`


---

## stg_itv_spinoff__live_quizes


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__live_quizes.sql` |

### Dependencies

**Sources:**
- `itv_spinoff_live.livequizzes`


---

## stg_itv_spinoff__player_answers


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__player_answers.sql` |

### Dependencies

**Sources:**
- `itv_spinoff_live.playeranswers`


---

## stg_itv_spinoff__players


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__players.sql` |

### Dependencies

**Sources:**
- `itv_spinoff_live.players`


---

## stg_itv_spinoff__quiz_attempts


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__quiz_attempts.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.quiz_attempt`


---

## stg_itv_spinoff__quizes


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__quizes.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.quiz`


---

## stg_itv_spinoff__user_achievements


| Attribute | Value |
|-----------|-------|
| Path | `itv_spinoff\staging\stg_itv_spinoff__user_achievements.sql` |

### Dependencies

**Sources:**
- `itv_spinoff.user_achievement`


---

