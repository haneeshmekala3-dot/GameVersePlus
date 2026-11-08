import streamlit as st
import hashlib
import pandas as pd
from db_connection import get_connection

# Hashing function
def make_hash(password):
    return hashlib.sha256(password.encode()).hexdigest()

# Verify password
def check_hash(password, hashed):
    return make_hash(password) == hashed

# Check if user exists
def user_exists(username):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT username FROM User WHERE username=%s", (username,))
    result = cur.fetchone()
    conn.close()
    return result is not None

# Signup user
def signup_user(username, email, password, country):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO User (username, email, password_hash, country, role_id)
        VALUES (%s, %s, %s, %s, %s)
    """, (username, email, make_hash(password), country, 1))
    conn.commit()
    conn.close()

# Login user
def login_user(username, password):
    conn = get_connection()
    df = pd.read_sql("""
        SELECT user_id, username, email, password_hash, role_id
        FROM User
        WHERE username = %s
    """, conn, params=(username,))
    conn.close()

    if not df.empty and check_hash(password, df['password_hash'].iloc[0]):
        return df.iloc[0]
    else:
     return None