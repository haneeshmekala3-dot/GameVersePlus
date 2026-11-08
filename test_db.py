from db_connection import get_connection

def test_connection():
    conn = get_connection()
    if conn:
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()

        print("\n📋 Tables inside your 'gameverse_plus' database:")
        for table in tables:
            print("-", table[0])

        conn.close()
    else:
        print("⚠️ Could not connect to MySQL database.")

if __name__ == "__main__":
    test_connection()
