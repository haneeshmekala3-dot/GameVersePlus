# app.py
import streamlit as st
import pandas as pd
import plotly.express as px
from streamlit_option_menu import option_menu
from db_connection import get_connection
from auth import login_user, signup_user, user_exists

# -------------------------
# Helpers
# -------------------------
def normalize_user(user_row):
    """
    Convert pandas Series or dict-like to a plain Python dict with native types.
    This prevents numpy.int64 -> DB conversion errors.
    """
    if user_row is None:
        return None
    # If it's a pandas Series
    try:
        if hasattr(user_row, "to_dict"):
            u = dict(user_row.to_dict())
        else:
            u = dict(user_row)
    except Exception:
        u = dict(user_row)

    # Cast numeric fields to Python ints if present
    if "user_id" in u and u["user_id"] is not None:
        try:
            u["user_id"] = int(u["user_id"])
        except Exception:
            pass
    if "role_id" in u and u["role_id"] is not None:
        try:
            u["role_id"] = int(u["role_id"])
        except Exception:
            pass
    return u

def get_user_id():
    """Return logged-in user's id as Python int or None."""
    if "user" in st.session_state and st.session_state.user:
        try:
            return int(st.session_state.user.get("user_id"))
        except Exception:
            return None
    return None

def is_admin():
    """Return True if current user is admin (role_id == 2)."""
    if "user" in st.session_state and st.session_state.user:
        try:
            return int(st.session_state.user.get("role_id", 1)) == 2
        except Exception:
            return False
    return False

def safe_read_sql(sql, conn, params=None):
    """Run a read query and return DataFrame or empty DataFrame on error (with message)."""
    try:
        if params is None:
            return pd.read_sql(sql, conn)
        else:
            return pd.read_sql(sql, conn, params=params)
    except Exception as e:
        st.error(f"Database read error: {e}")
        return pd.DataFrame()

def safe_execute(conn, sql, params=None):
    """Execute a write query and commit, with error handling."""
    try:
        cur = conn.cursor()
        if params is None:
            cur.execute(sql)
        else:
            cur.execute(sql, params)
        conn.commit()
        return True
    except Exception as e:
        st.error(f"Database execute error: {e}")
        return False

# -------------------------
# Page config & session
# -------------------------
st.set_page_config(page_title="GameVerse+", page_icon="🎮", layout="wide")

if "logged_in" not in st.session_state:
    st.session_state.logged_in = False
    st.session_state.user = None

# -------------------------
# Login / Signup
# -------------------------
if not st.session_state.logged_in:
    st.markdown("""
        <h1 style='text-align:center;color:#00BFFF;font-family:Orbitron;'>🎮 GameVerse+ Login</h1>
    """, unsafe_allow_html=True)

    option = st.radio("Select Option", ["Login", "Sign Up"], horizontal=True)

    if option == "Login":
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        if st.button("Login"):
            user_row = login_user(username, password)  # may return pandas Series
            if user_row is not None:
                user = normalize_user(user_row)
                st.session_state.logged_in = True
                st.session_state.user = user
                st.success(f"✅ Welcome, {user.get('username', 'User')}!")
                st.rerun()
            else:
                st.error("❌ Invalid username or password")

    elif option == "Sign Up":
        username = st.text_input("Choose a Username")
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        country = st.text_input("Country")
        if st.button("Sign Up"):
            if user_exists(username):
                st.warning("⚠ Username already exists. Try another.")
            else:
                signup_user(username, email, password, country)
                st.success("🎉 Account created! You can now login.")
    st.stop()

# -------------------------
# Styling
# -------------------------
st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700&display=swap');

