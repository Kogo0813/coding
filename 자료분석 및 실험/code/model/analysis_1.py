# package load
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import plotly_express as px
from prophet import Prophet


# 기상 data load
weather_1 = pd.read_csv('../../data/weather/peak_2018.csv')
weather_2 = pd.read_csv('../../data/weather/peak_2019.csv')
weather_3 = pd.read_csv('../../data/weather/peak_2020.csv')

test_weather = pd.read_csv('../../data/weather/peak_2021.csv')

# 따릉이 수요량 data load
demand = pd.read_csv('../../data/traindata.csv')
demand

# 2020년 데이터 + 확진자
df = pd.read_csv('../../data/df_with_infected.csv', index_col = 0)
df

# 1. 강수량이 따릉이 수요량에 영향을 주는지를 확인하고자 한다.

## 1-(1) 전체 기간에 대해서 확인해보자
df['rainy'] = np.where(df['rain'] > 0.05 , 1, 0)
df.date = pd.to_datetime(df.date)
df.query('date >= "2020-07-01" & date <= "2020-08-31"')
df.iloc[163:225, 8] = 1
df.rename(columns = {'snow' : 'bool_date'}, inplace = True)
df['mul'] = df.rainy * df.bool_date
df


## 변수의 유의미성 확인하기
import statsmodels.api as sm
result_all = sm.OLS.from_formula('광진구 ~ rainy + bool_date ', data = df).fit()
result_all.summary() # 전체가간에 대해서 봤을 때는 rainy변수만 유의함 => 구간을 나누어서 봐야할듯


## 4개월 단위로 나누어서 확인해보자
plt.rc('font', family = 'Malgun Gothic')
df[['광진구', 'rain']].plot()
plt.show()

# 4개월 단위 분리
df_1 = df[:115]; df_2 = df[115: 115+116];df_3 = df[115+116:];df_3


# 첫번째 구간에 대한 회귀분석
sm.OLS.from_formula('광진구 ~ rainy + bool_date ', data = df_1).fit().summary() # 상호작용 효과만 유의하지 않음

# 두번째 구간에 대한 회귀분석
sm.OLS.from_formula('광진구 ~ rainy + bool_date + mul ', data = df_2).fit().summary() # 상호작용 효과만 유의하지 않음

# 세번째 구간에 대한 회귀분석
sm.OLS.from_formula('광진구 ~ rainy + bool_date + mul ', data = df_3).fit().summary() # 상호작용 효과가 유의하지만 계수가 예상한 방향과 다름

""" 여름철에 강수량이 많은 날에 대한 상호작용 효과가 존재하지 않음. 그저 강수량이 많은 날에는 따릉이 수요량이 감소하는 것만이 자명함 """

# 2. 코로나 19가 따릉이 수요량에 영향을 주는지를 확인하고자 한다.
## 가장 simple하게 회귀분석으로 확인해보자

# 전체 기간에 대해서 확인해보자
sm.OLS.from_formula('광진구 ~ sum + rainy', data = df).fit().summary() # 유의하긴 하지만 영향이 매우적어보임

# 첫번째 구간에 대해서 확인해보자
sm.OLS.from_formula('광진구 ~ sum + rainy', data = df_1).fit().summary() # 확진이 수요량에 영향을 미친다고 보기 어려움

# 두번째 구간에 대해서 확인해보자
sm.OLS.from_formula('광진구 ~ sum + rainy', data = df_2).fit().summary() # 유의하긴 하지만 영향이 매우적어보임

# 세번째 구간에 대해서 확인해보자
sm.OLS.from_formula('광진구 ~ sum + rainy', data = df_3).fit().summary() # 유의하긴 하지만 영향이 매우적어보임

# 250일 전후 비교
df_250_1 = df[:250]; df_250_2 = df[250:]; df_250_2
df['bool_date_infected'] = np.where(df['date'] > "2020-09-26", 1, 0)
df['infected_diff'] = df['sum'].diff().fillna(0)
df['infected_diff'] = np.where(df.infected_diff > 0, 1, 0)
df['mul_infected'] = df['bool_date_infected'] * df['infected_diff']

sm.OLS.from_formula('광진구 ~ sum  ', data = df).fit().summary()

# 매일마다 확진자 수에 따라 영향을 받지는 않지만 250일 이후로는 유의수준 5%에서 영향을 받는다고 할 수 있다.

# 2020년 따릉이 보유량 : 37500대
import os
data_path = '../../data/'
having = pd.read_csv(data_path + '따릉이보유량.csv', encoding='cp949');having

plt.style.use('ggplot')
demand['광진구'].plot(label = 'demand')
plt.legend()
plt.show()

# 2021년 수요량
testdata = pd.read_csv('../../data/testdata.csv')
testdata['광진구'].plot(label = 'demand')
plt.legend()
plt.show()

