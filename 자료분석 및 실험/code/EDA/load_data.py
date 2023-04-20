from matplotlib import font_manager, rc
import pandas as pd
import os

pathdir = '../../data'

# Load data
df = pd.read_csv(pathdir + '/traindata.csv', encoding='utf-8')
df.info()


# matplot에서 한글 깨짐 방지 코드
font_path = "C:/Windows/Fonts/NGULIM.TTF"
font = font_manager.FontProperties(fname=font_path).get_name()
rc('font', family=font)


# 일별 구별 따릉이 대여량
import plotly.express as px

## 광진구 따릉이 수요량
px.line(df['광진구'], labels = {'index' : '날짜', 'value' : '대여량', 'variable' : '구'}, title = '광진구 따릉이 수요량')

## 성동구 따릉이 수요량
px.line(df['성동구'], labels = {'index' : '날짜', 'value' : '대여량', 'variable' : '구'}, title = '성동구 따릉이 수요량')

## 동대문구 따릉이 수요량
px.line(df['동대문구'], labels = {'index' : '날짜', 'value' : '대여량', 'variable' : '구'}, title = '동대문구 따릉이 수요량')

## 중랑구 따릉이 수요량
px.line(df['중랑구'], labels = {'index' : '날짜', 'value' : '대여량', 'variable' : '구'}, title = '중랑구 따릉이 수요량')

## 날짜에 대한 회귀분석을 통해 전체적인 패턴을 파악해보자
import statsmodels.api as sm
sm.OLS(df['광진구'], sm.add_constant(df.index)).fit().summary() # p-value가 중요한게 아님(긴 기간에 대한 패턴 파악이 목표임)

import matplotlib.pyplot as pl
ax  = plt.subplot()
ax.plot(df.index, df['광진구'], 'o')s
ax.plot(df.index, 0.0047*df.index + 2.9962, color = 'red')
ax.set_title('광진구 따릉이 수요량')
plt.show()

## prophet을 이용한 시계열 기본 예측 (toy model)
import prophet


## prophet 형태에 맞게 데이터 테이블 수정
df

m = Prophet()
m.fit(df_prophet)