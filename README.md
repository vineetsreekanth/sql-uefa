# SQL Analytics — 55 Progressive Queries

Structured SQL analysis on a UEFA football dataset using PostgreSQL — covering basic aggregations, multi-table joins, subqueries, window functions, and complex analytical queries.

---

## Dataset

A UEFA Champions League style football database with 5 tables:

| Table | Description |
|-------|-------------|
| `teams` | Team name, country, home stadium |
| `stadiums` | Stadium name, city, country, capacity |
| `players` | Player ID, name, nationality, position, height, weight, preferred foot |
| `matches` | Match ID, season, date, teams, scores, attendance |
| `goals` | Goal ID, match ID, player ID, duration, assist, goal type |

---

## Query Progression

55 queries structured from basic to advanced:

**Basic (Q1–Q15)** — Aggregations, filters, GROUP BY
- Top goal scorers per season
- Teams with most goals
- Stadiums hosting most matches
- Average attendance per season

**Intermediate (Q16–Q35)** — Multi-table JOINs, subqueries
- Home win vs away win distribution by country
- Players who never scored a goal
- Stadium capacity analysis by country
- Most common match results

**Advanced (Q36–Q55)** — Window functions, CTEs, complex analytics
- Top 3 assist leaders in matches their team lost
- Players who scored in every match they played
- Goals scored in penalty shootout matches
- Players with highest goals-per-match ratio by country
- Teams winning most matches with 3+ goal difference

---

## Key Concepts Covered

- `GROUP BY` with `HAVING`
- `INNER JOIN`, `LEFT JOIN` across multiple tables
- Subqueries and nested `SELECT`
- `RANK()`, `ROW_NUMBER()`, `DENSE_RANK()` window functions
- `PARTITION BY` for season-level analysis
- Aggregations: `COUNT`, `SUM`, `AVG`, `MAX`
- Filtering with `WHERE`, `IN`, `NOT IN`

---

## How to Run

1. Install PostgreSQL
2. Create a database and run `SQL_Project.sql`
3. The file includes table creation, data loading references, and all 55 queries with comments

---

## Files

| File | Description |
|------|-------------|
| `SQL_Project.sql` | All 55 queries with comments |
| `Teams.csv` | Teams data |
| `Stadiums.csv` | Stadiums data |
| `Players.csv` | Players data |
| `Matches.csv` | Matches data |
| `goals.csv` | Goals data |

---

## Tools

PostgreSQL, pgAdmin

---

## Author

**Vineet S P** — Data Analyst, Mysore  
[Portfolio](https://vineetsreekanth.github.io/Vineet_Portfolio/) · [LinkedIn](https://linkedin.com/in/vineet-s-p-b6367a1b6)
