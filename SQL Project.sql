SELECT current_database();

CREATE TABLE teams (
    TEAM_NAME VARCHAR(100),
    COUNTRY VARCHAR(100),
    HOME_STADIUM VARCHAR(100)
);

CREATE TABLE stadiums (
    NAME VARCHAR(100),
    CITY VARCHAR(100),
    COUNTRY VARCHAR(100),
    CAPACITY INT
);

CREATE TABLE players (
    PLAYER_ID VARCHAR(20) PRIMARY KEY,
    FIRST_NAME VARCHAR(100),
    LAST_NAME VARCHAR(100),
    NATIONALITY VARCHAR(100),
    DOB DATE,
    TEAM VARCHAR(100),
    JERSEY_NUMBER INT,
    POSITION VARCHAR(50),
    HEIGHT INT,
    WEIGHT INT,
    FOOT CHAR(1)
);

CREATE TABLE matches (
    MATCH_ID VARCHAR(20) PRIMARY KEY,
    SEASON VARCHAR(20),
    DATE VARCHAR(20),
    HOME_TEAM VARCHAR(100),
    AWAY_TEAM VARCHAR(100),
    STADIUM VARCHAR(100),
    HOME_TEAM_SCORE INT,
    AWAY_TEAM_SCORE INT,
    PENALTY_SHOOT_OUT INT,
    ATTENDANCE INT
);

CREATE TABLE goals (
    GOAL_ID VARCHAR(20) PRIMARY KEY,
    MATCH_ID VARCHAR(20),
    PID VARCHAR(20),
    DURATION INT,
    ASSIST VARCHAR(20),
    GOAL_DESC VARCHAR(100)
);

SELECT COUNT(*) FROM teams;
SELECT COUNT(*) FROM stadiums;
SELECT COUNT(*) FROM players;
SELECT COUNT(*) FROM matches;
SELECT COUNT(*) FROM goals;

-- Q1: Which player scored the most goals in each season?
SELECT season, pid, goal_count
FROM (
    SELECT m.season, g.pid, COUNT(*) AS goal_count,
        RANK() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) AS rnk
    FROM goals g
    JOIN matches m ON g.match_id = m.match_id
    GROUP BY m.season, g.pid
) ranked
WHERE rnk = 1;


-- Q2: How many goals did each player score in each season?
SELECT m.season, g.pid, COUNT(*) AS total_goals
FROM goals g
JOIN matches m ON g.match_id = m.match_id
GROUP BY m.season, g.pid
ORDER BY m.season, total_goals DESC;


-- Q3: Total number of goals scored in match 'mt403'
SELECT COUNT(*) AS total_goals
FROM goals
WHERE match_id = 'mt403';


-- Q4: Which player assisted the most goals in each season?
SELECT season, assist, assist_count
FROM (
    SELECT m.season, g.assist, COUNT(*) AS assist_count,
        RANK() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) AS rnk
    FROM goals g
    JOIN matches m ON g.match_id = m.match_id
    WHERE g.assist IS NOT NULL
    GROUP BY m.season, g.assist
) ranked
WHERE rnk = 1;


-- Q5: Which players have scored goals in more than 10 matches?
SELECT pid, COUNT(DISTINCT match_id) AS matches_scored
FROM goals
GROUP BY pid
HAVING COUNT(DISTINCT match_id) > 10;


-- Q6: Average number of goals scored per match in each season
SELECT m.season,
    ROUND(COUNT(g.goal_id)::NUMERIC / COUNT(DISTINCT m.match_id), 2) AS avg_goals_per_match
FROM matches m
LEFT JOIN goals g ON m.match_id = g.match_id
GROUP BY m.season
ORDER BY m.season;


-- Q7: Which player has the most goals in a single match?
SELECT pid, match_id, goal_count
FROM (
    SELECT pid, match_id, COUNT(*) AS goal_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM goals
    GROUP BY pid, match_id
) ranked
WHERE rnk = 1;


-- Q8: Which team scored the most goals across all seasons?
SELECT p.team, COUNT(*) AS total_goals
FROM goals g
JOIN players p ON g.pid = p.player_id
GROUP BY p.team
ORDER BY total_goals DESC
LIMIT 1;


-- Q9: Which stadium hosted the most goals scored in a single season?
SELECT season, stadium, total_goals
FROM (
    SELECT m.season, m.stadium, COUNT(*) AS total_goals,
        RANK() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) AS rnk
    FROM goals g
    JOIN matches m ON g.match_id = m.match_id
    GROUP BY m.season, m.stadium
) ranked
WHERE rnk = 1;

-- Q10: Highest-scoring match in each season
SELECT season, match_id, home_team, away_team, total_goals
FROM (
    SELECT season, match_id, home_team, away_team,
        home_team_score + away_team_score AS total_goals,
        RANK() OVER (PARTITION BY season ORDER BY home_team_score + away_team_score DESC) AS rnk
    FROM matches
) ranked
WHERE rnk = 1;


