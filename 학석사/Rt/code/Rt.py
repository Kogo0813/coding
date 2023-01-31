## 해야할 것
1. [지역별_데이터_프레임_(others_Delta_Omicron_total)로_통일하기](#preprocessing)
2. [지역별_total로_구한_Rt_계산](#regionrtcal)  
   
   2.1 [내장함수로_계산](#rcovid)  
   2.2 [계산식으로_계산](#rcovidd)
3. [지역별_total_Rt_시각화](#regionvisual)
4. [지역별_변이별_Rt_계산](#varrt)
5. [지역별_변이별_Rt_시각화](#varvisual)
6. [정책효과반영](#policy)
7. [지역별 월별 Rt](#monthrt)
### 1. 데이터_전처리<a id = "preprocessing"></a>
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
data = pd.read_excel('../data/COVID19_variants_국내.xlsx', index_col = False)
data.rename(columns = {'Unnamed: 0':'date'}, inplace = True)
data.info()
data['date'] = pd.to_datetime(data['date'])
data.info()
data = data.set_index('date')
data
## 3개의 컬럼을 제외하고는 sparse하므로 제거
df = data[['city', '-', 'Delta', 'Omicron']]
df.rename(columns = {'-':'Other'}, inplace = True)
# total 컬럼 생성
df['total'] = df['Delta'] + df['Omicron'] + df['Other']
## 도시들이 꽤나 많으므로 광역시들의 Rt를 우선적으로 계산해 그래프로 나타내자

Incheon_df = df[df['city'] == 'Incheon']
Busan_df = df[df['city'] == 'Busan']
Seoul_df = df[df['city'] == 'Seoul']
Daegu_df = df[df['city'] == 'Daegu']
Daejeon_df = df[df['city'] == 'Daejeon']
Gwangju_df = df[df['city'] == 'Gwangju']
Ulsan_df = df[df['city'] == 'Ulsan']




# 각 지역의 델타, 오미크론 변이 확진자 총합?

regions = [Incheon_df, Busan_df, Seoul_df, Daegu_df, Daejeon_df, Gwangju_df, Ulsan_df]
regions_name = ['Incheon', 'Busan', 'Seoul', 'Daegu', 'Daegeon', 'Gwangju', 'Ulsan']

print('-' * 50)
for i in range(len(regions)):
    print(regions_name[i], '지역의 델타 변이 확진자 수의 총합 : ', np.sum(regions[i]['Delta']))
    print(regions_name[i], '지역의 오미크론 변이 확진자 수의 총합 : ', np.sum(regions[i]['Omicron']))
    print(regions_name[i], '지역의 그 외 변이 확진자 수의 총합 : ', np.sum(regions[i]['Other']))
    print('-' * 50)
### 2. 지역_통합_Rt <a id = "regionrtcal"></a>
##### 2.1 내장함수로_계산<a id = "rcovid"></a>
import epyestim
import epyestim.covid19 as covid19


# 내장함수 불러오기
si_distrb = covid19.generate_standard_si_distribution() ## serial interval mean 4.3일을 고려한 분포 생성
delay_distrb = covid19.generate_standard_infection_to_reporting_distribution() ## 평균 delay mean : 10.3일 고려한 분포 생성
# 내장함수로 계산

for i in range(len(regions)):
    ch_time_varying_r = covid19.r_covid(regions[i]['total'], gt_distribution = si_distrb)
    
    # 그래프
    fig, ax = plt.subplots(1,1, figsize=(12, 6))

    ch_time_varying_r.loc[:,'Q0.5'].plot(ax=ax, color='red')
    # CI
    ax.fill_between(ch_time_varying_r.index, 
                        ch_time_varying_r['Q0.025'], 
                        ch_time_varying_r['Q0.975'], 
                        color='red', alpha=0.2)
    ax.set_xlabel('date')
    ax.set_ylabel('R(t) with 95%-CI')
    ax.axhline(y=1)
    ax.set_title(f'{regions_name[i]} Cori Total R(t)')
    plt.show()
##### 2.2 계산식을 통한 Rt 계산<a id = "rcovidd"></a>
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

for i in range(len(regions)):
    regions[i].loc[:, 'W'] = W(len(regions[i])) # 문제없음
Seoul_df = Seoul_df.reset_index()
Ulsan_df = Ulsan_df.reset_index()
Incheon_df = Incheon_df.reset_index()
Gwangju_df = Gwangju_df.reset_index()
Daegu_df = Daegu_df.reset_index()
Daejeon_df = Daejeon_df.reset_index()
Busan_df = Busan_df.reset_index()
# Cori Rt 계산

for i in range(1, len(Seoul_df.index)):
    Seoul_df.loc[i, 'Cori'] = Cori(i, Seoul_df['total'], Seoul_df['W'])
    Ulsan_df.loc[i, 'Cori'] = Cori(i, Ulsan_df['total'], Ulsan_df['W'])
    Daegu_df.loc[i, 'Cori'] = Cori(i, Daegu_df['total'], Daegu_df['W'])
    Daejeon_df.loc[i, 'Cori'] = Cori(i, Daejeon_df['total'], Daejeon_df['W'])
    Busan_df.loc[i, 'Cori'] = Cori(i, Busan_df['total'], Busan_df['W'])
    Incheon_df.loc[i, 'Cori'] = Cori(i, Incheon_df['total'], Incheon_df['W'])
    Gwangju_df.loc[i, 'Cori'] = Cori(i, Gwangju_df['total'], Gwangju_df['W'])
### 3. 지역별 통합 Rt 시각화<a id = "regionvisual"></a>
big_regions = [Seoul_df, Busan_df, Daegu_df, Incheon_df, Gwangju_df, Daejeon_df, Ulsan_df]

for i in range(len(big_regions)):
    big_regions[i] = big_regions[i].dropna()
    f, axes = plt.subplots(3, 1)
    f.set_size_inches((12, 15))
    x=big_regions[i]['date']
    y=big_regions[i]['Cori']
    yhat=savgol_filter(y,12,9)
    # cori_no_filter
    axes[0].plot(x,y,'r')
    axes[0].axhline(y=1)
    axes[0].set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes[0].set_ylim(0,15)
    axes[0].set_xlabel('date')
    axes[0].set_ylabel('R(t)')
    axes[0].set_title(f'{regions_name[i]} cori_no_filter')
    # cori_with_filter
    axes[1].plot(x,yhat,'r')
    axes[1].axhline(y=1)
    axes[1].set_xlim([dt.date(2020,1,1),dt.date(2021,12,31)])
    axes[1].set_ylim(0,15)
    axes[1].set_xlabel('date')
    axes[1].set_ylabel('R(t)')
    axes[1].set_title(f'{regions_name[i]} cori_with_filter')
    # cori_with_case
    axes[2].plot(x,yhat,'r')
    axes[2].axhline(y=1,color='black')
    axes[2].set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes[2].set_ylim(0,15)
    axes[2].set_xlabel('date')
    axes[2].set_ylabel('R(t)')
    axes[2].set_title(f'{regions_name[i]} cori_with_case')
    ax = axes[2].twinx()
    x1=big_regions[i]['date']
    y1=big_regions[i]['total']
    ax.plot(x1,y1)
    ax.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    ax.set_ylim(0,3500)
    plt.show()
#### Rt가 비정상적으로 높은 데이터 처리 후의 시각화 결과

- Rt가 15보다 큰 데이터는 0으로 처리한다.
big_regions = [Seoul_df, Busan_df, Daegu_df, Incheon_df, Gwangju_df, Daejeon_df, Ulsan_df]

for i in range(len(big_regions)):
    big_regions[i] = big_regions[i].dropna()
    big_regions[i].loc[big_regions[i]['Cori'] > 13, 'Cori'] = 0
    f, axes = plt.subplots(3, 1)
    f.set_size_inches((12, 15))
    x=big_regions[i]['date']
    y=big_regions[i]['Cori']
    yhat=savgol_filter(y,12,9)
    # cori_no_filter
    axes[0].plot(x,y,'r')
    axes[0].axhline(y=1)
    axes[0].set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes[0].set_ylim(0,15)
    axes[0].set_xlabel('date')
    axes[0].set_ylabel('R(t)')
    axes[0].set_title(f'{regions_name[i]} cori_no_filter')
    # cori_with_filter
    axes[1].plot(x,yhat,'r')
    axes[1].axhline(y=1)
    axes[1].set_xlim([dt.date(2020,1,1),dt.date(2021,12,31)])
    axes[1].set_ylim(0,15)
    axes[1].set_xlabel('date')
    axes[1].set_ylabel('R(t)')
    axes[1].set_title(f'{regions_name[i]} cori_with_filter')
    # cori_with_case
    axes[2].plot(x,yhat,'r')
    axes[2].axhline(y=1,color='black')
    axes[2].set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes[2].set_ylim(0,15)
    axes[2].set_xlabel('date')
    axes[2].set_ylabel('R(t)')
    axes[2].set_title(f'{regions_name[i]} cori_with_case')
    ax = axes[2].twinx()
    x1=big_regions[i]['date']
    y1=big_regions[i]['total']
    ax.plot(x1,y1)
    ax.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    ax.set_ylim(0,300)
    plt.show()
대체적으로 확진자 수가 적어서 증감을 판단하는 데 있어 오차가 클 것으로 보인다.

### 4. 지역별 변이별 Rt 계산<a id = "varrt"></a>
# W(s) 계산

for i in range(len(big_regions)):
    big_regions[i].loc[:, 'W'] = W(len(big_regions[i])) # 문제없음
    
# Delta Cori Rt 계산

for i in range(1, len(Seoul_df.index)):
    Seoul_df.loc[i, 'Delta_Cori'] = Cori(i, Seoul_df['Delta'], Seoul_df['W'])
    Ulsan_df.loc[i, 'Delta_Cori'] = Cori(i, Ulsan_df['Delta'], Ulsan_df['W'])
    Daegu_df.loc[i, 'Delta_Cori'] = Cori(i, Daegu_df['Delta'], Daegu_df['W'])
    Daejeon_df.loc[i, 'Delta_Cori'] = Cori(i, Daejeon_df['Delta'], Daejeon_df['W'])
    Busan_df.loc[i, 'Delta_Cori'] = Cori(i, Busan_df['Delta'], Busan_df['W'])
    Incheon_df.loc[i, 'Delta_Cori'] = Cori(i, Incheon_df['Delta'], Incheon_df['W'])
    Gwangju_df.loc[i, 'Delta_Cori'] = Cori(i, Gwangju_df['Delta'], Gwangju_df['W'])
    
# Omicron Cori Rt 계산

for i in range(1, len(Seoul_df.index)):
    Seoul_df.loc[i, 'Omicron_Cori'] = Cori(i, Seoul_df['Omicron'], Seoul_df['W'])
    Ulsan_df.loc[i, 'Omicron_Cori'] = Cori(i, Ulsan_df['Omicron'], Ulsan_df['W'])
    Daegu_df.loc[i, 'Omicron_Cori'] = Cori(i, Daegu_df['Omicron'], Daegu_df['W'])
    Daejeon_df.loc[i, 'Omicron_Cori'] = Cori(i, Daejeon_df['Omicron'], Daejeon_df['W'])
    Busan_df.loc[i, 'Omicron_Cori'] = Cori(i, Busan_df['Omicron'], Busan_df['W'])
    Incheon_df.loc[i, 'Omicron_Cori'] = Cori(i, Incheon_df['Omicron'], Incheon_df['W'])
    Gwangju_df.loc[i, 'Omicron_Cori'] = Cori(i, Gwangju_df['Omicron'], Gwangju_df['W'])
    
# Others Rt 계산

for i in range(1, len(Seoul_df.index)):
    Seoul_df.loc[i, 'Others_Cori'] = Cori(i, Seoul_df['Other'], Seoul_df['W'])
    Ulsan_df.loc[i, 'Others_Cori'] = Cori(i, Ulsan_df['Other'], Ulsan_df['W'])
    Daegu_df.loc[i, 'Others_Cori'] = Cori(i, Daegu_df['Other'], Daegu_df['W'])
    Daejeon_df.loc[i, 'Others_Cori'] = Cori(i, Daejeon_df['Other'], Daejeon_df['W'])
    Busan_df.loc[i, 'Others_Cori'] = Cori(i, Busan_df['Other'], Busan_df['W'])
    Incheon_df.loc[i, 'Others_Cori'] = Cori(i, Incheon_df['Other'], Incheon_df['W'])
    Gwangju_df.loc[i, 'Others_Cori'] = Cori(i, Gwangju_df['Other'], Gwangju_df['W'])

### 5. 지역별 변이별 Rt 시각화<a id = "varvisual"></a>
big_regions = [Seoul_df, Busan_df, Daegu_df, Incheon_df, Gwangju_df, Daejeon_df, Ulsan_df]

plt.rc('font', size=30)        # 기본 폰트 크기
plt.rc('axes', labelsize=30)   # x,y축 label 폰트 크기
plt.rc('xtick', labelsize=15)  # x축 눈금 폰트 크기 
plt.rc('ytick', labelsize=15)  # y축 눈금 폰트 크기
plt.rc('legend', fontsize=30)  # 범례 폰트 크기
plt.rc('figure', titlesize=30) # figure title 폰트 크기

for i in range(len(big_regions)):
    big_regions[i] = big_regions[i].dropna()
    big_regions[i].loc[big_regions[i]['Cori'] > 10, 'Cori'] = 0
    big_regions[i].loc[big_regions[i]['Delta_Cori'] > 10, 'Delta_Cori'] = 0
    big_regions[i].loc[big_regions[i]['Omicron_Cori'] > 10, 'Omicron_Cori'] = 0
    big_regions[i].loc[big_regions[i]['Others_Cori'] > 10, 'Others_Cori'] = 0
    f, axes = plt.subplots(1, 1)
    f.set_size_inches((20, 8))
    x=big_regions[i]['date']
    y=big_regions[i]['Cori']
    y_1 = big_regions[i]['Delta_Cori']
    y_2 = big_regions[i]['Omicron_Cori']
    y_3 = big_regions[i]['Others_Cori']
    yhat=savgol_filter(y,31,3)
    y1_hat = savgol_filter(y_1, 31, 3)
    y2_hat = savgol_filter(y_2, 31, 3)
    y3_hat = savgol_filter(y_3, 31, 3)

    # cori_with_case
    axes.plot(x,yhat,'r', linewidth = 5)
    axes.plot(x,y1_hat, 'b', linewidth = 5)
    axes.plot(x,y2_hat, 'g', linewidth = 5)
    axes.plot(x, y3_hat , 'y', linewidth = 5)
    axes.axhline(y=1,color='black')
    axes.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes.set_ylim(0,15)
    axes.set_xlabel('date')
    axes.set_ylabel('R(t)')
    axes.set_title(f'{regions_name[i]} cori_with_case')
    ax = axes.twinx()
    x1=big_regions[i]['date']
    y1=big_regions[i]['total']
    total_hat = savgol_filter(y1, 31, 3)
    ax.plot(x1,total_hat, linewidth = 5)
    ax.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    ax.set_ylim(0,300)
    axes.legend(['Cori', 'Delta_Cori', 'Omicron_Cori'], fontsize = 20, loc = 'upper left')
    ax.legend(['total_case'], loc='upper right', fontsize = 20)
    plt.show()
### 6. 정책효과 반영<a id = "policy"></a>
policy = pd.read_excel('../data/df_policy_230104.xlsx', sheet_name = 'policy')
policy.set_index('date', inplace = True)
### 4가지 정책효과의 강도를 나타내는 변수 생성(간단하게 4가지 정책 강도의 평균으로 책정)

policy['strength'] = (policy['CM_S'] + policy['CM_W'] + policy['CM_C'] + policy['CM_R'])/4
policy['strength'].plot()
plt.show()
## 정책효과 그래프와 같이 표현하기 위해 date를 조정함
policy_match = policy.iloc[18:, :]


big_regions = [Seoul_df, Busan_df, Daegu_df, Incheon_df, Gwangju_df, Daejeon_df, Ulsan_df]

plt.rc('font', size=30)        # 기본 폰트 크기
plt.rc('axes', labelsize=30)   # x,y축 label 폰트 크기
plt.rc('xtick', labelsize=15)  # x축 눈금 폰트 크기 
plt.rc('ytick', labelsize=15)  # y축 눈금 폰트 크기
plt.rc('legend', fontsize=30)  # 범례 폰트 크기
plt.rc('figure', titlesize=30) # figure title 폰트 크기

for i in range(len(big_regions)):
    big_regions[i] = big_regions[i].dropna()
    big_regions[i].loc[big_regions[i]['Cori'] > 10, 'Cori'] = 0
    big_regions[i].loc[big_regions[i]['Delta_Cori'] > 10, 'Delta_Cori'] = 0
    big_regions[i].loc[big_regions[i]['Omicron_Cori'] > 10, 'Omicron_Cori'] = 0
    # big_regions[i].loc[big_regions[i]['Others_Cori'] > 10, 'Others_Cori'] = 0
    f, axes = plt.subplots(1, 1)
    f.set_size_inches((20, 8))
    x=big_regions[i].loc[:899, 'date']
    y=big_regions[i].loc[:899, 'Cori']
    y_1 = big_regions[i].loc[:899, 'Delta_Cori']
    y_2 = big_regions[i].loc[:899, 'Omicron_Cori']
    # y_3 = big_regions[i].loc[:899, 'Others_Cori']
    yhat = savgol_filter(y, 31, 3)
    y1_hat = savgol_filter(y_1, 31, 3)
    y2_hat = savgol_filter(y_2, 31, 3)
    # y3_hat = savgol_filter(y_3, 31, 3)

    # cori_with_case
    axes.plot(x,yhat,'r', linewidth = 5)
    axes.plot(x,y1_hat, 'b', linewidth = 5)
    axes.plot(x,y2_hat, 'g', linewidth = 5)
    # axes.plot(x, y3_hat , 'y', linewidth = 5)
    axes.plot(x, policy_match['strength'], 'k', linewidth = 5)
    axes.axhline(y=1,color='black')
    axes.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes.set_ylim(0,15)
    axes.set_xlabel('date')
    axes.set_ylabel('R(t)')
    axes.set_title(f'{regions_name[i]} cori_with_case')
    ax = axes.twinx()
    x1=big_regions[i].loc[:899, 'date']
    y1=big_regions[i].loc[:899, 'total']
    total_hat = savgol_filter(y1, 31, 3)
    ax.plot(x1,total_hat, linewidth = 5)
    ax.set_xlim([dt.date(2020,1,1),dt.date(2022,7,5)])
    ax.set_ylim(0,200)
    axes.legend(['Cori', 'Delta_Cori', 'Omicron_Cori', 'policy_strength'], fontsize = 20, loc = 'upper left')
    ax.legend(['total_case'], loc='upper right', fontsize = 20)

    plt.show()
Seoul_df.iloc[:899, :]
policy.iloc[18:, :]
## 7. 월별 Rt median 으로 시각화 <a id = 'monthrt'></a>
Ulsan_df_month = Ulsan_df.set_index('date').resample('M').median()
Seoul_df_month = Seoul_df.set_index('date').resample('M').median()
Gwangju_df_month = Gwangju_df.set_index('date').resample('M').median()
Daegu_df_month = Daegu_df.set_index('date').resample('M').median()
Daejeon_df_month = Daejeon_df.set_index('date').resample('M').median()
Incheon_df_month = Incheon_df.set_index('date').resample('M').median()
Busan_df_month = Busan_df.set_index('date').resample('M').median()
big_regions_month = [Ulsan_df_month, Seoul_df_month, Gwangju_df_month, Daegu_df_month, Daejeon_df_month, Incheon_df_month, Busan_df_month]
Ulsan_df_month = Ulsan_df_month.reset_index()
Seoul_df_month = Seoul_df_month.reset_index()
Gwangju_df_month = Gwangju_df_month.reset_index()
Daegu_df_month = Daegu_df_month.reset_index()
Daejeon_df_month = Daejeon_df_month.reset_index()
Incheon_df_month = Incheon_df_month.reset_index()
Busan_df_month = Busan_df_month.reset_index()


## 정책효과 그래프와 같이 표현하기 위해 date를 조정함
policy_match = policy.iloc[18:, :]
policy_match_month = policy_match.copy()
policy_match_month
policy_match_month.index = pd.DatetimeIndex(policy_match_month.index)
policy_match_month = policy_match_month.resample('M').median()
Ulsan_df_month


big_regions_month = [Ulsan_df_month, Seoul_df_month, Gwangju_df_month, Daegu_df_month, Daejeon_df_month, Incheon_df_month, Busan_df_month]


plt.rc('font', size=30)        # 기본 폰트 크기
plt.rc('axes', labelsize=30)   # x,y축 label 폰트 크기
plt.rc('xtick', labelsize=15)  # x축 눈금 폰트 크기 
plt.rc('ytick', labelsize=15)  # y축 눈금 폰트 크기
plt.rc('legend', fontsize=30)  # 범례 폰트 크기
plt.rc('figure', titlesize=30) # figure title 폰트 크기

for i in range(len(big_regions_month)):
    big_regions_month[i] = big_regions_month[i].dropna()
    big_regions_month[i].loc[big_regions_month[i]['Cori'] > 10, 'Cori'] = 0
    big_regions_month[i].loc[big_regions_month[i]['Delta_Cori'] > 10, 'Delta_Cori'] = 0
    big_regions_month[i].loc[big_regions_month[i]['Omicron_Cori'] > 10, 'Omicron_Cori'] = 0
    # big_regions[i].loc[big_regions[i]['Others_Cori'] > 10, 'Others_Cori'] = 0
    f, axes = plt.subplots(1, 1)
    f.set_size_inches((20, 8))
    x=big_regions_month[i].loc[:30, 'date']
    y=big_regions_month[i].loc[:30, 'Cori']
    y_1 = big_regions_month[i].loc[:30, 'Delta_Cori']
    y_2 = big_regions_month[i].loc[:30, 'Omicron_Cori']
    # y_3 = big_regions[i].loc[:899, 'Others_Cori']
    yhat = savgol_filter(y, 31, 3)
    y1_hat = savgol_filter(y_1, 31, 3)
    y2_hat = savgol_filter(y_2, 31, 3)
    # y3_hat = savgol_filter(y_3, 31, 3)

    # cori_with_case
    axes.plot(x,yhat,'r', linewidth = 5)
    axes.plot(x,y1_hat, 'b', linewidth = 5)
    axes.plot(x,y2_hat, 'g', linewidth = 5)
    # axes.plot(x, y3_hat , 'y', linewidth = 5)
    axes.plot(x, policy_match_month['strength'], 'k', linewidth = 5)
    axes.axhline(y=1,color='black')
    axes.set_xlim([dt.date(2020,1,1),dt.date(2022,12,31)])
    axes.set_ylim(0,5)
    axes.set_xlabel('date')
    axes.set_ylabel('R(t)')
    axes.set_title(f'{regions_name[i]} cori_with_case')
    ax = axes.twinx()
    x1=big_regions_month[i].loc[:30, 'date']
    y1=big_regions_month[i].loc[:30, 'total']
    total_hat = savgol_filter(y1, 31, 3)
    ax.plot(x1,total_hat, linewidth = 5)
    ax.set_xlim([dt.date(2020,1,31),dt.date(2022,7,31)])
    ax.set_ylim(0,100)
    axes.legend(['Cori', 'Delta_Cori', 'Omicron_Cori', 'policy_strength'], fontsize = 20, loc = 'upper left')
    ax.legend(['total_case'], loc='upper right', fontsize = 20)

    plt.show()