.stApp {
    background-color: #0e1117;
    color: #e6e6e6;
    font-family: 'Orbitron', sans-serif;
}
.stSidebar {
    background-color: #15181e !important;
    border-right: 2px solid #00BFFF;
    box-shadow: 0px 0px 20px rgba(0,191,255,0.2);
}
h1, h2, h3, h4 {
    color: #00BFFF;
    text-shadow: 0px 0px 10px rgba(0,191,255,0.5);
    font-weight: 700;
}
button[kind="primary"] {
    background-color: #00BFFF !important;
    color: black !important;
    border-radius: 10px !important;
    font-weight: bold;
    transition: 0.3s;
}
button[kind="primary"]:hover {
    background-color: #007acc !important;
    color: white !important;
    transform: scale(1.03);
}
.stMetric {
    background-color: #1a1d23;
    border-radius: 12px;
    padding: 15px;
    margin: 5px;
    box-shadow: 0 0 15px rgba(0,191,255,0.1);
    transition: all 0.3s ease-in-out;
}
.stMetric:hover {
    transform: scale(1.05);
    box-shadow: 0 0 25px rgba(0,191,255,0.3);
}
hr {
    border: 1px solid rgba(0,191,255,0.3);
    margin: 20px 0;
}
.sidebar-logo {
    display: block;
    margin: auto;
    width: 80px;
    border-radius: 50%;
    box-shadow: 0 0 15px rgba(0,191,255,0.4);
    margin-bottom: 15px;
}
</style>
""", unsafe_allow_html=True)


# Fetch wallet balance
conn = get_connection()
user_id = st.session_state.user.get("user_id") if st.session_state.user else None
wallet = 0.0
if conn and user_id is not None:
    wallet_df = safe_read_sql("SELECT wallet_balance FROM User WHERE user_id=%s", conn, params=(int(user_id),))
    if not wallet_df.empty and "wallet_balance" in wallet_df.columns:
        wallet = float(wallet_df["wallet_balance"].iloc[0])
    conn.close()

st.markdown(f"""
    <div style="
        background-color:#111827;
        padding:12px;
        border-radius:10px;
        margin-bottom:10px;
        color:#00BFFF;
        text-align:center;
        font-size:18px;">
        💰 <b>Wallet:</b> ₹{wallet}
    </div>
