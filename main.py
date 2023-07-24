from urllib.request import urlopen
from bs4 import BeautifulSoup
import pandas as pd

url = "https://www.baseball-reference.com/teams/MIL/bat.shtml"

html = urlopen(url)

soup = BeautifulSoup(html, features='html.parser')

soup.findAll('tr', limit = 2)

headers = [th.getText() for th in soup.findAll('tr', limit = 2) [0].findAll('th')]
print(headers)

headers = headers[1:]
headers

rows = soup.findAll('tr')[1:]
print(len(rows))
player_stats = [[td.getText() for td in rows [i].findAll('td')] 
    for i in range (len(rows))]
print(player_stats)


stats = pd.DataFrame(player_stats,columns = headers)

print(stats)

stats.to_csv('Brewers_Batting_Stats.csv')