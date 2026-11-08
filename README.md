# 🎮 GameVerse+

[![Streamlit App](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](https://gameverseplus-6l2rpdkppknw4ymzqzchxb.streamlit.app/)
[![Python](https://img.shields.io/badge/Python-3.9%20%7C%203.10%20%7C%203.11%20%7C%203.12-blue.svg)](https://www.python.org/)
[![Database](https://img.shields.io/badge/Database-MySQL%20%2F%20TiDB-orange.svg)](https://tidbcloud.com/)
[![Tests](https://img.shields.io/badge/Tests-12%2F12%20Passing-brightgreen.svg)](tests/test_components.py)

**GameVerse+** is an end-to-end full-stack Game Management, Analytics, and Achievement Tracking Platform built with **Streamlit (Python)** and **MySQL / TiDB**. It provides an interactive ecosystem for gamers to track titles, manage collections, unlock achievements, write reviews, and climb community leaderboards.

---

## 🌐 Live Deployment Links

- **🚀 Live Web Application:** **[https://gameverseplus-6l2rpdkppknw4ymzqzchxb.streamlit.app/](https://gameverseplus-6l2rpdkppknw4ymzqzchxb.streamlit.app/)**
- **💻 GitHub Source Repository:** **[https://github.com/haneeshmekala3-dot/GameVersePlus](https://github.com/haneeshmekala3-dot/GameVersePlus)**

---

## 🔑 Sample Login Credentials

Use any of these pre-configured test accounts to explore the live website:

| Role | Username | Password | Features Accessible |
| :--- | :--- | :--- | :--- |
| **🛡️ Admin** | `AdminUser` | `admin123` | Dashboard, Analytics, Add Game, Admin Tools (Broadcasts & CSV Data Export) |
| **👤 Player** | `Haneesh` | `12345` | Library, Cart & Checkout, ₹5,900 Wallet, Game Collection, Achievements, Friends |
| **👥 Player** | `Ravi` | `67890` | Wishlist items, Reviews, Incoming/Outgoing Friend Requests |

> 💡 *You can also click **"Sign Up"** on the login screen to create a brand new player account with an initial wallet balance.*

---

## 🚀 Key Features

- **🕹 Game Library**: Browse, search, and explore 50+ games with developer, publisher, and genre associations.
- **🏆 Achievements System**: 100+ unlockable game achievements integrated with player leaderboard points.
- **💰 In-App Wallet & Checkout**: Pre-loaded wallet system with balance checks and instant checkout.
- **🛒 Shopping Cart**: Add games, view total prices, and checkout multiple items simultaneously.
- **📥 Auto-Collection**: Purchased titles are automatically registered to your personal library.
- **📊 Analytics & Visualizations**: Interactive Plotly charts displaying genre distribution, top players, and most played games.
- **👥 Roles & Authentication**: Role-based access control (Admin, Player, Moderator) secured with SHA-256 password hashing.
- **💬 Community Reviews & Comments**: Threaded player reviews, ratings (1.0–10.0), and user comment discussions.
- **🔔 Notifications**: Real-time notification center for purchases, unlocked achievements, and friend requests.
- **🤝 Social & Multiplayer**: Friend request workflows, player acceptance, and multiplayer match history tracking.

---

## 🛠 Tech Stack

- **Frontend / UI**: [Streamlit](https://streamlit.io/), `streamlit-option-menu`
- **Visualizations**: [Plotly Express](https://plotly.com/)
- **Backend**: Python 3 (Pandas, MySQL Connector)
- **Database**: MySQL 8.0 / TiDB Serverless (Triggers, Views, Constraints, Normalized 3NF Schema)
- **Database Modeling**: MySQL Workbench (`.mwb`)

---

## 📁 Project Structure

```text
GameVersePlus/
├── app.py                     # Main Streamlit web application & routing
├── auth.py                    # User authentication, hashing & session handling
├── db_connection.py           # Database connection manager (Local + TiDB Cloud SSL)
├── requirements.txt           # Python dependency specifications
├── .env.example               # Configuration template for environment variables
├── .gitignore                 # Excludes virtual environments, cache, and secrets
├── .streamlit/
│   └── config.toml            # Custom dark gaming UI theme preset
├── database/
│   ├── gameverse_plus.sql     # Full database schema, seed data & triggers
│   └── dbslabproject.mwb      # MySQL Workbench visual Entity-Relationship model
└── tests/
    └── test_components.py     # Automated test suite (12 component tests)
```

---

## 🧪 Automated Testing

GameVerse+ includes an automated test suite verifying all 12 core components:

```bash
python tests/test_components.py
```

### Verified Test Suite:
- `test_01_db_connection`: Verifies active connection to cloud database
- `test_02_auth_admin_login`: Verifies admin authentication and role elevation (Role 2)
- `test_03_auth_player_login`: Verifies player authentication (Role 1)
- `test_04_auth_invalid_credentials`: Verifies invalid password rejection
- `test_05_auth_user_exists`: Verifies user registration checks
- `test_06_dashboard_queries`: Verifies dashboard metrics and genre aggregations
- `test_07_games_library_and_relations`: Verifies 50+ games with developer/publisher joins
- `test_08_wallet_and_user_balance`: Verifies wallet balance calculation
- `test_09_leaderboard_query`: Verifies points ranking and achievement score
- `test_10_reviews_and_comments`: Verifies community reviews and comment threads
- `test_11_achievements_system`: Verifies 100+ achievement milestones
- `test_12_notifications_system`: Verifies notification delivery query

---

## ⚡ Local Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/haneeshmekala3-dot/GameVersePlus.git
cd GameVersePlus
```

### 2. Configure Environment
Copy `.env.example` to `.env` and fill in your database details:
```bash
copy .env.example .env
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Run the Application
```bash
streamlit run app.py
```
Open [http://localhost:8501](http://localhost:8501) in your browser.

---

## 👥 Contributors

- **Haneesh Mekala** ([@haneeshmekala3-dot](https://github.com/haneeshmekala3-dot)) — Project Lead, Full-Stack Development & Cloud Deployment
- **Yogyabhilash** ([@Yogyabhilash](https://github.com/Yogyabhilash)) — Database Architecture, Schema Design & Analytics Engineering

