# load packages
import pandas as pd
import numpy as np
import os
import datetime as dt
import seaborn as sns
from scipy.signal import savgol_filter
from scipy.stats import gamma, poisson
import matplotlib as mpl
import itertools
import matplotlib.pyplot as plt
import re
from folium import plugins
from folium.plugins import HeatMap

# load data
data = pd.read_excel('../data/COVID19_variants_국내.xlsx', index_col = False)
data.rename(columns = {'Unnamed: 0':'date'}, inplace = True)
data.info()

data['date'] = pd.to_datetime(data['date'])
data.info()
data = data.set_index('date')
data

## 3개의 컬럼을 제외하고는 sparse하므로 제거
df = data[['city', '-', 'Delta', 'Omicron', 'Eta', 'Iota', 'Beta']]
df.rename(columns = {'-':'Other', 'Eta' : 'Delta_cori', 'Iota' : 'Omicron_cori', 'Beta' : 'Total_cori'}, inplace = True)

# total 컬럼 생성
df['total'] = df['Delta'] + df['Omicron'] + df['Other']

# Cori의 Ws Gamma 분포 함수
def W(num):
    from numpy import linspace, exp
    x = linspace(1, num, num)
    from scipy.special import gamma
    mu = 4.8
    sig = 2.3
    shape = mu ** 2 / sig ** 2
    scale = sig ** 2 / mu
    y = x ** (shape - 1) * exp(-x / scale) / (scale ** shape * gamma(shape)) ## gamma 분포의 pdf 정의
    W = y
    return W


# Cori 계산 함수
def Cori(j, data, W):
    a = data.values[j] ## I_t
    b = 0 ## 초기화
    for k in range(1, j):
        b += data[j-k] * W[k] ## I[t-s] * Ws
    if (b > 0) :
        r = a / b
    else:
        r = 0
    return r

# W(s) 계산

df.loc[:, 'W'] = W(len(df))

def Cori_total(j, data):
    data = data.to_numpy()
    a = data[j, 7]
    b = 0
    
    for k in range(1, j):
        b += data[j-k, 7] * data[k, 8]
    if (b > 0) :
        r = a / b
    else:
        r = 0
    return r

def Cori_delta(j, data):
    data = data.to_numpy()
    a = data[j, 2]
    b = 0
    
    for k in range(1, j):
        b += data[j-k, 2] * data[k, 8]
    if (b > 0) :
        r = a / b
    else:
        r = 0
    return r

def Cori_omicron(j, data):
    data = data.to_numpy()
    a = data[j, 3]
    b = 0
    
    for k in range(1, j):
        b += data[j-k, 3] * data[k, 8]
    if (b > 0) :
        r = a / b
    else:
        r = 0
    return r

df_np = df.to_numpy()
for i in np.arange(1, len(df)):
    df_np[i, 6] = Cori_total(i, df)
    df_np[i, 4] = Cori_delta(i, df)
    df_np[i, 5] = Cori_omicron(i, df)
    
df_result = pd.DataFrame(df_np, columns = ['city', 'Other', 'Delta', 'Omicron', 'Delta_cori', 'Omicron_cori', 'Total_cori', 'total', 'W'])
df_result.index= df.index
df_result


# Cori가 15 이상인 경우 0으로 처리
df_result.loc[df_result['Total_cori'] > 15, ['Total_cori']] = 0
df_result.loc[df_result['Delta_cori'] > 15, ['Delta_cori']] = 0
df_result.loc[df_result['Omicron_cori'] > 15, ['Omicron_cori']] = 0


df_month_total_cori = df_result.groupby(['city']).resample('M')['Total_cori'].mean()
df_month_delta_cori = df_result.groupby(['city']).resample('M')['Delta_cori'].mean()
df_month_omicron_cori = df_result.groupby(['city']).resample('M')['Omicron_cori'].mean()
df_month_total = df_result.groupby(['city']).resample('M')['total'].mean()
df_month_delta = df_result.groupby(['city']).resample('M')['Delta'].mean()
df_month_omicron = df_result.groupby(['city']).resample('M')['Omicron'].mean()