""", unsafe_allow_html=True)


# -------------------------
# Sidebar and menu
# -------------------------
with st.sidebar:
    st.image("https://us.aimcontrollers.com/wp-content/uploads/2020/10/Aim_Grid_Gray-500x500.png")
    # notification count (ensure Python int passed)
    conn = None
    try:
        conn = get_connection()
        uid = get_user_id()
        if uid is None:
            notif_count = 0
        else:
            notif_df = safe_read_sql("SELECT COUNT(*) AS cnt FROM Notification WHERE user_id=%s AND is_read=FALSE;", conn, params=(int(uid),))
            notif_count = int(notif_df["cnt"].iloc[0]) if not notif_df.empty else 0
    finally:
        if conn:
            conn.close()

    choice = option_menu(
        menu_title="GameVerse+",
        options=[
            "Home", "Profile", "Users", "Games", "Add Game",
            "Achievements", "Add Achievement",
            "Leaderboard", "Friends", "Game Collection",
            "Add Money", "Cart",
            f"Notifications {'🔴' if notif_count > 0 else ''}",
            "Analytics", "Admin Tools", "About"
        ],

        icons=[
            "house", "person", "people", "controller", "plus-circle",
            "trophy", "award", "bar-chart", "person-plus", "collection",
            "cash-coin", "cart",
            "bell", "graph-up", "gear", "info-circle"
        ],
        menu_icon="joystick",
        default_index=0
    )

    st.markdown("---")
    if st.button("🚪 Logout"):
        st.session_state.logged_in = False
        st.session_state.user = None
        st.rerun()

# -------------------------
# Home
# -------------------------
if choice == "Home":
    st.markdown("""
        <div style='background: linear-gradient(90deg, #00BFFF, #007acc, #00BFFF);
        background-size: 300% 300%; animation: gradientMove 5s infinite;
        color: white; text-align: center; padding: 18px; border-radius: 10px;
        font-family: Orbitron, sans-serif; font-size: 28px; font-weight: 700;
        text-shadow: 0 0 10px rgba(0,191,255,0.7);'>
        🎮 Welcome to GameVerse+ — The Ultimate Game & Achievement Tracker 🎮
        </div>
        <style>
        @keyframes gradientMove {
            0% {background-position: 0% 50%;}
            50% {background-position: 100% 50%;}
            100% {background-position: 0% 50%;}
        }
        </style>
    """, unsafe_allow_html=True)

    st.title("🎮 GameVerse+ Dashboard")
    st.markdown("Welcome to GameVerse+, your all-in-one platform to manage games, track achievements, and view player rankings!")

    conn = get_connection()
    try:
        games_cnt_df = safe_read_sql("SELECT COUNT(*) AS count FROM Game", conn)
        total_games = int(games_cnt_df["count"].iloc[0]) if not games_cnt_df.empty else 0

        users_cnt_df = safe_read_sql("SELECT COUNT(*) AS count FROM User", conn)
        total_users = int(users_cnt_df["count"].iloc[0]) if not users_cnt_df.empty else 0

        ach_cnt_df = safe_read_sql("SELECT COUNT(*) AS count FROM Achievement", conn)
        total_achievements = int(ach_cnt_df["count"].iloc[0]) if not ach_cnt_df.empty else 0

        avg_price_df = safe_read_sql("SELECT ROUND(AVG(price),2) AS avg_price FROM Game", conn)
        avg_price = float(avg_price_df["avg_price"].iloc[0]) if not avg_price_df.empty and avg_price_df["avg_price"].iloc[0] is not None else 0.0

        col1, col2, col3, col4 = st.columns(4)
        col1.metric("🎮 Total Games", int(total_games))
        col2.metric("👥 Total Players", int(total_users))
        col3.metric("🏆 Achievements", int(total_achievements))
        col4.metric("💰 Avg Game Price ($)", avg_price)

        st.markdown("---")

        genre_df = safe_read_sql("""
            SELECT g.name AS Genre, COUNT(gg.game_id) AS GameCount
            FROM Genre g
            JOIN GameGenre gg ON g.genre_id = gg.genre_id
            GROUP BY g.name;
        """, conn)
        if not genre_df.empty:
            st.subheader("📊 Games by Genre")
            fig = px.pie(genre_df, names='Genre', values='GameCount', title='Game Distribution by Genre')
            st.plotly_chart(fig, use_container_width=True)

        st.markdown("---")
        leaderboard_df = safe_read_sql("""
            SELECT u.username, l.total_points, l.total_achievements
            FROM Leaderboard l
            JOIN User u ON l.user_id = u.user_id
            ORDER BY l.total_points DESC LIMIT 5;
        """, conn)
        if not leaderboard_df.empty:
            st.subheader("🏅 Top Players by Total Points")
            st.plotly_chart(px.bar(leaderboard_df, x='username', y='total_points', color='total_achievements', text_auto=True), use_container_width=True)

        st.markdown("---")
        games_df = safe_read_sql("""
            SELECT title, release_date, price
            FROM Game
            ORDER BY release_date DESC
            LIMIT 5;
        """, conn)
        if not games_df.empty:
            st.subheader("🕹 Recently Added Games")
            st.dataframe(games_df, use_container_width=True)
    finally:
        conn.close()

# -------------------------
# Profile
# -------------------------
elif choice == "Profile":
    st.header("👤 My Profile")
    conn = get_connection()
    try:
        user_id = get_user_id()
        if user_id is None:
            st.error("User not found in session.")
            st.stop()

        profile = safe_read_sql("""
            SELECT username, email, country, join_date, total_playtime
            FROM User WHERE user_id=%s;
        """, conn, params=(int(user_id),))
        if profile.empty:
            st.info("Profile not available.")
        else:
            st.dataframe(profile, use_container_width=True)

        stats = safe_read_sql("""
            SELECT 
                (SELECT COUNT(*) FROM GameCollection WHERE user_id=%s) AS GamesOwned,
                (SELECT COUNT(*) FROM UserAchievement WHERE user_id=%s) AS Achievements,
                (SELECT COUNT(*) FROM Review WHERE user_id=%s) AS Reviews;
        """, conn, params=(int(user_id), int(user_id), int(user_id)))
        if not stats.empty:
            col1, col2, col3 = st.columns(3)
            col1.metric("🎮 Games Owned", int(stats["GamesOwned"].iloc[0]))
            col2.metric("🏆 Achievements", int(stats["Achievements"].iloc[0]))
            col3.metric("💬 Reviews", int(stats["Reviews"].iloc[0]))
    finally:
        conn.close()

# -------------------------
# Games
# -------------------------
elif choice == "Games":
    st.header("🕹 Game Library")
    conn = get_connection()

    try:
        # Fetch all games
        df = safe_read_sql("""
            SELECT g.game_id, g.title, d.name AS Developer, p.name AS Publisher,
                   g.price, g.release_date
            FROM Game g
            LEFT JOIN Developer d ON g.developer_id = d.developer_id
            LEFT JOIN Publisher p ON g.publisher_id = p.publisher_id;
        """, conn)

        if df.empty:
            st.info("No games available yet. Add some!")
        else:
            st.dataframe(df, use_container_width=True)

        st.subheader("🛒 Buy or Add to Cart")

        if not df.empty:

            # Select game
            game_choice = st.selectbox("Select game:", df["title"].tolist())
            row = df[df["title"] == game_choice].iloc[0]
            gid = int(row["game_id"])
            price = float(row["price"])

            uid = get_user_id()

            # Fetch user wallet
            conn2 = get_connection()
            wallet_df = safe_read_sql(
                "SELECT wallet_balance FROM User WHERE user_id=%s",
                conn2, params=(uid,)
            )
            conn2.close()

            wallet = float(wallet_df["wallet_balance"].iloc[0]) if not wallet_df.empty else 0.0

            st.markdown(f"💰 **Price:** ₹{price} | 🧍 Your Wallet: **₹{wallet}**")

            # Check if user already owns this game
            conn3 = get_connection()
            owned_df = safe_read_sql(
                "SELECT * FROM GameCollection WHERE user_id=%s AND game_id=%s",
                conn3, params=(uid, gid)
            )
            conn3.close()

            already_owned = not owned_df.empty
            if already_owned:
                st.info("✅ You already own this game!")

            # ---------------------------
            # Add to Cart Button
            # ---------------------------
            if st.button("Add to Cart"):
                if already_owned:
                    st.warning("⚠ You already own this game. No need to add to cart.")
                else:
                    conn4 = get_connection()
                    safe_execute(conn4,
                        "INSERT INTO Cart (user_id, item_type, item_id) VALUES (%s, 'Game', %s)",
                        (uid, gid)
                    )
                    conn4.close()
                    st.success(f"🛒 '{game_choice}' added to cart!")

            # ---------------------------
            # Buy Now Button
            # ---------------------------
            if st.button("💵 Buy Now"):
                if already_owned:
                    st.warning("⚠ You already own this game.")
                elif wallet < price:
                    st.error("❌ Not enough balance! Please add money.")
                else:
                    conn5 = get_connection()

                    # 1️⃣ Deduct money
                    safe_execute(conn5,
                        "UPDATE User SET wallet_balance = wallet_balance - %s WHERE user_id=%s",
                        (price, uid)
                    )

                    # 2️⃣ Register purchase
                    safe_execute(conn5,
                        """
                        INSERT INTO Purchase (user_id, item_type, item_id, price)
                        VALUES (%s, 'Game', %s, %s)
                        """,
                        (uid, gid, price)
                    )

                    # 3️⃣ Add to collection
                    safe_execute(conn5,
                        """
                        INSERT INTO GameCollection (user_id, game_id, status)
                        VALUES (%s, %s, 'Wishlist')
                        ON DUPLICATE KEY UPDATE status='Wishlist'
                        """,
                        (uid, gid)
                    )

                    conn5.close()

                    st.success(f"🎉 Purchased '{game_choice}' successfully!")
                    st.rerun()

    finally:
        conn.close()

# -------------------------
# Add Game (admin only)
# -------------------------
elif choice == "Add Game":
    if not is_admin():
        st.warning("🚫 Access denied — Admins only.")
        st.stop()

    st.header("➕ Add a New Game")
    with st.form("add_game_form"):
        title = st.text_input("Game Title")
        developer_id = st.number_input("Developer ID", min_value=1, value=1)
        publisher_id = st.number_input("Publisher ID", min_value=1, value=1)
        release_date = st.date_input("Release Date")
        price = st.number_input("Price ($)", min_value=0.0, format="%.2f")
        description = st.text_area("Description")
        submit = st.form_submit_button("Add Game")
        if submit:
            conn = get_connection()
            try:
                success = safe_execute(conn, """
                    INSERT INTO Game (title, developer_id, publisher_id, release_date, price, description)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (title, int(developer_id), int(publisher_id), release_date, float(price), description))
                if success:
                    st.success(f"✅ Game '{title}' added successfully!")
                    st.rerun()
            finally:
                conn.close()

