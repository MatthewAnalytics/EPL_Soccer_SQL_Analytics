-- ==============================================================================
-- PROJECT: English Premier League Performance Analytics
-- ARCHITECT: Matthew Hanna
-- ==============================================================================

-- QUERY 1: Calculates all-time home wins and win percentages per individual club
SELECT
    home_team,
    COUNT(*) as total_home_matches,
    SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END) as total_home_wins,
    ROUND((SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100, 2) as home_win_percentage
FROM soccer_matches
GROUP BY home_team
ORDER BY home_win_percentage DESC;


-- QUERY 2: Shows whether home field advantage has waivered over the decades
SELECT
    season,
    COUNT(*) as total_season_games,
    SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END) as total_home_wins,
    ROUND(
        (SUM(CASE WHEN ft_result = 'H' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100, 
        2
    ) as league_wide_home_win_pct
FROM soccer_matches
GROUP BY season
ORDER BY season DESC;


-- QUERY 3: Measures home team scoring efficiency and basic all-time goal differentials
SELECT 
    home_team,
    COUNT(*) as total_home_games,
    SUM(fth_goals) as total_goals_scored,
    SUM(fta_goals) as total_goals_conceded,
    (SUM(fth_goals) - SUM(fta_goals)) as home_goal_differential,
    ROUND(AVG(fth_goals), 2) as avg_goals_scored_per_game
FROM soccer_matches
GROUP BY home_team
ORDER BY home_goal_differential DESC;


-- QUERY 4: Standardizes inconsistent team names to recalculate clean home metrics
SELECT 
    CASE 
        WHEN home_team = 'Ipswich Town' THEN 'Ipswich'
        WHEN home_team = 'Brighton & Hove Albion' THEN 'Brighton'
        ELSE home_team 
    END as cleaned_home_team,
    COUNT(*) as total_home_games,
    SUM(fth_goals) as total_goals_scored,
    SUM(fta_goals) as total_goals_conceded,
    (SUM(fth_goals) - SUM(fta_goals)) as home_goal_differential
FROM soccer_matches
GROUP BY 
    CASE 
        WHEN home_team = 'Ipswich Town' THEN 'Ipswich'
        WHEN home_team = 'Brighton & Hove Albion' THEN 'Brighton'
        ELSE home_team 
    END
ORDER BY home_goal_differential DESC;


-- QUERY 5: Finding the "Comeback Kings" for teams playing at Home
WITH match_outcomes AS (
    SELECT 
        season,
        home_team,
        away_team,
        ht_result,
        ft_result,
        ROW_NUMBER() OVER(PARTITION BY home_team ORDER BY season DESC) as match_sequence
    FROM soccer_matches
)
SELECT 
    home_team,
    COUNT(*) as halftime_comeback_wins
FROM match_outcomes
WHERE ht_result = 'A' AND ft_result = 'H'
GROUP BY home_team
ORDER BY halftime_comeback_wins DESC;


-- QUERY 6: Finding the "Comeback Kings" for teams playing Away
WITH away_match_outcomes AS (
    SELECT 
        season,
        home_team,
        away_team,
        ht_result,
        ft_result
    FROM soccer_matches
)
SELECT 
    away_team,
    COUNT(*) as away_halftime_comeback_wins
FROM away_match_outcomes
WHERE ht_result = 'H' AND ft_result = 'A'
GROUP BY away_team
ORDER BY away_halftime_comeback_wins DESC;


-- QUERY 7: Finding the true absolute "Comeback Kings" across both Home and Away matches
WITH all_comebacks AS (
    -- Scenario A: Home team comebacks
    SELECT 
        home_team AS team,
        1 AS comeback_point
    FROM soccer_matches
    WHERE ht_result = 'A' AND ft_result = 'H'
    
    UNION ALL
    
    -- Scenario B: Away team comebacks
    SELECT 
        away_team AS team,
        1 AS comeback_point
    FROM soccer_matches
    WHERE ht_result = 'H' AND ft_result = 'A'
)
SELECT 
    team,
    SUM(comeback_point) AS total_combined_comebacks
FROM all_comebacks
GROUP BY team
ORDER BY total_combined_comebacks DESC;

-- ==============================================================================
-- 								END OF SCRIPT
-- ==============================================================================