df_month_total_cori = df_month_total_cori.unstack()
df_month_delta_cori = df_month_delta_cori.unstack()
df_month_omicron_cori = df_month_omicron_cori.unstack()
df_month_total = df_month_total.unstack()
df_month_delta = df_month_delta.unstack()
df_month_omicron = df_month_omicron.unstack()

df_month_total.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']
df_month_total_cori.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']
df_month_delta.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']
df_month_delta_cori.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']
df_month_omicron.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']
df_month_omicron_cori.columns = ['2020-01', '2020-02', '2020-03', '2020-04', '2020-05', '2020-06', '2020-07', '2020-08', '2020-09', '2020-10', '2020-11', '2020-12', '2021-01', '2021-02', '2021-03', '2021-04', '2021-05', '2021-06', '2021-07', '2021-08', '2021-09', '2021-10', '2021-11', '2021-12', '2022-01', '2022-02', '2022-03', '2022-04', '2022-05', '2022-06', '2022-07', '2022-08', '2022-09', '2022-10', '2022-11', '2022-12']

df_month_total.drop('total', inplace = True)
df_month_total_cori.drop('total', inplace = True)
df_month_delta.drop('total', inplace = True)
df_month_delta_cori.drop('total', inplace = True)
df_month_omicron.drop('total', inplace = True)
df_month_omicron_cori.drop('total', inplace = True)

import geopandas as gpd

korea = gpd.read_file('D:\\datasets\\행정구역_shp/ctp_rvn.shp')

col_name = ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju', 'Daejeon', 'Ulsan', 'Sejong', 'Gyeonggi', 'Gangwon', 
            'Chungbuk', 'Chungnam', 'Jeonbuk', 'Jeonnam', 'Gyeongbuk', 'Gyeongnam', 'Jeju']
korea['CTP_ENG_NM'] = col_name

