import requests
import xml.etree.ElementTree as ET
import pprint

encoding = 'LVAUeByftALQomcWcJcM3yWFXCPlLRN94Ca5FzqsezuzZy7Pr2NdCP1LejoNBBvDfAE56ChqSAOuPaw7r9x9ZA%3D%3D'
decoding = 'LVAUeByftALQomcWcJcM3yWFXCPlLRN94Ca5FzqsezuzZy7Pr2NdCP1LejoNBBvDfAE56ChqSAOuPaw7r9x9ZA=='
url = 'http://apis.data.go.kr/5530000/hs-coronavirus-coronic/getHsCoronavirusCoronic'
params = {'serviceKey' : decoding, 'pageNo' : 1, 'numOfRows' : 100}

response = requests.get(url, params=params)
content = response.text
pp = pprint.PrettyPrinter(indent=4)
print(pp.pprint(content))

### xml을 DataFrame으로 변환하기 ###
from os import name
import xml.etree.ElementTree as et
import pandas as pd
import bs4
from lxml import html
from urllib.parse import urlencode, quote_plus, unquote

xml_obj = bs4.BeautifulSoup(content)
rows = xml_obj.findAll('item')
print(rows)

# 각 행의 컬럼, 이름, 값을 가지는 리스트 만들기
row_list = [] # 행값
name_list = [] # 열이름값
value_list = [] #데이터값

# xml 안의 데이터 수집
for i in range(0, len(rows)):
    columns = rows[i].find_all()
    #첫째 행 데이터 수집
    for j in range(0,len(columns)):
        if i ==0:
            # 컬럼 이름 값 저장
            name_list.append(columns[j].name)
        # 컬럼의 각 데이터 값 저장
        value_list.append(columns[j].text)
    # 각 행의 value값 전체 저장
    row_list.append(value_list)
    # 데이터 리스트 값 초기화
    value_list=[]
    
    
corona_df = pd.DataFrame(row_list, columns=name_list)
print(corona_df.head(19))
corona_df = pd.DataFrame(row_list)
corona_df