import psycopg2
import datetime

con = psycopg2.connect(
    database="fced20",
    user="fced20",
    password="kunoichi15",
    host="dbm.fe.up.pt",
    options="-c search_path='Trabalho'"
    )

print("###################################################")
print("### Welcome to the COVID-19 DataBase Interface! ###")
print("###################################################")
print("It was designed By Pedro Caracas, Augusto Agostini, Júlio Oliveira and Alvimar Lousada \n")

print('\n') 
print('What do you wish to do?\n')
print('Option a: press 1 plus enter to add new data')
print('Option b: press 2 plus enter to delete some data')
print('Option c: press any other letter or number plus enter to exit the interface\n')
mode = str(input())

cur = con.cursor()

if mode == '1':
        print('From which country is the info you want to update? Press enter after typing')
        country  = str(input())

        print('From wWhich state is the info you want to update? Press enter after typing')
        print('PS. if you do not have this information press enter')
        state  = str(input())
    
        print('Type the day you want to update in the YYYY-MM-DD format. Press enter after typing')
        day = str(input())
    
        print(f"How many confirmed cases where registered in {country} -- {day} ? Press enter after typing")
        cases = str(input())

        cur.execute(f'''
        INSERT INTO "Trabalho"."cases" (day, state, country, ncases)
        VALUES ('{day}', '{state}', '{country}', '{cases}');
        ''')
        con.commit()

elif mode == '2':
        print('For which country do you want to delete info? Press enter after typing')
        country  = str(input())

        if country in ['Australia', 'China', 'Canada', 'Denmark', 'France', 'Netherlands', 'United Kindom']:
            print('For which state do you want to delete info? Press enter after typing')
            print(f'PS. if you do not know it press N and then all the info about {country} for a given date will be deleted')
            state  = str(input())
        
        else:
            pass

        print('Type the date for which you want to delete the info in the YYYY-MM-DD format. Press enter after typing')
        print(f'PS. if you do not know it press N and then the info for all days will be deleted')
        day = str(input())

        if (state=='N' and day=='N'):
            cur.execute(f'''
                DELETE FROM "Trabalho"."cases"
                WHERE(country={country});
            ''')
            con.commit()

        elif state=='N':
            cur.execute(f'''
                DELETE FROM "Trabalho"."cases"
                WHERE(country={country} AND day={day});
            ''')
            con.commit()

        elif day=='N':
            cur.execute(f'''
                DELETE FROM "Trabalho"."cases"
                WHERE(country={country} AND state={state});
            ''')
            con.commit()

        else:
            cur.execute(f'''
                DELETE FROM "Trabalho"."cases"
                WHERE(country={country} AND state={state} AND day={day});
            ''')
            con.commit()

else:
        print("\n You have just exited the COVID-19 DataBase Interface. Goodbye!")
        con.close()
        exit()