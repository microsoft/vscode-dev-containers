#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

#%%
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import psycopg2

try:
    conn = psycopg2.connect("dbname='postgres' user='postgres' host='localhost' password='postgres'")
except:
    print("Unable to connect to the database")
    exit()

try:
    with conn.cursor() as cur:
        cur.execute("""SELECT COUNT(1) from pg_database WHERE datname='postgres'""")
        rows = cur.fetchone()

    if(rows[0]==1):
        print("DATABASE CONNECTED")
    else:
        print("ERROR FINDING DATABASE")
finally:
    conn.close()

# # Data for plotting
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
