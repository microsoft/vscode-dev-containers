#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

#%%
import os
import traceback

import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import psycopg2

# Connect to the database
try:
    pg_user = os.environ['POSTGRES_USER']
    pg_password = os.environ['POSTGRES_PASSWORD']
    pg_db = os.environ['POSTGRES_DB']
    pg_host = os.environ['POSTGRES_HOST']
    conn = psycopg2.connect("dbname='{pg_db}' user='{pg_user}' host='{pg_host}' password='{pg_password}'".format(
        pg_db=pg_db,
        pg_user=pg_user,
        pg_host=pg_host,
        pg_password=pg_password
    ))
except Exception:
    print("Unable to connect to the database")
    traceback.print_exc()
    exit(1)

# Execute a query
try:
    with conn.cursor() as cur:
        cur.execute("""SELECT COUNT(1) from pg_database WHERE datname='postgres'""")
        rows = cur.fetchone()

    if rows[0]==1:
        print("DATABASE CONNECTED")
    else:
        print("ERROR FINDING DATABASE")
        exit(1)
except Exception:
    print("ERROR EXECUTING DATABASE QUERY")
    traceback.print_exc()
    exit(1)
finally:
    conn.close()

# Data for plotting
t = np.arange(0.0, 2.0, 0.01)
s = 1 + np.sin(2 * np.pi * t)

fig, ax = plt.subplots()
ax.plot(t, s)

ax.set(xlabel='time (s)', ylabel='voltage (mV)',
       title='About as simple as it gets, folks')
ax.grid()

fig.savefig("plot.png")
plt.show()

print('Open test-project/plot.png to see the result!')
