import unittest
import os
import sys

# Ensure project root is in sys.path
sys.path.insert(0, r"C:\GameVersePlus")

from db_connection import get_connection
from auth import login_user, user_exists, check_hash, make_hash
import pandas as pd

class TestGameVersePlusComponents(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Configure connection to cloud database for end-to-end testing
        os.environ["DB_HOST"] = "gateway01.ap-northeast-1.prod.aws.tidbcloud.com"
        os.environ["DB_PORT"] = "4000"
        os.environ["DB_USER"] = "pbEDom2vrDXBZRv.root"
        os.environ["DB_PASSWORD"] = "1tEefXE5nY9QErn3"
        os.environ["DB_NAME"] = "gameverse_plus"
        os.environ["DB_SSL"] = "true"

        cls.conn = get_connection()
        assert cls.conn is not None, "Failed to connect to TiDB Cloud database"

    @classmethod
    def tearDownClass(cls):
        if cls.conn and cls.conn.is_connected():
            cls.conn.close()

    def test_01_db_connection(self):
        """Test database connection is alive and healthy."""
        self.assertTrue(self.conn.is_connected())

    def test_02_auth_admin_login(self):
        """Test Admin login with credentials."""
        user = login_user("AdminUser", "admin123")
        self.assertIsNotNone(user, "Admin login failed")
        self.assertEqual(user["username"], "AdminUser")
        self.assertEqual(int(user["role_id"]), 2)

    def test_03_auth_player_login(self):
        """Test Player login with credentials."""
        user = login_user("Haneesh", "12345")
        self.assertIsNotNone(user, "Player login failed")
        self.assertEqual(user["username"], "Haneesh")
        self.assertEqual(int(user["role_id"]), 1)

    def test_04_auth_invalid_credentials(self):
        """Test login fails with incorrect password."""
        user = login_user("AdminUser", "wrongpassword")
        self.assertIsNone(user)

    def test_05_auth_user_exists(self):
        """Test user existence check."""
        self.assertTrue(user_exists("Haneesh"))
        self.assertTrue(user_exists("AdminUser"))
        self.assertFalse(user_exists("NonExistentUserXYZ999"))

    def test_06_dashboard_queries(self):
        """Test Dashboard queries (counts, metrics, genre distribution)."""
        games_df = pd.read_sql("SELECT COUNT(*) AS count FROM Game", self.conn)
        self.assertGreater(int(games_df["count"].iloc[0]), 0)

        users_df = pd.read_sql("SELECT COUNT(*) AS count FROM User", self.conn)
        self.assertGreater(int(users_df["count"].iloc[0]), 0)

        genre_df = pd.read_sql("""
            SELECT g.name AS Genre, COUNT(gg.game_id) AS GameCount
            FROM Genre g
            JOIN GameGenre gg ON g.genre_id = gg.genre_id
            GROUP BY g.name;
        """, self.conn)
        self.assertFalse(genre_df.empty)

    def test_07_games_library_and_relations(self):
        """Test Games library query with Developer and Publisher joins."""
        df = pd.read_sql("""
            SELECT g.game_id, g.title, d.name AS Developer, p.name AS Publisher,
                   g.price, g.release_date
            FROM Game g
            LEFT JOIN Developer d ON g.developer_id = d.developer_id
            LEFT JOIN Publisher p ON g.publisher_id = p.publisher_id;
        """, self.conn)
        self.assertFalse(df.empty)
        self.assertGreaterEqual(len(df), 50, "Expected at least 50 games in library")

    def test_08_wallet_and_user_balance(self):
        """Test wallet balance query for users."""
        df = pd.read_sql("SELECT user_id, wallet_balance FROM User WHERE username='Haneesh'", self.conn)
        self.assertFalse(df.empty)
        wallet = float(df["wallet_balance"].iloc[0])
        self.assertGreaterEqual(wallet, 0.0)

    def test_09_leaderboard_query(self):
        """Test Leaderboard rankings query."""
        df = pd.read_sql("""
            SELECT u.username, l.total_points, l.total_achievements, l.rank_position
            FROM Leaderboard l
            JOIN User u ON l.user_id = u.user_id
            ORDER BY l.total_points DESC;
        """, self.conn)
        self.assertFalse(df.empty)

    def test_10_reviews_and_comments(self):
        """Test Reviews and Comments queries."""
        reviews = pd.read_sql("""
            SELECT r.review_id, u.username AS Reviewer, g.title AS Game, 
                   r.rating, r.review_text, r.review_date
            FROM Review r
            JOIN User u ON r.user_id = u.user_id
            JOIN Game g ON r.game_id = g.game_id
            ORDER BY r.review_date DESC;
        """, self.conn)
        self.assertFalse(reviews.empty)

        comments = pd.read_sql("SELECT COUNT(*) AS count FROM Comment", self.conn)
        self.assertGreater(int(comments["count"].iloc[0]), 0)

    def test_11_achievements_system(self):
        """Test Achievements table query."""
        ach_df = pd.read_sql("SELECT COUNT(*) AS count FROM Achievement", self.conn)
        self.assertGreaterEqual(int(ach_df["count"].iloc[0]), 100)

    def test_12_notifications_system(self):
        """Test Notifications system query."""
        notif_df = pd.read_sql("SELECT * FROM Notification WHERE user_id=1", self.conn)
        self.assertFalse(notif_df.empty)

if __name__ == "__main__":
    unittest.main()

