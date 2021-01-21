import psycopg2
import csv

# CREATE THE DB CONNECTION CALLED "CON"
con = psycopg2.connect(
    database="fced20",
    user="fced20",
    password="kunoichi15",
    host="dbm.fe.up.pt",
    options="-c search_path='Trabalho'" #connect refered to schema

)

# CREATE A CURSOR
cur = con.cursor()

# CUR EXECUTES SQL COMMANDS (queries) IN PYTHON
cur.execute(f'''

DELETE  FROM "Trabalho"."cases"

''')


with open('formatted_covid_data.csv', 'r') as cases:
    data = csv.reader(cases)
    for row in data:
        print(row)
        cur.execute(f'''

        INSERT INTO "Trabalho"."cases" (day, state, country, ncases)
        VALUES ('{row[0]}', '{row[1]}', '{row[2]}', '{row[3]}')

    
        
        ''')

# COMMIT WRITES THE ABOVE WRITTEN CODE IN THE DB
con.commit() 

# CLOSE TURN OFF THE PYTHON-DB CONNECTION
con.close()
