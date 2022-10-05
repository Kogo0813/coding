import os
os.chdir('D:\\OneDrive - knu.ac.kr\\학석사\\ML_학회발표\\integrate')

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

integrate = pd.read_csv('ML_integrate.csv')
integrate.columns

integrate.drop('Unnamed: 0', axis  = 1, inplace = True)

cor_mean = integrate.mean(axis = 1)
cor_mean = pd.DataFrame(cor_mean)
integrated = pd.concat([integrate, cor_mean], axis = 1)

integrated.rename(columns = {0: 'cor_mean'}, inplace = True)

# 상승중
integrated.loc[integrated['cor_mean'] > 0.3, 'cor_mean'] = 1

# 상승조짐
integrated.loc[(0.1 < integrated['cor_mean']) & (integrated['cor_mean'] < 0.3) , 'cor_mean'] = 2

# 변화없음(일상)
integrated.loc[(-0.1 < integrated['cor_mean']) & (integrated['cor_mean'] < 0.1) , 'cor_mean'] = 3

# 하강조짐
integrated.loc[(-0.3< integrated['cor_mean']) & (integrated['cor_mean'] < -0.1) , 'cor_mean'] = 4

# 하강중
integrated.loc[integrated['cor_mean'] < -0.3, 'cor_mean'] = 5

integrated['cor_mean'] = integrated['cor_mean'].astype('int')
integrated.info()

mobility = pd.read_excel('mobility_data.xlsx')
mobility

