# 코로나와 따릉이 수요량이 관계가 없다고 입증
from sklearn.preprocessing import PolynomialFeatures

# RCP scenario
rcp = pd.read_csv(data_path + 'RCP_scenario.csv')
rcp = rcp[2:]
rcp

weather_3.dropna(inplace = True)
weather_3.date = pd.to_datetime(weather_3.date)
weather_3['rainy'] = np.where(weather_3['rain'] > 0.05 , 1, 0)
weather_3.set_index('date', inplace = True)
weather_3.resample('M')['rainy'].sum()
weather_3.resample('M')['rain'].sum()

# 실제 2021 강수량 데이터
rain_2021 = pd.read_csv(data_path + 'weather/peak_2021.csv')
rain_2021.date = pd.to_datetime(rain_2021.date)
rain_2021.set_index('date', inplace = True)
rain_2021.resample('M')['rain'].sum().plot()
rcp['강수량(mm)'] = rcp['강수량(mm)'].astype(float)
rcp['강수량(mm)'].plot()

# 
df_poly = df[['광진구', 'temp', 'rain', 'sum']]

from sklearn.model_selection import train_test_split
x_train, x_test, y_train, y_test = train_test_split(df_poly.drop('광진구', axis = 1), df_poly['광진구'], test_size = 0.2, random_state = 42)
model = PolynomialFeatures(degree = 2, include_bias=True)
x_poly = model.fit_transform(x_train)

from sklearn.linear_model import LinearRegression
lin_reg = LinearRegression()
lin_reg.fit(x_poly, y_train)
lin_reg.intercept_, lin_reg.coef_
lin_reg.score(x_poly, y_train)


# 코로나19가 관련이 없다는 것을 이중차분법을 통해서 입증해보자
demand.date = pd.to_datetime(demand.date)
demand.set_index('date', inplace = True)
demand_2019 = demand.loc['2019-07-18' : '2019-12-31', :]
demand_2020 = df[180:]

demand_2019['sum'] = 0
demand_2019.loc['2019-09-26' :, 'bool_date'] = 1
demand_2019.fillna(0, inplace = True)
demand_2019 = demand_2019[['sum', 'bool_date', '광진구']]
demand_2019.rename(columns = {'sum' : 'sum_diff'}, inplace = True)
# 통제군 : demand_2019
""" weather_2.date = pd.to_datetime(weather_2.date)
weather_2.set_index('date', inplace = True)
weather_2_rain = weather_2.loc['2019-07-18' : '2019-12-31', :]
weather_2_rain['rainy'] = np.where(weather_2_rain['rain'] > 0.05 , 1, 0)
weather_2_rain.loc[weather_2_rain.index > '2019-09-26', 'bool_date'] = 1
weather_2_rain.fillna(0, inplace = True)
weather_2_rain.bool_date = weather_2_rain.bool_date.astype(int) """


# 실험군
df['sum_diff'] = df['sum'].diff()
df_exp = df.loc['2020-07-18' : , :]
df_exp['sum_diff'] = np.where(df_exp['sum_diff'] > 0, 1, 0)
df_exp.loc['2020-09-26' :, 'bool_date'] = 1
df_exp.fillna(0, inplace = True)
df_exp = df_exp[['sum_diff', 'bool_date', '광진구']]
df_exp

did_df = pd.concat([demand_2019, df_exp], axis = 0)
did_df['mul'] = did_df['sum_diff'] * did_df['bool_date']
did_df
# 이중차분법
import statsmodels.api as sm
sm.OLS.from_formula('광진구 ~ sum_diff + bool_date + mul', data = did_df).fit().summary()

# plot을 통해 나타내보자
plt.style.use('ggplot')
plt.rc('font', family = 'AppleGothic')

# 기간 동일 설정
demand_2019_copy = demand_2019.copy()
df_exp.index = df_exp.index.astype('object')
demand_2019_copy.index = df_exp.index

demand_2019_copy['광진구'].plot()
df_exp['광진구'].plot()
plt.axvline(x = '2019-09-26', color = 'black', linestyle = '--')
plt.show()

fig, ax = plt.subplots()
ax.plot(demand_2019_copy.index, demand_2019_copy['광진구'], label = '통제군')
ax.plot(df_exp.index, df_exp['광진구'], label = '실험군')
plt.legend()
plt.show()

df_exp.index


# rcp시나리오에 근거해서 랜덤하게 강수량 뿌리기
total_weather = pd.concat([weather_1, weather_2, weather_3], axis = 0)
total_weather.dropna(inplace = True)
total_weather.date = pd.to_datetime(total_weather.date)
total_weather.set_index('date', inplace = True)

# 월별 비가 온날의 횟수
total_weather['rainy'] = np.where(total_weather['rain'] > 1 , 1, 0)
num_weather = total_weather.resample('M')['rainy'].sum()
num_weather.plot(label = '월별 비가 온날의 횟수')
plt.legend()
plt.show()