# 2022년
df_202203_cori = korea.merge(df_month_total_cori.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_cori = korea.merge(df_month_total_cori.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_cori = korea.merge(df_month_total_cori.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_cori = korea.merge(df_month_total_cori.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202203_total = korea.merge(df_month_total.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_total = korea.merge(df_month_total.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_total = korea.merge(df_month_total.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_total = korea.merge(df_month_total.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202203_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202203_delta = korea.merge(df_month_delta.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_delta = korea.merge(df_month_delta.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_delta = korea.merge(df_month_delta.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_delta = korea.merge(df_month_delta.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202203_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202203_omicron = korea.merge(df_month_omicron.loc[:,['2022-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202206_omicron = korea.merge(df_month_omicron.loc[:,['2022-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202209_omicron = korea.merge(df_month_omicron.loc[:,['2022-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202212_omicron = korea.merge(df_month_omicron.loc[:,['2022-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

# 2021년
df_202103_cori = korea.merge(df_month_total_cori.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_cori = korea.merge(df_month_total_cori.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_cori = korea.merge(df_month_total_cori.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_cori = korea.merge(df_month_total_cori.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202103_total = korea.merge(df_month_total.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_total = korea.merge(df_month_total.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_total = korea.merge(df_month_total.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_total = korea.merge(df_month_total.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202103_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202103_delta = korea.merge(df_month_delta.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_delta = korea.merge(df_month_delta.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_delta = korea.merge(df_month_delta.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_delta = korea.merge(df_month_delta.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202103_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202103_omicron = korea.merge(df_month_omicron.loc[:,['2021-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202106_omicron = korea.merge(df_month_omicron.loc[:,['2021-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202109_omicron = korea.merge(df_month_omicron.loc[:,['2021-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202112_omicron = korea.merge(df_month_omicron.loc[:,['2021-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

#2020년
df_202003_cori = korea.merge(df_month_total_cori.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_cori = korea.merge(df_month_total_cori.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_cori = korea.merge(df_month_total_cori.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_cori = korea.merge(df_month_total_cori.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202003_total = korea.merge(df_month_total.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_total = korea.merge(df_month_total.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_total = korea.merge(df_month_total.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_total = korea.merge(df_month_total.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202003_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_delta_cori = korea.merge(df_month_delta_cori.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202003_delta = korea.merge(df_month_delta.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_delta = korea.merge(df_month_delta.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_delta = korea.merge(df_month_delta.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_delta = korea.merge(df_month_delta.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202003_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_omicron_cori = korea.merge(df_month_omicron_cori.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

df_202003_omicron = korea.merge(df_month_omicron.loc[:,['2020-03']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202006_omicron = korea.merge(df_month_omicron.loc[:,['2020-06']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202009_omicron = korea.merge(df_month_omicron.loc[:,['2020-09']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')
df_202012_omicron = korea.merge(df_month_omicron.loc[:,['2020-12']], left_on = 'CTP_ENG_NM', right_on = 'city', how = 'left')

# 2020년 3,6,9,12월 변이별 확진자와 변이 Cori 비교
df_202003_total.plot(column = '2020-03', cmap = 'Reds', legend = True)
plt.axis('off')
plt.title('2020-03-total_infected')
plt.show()

df_202003_cori.plot(column = '2020-03', cmap = 'Reds', legend = True, vmin = 0, vmax = 2)
plt.axis('off')
plt.title('2020-03-total_cori')
plt.show()

df_202003_delta.plot(column = '2020-03', cmap = 'Reds', legend = True)
plt.axis('off')
plt.title('2020-03-delta_infected')
plt.show()

df_202003_delta_cori.plot(column = '2020-03', cmap = 'Reds', legend = True, vmin = 0, vmax = 2)
plt.axis('off')
plt.title('2020-03-delta_cori')
plt.show()

df_202003_omicron.plot(column = '2020-03', cmap = 'Reds', legend = True)
plt.axis('off')
plt.title('2020-03-omicron_infected')
plt.show()

df_202003_omicron_cori.plot(column = '2020-03', cmap = 'Reds', legend = True, vmin = 0, vmax = 2)
plt.axis('off')
plt.title('2020-03-omicron_cori')
plt.show()

# total 확진자수
# 전체 확진자, cori 비교

df_202003_delta.plot(column = '2020-03', cmap = 'Reds', figsize = (10,10),  legend = True)
plt.title('2020-03-delta infected')
plt.axis('off')

df_202006_delta.plot(column = '2020-06', cmap = 'Reds', figsize = (10,10), legend = True)
plt.title('2020-06-delta infected')
plt.axis('off')

df_202009_delta.plot(column = '2020-09', cmap = 'Reds', figsize = (10,10),  legend = True)
plt.title('2020-09-delta infected')
plt.axis('off')

df_202012_delta.plot(column = '2020-12', cmap = 'Reds', figsize = (10,10), legend = True)
plt.title('2020-12-deltat infected')
plt.axis('off')

df_202103_delta.plot(column = '2021-03', cmap = 'Reds', figsize = (10,10),  legend = True)
plt.title('2021-03-delta infected')
plt.axis('off')

df_202106_delta_cori.plot(column = '2021-06', cmap = 'Reds', figsize = (10,10), vmin = 0, vmax =2,  legend = True)
plt.title('2021-06-delta cori')
plt.axis('off')

df_202109_delta_cori.plot(column = '2021-09', cmap = 'Reds', figsize = (10,10), vmin = 0, vmax =2, legend = True)
plt.title('2021-09-delta cori')
plt.axis('off')

df_202112_delta_cori.plot(column = '2021-12', cmap = 'Reds', figsize = (10,10), vmin = 0, vmax = 2, legend = True)
plt.title('2021-12-delta cori')
plt.axis('off')

df_202203_delta_cori.plot(column = '2022-03', cmap = 'Reds', figsize = (10,10), vmin = 0, vmax = 2, legend = True)
plt.title('2022-03-delta cori')
plt.axis('off')

df_202206_omicron_cori.plot(column = '2022-06', cmap = 'Reds', figsize = (10,10),vmin = 0, vmax = 2, legend = True)
plt.title('2022-06-omicron cori')
plt.axis('off')

df_202209_omicron_cori.plot(column = '2022-09', cmap = 'Reds', figsize = (10,10),vmin = 0, vmax = 2,legend = True)
plt.title('2022-09-omicron cori')
plt.axis('off')

df_202212_omicron_cori.plot(column = '2022-12', cmap = 'Reds', figsize = (10,10), vmin = 0, vmax = 2, legend = True)
plt.title('2022-12-omicron cori')
plt.axis('off')