-- Q11: How many matches ended in a draw in each season?
SELECT season, COUNT(*) AS draws
FROM matches
WHERE home_team_score = away_team_score
GROUP BY season
ORDER BY season;


-- Q12: Which team had the highest average score in season 2021-2022?
SELECT team, ROUND(AVG(score), 2) AS avg_score
FROM (
    SELECT home_team AS team, home_team_score AS score FROM matches WHERE season = '2021-2022'
    UNION ALL
    SELECT away_team AS team, away_team_score AS score FROM matches WHERE season = '2021-2022'
) all_scores
GROUP BY team
ORDER BY avg_score DESC
LIMIT 1;


-- Q13: How many penalty shootouts occurred in each season?
SELECT season, COUNT(*) AS penalty_shootouts
FROM matches
WHERE penalty_shoot_out = 1
GROUP BY season
ORDER BY season;


-- Q14: Average attendance for home teams in 2021-2022 season
SELECT home_team, ROUND(AVG(attendance), 0) AS avg_attendance
FROM matches
WHERE season = '2021-2022'
GROUP BY home_team
ORDER BY avg_attendance DESC;


-- Q15: Which stadium hosted the most matches in each season?
SELECT season, stadium, match_count
FROM (
    SELECT season, stadium, COUNT(*) AS match_count,
        RANK() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS rnk
    FROM matches
    GROUP BY season, stadium
) ranked
WHERE rnk = 1;


-- Q16: Distribution of matches played in different countries in each season
SELECT m.season, s.country, COUNT(*) AS match_count
FROM matches m
JOIN stadiums s ON m.stadium = s.name
GROUP BY m.season, s.country
ORDER BY m.season, match_count DESC;


-- Q17: Most common result in matches (home win, away win, draw)
SELECT result, COUNT(*) AS count
FROM (
    SELECT 
        CASE 
            WHEN home_team_score > away_team_score THEN 'Home Win'
            WHEN away_team_score > home_team_score THEN 'Away Win'
            ELSE 'Draw'
        END AS result
    FROM matches
) results
GROUP BY result
ORDER BY count DESC;

-- Q18: Which players have the highest total goals scored (including assists)?
SELECT pid, COUNT(*) AS contributions
FROM (
    SELECT pid FROM goals
    UNION ALL
    SELECT assist AS pid FROM goals WHERE assist IS NOT NULL
) all_contributions
GROUP BY pid
ORDER BY contributions DESC
LIMIT 10;


-- Q19: Average height and weight of players per position
SELECT position, 
    ROUND(AVG(height), 1) AS avg_height,
    ROUND(AVG(weight), 1) AS avg_weight
FROM players
GROUP BY position
ORDER BY position;


-- Q20: Which player has the most goals scored with their left foot?
SELECT g.pid, COUNT(*) AS left_foot_goals
FROM goals g
JOIN players p ON g.pid = p.player_id
WHERE p.foot = 'L'
GROUP BY g.pid
ORDER BY left_foot_goals DESC
LIMIT 1;


-- Q21: Average age of players per team
SELECT team, 
    ROUND(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, dob))), 1) AS avg_age
FROM players
GROUP BY team
ORDER BY team;


-- Q22: How many players are listed for each team?
SELECT team, COUNT(*) AS player_count
FROM players
GROUP BY team
ORDER BY player_count DESC;


-- Q23: Which player played in the most matches in each season?
SELECT season, pid, match_count
FROM (
    SELECT m.season, g.pid, COUNT(DISTINCT g.match_id) AS match_count,
        RANK() OVER (PARTITION BY m.season ORDER BY COUNT(DISTINCT g.match_id) DESC) AS rnk
    FROM goals g
    JOIN matches m ON g.match_id = m.match_id
    GROUP BY m.season, g.pid
) ranked
WHERE rnk = 1;


-- Q24: Most common position for players across all teams
SELECT position, COUNT(*) AS player_count
FROM players
GROUP BY position
ORDER BY player_count DESC
LIMIT 1;


-- Q25: Which players have never scored a goal?
SELECT player_id, first_name, last_name, team
FROM players
WHERE player_id NOT IN (SELECT DISTINCT pid FROM goals);

-- Q26: Which team has the largest home stadium in terms of capacity?
SELECT t.team_name, s.name AS stadium, s.capacity
FROM teams t
JOIN stadiums s ON t.home_stadium = s.name
ORDER BY s.capacity DESC
LIMIT 1;


-- Q27: Which teams from each country participated in UEFA competition each season?
SELECT m.season, t.country, t.team_name
FROM matches m
JOIN teams t ON m.home_team = t.team_name OR m.away_team = t.team_name
GROUP BY m.season, t.country, t.team_name
ORDER BY m.season, t.country;