# -------------------------
# Achievements
# -------------------------
elif choice == "Achievements":
    st.header("🏆 Achievements & Progress")
    conn = get_connection()
    try:
        df = safe_read_sql("""
            SELECT a.achievement_id, g.title AS Game, a.name AS Achievement, a.points
            FROM Achievement a
            JOIN Game g ON a.game_id = g.game_id;
        """, conn)
        if df.empty:
            st.info("No achievements found.")
        else:
            total_points = df["points"].sum() if not df.empty else 1
            for _, row in df.iterrows():
                st.write(f"🎯 {row['Game']} — {row['Achievement']} ({row['points']} pts)")
                try:
                    st.progress(min(1.0, float(row["points"]) / float(total_points)))
                except Exception:
                    pass
    finally:
        conn.close()

# -------------------------
# Add Achievement (admin only)
# -------------------------
elif choice == "Add Achievement":
    if not is_admin():
        st.warning("🚫 Access denied — Admins only.")
        st.stop()

    st.header("🏅 Add a New Achievement")
    with st.form("add_achievement_form"):
        game_id = st.number_input("Game ID", min_value=1, value=1)
        name = st.text_input("Achievement Name")
        description = st.text_area("Description")
        points = st.number_input("Points", min_value=0, value=10)
        submit = st.form_submit_button("Add Achievement")
        if submit:
            conn = get_connection()
            try:
                success = safe_execute(conn, """
                    INSERT INTO Achievement (game_id, name, description, points)
                    VALUES (%s, %s, %s, %s)
                """, (int(game_id), name, description, int(points)))
                if success:
                    st.success(f"🏆 Achievement '{name}' added successfully!")
                    st.rerun()
            finally:
                conn.close()