# 3년간의 평균 월별 비가 온 날의 횟수로 랜덤하게 뿌리려고 한다.

num_weather_arr = np.array(num_weather)
num_weather_arr = num_weather_arr.reshape(3, 12)
cnt = num_weather_arr.sum(axis = 0)
cnt = cnt/3
cnt = cnt.round(0)
cnt # 월별 비가 온 날의 횟수 평균

# rcp 데이터
pwd()
rcp = pd.read_csv('../../data/RCP_scenario.csv')
rcp.reset_index(drop = True, inplace = True)
rcp = rcp[2:]
rcp_45 = rcp[0:12]
rcp_60 = rcp[13:25]
rcp_45array = rcp_45.iloc[:,1]
rcp_60array = rcp_60.iloc[:,1]
rcp

rcp_26 = pd.read_csv('../../data/RCP_array.csv', index_col = 0)
rcp_26

fig, ax = plt.subplots(1,2)
total_weather.resample('M')['rain'].sum().plot(ax = ax[0])
rcp['강수량(mm)'].plot(ax = ax[1])
plt.show()

# scale이 맞지 않음
## 실제 2021 weather data
weather_2021 = pd.read_csv('../../data/weather/peak_2021.csv', encoding = 'cp949')
weather_2021.date = pd.to_datetime(weather_2021.date)
weather_2021.set_index('date', inplace=True)
sum_2021 = weather_2021.resample('M')['rain'].sum()

## 실제 강수량과 rcp 강수량의 scale 보정
fig, ax = plt.subplots(1,2 , figsize = (10,5))
ax[0].set_title('2021 실제 강수량')
weather_2021.resample('M')['rain'].sum().plot(ax = ax[0])
ax[0].legend(['rain'])
rcp['강수량(mm)'].plot(ax = ax[1])
ax[1].set_title('rcp 강수량')
ax[1].legend(['rain'])
plt.show()

# rcp 강수량의 scale을 실제 강수량의 scale에 맞춰주기
from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler()
rcp_45['강수량(mm)'] = scaler.fit_transform(rcp_45['강수량(mm)'].values.reshape(-1,1))
rcp_60['강수량(mm)'] = scaler.fit_transform(rcp_60['강수량(mm)'].values.reshape(-1,1))

## scale 보정 확인
plt.rc('font' , family = 'AppleGothic')
plt.style.use('ggplot')
fig, ax = plt.subplots(1,4 , figsize = (10,8))
ax[0].set_title('2021 실제 강수량')
ax[0].plot(np.arange(12), sum_2021)
ax[0].legend(['rain'])
ax[1].plot(np.arange(12), rcp_26['0'].values)
ax[1].set_title('rcp_26 강수량')
ax[1].legend(['rcp_26'])
ax[2].plot(np.arange(12), rcp_45['강수량(mm)'].values)
ax[2].set_title('rcp_45 강수량')
ax[2].legend(['rcp_45'])
ax[3].plot(np.arange(12), rcp_60['강수량(mm)'].values)
ax[3].set_title('rcp_60 강수량')
ax[3].legend(['rcp_60'])
plt.show()

sum_2021 = scaler.fit_transform(sum_2021.values.reshape(-1,1))
plt.plot(np.arange(12), sum_2021)

## MinMax보정 확인

# 랜덤하게 뿌려보자
cnt
rcp_array = scaler.fit_transform(rcp_array.values.reshape(-1,1))
rcp_array

pd.DataFrame(cnt).to_csv('../../data/cnt.csv')
pd.DataFrame(rcp_45array).to_csv('../../data/rcp_45array.csv')
pd.DataFrame(rcp_60array).to_csv('../../data/rcp_60array.csv')

# R로 랜덤하게 뿌린 결과를 가져오자
result = pd.read_csv('../../data/scenario.csv', index_col = 0)
result.dropna(inplace = True)
result

result_2 = pd.read_csv('../../data/scenario_45.csv')
result_3 = pd.read_csv('../../data/scenario_60.csv')
result_2['random'].plot()
weather_2021.rain.plot()


# 실제 2021 강수량과 비교해보자
weather_2021.rain = np.where(weather_2021.rain < 0.05, 0, weather_2021.rain)

weather_2021.merge(result_2, left_index = True, right_index = True)
result_2.set_index('k_lst', inplace = True)
result_2.rename(columns = {'k_lst' : 'date', 'r_lst': 'random'}, inplace = True)
result_2.index = pd.to_datetime(result_2.index, format = '%Y.%m.%d')

# random하게 뿌린 강수량을 df에 추가


join_df_2 = weather_2021.join(result_2).fillna(0)
plt.style.use('ggplot')
join_df_2[['rain', 'random']].plot()

# scale 조정
from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler()
join_df_2.rain = scaler.fit_transform(join_df_2['rain'].values.reshape(-1,1))