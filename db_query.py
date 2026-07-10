import sqlite3
import os

db_path = r"c:\Users\ACER\my_pro\itqan_academy_backend\db.sqlite3"
print("DB Path exists:", os.path.exists(db_path))

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # List tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [r[0] for r in cursor.fetchall()]
    print("Tables in database:", tables)
    
    if "academy_circle" in tables:
        cursor.execute("SELECT * FROM academy_circle;")
        circles = cursor.fetchall()
        print("Circles count:", len(circles))
        print("Circles data:")
        for c in circles:
            print(c)
    else:
        print("academy_circle table not found")
        
    conn.close()
except Exception as e:
    print("Error reading SQLite DB:", e)