# -------------------------
# Users (admin only)
# -------------------------
elif choice == "Users":
    if not is_admin():
        st.warning("🚫 Access denied — Admins only.")
        st.stop()

    st.header("👥 Manage Users")
    conn = get_connection()
    try:
        search = st.text_input("🔍 Search by username or email")
        query = "SELECT user_id, username, email, country, role_id, total_playtime, join_date FROM User"
        params = None
        if search:
            query += " WHERE username LIKE %s OR email LIKE %s"
            like = f"%{search}%"
            params = (like, like)
        df = safe_read_sql(query, conn, params=params)
        if df.empty:
            st.info("No users found.")
        else:
            st.dataframe(df, use_container_width=True)

        st.markdown("---")
        col1, col2 = st.columns(2)

        with col1:
            st.subheader("➕ Add New User")
            with st.form("add_user"):
                username = st.text_input("Username")
                email = st.text_input("Email")
                password = st.text_input("Password", type="password")
                country = st.text_input("Country")
                role = st.selectbox("Role", ["Player", "Admin", "Moderator"])
                role_id = {"Player": 1, "Admin": 2, "Moderator": 3}[role]
                submit_user = st.form_submit_button("Add User")
                if submit_user:
                    success = safe_execute(conn, """
                        INSERT INTO User (username, email, password_hash, country, role_id)
                        VALUES (%s, %s, %s, %s, %s)
                    """, (username, email, password, country, int(role_id)))
                    if success:
                        st.success(f"✅ User '{username}' added successfully!")
                        st.rerun()

        with col2:
            st.subheader("🗑 Delete User")
            user_id = st.number_input("Enter User ID to delete", min_value=1, value=1)
            if st.button("Delete User"):
                success = safe_execute(conn, "DELETE FROM User WHERE user_id=%s", (int(user_id),))
                if success:
                    st.warning(f"⚠ User with ID {user_id} deleted successfully!")
                    st.rerun()
    finally:
        conn.close()

# -------------------------
# Leaderboard
# -------------------------
elif choice == "Leaderboard":
    st.header("📊 Leaderboard")
    conn = get_connection()
    try:
        df = safe_read_sql("""
            SELECT u.username, l.total_points, l.total_achievements, l.rank_position
            FROM Leaderboard l
            JOIN User u ON l.user_id = u.user_id
            ORDER BY l.total_points DESC;
        """, conn)
        if df.empty:
            st.info("Leaderboard is empty. Add users and achievements first!")
        else:
            st.dataframe(df, use_container_width=True)
    finally:
        conn.close()

# -------------------------
# Analytics (admin only)
# -------------------------
elif choice == "Analytics":
    if not is_admin():
        st.warning("🚫 Access denied — Admins only.")
        st.stop()

    st.header("📊 Analytics Dashboard")
    conn = get_connection()
    try:
        df1 = safe_read_sql("""
            SELECT g.title, SUM(c.hours_played) AS total_hours
            FROM GameCollection c
            JOIN Game g ON c.game_id = g.game_id
            GROUP BY g.title ORDER BY total_hours DESC LIMIT 5;
        """, conn)
        if not df1.empty:
            st.plotly_chart(px.bar(df1, x="title", y="total_hours", title="Most Played Games"), use_container_width=True)
        else:
            st.info("No game collection data available.")
    finally:
        conn.close()

# -------------------------
# Admin Tools (admin only)
# -------------------------
elif choice == "Admin Tools":
    if not is_admin():
        st.warning("🚫 Access denied — Admins only.")
        st.stop()

    st.header("🛠 Admin Tools")
    conn = get_connection()
    try:
        st.subheader("📢 Send System Notification")
        message = st.text_area("Enter message")
        notif_type = st.selectbox("Type", ["System", "FriendRequest", "Achievement", "Purchase"])
        if st.button("Send Notification to All Users"):
            success = safe_execute(conn, """
                INSERT INTO Notification (user_id, message, type)
                SELECT user_id, %s, %s FROM User;
            """, (message, notif_type))
            if success:
                st.success("✅ Notification sent to all users!")
                st.rerun()

        st.markdown("---")
        st.subheader("🧾 Export Data")
        table_choice = st.selectbox("Select table to export", ["User", "Game", "Purchase", "Review"])
        df = safe_read_sql(f"SELECT * FROM {table_choice}", conn)
        if not df.empty:
            csv_data = df.to_csv(index=False)
            st.download_button(f"📥 Download {table_choice} Data", csv_data, f"{table_choice}.csv", "text/csv")
        else:
            st.info("No data to export.")
    finally:
        conn.close()

