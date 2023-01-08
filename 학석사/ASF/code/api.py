import requests
import pprint
import json
url = 'http://211.237.50.150:7080/openapi/sample/xml/Grid_20220824000000000641_1/1/5'
params = {'API_KEY' : '3c178f55c7f08e0e5b52ae5b767a037f8b0efb6af9089d9f4083daf9ba9377a4',
          'TYPE' : 'json',
          'API_URL' : url,
          'START_INDEX' : 1,
          'END_INDEX' : 100}

response = requests.get(url, params=params)

jsonData = None
if response.status_code == 200:
    jsonData = response.json()
    print(jsonData)