-- Q28: Which team scored the most goals across home and away matches in each season?
SELECT season, team, SUM(goals_scored) AS total_goals
FROM (
    SELECT season, home_team AS team, home_team_score AS goals_scored FROM matches
    UNION ALL
    SELECT season, away_team AS team, away_team_score AS goals_scored FROM matches
) all_goals
GROUP BY season, team
ORDER BY season, total_goals DESC;


-- Q29: How many teams have home stadiums in each city/country?
SELECT s.country, s.city, COUNT(*) AS team_count
FROM teams t
JOIN stadiums s ON t.home_stadium = s.name
GROUP BY s.country, s.city
ORDER BY team_count DESC;


-- Q30: Which teams had the most home wins in 2021-2022 season?
SELECT home_team, COUNT(*) AS home_wins
FROM matches
WHERE season = '2021-2022'
AND home_team_score > away_team_score
GROUP BY home_team
ORDER BY home_wins DESC;

-- Q31: Which stadium has the highest capacity?
SELECT name, city, country, capacity
FROM stadiums
ORDER BY capacity DESC
LIMIT 1;


-- Q32: How many stadiums are in Russia or London?
SELECT name, city, country, capacity
FROM stadiums
WHERE country = 'Russia' OR city = 'London';


-- Q33: Which stadium hosted the most matches during each season?
SELECT season, stadium, match_count
FROM (
    SELECT season, stadium, COUNT(*) AS match_count,
        RANK() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS rnk
    FROM matches
    GROUP BY season, stadium
) ranked
WHERE rnk = 1;


-- Q34: Average stadium capacity for teams participating in each season
SELECT m.season, ROUND(AVG(s.capacity), 0) AS avg_capacity
FROM matches m
JOIN stadiums s ON m.stadium = s.name
GROUP BY m.season
ORDER BY m.season;


-- Q35: How many teams play in stadiums with capacity over 50,000?
SELECT t.team_name, s.name AS stadium, s.capacity
FROM teams t
JOIN stadiums s ON t.home_stadium = s.name
WHERE s.capacity > 50000
ORDER BY s.capacity DESC;


-- Q36: Which stadium had the highest average attendance in each season?
SELECT season, stadium, avg_attendance
FROM (
    SELECT season, stadium, ROUND(AVG(attendance), 0) AS avg_attendance,
        RANK() OVER (PARTITION BY season ORDER BY AVG(attendance) DESC) AS rnk
    FROM matches
    GROUP BY season, stadium
) ranked
WHERE rnk = 1;


-- Q37: Distribution of stadium capacities by country
SELECT country, COUNT(*) AS stadium_count,
    ROUND(AVG(capacity), 0) AS avg_capacity,
    MIN(capacity) AS min_capacity,
    MAX(capacity) AS max_capacity
FROM stadiums
GROUP BY country
ORDER BY stadium_count DESC;


-- Q38: Which players scored the most goals at each stadium?
SELECT season, stadium, pid, goals
FROM (
    SELECT m.season, m.stadium, g.pid, COUNT(*) AS goals,
        RANK() OVER (PARTITION BY m.stadium ORDER BY COUNT(*) DESC) AS rnk
    FROM goals g
    JOIN matches m ON g.match_id = m.match_id
    GROUP BY m.season, m.stadium, g.pid
) ranked
WHERE rnk = 1;


-- Q39: Which team won the most home matches in season 2021-2022?
SELECT home_team, COUNT(*) AS home_wins
FROM matches
WHERE season = '2021-2022'
AND home_team_score > away_team_score
GROUP BY home_team
ORDER BY home_wins DESC
LIMIT 1;


-- Q40: Which players played for the team that scored most goals in 2021-2022?
SELECT player_id, first_name, last_name, team
FROM players
WHERE team = (
    SELECT team FROM (
        SELECT home_team AS team, home_team_score AS goals FROM matches WHERE season = '2021-2022'
        UNION ALL
        SELECT away_team, away_team_score FROM matches WHERE season = '2021-2022'
    ) t
    GROUP BY team
    ORDER BY SUM(goals) DESC
    LIMIT 1
);


-- Q41: Goals scored by home teams where attendance was above 50,000
SELECT SUM(m.home_team_score) AS total_home_goals
FROM matches m
WHERE m.attendance > 50000;


-- Q42: Players in matches with the highest score difference
SELECT DISTINCT g.pid, m.match_id,
    ABS(m.home_team_score - m.away_team_score) AS score_diff
FROM goals g
JOIN matches m ON g.match_id = m.match_id
ORDER BY score_diff DESC
LIMIT 20;


-- Q43: Goals scored in matches that ended in penalty shootouts
SELECT COUNT(*) AS goals_in_shootout_matches
FROM goals g
JOIN matches m ON g.match_id = m.match_id
WHERE m.penalty_shoot_out = 1;


