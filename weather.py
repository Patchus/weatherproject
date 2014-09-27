import urllib2
import json
import pandas as pd
import datetime as dt
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEImage import MIMEImage
from subprocess import call
import smtplib
import os
import glob
import sys

cities_interests = ['NY/New_York','DC/Washington','UK/Liverpool','GA/Alpharetta','NJ/Toms_River','AU/Sydney']

daily_reads = []
for city in cities_interests:    
    f = urllib2.urlopen('http://api.wunderground.com/api/ac91bb3fd50992d4/forecast10day/q/'+city+'.json')
    json_string = f.read()
    parsed_json = json.loads(json_string)
    for day in parsed_json['forecast']['simpleforecast']['forecastday']:
        daily_reads.append({'date':str(day['date']['year'])+'-'+str(day['date']['month']).zfill(2)+'-'+str(day['date']['day']).zfill(2),
                      'high_f': day['high']['fahrenheit'],
                      'high_c': day['high']['celsius'],
                      'low_f': day['low']['fahrenheit'],
                      'low_c': day['low']['celsius'],
                      'rain_in' : day['qpf_allday']['in'],
                      'rain_mm' : day['qpf_allday']['mm'],
                      'As_of_date':dt.datetime.now().strftime('%Y-%m-%d'),
                      'city': city.split('/')[1]})

dailyread_df = pd.DataFrame(daily_reads)

message = 'City     '.ljust(10)+' High  '+'Low '+ 'Rain     '+'\n'
for i in range(0,len(dailyread_df)):
    if dailyread_df['date'][i] == dt.datetime.now().strftime('%Y-%m-%d'):
        message += dailyread_df['city'][i].ljust(10)+' '+dailyread_df['high_f'][i].ljust(6)+dailyread_df['low_f'][i].ljust(4)+str(dailyread_df['rain_in'][i])+'\n'+'\n'
        
message += '\n'+'--------- Metric-------'+'\n'
message += 'City     '.ljust(10)+' High  '+'Low '+ 'Rain     '+'\n'
for i in range(0,len(dailyread_df)):
    if dailyread_df['date'][i] == dt.datetime.now().strftime('%Y-%m-%d'):
        message += dailyread_df['city'][i].ljust(10)+' '+dailyread_df['high_c'][i].ljust(6)+dailyread_df['low_c'][i].ljust(4)+str(dailyread_df['rain_mm'][i])+'\n'+'\n'

# Run the External Plotting Portion
dailyread_df.to_csv('weather_daily.csv',headers=False)
os.system('cat weather_daily.csv >> vintage_weather.csv')
os.system('R CMD BATCH weather_plots.R')


pics = glob.glob('*.png')

fromaddr = str(sys.argv[1])+'gmail.com'
toaddr = str(sys.argv[3])
msg = MIMEMultipart()
msg['From'] = fromaddr
msg['To'] = toaddr
msg['Subject'] = dt.datetime.now().strftime('%d-%m-%Y')+' Weather'

body = message
msg.attach(MIMEText(body, 'plain'))
msg.attach(MIMEImage(file(pics[0]).read()))

server = smtplib.SMTP('smtp.gmail.com', 587)
server.ehlo()
server.starttls()
server.ehlo()
server.login(str(sys.argv[1]), str(sys.argv[2]))
text = msg.as_string()
server.sendmail(fromaddr, toaddr, text)

os.remove(pics[0])


### Now create the .json for the webapp

import pandas as pd
from datetime import datetime as dt

weather = pd.read_csv('weather_daily.csv')

weather = pd.read_csv('weather_daily.csv')
weather = weather[['city','date','high_f']].drop_duplicates()
nycd = {}

cities = weather['city'].drop_duplicates()

for city in cities:
    nycd[city] = list(weather['high_f'][weather['city']==city])
    
nycd['dates'] = []
for date in list(weather['date'].drop_duplicates()[0:10]):
    nycd['dates'].append(dt.strptime(date, "%Y-%m-%d"))

nycd_df = pd.DataFrame(nycd)
nycd_df.index = nycd_df.dates
nycd_df = nycd_df.drop('dates',1)
import vincent 
#vincent.core.initialize_notebook()

line = vincent.Line(nycd_df)
line.axis_titles(x='Date', y='Tempature F')
line.legend(title='Cities')
line.scales[1].domain_max = max(nycd_df.max())+10
line.scales[1].domain_min = min(nycd_df.min())-10
line.scales[1].grammar()
line.scales[1].zero = False
line.to_json('/var/www/html/weather.json')
 