# -------------------------
# Notifications
# -------------------------
elif choice.startswith("Notifications"):
    st.header("🔔 Notifications Center")
    conn = get_connection()
    try:
        user_id = get_user_id()
        if user_id is None:
            st.error("User not found.")
            st.stop()

        df = safe_read_sql("""
            SELECT notification_id, message, type, created_at, 
                   CASE WHEN is_read THEN '✅ Read' ELSE '🕐 Unread' END AS status
            FROM Notification
            WHERE user_id = %s
            ORDER BY created_at DESC;
        """, conn, params=(int(user_id),))
        if df.empty:
            st.info("No notifications yet! 🎮")
        else:
            st.dataframe(df, use_container_width=True)

        if st.button("Mark All as Read"):
            if safe_execute(conn, "UPDATE Notification SET is_read = TRUE WHERE user_id = %s", (int(user_id),)):
                st.success("✅ All notifications marked as read!")
                st.rerun()
    finally:
        conn.close()

# -------------------------
# Reviews
# -------------------------
elif choice == "Reviews":
    st.header("🧾 Game Reviews & Comments")
    conn = get_connection()
    try:
        df_reviews = safe_read_sql("""
            SELECT r.review_id, u.username AS Reviewer, g.title AS Game, 
                   r.rating, r.review_text, r.review_date
            FROM Review r
            JOIN User u ON r.user_id = u.user_id
            JOIN Game g ON r.game_id = g.game_id
            ORDER BY r.review_date DESC;
        """, conn)
        if df_reviews.empty:
            st.info("No reviews posted yet!")
        else:
            for _, row in df_reviews.iterrows():
                st.subheader(f"🎮 {row['Game']} — ⭐ {row['rating']}/10")
                st.write(f"🧑 **{row['Reviewer']}** said:")
                st.write(row['review_text'])
                st.caption(f"🕓 Posted on: {row['review_date']}")

                comments = safe_read_sql("""
                    SELECT u.username, c.comment_text, c.comment_date
                    FROM Comment c
                    JOIN User u ON c.user_id = u.user_id
                    WHERE c.review_id = %s
                    ORDER BY c.comment_date ASC;
                """, conn, params=(int(row["review_id"]),))

                if not comments.empty:
                    for _, com in comments.iterrows():
                        st.markdown(f"> 💬 **{com['username']}**: {com['comment_text']}")
                else:
                    st.write("_No comments yet_")

                with st.expander("💭 Add Comment"):
                    new_comment = st.text_area(f"Add a comment for Review #{row['review_id']}")
                    if st.button(f"Post Comment #{row['review_id']}"):
                        if new_comment.strip():
                            if safe_execute(conn, "INSERT INTO Comment (review_id, user_id, comment_text) VALUES (%s, %s, %s)", (int(row["review_id"]), get_user_id(), new_comment)):
                                st.success("💬 Comment added successfully!")
                                st.rerun()
                        else:
                            st.warning("Comment cannot be empty.")
                st.markdown("---")
    finally:
        conn.close()

# -------------------------
# Friends
# -------------------------
elif choice.startswith("Friends"):
    st.header("🤝 Friendships & Requests")
    conn = get_connection()
    try:
        user_id = get_user_id()
        if user_id is None:
            st.error("User not found.")
            st.stop()

        st.subheader("👥 Your Friends")
        friends_df = safe_read_sql("""
            SELECT u.username AS Friend, f.status, f.since
            FROM Friendship f
            JOIN User u ON f.friend_id = u.user_id
            WHERE f.user_id = %s AND f.status='Accepted';
        """, conn, params=(int(user_id),))
        if friends_df.empty:
            st.info("No friends yet 😅")
        else:
            st.dataframe(friends_df, use_container_width=True)

        st.markdown("---")
        st.subheader("📩 Incoming Friend Requests")
        incoming = safe_read_sql("""
            SELECT f.user_id, u.username
            FROM Friendship f
            JOIN User u ON f.user_id = u.user_id
            WHERE f.friend_id = %s AND f.status='Pending';
        """, conn, params=(int(user_id),))
        if incoming.empty:
            st.write("_No pending requests_")
        else:
            for _, req in incoming.iterrows():
                col1, col2 = st.columns([3, 1])
                with col1:
                    st.write(f"👤 {req['username']} wants to be friends.")
                with col2:
                    if st.button(f"✅ Accept {req['user_id']}"):
                        if safe_execute(conn, "UPDATE Friendship SET status='Accepted' WHERE user_id=%s AND friend_id=%s;", (int(req["user_id"]), int(user_id))):
                            safe_execute(conn, "INSERT INTO Friendship (user_id, friend_id, status) VALUES (%s,%s,'Accepted') ON DUPLICATE KEY UPDATE status='Accepted';", (int(user_id), int(req["user_id"])))
                            st.success(f"🎉 You are now friends with {req['username']}!")
                            st.rerun()

        st.markdown("---")
        st.subheader("➕ Send Friend Request")
        all_users = safe_read_sql("SELECT user_id, username FROM User WHERE user_id != %s;", conn, params=(int(user_id),))
        if not all_users.empty:
            friend_choice = st.selectbox("Select a user", all_users["username"].tolist())
            if st.button("Send Request"):
                friend_id = int(all_users[all_users["username"] == friend_choice]["user_id"].iloc[0])
                if safe_execute(conn, """
                    INSERT INTO Friendship (user_id, friend_id, status)
                    VALUES (%s, %s, 'Pending')
                    ON DUPLICATE KEY UPDATE status='Pending';
                """, (int(user_id), int(friend_id))):
                    st.success(f"Request sent to {friend_choice}!")
                    st.rerun()
        else:
            st.info("No other users available.")
    finally:
        conn.close()

