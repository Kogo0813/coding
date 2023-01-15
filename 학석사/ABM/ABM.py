import numpy as np
from numpy.random import rand, randn
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import seaborn as sns
from IPython.display import HTML
[1. 시간에 따른 산점도 애니메이션](#animate)  

[2. 거리행렬](#distancematrix)  

[3. 배열](#array)  

[4. 확률계산](#prob)  

[5. SIR모델](#SIR)


## 1. 시간에 따른 산점도 애니메이션 <a id="animate"></a>

z = randn(10000)
z + 2
print((z ** 2).mean())
print((z ** 2).var())
def moving_agent(n):
    from matplotlib.animation import ArtistAnimation
    from IPython.display import HTML
    
    location = rand(2, n)
    
    
    fig, ax = plt.subplots()
    ax.set(xlim = (-10, 10), ylim = (-10, 10))
    
    
    loc_lst = []
    for frame in range(100):
        location += 0.2 * randn(2, n)
        loc = ax.scatter(location[0], location[1], color = 'blue', s = 10)
        loc_lst.append([loc])
        
    
    anim = ArtistAnimation(fig, loc_lst, interval = 5)
    return HTML(anim.to_jshtml())
        
    

    

    
    
moving_agent(100)
## 2. 거리행렬 <a id="distancematrix"></a>
## 거리행렬

n = 10
k = 0.2
location = rand(2, n)
print(location[:, 1])
print(location[:, 8])
print(sum((location[:, 1] - location[:, 8]) ** 2))


from numpy import zeros
from math import pi, sqrt

D = zeros([10, 10])
for i in range(n):
    for j in range(n):
        D[i, j] = sqrt(sum((location[:, i] - location[:, j]) ** 2))

D       
D < k
print(np.sum(D < k, axis = 1))
## 3. 배열 <a id="array"></a>
## 배열

state = np.array(['S' for _ in range(10)])
state = np.append(state, 'I')
state = np.append(state, 'I')
state

bit_S = state == 'S'
bit_I = state == 'I'
n_S = np.sum(bit_S)
n_I = np.sum(bit_I)
n = 12
location = rand(2, n)

D = zeros([n_S, n_I])
for i in range(n_S):
    for j in range(n_I):
        D[i, j] = sqrt(sum((location[:, i] - location[:, 10 + j]) ** 2))

D
from scipy.spatial import distance
pair = distance.cdist(location[:, bit_S].T, location[:, bit_I].T, 'euclidean')
contact = np.sum(pair < k, axis = 1)
print(pair)

contact
## 4. 확률계산 <a id="prob"></a>
b = 0.5 # beta

# 감염자가 되는 확률
1 - (1 - b) ** contact
infected = 1 - (1-b) ** contact < rand(n_S)
infected
np.put(state, np.where(bit_S)[0][infected], 'I')
state

## 5. SIR모델 <a id="SIR"></a>
def SIR(n):
    beta = 0.3
    sigma = 0.1
    mu = 0.1
    
    S_ = []
    I_ = []
    R_ = []
    t = 0
    
    ID = range(n)
    state = np.array(['S' for _ in range(n)])
    state[0] = 'I'
    location = rand(2, n)
    
    while sum(state == 'I') > 0:
        t += 1
        location += randn(2, n)
        bit_S = state == 'S'; n_S = np.sum(bit_S); ID_S = np.array(ID)[bit_S]; S_.append(n_S)
        bit_I = state == 'I'; n_I = np.sum(bit_I); ID_I = np.array(ID)[bit_I]; I_.append(n_I)
        bit_R = state == 'R'; n_R = np.sum(bit_R); ID_R = np.array(ID)[bit_R]; R_.append(n_R)
        
        D = distance.cdist(location[:, bit_S].T, location[:, bit_I].T, 'euclidean')
        contact = np.sum(D < k, axis = 1)
        infected = rand(n_S) < (1 - (1 - beta) ** contact)
        
        np.put(state, ID_S[infected], 'I')
        np.put(state, ID_I[rand(n_I) < mu], 'R')
        
    return S_, I_, R_

S, I, R = SIR(5*10**4)
t_end = len(S)
t_end

fig, ax = plt.subplots()

def animate(t):
    x = np.arange(t_end)
    y1 = S
    y2 = I
    y3 = R
        
    ax.plot(x[:t], y1[:t], color = 'blue', label = 'S')
    ax.plot(x[:t], y2[:t], color = 'red', label = 'I')
    ax.plot(x[:t], y3[:t], color = 'green', label = 'R')
    ax.set(xlim = (0, t_end), ylim = (0, 50000))
    
    
ani = FuncAnimation(fig, animate, np.arange(t_end), interval = 100)

HTML(ani.to_jshtml())
## 최적화
import scipy
from scipy.spatial import KDTree

kdtree = KDTree(location[:, bit_I])
print(kdtree)
kdtree.query(location[:, bit_S].T, distance_upper_bound=k)[0] < k
def SIR2(n):
    beta = 0.3
    sigma = 0.1
    mu = 0.1
    
    S_ = []
    I_ = []
    R_ = []
    t = 0
    
    ID = range(n)
    state = np.array(['S' for _ in range(n)])
    state[1] = 'I'
    location = rand(2, n)
    
    while sum(state == 'I') > 0:
        t += 1
        location += randn(2, n)
        bit_S = state == 'S'; n_S = np.sum(bit_S); ID_S = np.array(ID)[bit_S]; S_.append(n_S)
        bit_I = state == 'I'; n_I = np.sum(bit_I); ID_I = np.array(ID)[bit_I]; I_.append(n_I)
        bit_R = state == 'R'; n_R = np.sum(bit_R); ID_R = np.array(ID)[bit_R]; R_.append(n_R)
        
        KDtree_I = KDTree(location[:, bit_I].T)
        contact = KDtree_I.query(location[:, bit_S].T, distance_upper_bound=k)[0] < k
        infected = rand(n_S) < (1 - (1 - beta) ** contact)
        
        np.put(state, ID_S[infected], 'I')
        np.put(state, ID_I[rand(n_I) < mu], 'R')        
    return S_, I_, R_

    
S, I, R = SIR2(5*10**4)
fig, ax = plt.subplots()

def animate(t):
    x = np.arange(t_end)
    y1 = S
    y2 = I
    y3 = R
        
    ax.plot(x[:t], y1[:t], color = 'blue', label = 'S')
    ax.plot(x[:t], y2[:t], color = 'red', label = 'I')
    ax.plot(x[:t], y3[:t], color = 'green', label = 'R')
    ax.set(xlim = (0, t_end), ylim = (0, 50000))
    
    
ani = FuncAnimation(fig, animate, np.arange(t_end), interval = 100)

HTML(ani.to_jshtml())
