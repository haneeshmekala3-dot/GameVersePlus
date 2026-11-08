import os
import mysql.connector

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

def get_secret(key, default=""):
    """Fetch configuration from Streamlit secrets, os.environ, or fallback to default."""
    try:
        import streamlit as st
        if key in st.secrets:
            return st.secrets[key]
        if "mysql" in st.secrets and key in st.secrets["mysql"]:
            return st.secrets["mysql"][key]
    except Exception:
        pass
    return os.getenv(key, default)

def get_connection():
    """
    Establish and return a connection to the MySQL database.
    Supports both local instances and cloud-hosted databases (with custom port & SSL).
    """
    host = get_secret("DB_HOST", "localhost")
    user = get_secret("DB_USER", "root")
    password = get_secret("DB_PASSWORD", "Tysdt324#")
    database = get_secret("DB_NAME", "gameverse_plus")
    port_val = get_secret("DB_PORT", "3306")

    try:
        port = int(port_val)
    except (ValueError, TypeError):
        port = 3306

    connect_kwargs = {
        "host": host,
        "user": user,
        "password": password,
        "database": database,
        "port": port
    }

    # Enable SSL when configured or when connecting to cloud MySQL
    ssl_setting = get_secret("DB_SSL", "").lower()
    if ssl_setting in ("true", "1", "yes") or host not in ("localhost", "127.0.0.1"):
        connect_kwargs["ssl_disabled"] = False

    try:
        connection = mysql.connector.connect(**connect_kwargs)
        if connection.is_connected():
            return connection
    except mysql.connector.Error as e:
        print(f"❌ Connection error: {e}")
        return None