-- Q44: Distribution of home wins vs away wins by country for all seasons
SELECT s.country,
    SUM(CASE WHEN m.home_team_score > m.away_team_score THEN 1 ELSE 0 END) AS home_wins,
    SUM(CASE WHEN m.away_team_score > m.home_team_score THEN 1 ELSE 0 END) AS away_wins,
    SUM(CASE WHEN m.home_team_score = m.away_team_score THEN 1 ELSE 0 END) AS draws
FROM matches m
JOIN stadiums s ON m.stadium = s.name
GROUP BY s.country
ORDER BY home_wins DESC;


-- Q45: Which team scored the most goals in the highest-attended matches?
SELECT team, SUM(goals) AS total_goals
FROM (
    SELECT home_team AS team, home_team_score AS goals
    FROM matches ORDER BY attendance DESC LIMIT 10
    UNION ALL
    SELECT away_team, away_team_score
    FROM matches ORDER BY attendance DESC LIMIT 10
) top_matches
GROUP BY team
ORDER BY total_goals DESC
LIMIT 1;


-- Q46: Top 3 players who assisted most in matches where their team lost
SELECT g.assist AS pid, COUNT(*) AS assists_in_losses
FROM goals g
JOIN matches m ON g.match_id = m.match_id
JOIN players p ON g.assist = p.player_id
WHERE g.assist IS NOT NULL
AND (
    (p.team = m.home_team AND m.home_team_score < m.away_team_score)
    OR
    (p.team = m.away_team AND m.away_team_score < m.home_team_score)
)
GROUP BY g.assist
ORDER BY assists_in_losses DESC
LIMIT 3;


-- Q47: Total goals scored by players positioned as defenders
SELECT COUNT(*) AS defender_goals
FROM goals g
JOIN players p ON g.pid = p.player_id
WHERE p.position = 'Defender';


-- Q48: Players who scored in stadiums with capacity over 60,000
SELECT DISTINCT g.pid, m.stadium, s.capacity
FROM goals g
JOIN matches m ON g.match_id = m.match_id
JOIN stadiums s ON m.stadium = s.name
WHERE s.capacity > 60000;


-- Q49: Goals scored in matches played in each city per season
SELECT m.season, s.city, COUNT(*) AS total_goals
FROM goals g
JOIN matches m ON g.match_id = m.match_id
JOIN stadiums s ON m.stadium = s.name
GROUP BY m.season, s.city
ORDER BY m.season, total_goals DESC;


-- Q50: Players who scored in matches with attendance over 100,000
SELECT DISTINCT g.pid, m.match_id, m.attendance
FROM goals g
JOIN matches m ON g.match_id = m.match_id
WHERE m.attendance > 100000;

-- Q51: Average goals scored by each team in the first 30 minutes
SELECT p.team,
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT g.match_id), 2) AS avg_early_goals
FROM goals g
JOIN players p ON g.pid = p.player_id
WHERE g.duration <= 30
GROUP BY p.team
ORDER BY avg_early_goals DESC;


-- Q52: Which stadium had the highest average score difference?
SELECT stadium,
    ROUND(AVG(ABS(home_team_score - away_team_score)), 2) AS avg_score_diff
FROM matches
GROUP BY stadium
ORDER BY avg_score_diff DESC
LIMIT 1;


-- Q53: Players who scored in every match they played
SELECT pid, COUNT(DISTINCT match_id) AS matches_with_goals
FROM goals
GROUP BY pid
HAVING COUNT(DISTINCT match_id) = (
    SELECT COUNT(DISTINCT match_id)
    FROM goals g2
    WHERE g2.pid = goals.pid
);


-- Q54: Teams that won most matches with goal difference of 3+ in 2021-2022
SELECT team, SUM(big_wins) AS total_big_wins
FROM (
    SELECT home_team AS team, COUNT(*) AS big_wins
    FROM matches
    WHERE season = '2021-2022'
    AND (home_team_score - away_team_score) >= 3
    GROUP BY home_team
    UNION ALL
    SELECT away_team, COUNT(*)
    FROM matches
    WHERE season = '2021-2022'
    AND (away_team_score - home_team_score) >= 3
    GROUP BY away_team
) all_wins
GROUP BY team
ORDER BY total_big_wins DESC;


-- Q55: Player from a specific country with highest goals per match ratio
-- Change 'Brazil' to any country you want
SELECT g.pid, p.nationality,
    COUNT(*) AS total_goals,
    COUNT(DISTINCT g.match_id) AS matches_played,
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT g.match_id), 2) AS goals_per_match
FROM goals g
JOIN players p ON g.pid = p.player_id
WHERE p.nationality = 'Brazil'
GROUP BY g.pid, p.nationality
ORDER BY goals_per_match DESC
LIMIT 1;