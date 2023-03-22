from matplotlib import font_manager, rc
import pandas as pd
import os

pathdir = '../data'

# Load data
df = pd.read_csv(pathdir + '/train.csv', encoding='utf-8')
df.info()

submisson = pd.read_csv(pathdir + '/sample_submission.csv', encoding='utf-8')
submisson.to_csv(pathdir + '/submission.csv', index=False, encoding='cp949')
# matplot에서 한글 깨짐 방지 코드
font_path = "C:/Windows/Fonts/NGULIM.TTF"
font = font_manager.FontProperties(fname=font_path).get_name()
rc('font', family=font)


df[['광진구', '동대문구', '성동구', '중랑구']].hist()
