"""Script to import any number of JSON formatted files into a db"""

import sqlite3
import requests
from tqdm import tqdm
from sqlite3 import Error
from operator import itemgetter
from collections import defaultdict

files = [
    "https://raw.githubusercontent.com/taivop/joke-dataset/master/wocka.json",
    "https://raw.githubusercontent.com/taivop/joke-dataset/master/stupidstuff.json",
    "https://raw.githubusercontent.com/taivop/joke-dataset/master/reddit_jokes.json"
]


db = None


def create_connection(db_file="database.db"):
    """ create a database connection to a SQLite database """
    conn = None
    global db
    try:
        conn = sqlite3.connect(db_file)
        print(f"✅ SQLITE: {sqlite3.version}")
    except Error as e:
        print(e)
    finally:
        if conn:
            db = conn
            return db


def create_table():
    """Create the jokes database given the common schema"""

    global db

    cursor = db.cursor()

    sql_command = '''CREATE TABLE IF NOT EXISTS
    JOKES(
       ID INTEGER PRIMARY KEY,
       TITLE TEXT,
       BODY TEXT,
       CATEGORY TEXT,
       SCORE REAL
    )'''

    cursor.execute(sql_command)
    print("✅ Table exists/created!")
    return


def insert_joke_in_db(joke, p_bar):
    """insert a joke, check for duplicate body, multiprocess"""

    global db
    try:
        cursor = db.cursor()
        title, body, category, score = itemgetter('title', 'body', 'category', 'score')(joke)

        title = title.encode('utf-8', 'replace').decode() if title else title
        body = body.encode('utf-8', 'replace').decode() if body else body
        category = category.encode('utf-8', 'replace').decode() if category else category

        if body == "":
            return

        # check duplicates
        sql_select_query = """SELECT * FROM JOKES WHERE BODY = ?"""
        cursor.execute(sql_select_query, (body,))
        rows = cursor.fetchall()

        if len(rows):
            p_bar.write("‼️ skipping duplicates..", end='\r')
            return

        query_insert = '''INSERT INTO JOKES(TITLE, BODY, CATEGORY, SCORE) VALUES(?, ?, ?, ?);'''

        data = (title, body, category, score)
        cursor.execute(query_insert, data)

    except Error as e:
        print(e)

    finally:
        db.commit()
        cursor.close()
    return


def make_joke_object(joke_obj):
    """process each json object for the db"""

    joke = defaultdict(object)
    schema_keys = ['title', 'body', 'category', 'score']

    missing_keys = list(set(schema_keys) - set(joke_obj.keys()))

    for s_key in schema_keys:
        if s_key in missing_keys:
            joke[s_key] = None
        else:
            joke[s_key] = joke_obj[s_key]

    return joke


def json_to_sqlite(f):
    """insert JSON @ URL into the sqlite"""

    with requests.get(f, stream=True) as res:
        jokes = res.json()
        length = len(jokes)
        print(f"🗄 Processing: {f}")

        with tqdm(total=length, unit_scale=False, initial=0, ascii=False, colour='YELLOW') as p_bar:
            for j in jokes:
                row = make_joke_object(j)
                insert_joke_in_db(row, p_bar)
                p_bar.update(1)


if __name__ == '__main__':
    create_connection("jokes2.db")
    create_table()

    for file in files:
        json_to_sqlite(file)

    db.close()
