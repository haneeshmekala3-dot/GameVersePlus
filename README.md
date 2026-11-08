# 🎮 GameVerse+

**GameVerse+** is a full-stack Game Management, Analytics, and Achievement Tracking Platform built with **Streamlit (Python)** and **MySQL**.

---

## 🚀 Features

- **🕹 Game Library**: Browse, manage, and search 50+ games with genre and platform filtering.
- **🏆 Achievements System**: Track unlockable milestones with leaderboard score integration.
- **💰 Wallet & Checkout**: In-app wallet system with automated balance verification and deduction.
- **🛒 Shopping Cart**: Add and remove games with one-click checkout.
- **📥 Auto Game Collection**: Purchased items are automatically registered to your library via database triggers.
- **📊 Analytics & Visualizations**: Interactive Plotly charts for genre distribution and top player leaderboards.
- **👥 Roles & Security**: Role-based access (Player, Admin, Moderator) with SHA-256 hashed authentication.
- **💬 Community Reviews & Comments**: Leave ratings, reviews, and interact with other players.
- **🔔 Notifications**: Real-time alerts for purchases, achievements, and friend requests.
- **🤝 Friends & Multiplayer**: Send friend requests and track multiplayer match scores.

---

## 🛠 Tech Stack

- **Frontend / UI**: [Streamlit](https://streamlit.io/), `streamlit-option-menu`
- **Data Visualization**: [Plotly](https://plotly.com/)
- **Backend**: Python 3
- **Database**: MySQL (Triggers, Views, Foreign Key Constraints, Normalized Schema)
- **Database Modeling**: MySQL Workbench (`.mwb`)

---

## 📁 Project Structure

```text
GameVersePlus/
├── app.py                # Main Streamlit web application
├── auth.py               # Authentication and password hashing logic
├── db_connection.py      # MySQL database connection handler
├── test_db.py            # Quick database connection verification
├── requirements.txt      # Python dependencies
├── .env.example          # Template for database configuration
├── .gitignore            # Git ignore rules for venv, secrets, and cache
└── database/
    ├── gameverse_plus.sql # Complete database schema, seed data, and triggers
    └── dbslabproject.mwb # MySQL Workbench visual ER model
```

---

## ⚡ Getting Started

### 1. Database Setup
1. Open your MySQL client (e.g., MySQL Workbench or MySQL CLI).
2. Execute the script in `database/gameverse_plus.sql`:
   ```bash
   mysql -u root -p < database/gameverse_plus.sql
   ```
   This creates the `gameverse_plus` database, schema, sample data, and triggers.

### 2. Environment Configuration
1. Copy `.env.example` to `.env`:
   ```bash
   copy .env.example .env
   ```
2. Update `.env` with your MySQL credentials:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=gameverse_plus
   ```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Run the Application
```bash
streamlit run app.py
```
Open your browser at `http://localhost:8501`.