# -------------------------
# Game Collection
# -------------------------
elif choice == "Game Collection":
    st.header("🎮 My Game Collection")
    conn = get_connection()
    try:
        user_id = get_user_id()
        if user_id is None:
            st.error("User not found.")
            st.stop()

        collection_df = safe_read_sql("""
            SELECT g.title AS Game, c.status, c.hours_played, c.rating, c.added_date
            FROM GameCollection c
            JOIN Game g ON c.game_id = g.game_id
            WHERE c.user_id = %s;
        """, conn, params=(int(user_id),))
        if collection_df.empty:
            st.info("No games in your collection yet. Add some below 👇")
        else:
            st.dataframe(collection_df, use_container_width=True)

        st.markdown("---")
        st.subheader("➕ Add Game to Your Collection")
        games = safe_read_sql("SELECT game_id, title FROM Game;", conn)
        if games.empty:
            st.info("No games available to add.")
        else:
            selected_title = st.selectbox("Select Game", games["title"].tolist())
            status = st.selectbox("Status", ["Playing", "Completed", "Wishlist", "Dropped", "On Hold"])
            hours = st.number_input("Hours Played", min_value=0.0, step=0.5)
            rating = st.number_input("Rating (1-10)", min_value=0.0, max_value=10.0, step=0.1)
            if st.button("Add to Collection"):
                game_id = int(games[games["title"] == selected_title]["game_id"].iloc[0])
                if safe_execute(conn, """
                    INSERT INTO GameCollection (user_id, game_id, status, hours_played, rating)
                    VALUES (%s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE status=%s, hours_played=%s, rating=%s;
                """, (int(user_id), int(game_id), status, float(hours), float(rating), status, float(hours), float(rating))):
                    st.success(f"🎮 '{selected_title}' added/updated successfully!")
                    st.rerun()
    finally:
        conn.close()


# -------------------------
# Add Money Page
# -------------------------
elif choice == "Add Money":
    st.header("💵 Add Money to Wallet")

    uid = get_user_id()
    if uid is None:
        st.error("User not logged in.")
        st.stop()

    conn = get_connection()
    add_amt = st.number_input("Enter amount to add", min_value=1.0, step=1.0)

    if st.button("Add Money"):
        if safe_execute(conn,
            "UPDATE User SET wallet_balance = wallet_balance + %s WHERE user_id=%s",
            (float(add_amt), int(uid))
        ):
            st.success(f"Successfully added ₹{add_amt} to your wallet!")
            st.rerun()

    conn.close()



# -------------------------
# Cart Page
# -------------------------
# -------------------------
# Cart
# -------------------------
# -------------------------
# Cart
# -------------------------
elif choice == "Cart":
    st.header("🛒 Your Cart")

    uid = get_user_id()
    if uid is None:
        st.error("User not found.")
        st.stop()

    conn = get_connection()
    try:
        # Fetch cart items
        cart_df = safe_read_sql("""
            SELECT c.cart_id, g.title, g.price, c.item_id AS game_id
            FROM Cart c
            JOIN Game g ON c.item_id = g.game_id
            WHERE c.user_id=%s AND c.item_type='Game';
        """, conn, params=(uid,))

        if cart_df.empty:
            st.info("Your cart is empty 🛒")
            st.stop()

        st.dataframe(cart_df, use_container_width=True)

        total_price = float(cart_df["price"].sum())
        st.subheader(f"💰 Total: ₹{total_price}")

        # BUY ALL
        if st.button("Buy All"):
            # Fetch wallet
            wallet_df = safe_read_sql(
                "SELECT wallet_balance FROM User WHERE user_id=%s",
                conn, params=(uid,)
            )

            wallet = float(wallet_df["wallet_balance"].iloc[0]) if not wallet_df.empty else 0.0

            if wallet < total_price:
                st.error("❌ Not enough balance.")
                st.stop()

            # Deduct wallet
            safe_execute(conn,
                "UPDATE User SET wallet_balance = wallet_balance - %s WHERE user_id=%s",
                (total_price, uid)
            )

            # Add purchases + add to game collection
            for _, row in cart_df.iterrows():
                gid = int(row["game_id"])
                price = float(row["price"])

                safe_execute(conn, """
                    INSERT INTO Purchase (user_id, item_type, item_id, price)
                    VALUES (%s, 'Game', %s, %s)
                """, (uid, gid, price))

                safe_execute(conn, """
                    INSERT INTO GameCollection (user_id, game_id, status)
                    VALUES (%s, %s, 'Wishlist')
                    ON DUPLICATE KEY UPDATE status='Wishlist'
                """, (uid, gid))

            # Clear cart
            safe_execute(conn, "DELETE FROM Cart WHERE user_id=%s", (uid,))

            st.success("🎉 Purchase successful! Items added to your collection.")
            st.rerun()

    finally:
        conn.close()



