import pandas
import sqlite3
import os

if os.path.exists('./MusicStore.db'):
    os.remove('./MusicStore.db')

con = sqlite3.connect('./MusicStore.db')

data = pandas.read_csv('./hw5_original.csv')
data.to_sql('hw5_original', con, if_exists='replace')
