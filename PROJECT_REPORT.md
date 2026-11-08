# 🎓 GameVerse+ — Complete DBMS Project Report & Viva Guide

**Course:** Database Management Systems (DBMS) Laboratory  
**Project Name:** GameVerse+ (Gaming Platform & Analytics Hub)  
**Authors & Contributors:** Haneesh Mekala ([@haneeshmekala3-dot](https://github.com/haneeshmekala3-dot)), Yogi Abhilash ([@Yogyabhilash](https://github.com/Yogyabhilash)), Jaswanth, Saketh, Umesh, Tanoj, Bhargav  
**Live Application:** [https://gameverseplus-6l2rpdkppknw4ymzqzchxb.streamlit.app/](https://gameverseplus-6l2rpdkppknw4ymzqzchxb.streamlit.app/)  
**GitHub Repository:** [https://github.com/haneeshmekala3-dot/GameVersePlus](https://github.com/haneeshmekala3-dot/GameVersePlus)  

---

## 📑 Table of Contents
1. [Abstract & Problem Statement](#1-abstract--problem-statement)
2. [System Architecture](#2-system-architecture)
3. [Database Schema & Table Dictionary](#3-database-schema--table-dictionary)
4. [Entity-Relationship (ER) Design & Cardinality](#4-entity-relationship-er-design--cardinality)
5. [Normalization Proofs (1NF to 3NF/BCNF)](#5-normalization-proofs-1nf-to-3nfbcnf)
6. [Business Logic, Constraints & Triggers](#6-business-logic-constraints--triggers)
7. [Advanced SQL Queries & Analytics](#7-advanced-sql-queries--analytics)
8. [DBMS Viva Voce — Questions & Model Answers](#8-dbms-viva-voce--questions--model-answers)

---

## 1. Abstract & Problem Statement

Modern gaming ecosystems demand real-time tracking of player engagement, purchases, multi-tiered achievements, and social interactions. Traditional monolithic architectures often suffer from data redundancy, inconsistent inventory tracking, and weak referential integrity.

**GameVerse+** resolves these challenges by providing:
- A fully normalized relational schema (3NF) managing **22 interrelated tables**.
- Strict referential integrity enforcing foreign keys, cascade rules, and domain constraints.
- Integrated transactions handling shopping cart workflows, wallet deductions, and automatic inventory allocations.
- Real-time data visualization connecting Python (Streamlit + Plotly) to a distributed MySQL/TiDB cloud instance over TLS/SSL.

---

## 2. System Architecture

```text
[ Browser / Client ]
        │
        ▼ (HTTPS)
[ Streamlit Community Cloud ] (Python 3.10 / Web App)
        │
        ├─► auth.py          (SHA-256 Hashing, RBAC Session Management)
        ├─► app.py           (UI Router, Visualizations with Plotly)
        └─► db_connection.py (Connection Pooler with TLS/SSL Encryption)
        │
        ▼ (Port 4000, MySQL Protocol over TLS)
[ TiDB Serverless Cloud Database ] (Distributed MySQL Engine)
        │
        ├─► Tables (22 Normalized Relations: User, Game, Achievement, etc.)
        ├─► Constraints (Foreign Keys, Unique Indices, Defaults)
        └─► Indexes (Clustered PKs, B-Tree Secondary Lookups)
```

---

## 3. Database Schema & Table Dictionary

The database consists of **22 normalized relations** grouped into four key subsystems:

### A. User & Access Control Subsystem
1. **`Role`**: Stores role tiers (`Player`, `Admin`, `Moderator`).
   - `role_id` (PK, INT AUTO_INCREMENT)
   - `role_name` (ENUM, UNIQUE)
2. **`User`**: Registered user profiles, credentials, and wallet funds.
   - `user_id` (PK, INT AUTO_INCREMENT)
   - `username` (VARCHAR(50), UNIQUE, NOT NULL)
   - `email` (VARCHAR(100), UNIQUE, NOT NULL)
   - `password_hash` (VARCHAR(255), NOT NULL — SHA-256)
   - `wallet_balance` (DECIMAL(10,2), DEFAULT 5900.00)
   - `country` (VARCHAR(50))
   - `role_id` (FK REFERENCES Role(role_id))
   - `total_playtime` (INT, DEFAULT 0)
   - `join_date` (DATE, DEFAULT CURRENT_DATE)

### B. Catalog & Media Subsystem
3. **`Platform`**: Gaming consoles/PCs (`platform_id`, `name`, `manufacturer`, `release_year`).
4. **`Genre`**: Game classifications (`genre_id`, `name`, `description`).
5. **`Developer`**: Studio credits (`developer_id`, `name`, `headquarters`, `founded_year`).
6. **`Publisher`**: Distribution companies (`publisher_id`, `name`, `headquarters`, `founded_year`).
7. **`Game`**: Catalog titles (`game_id`, `title`, `price`, `release_date`, `description`, `developer_id` FK, `publisher_id` FK).
8. **`GamePlatform`**: M:N junction linking games to platforms (`game_id` FK, `platform_id` FK, Composite PK).
9. **`GameGenre`**: M:N junction linking games to genres (`game_id` FK, `genre_id` FK, Composite PK).
10. **`DLC`**: Downloadable expansions (`dlc_id`, `game_id` FK, `title`, `price`, `release_date`).

### C. Social, Reviews & Gamification Subsystem
11. **`Achievement`**: Milestones per game (`achievement_id`, `game_id` FK, `name`, `points`).
12. **`UserAchievement`**: Unlocked milestones (`user_id` FK, `achievement_id` FK, `unlocked_date`).
13. **`GameCollection`**: Player's personal library (`collection_id`, `user_id` FK, `game_id` FK, `status`, `hours_played`, `rating` DECIMAL(3,1)).
14. **`Review`**: User critiques (`review_id`, `user_id` FK, `game_id` FK, `rating` DECIMAL(3,1), `review_text`, `review_date`).
15. **`Comment`**: Threaded replies on reviews (`comment_id`, `review_id` FK, `user_id` FK, `comment_text`, `comment_date`).
16. **`Friendship`**: Social network graph (`user_id` FK, `friend_id` FK, `status`, `since`).
17. **`Matches`**: Multiplayer game sessions (`match_id`, `game_id` FK, `winner_id` FK, `duration`, `match_date`).
18. **`MatchParticipant`**: Match rosters and individual scores (`match_id` FK, `user_id` FK, `score`).
19. **`Leaderboard`**: Aggregated rankings (`leaderboard_id`, `user_id` FK, `total_points`, `total_achievements`, `rank_position`).

### D. E-Commerce Subsystem
20. **`Cart`**: Staged items awaiting checkout (`cart_id`, `user_id` FK, `item_type`, `item_id`, `added_date`, UNIQUE(`user_id`, `item_type`, `item_id`)).
21. **`Purchase`**: Financial audit log (`purchase_id`, `user_id` FK, `item_type`, `item_id`, `price`, `purchase_date`).
22. **`Notification`**: Real-time user alert dispatch (`notification_id`, `user_id` FK, `message`, `type`, `is_read`, `created_at`).

---

## 4. Entity-Relationship (ER) Design & Cardinality

| Relationship | Entities Involved | Cardinality | Explanation |
| :--- | :--- | :---: | :--- |
| **Catalog Developer** | Developer ➔ Game | **1 : N** | One studio develops multiple games; each game has one primary developer. |
| **Catalog Publisher** | Publisher ➔ Game | **1 : N** | One publisher distributes many titles; each title has one publisher. |
| **Genre Classification** | Game ➔ Genre | **M : N** | Handled via `GameGenre` junction table. |
| **Platform Release** | Game ➔ Platform | **M : N** | Handled via `GamePlatform` junction table. |
| **User Library** | User ➔ Game | **M : N** | Handled via `GameCollection` (`user_id`, `game_id` unique constraint). |
| **Social Graph** | User ➔ User | **M : N** | Self-referencing recursive relationship handled via `Friendship`. |
| **Reviews & Comments** | Review ➔ Comment | **1 : N** | One game review can hold multiple threaded replies from other users. |

---

## 5. Normalization Proofs (1NF to 3NF/BCNF)

### First Normal Form (1NF)
- **Criterion**: All attributes are atomic (no repeating groups, no multi-valued attributes like comma-separated genres or arrays).
- **Proof**: Multi-valued genres and platforms were extracted into dedicated junction tables (`GameGenre`, `GamePlatform`). All cell values store strictly atomic data types.

### Second Normal Form (2NF)
- **Criterion**: Relation is in 1NF and contains **no partial dependencies** (every non-prime attribute is fully functionally dependent on the entire primary key).
- **Proof**: In junction tables with composite primary keys such as `GamePlatform(game_id, platform_id)`, no attributes depend on only one part of the key. In `GameCollection`, an artificial surrogate key `collection_id` is assigned alongside a candidate key constraint `UNIQUE(user_id, game_id)`.

### Third Normal Form (3NF)
- **Criterion**: Relation is in 2NF and contains **no transitive dependencies** (no non-prime attribute determines another non-prime attribute $X \to Y \to Z$).
- **Proof**: Developer headquarters and founding years are not stored inside the `Game` table. Storing them in `Game` would introduce $GameID \to DeveloperID \to Headquarters$ (transitive dependency). Instead, they are isolated in `Developer` with $DeveloperID \to Headquarters$.

---

## 6. Business Logic, Constraints & Triggers

### A. Invariant Wallet Checking & Atomic Deductions
Before registering a transaction, the application and database verify available funds:
$$\text{Wallet}_{\text{new}} = \text{Wallet}_{\text{current}} - \text{Price} \quad \text{where } \text{Wallet}_{\text{current}} \ge \text{Price}$$

### B. Idempotent Library Additions
When a user buys a game, `GameCollection` enforces idempotency using `ON DUPLICATE KEY UPDATE`, ensuring duplicate entries are never created.

---

## 7. Advanced SQL Queries & Analytics

### Top 5 Most-Played Games (Aggregation & Joins)
```sql
SELECT g.title, SUM(c.hours_played) AS total_hours
FROM GameCollection c
JOIN Game g ON c.game_id = g.game_id
GROUP BY g.title
ORDER BY total_hours DESC
LIMIT 5;
```

### Leaderboard Ranking with Achievements Breakdown
```sql
SELECT u.username, l.total_points, l.total_achievements,
       RANK() OVER (ORDER BY l.total_points DESC) AS calculated_rank
FROM Leaderboard l
JOIN User u ON l.user_id = u.user_id;
```

---

## 8. DBMS Viva Voce — Questions & Model Answers

### Q1: Why did you choose 3NF normalization over denormalization?
> **Answer:** 3NF eliminates data anomalies (Insertion, Deletion, and Update anomalies). For instance, if an existing developer updates their headquarters, updating a single record in the `Developer` table immediately propagates across all 50+ linked games, preventing data inconsistencies while optimizing storage.

### Q2: How does your application prevent SQL Injection?
> **Answer:** All SQL queries that process dynamic user input use parameterized queries (prepared statements) via `mysql.connector` with `%s` placeholders. Input strings are treated strictly as literal data rather than executable SQL code.

### Q3: How is password security implemented?
> **Answer:** Passwords are never stored in plain text. They are hashed using SHA-256 (`hashlib.sha256`) before transmission and storage. When authenticating, the entered password is independently hashed and compared in constant time against the stored hash in the database.

### Q4: What is the purpose of surrogate keys vs. natural keys in your schema?
> **Answer:** We used surrogate keys (`INT AUTO_INCREMENT`) for primary keys like `user_id` and `game_id` because numeric keys are compact, indexed quickly with B-Trees, and decoupled from mutable business values like emails or titles. Unique constraints are placed on natural candidate keys (`username`, `email`) to maintain integrity.

### Q5: How do you handle cloud database latency and disconnection?
> **Answer:** Our connection manager in `db_connection.py` handles dynamic credential resolution, custom port mapping, and TLS/SSL encryption (`ssl_disabled=False`). Queries are executed with explicit exception handling (`try-except`) and resource cleanup to prevent orphaned connection leaks.