# -------------------------
# About
# -------------------------
elif choice == "About":
    st.markdown("""
        <h1 style='text-align:center; color:#00BFFF; font-family:Orbitron; font-size:42px; text-shadow:0 0 20px #00BFFF;'>ℹ About GameVerse+</h1>

        <div style="
            background-color:#0d1522;
            padding:25px;
            border-radius:12px;
            box-shadow:0 0 25px rgba(0,191,255,0.25);
            color:#e6e6e6;
            font-size:18px;
            line-height:1.7;
        ">
        
        <h2 style='color:#00BFFF;'>🎮 What is GameVerse+?</h2>
        <p>
            <b>GameVerse+</b> is a fully functional 
            <b>Game Management, Analytics & Achievement Tracking Platform</b>  
            built using <b>Python (Streamlit) + MySQL</b>.  
            It provides a seamless ecosystem for players, admins, and game communities.
        </p>

        <h2 style='color:#00BFFF;'>🚀 Key Features</h2>
        <ul>
            <li><b>🕹 Game Library</b> — Add, manage, and explore 50+ games.</li>
            <li><b>🏆 Achievements System</b> — Unlockable milestones with leaderboard points.</li>
            <li><b>💰 Wallet System</b> — In-app money system for buying games.</li>
            <li><b>🛒 Cart System</b> — Add/remove games & checkout securely.</li>
            <li><b>📥 Auto-Collection</b> — Purchased games automatically added to user library.</li>
            <li><b>📊 Analytics Dashboard</b> — Most played games, player stats & visual insights.</li>
            <li><b>👥 Users & Roles</b> — Player/Admin/Moderator with secure login.</li>
            <li><b>💬 Reviews & Comments</b> — Community game discussions.</li>
            <li><b>🔔 Notifications</b> — Purchases, achievements & friend requests.</li>
            <li><b>🤝 Friends System</b> — Send, accept, and manage friend requests.</li>
            <li><b>🏅 Leaderboard</b> — Ranks based on achievements & points.</li>
        </ul>

        <h2 style='color:#00BFFF;'>🛠 Technologies Used</h2>
        <ul>
            <li><b>Frontend & UI:</b> Streamlit</li>
            <li><b>Backend:</b> Python</li>
            <li><b>Database:</b> MySQL (with triggers, constraints, joins)</li>
            <li><b>Visualization:</b> Plotly Charts</li>
            <li><b>Security:</b> SHA2 password hashing</li>
        </ul>

        <h2 style='color:#00BFFF;'>🗂 Database Features</h2>
        <ul>
            <li>25+ normalized tables (3NF)</li>
            <li>Triggers for purchases, leaderboards & wallet handling</li>
            <li>Auto-updating user game collection</li>
            <li>Many-to-many relations: Genre, Platform, Friends</li>
            <li>Accurate referential integrity</li>
        </ul>

        <h2 style='color:#00BFFF;'>🏛 Project Purpose</h2>
        <p>
            This project was developed as a <b>DBMS + Full Stack Application</b>  
            demonstrating strong knowledge in:
        </p>
        <ul>
            <li>Database design & normalization</li>
            <li>Backend programming</li>
            <li>User authentication systems</li>
            <li>E-commerce workflows (wallet, purchases, cart)</li>
            <li>Data analytics and visualization</li>
        </ul>

        <h2 style='color:#00BFFF;'>👨‍💻 Developers & Contributors</h2>
        <p>
            Built with ❤️ by <b>Haneesh Mekala, Yogi Abhilash, Jaswanth, Saketh, Umesh, Tanoj, Bhargav</b>  
            — A complete end-to-end implementation showcasing DBMS, backend logic, UI design, and real-world system behavior.
        </p>

        <br>
        <p style='text-align:center; color:#00BFFF; font-size:22px; font-weight:bold;'>
            🚀 GameVerse+ — Where Gaming Meets Analytics  
        </p>

        </div>
    """, unsafe_allow_html=True)


