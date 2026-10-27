# English Premier League (EPL) Historical Performance Analytics
### Data Engineering & Business Intelligence Case Study
**Author:** Matthew Hanna  
**Specialty Focus:** PostgreSQL, Data Standardizing, Multi-Layered Aggregations, Window Functions

---

## Project Overview & Objective
This project analyzes over 20 years of historical English Premier League match records to evaluate macro-level sports trends and isolate clean team performance metrics. In sports analytics, evaluating historical data without filtering out era biases or text anomalies yields inaccurate results. 

The core objective of this study was to engineer an optimized data pipeline in **PostgreSQL** that removes chronological era skewing, standardizes messy raw string fields, and utilizes advanced table expressions to identify the ultimate competitive resilience metrics across the history of the league.

---

## Tech Stack & Database Architecture
*   **Database Engine:** PostgreSQL
*   **Visual Interface:** pgAdmin 4
*   **Core Concepts Demonstrated:** Conditional Logic (`CASE WHEN`), Data Type Casting (`::NUMERIC`), Common Table Expressions (CTEs), Partitioned Window Functions (`ROW_NUMBER()`), Set Operations (`UNION ALL`).

---

## Strategic Business Questions & Key Findings

### 1. Macro Trend Analysis: Is Home Field Advantage Vanishing?
*   **The Problem:** All-time team averages merge completely different eras together, creating a flat signal. 
*   **The Solution:** Aggregated and isolated total matches played against home team wins chronologically by season.
*   **Key Insight:** Home team win percentage remained highly steady near **45%–50%** for decades, but hit a massive historical low of **37.89% during the 2020/21 season**. This proves empirically that fan presence directly translates to home domain dominance and acts as a measurable crowd metric.

### 2. Data Cleaning & String Inconsistencies
*   **The Problem:** Initial team grouping metrics isolated clubs like Brighton and Ipswich Town down to just 1 single game each.
*   **The Discovery:** Explored the raw data to uncover dirty text entries where teams were split due to naming variants (e.g., `'Ipswich'` vs `'Ipswich Town'` and `'Brighton'` vs `'Brighton & Hove Albion'`).
*   **The Solution:** Implemented robust conditional mapping strings within the `GROUP BY` layers to force data standardization on the fly. 
*   **Result:** Successfully unified the fragments, showing Ipswich actually held 91 true home matches instead of 1.

### 3. Identifying the Ultimate "Comeback Kings"
*   **The Problem:** Tracking comebacks solely by home games introduces severe location bias.
*   **The Solution:** Stacked independent row-level sequences for both Home and Away comeback scenarios using a vertical `UNION ALL` embedded inside a Common Table Expression (CTE).
*   **Key Insight:** **Manchester United** officially claims the crown as the Ultimate Comeback King of the Premier League with **40 total combined victories** after trailing at half-time, narrowly beating out Tottenham Hotspur (39 comebacks) and Arsenal (37 comebacks).

---

## SQL Query Breakdown & Highlights

### Advanced Set Operations & CTEs: The Absolute Comeback Leaderboard
This query demonstrates the ability to vertically align independent conditional filters and compute totals across split dimensional layers (`home_team` vs `away_team` tracking).

```sql
-- QUERY 7: Finding the true absolute "Comeback Kings" across both Home and Away matches
WITH all_comebacks AS (
    -- Scenario A: Home team comebacks (Trailing at half, winning at full time)
    SELECT 
        home_team AS team,
        1 AS comeback_point
    FROM soccer_matches
    WHERE ht_result = 'A' AND ft_result = 'H'
    
    UNION ALL
    
    -- Scenario B: Away team comebacks (Trailing at half, winning at full time)
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
```

### Data Normalization & Cleaning Layer
Demonstrates how raw data was dynamically transformed and aggregated to solve the structural name variance problem.

```sql
-- QUERY 4: Standardizing Team Names and Recalculating Home Metrics
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
```

---

## 📈 Summary Conclusion
By shifting focus from flat static lookup summaries to granular, partitioned data engineering models, this project extracted clean, action-oriented intelligence from thousands of messy raw match rows. It proves capability in data manipulation, critical data auditing, and complex schema logic necessary for professional enterprise business analytics.
