# split train, test data
import pandas as pd
import numpy as np

# data 경로 지정
file_path = '../../data/'
bike = pd.read_csv(file_path + 'train.csv')

# 2020년 까지 train data, 2021년은 test data
bike.info()

# date column을 datetime으로 변환
bike.rename(columns={'일시': 'date'}, inplace=True)
bike.date = pd.to_datetime(bike['date'], format='%Y%m%d')

bike.set_index('date', inplace=True)
train = bike.loc[:'2020-12-31', :]
test = bike.loc['2021-01-01':, :]

train.to_csv(file_path + 'traindata.csv', index=True)
test.to_csv(file_path + 'testdata.csv', index=True)

# 기상 데이터 load
wt_2018 = pd.read_csv(file_path + 'weather/2018_weather.csv', encoding='cp949')


# 따릉이 수요량이 6시~18시 사이에 가장 많을 것으로 예측되니 8시~18시의 기상 데이터만 이용하자
wt_2018.rename(columns={'일시': 'date', '기온(°C)': 'temp',  '습도(%)': 'humid',
               '강수량(mm)': 'rain', '적설(cm)': 'snow'}, inplace=True)
wt_2018.drop(['지점', '지점명'], axis=1, inplace=True)
wt_2018.fillna(0, inplace=True)
wt_2018.date = wt_2018.date.astype('object')

peak_time = ['06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
             '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00']
time_06 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[0]), :]
time_07 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[1]), :]
time_08 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[2]), :]
time_09 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[3]), :]
time_10 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[4]), :]
time_11 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[5]), :]
time_12 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[6]), :]
time_13 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[7]), :]
time_14 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[8]), :]
time_15 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[9]), :]
time_16 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[10]), :]
time_17 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[11]), :]
time_18 = wt_2018.loc[wt_2018['date'].str.contains(peak_time[12]), :]

peak_2018 = pd.concat([time_06, time_07, time_08, time_09, time_10, time_11,
                      time_12, time_13, time_14, time_15, time_16, time_17, time_18], axis=0)
peak_2018.date = pd.to_datetime(peak_2018.date, format='%Y-%m-%d %H:%M')
peak_2018.set_index('date', inplace=True)
# 12월 31일은 00:00데이터만 존재함. 뒤에서 끌어와야할듯
peak_2018 = peak_2018.resample('D').mean()
peak_2018.to_csv(file_path + 'weather/peak_2018.csv', index=True)


# 다른 데이터도 한 번에 처리하기 위해 함수 제작
def weather_preprocessing(df):
    df.drop(['지점', '지점명'], axis=1, inplace=True)
    df.rename(columns={'일시': 'date', '기온(°C)': 'temp',  '습도(%)': 'humid',
              '강수량(mm)': 'rain', '적설(cm)': 'snow'}, inplace=True)
    df.fillna(0, inplace=True)

    peak_time = ['06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
                 '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00']
    time_06 = df.loc[df['date'].str.contains(peak_time[0]), :]
    time_07 = df.loc[df['date'].str.contains(peak_time[1]), :]
    time_08 = df.loc[df['date'].str.contains(peak_time[2]), :]
    time_09 = df.loc[df['date'].str.contains(peak_time[3]), :]
    time_10 = df.loc[df['date'].str.contains(peak_time[4]), :]
    time_11 = df.loc[df['date'].str.contains(peak_time[5]), :]
    time_12 = df.loc[df['date'].str.contains(peak_time[6]), :]
    time_13 = df.loc[df['date'].str.contains(peak_time[7]), :]
    time_14 = df.loc[df['date'].str.contains(peak_time[8]), :]
    time_15 = df.loc[df['date'].str.contains(peak_time[9]), :]
    time_16 = df.loc[df['date'].str.contains(peak_time[10]), :]
    time_17 = df.loc[df['date'].str.contains(peak_time[11]), :]
    time_18 = df.loc[df['date'].str.contains(peak_time[12]), :]

    peak = pd.concat([time_06, time_07, time_08, time_09, time_10, time_11,
                     time_12, time_13, time_14, time_15, time_16, time_17, time_18], axis=0)
    peak.date = pd.to_datetime(peak.date, format='%Y-%m-%d %H:%M')
    peak.set_index('date', inplace=True)
    peak = peak.resample('D').mean()  # 12월 31일은 00:00데이터만 존재함. 뒤에서 끌어와야할듯
    peak.to_csv(file_path + 'weather/peak_201.csv', index=True)


weather_2019 = pd.read_csv(
    file_path + 'weather/2019_weather.csv', encoding='cp949')
weather_preprocessing(weather_2019)

weather_2020 = pd.read_csv(
    file_path + 'weather/2020_weather.csv', encoding='cp949')
weather_preprocessing(weather_2020)

############################ 기상 데이터 전처리 완료 ############################
