import os
import mysql.connector

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

def get_connection():
    """
    Establish and return a connection to the MySQL database.
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", "Tysdt324#"),
            database=os.getenv("DB_NAME", "gameverse_plus")
        )

        if connection.is_connected():
            print("✅ Connected to MySQL successfully.")
        return connection

    except mysql.connector.Error as e:
        print(f"❌ Connection error: {e}")
        return None
