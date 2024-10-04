import matplotlib.pyplot as plt
import numpy as np

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

data = np.load("m0.npy")  # 这里读取数据
data = np.reshape(data, (3, 300, 200, 3), order='F')

mz = data[2, :, :, 2]

fig, ax = plt.subplots(figsize=(5, 3))

# 绘制热图，设置显示范围，调整Y轴方向
heatmap = ax.imshow(np.transpose(mz), cmap="coolwarm", extent=[0, 300, 0, 200], origin='lower', interpolation='lanczos')
circle = plt.Circle((50, 100), 3, color='yellow', fill=True, alpha=0.8)
ax.add_patch(circle)

circle = plt.Circle((150, 100), 3, color='yellow', fill=True, alpha=0.8)
ax.add_patch(circle)

circle = plt.Circle((250, 100), 3, color='yellow', fill=True, alpha=0.8)
ax.add_patch(circle)

XY = np.loadtxt('XY.txt')
x = XY[:, 1]*1e9
y = XY[:, 2]*1e9
x2 = x+100

ax.plot(x, y, '-', color='white', linewidth=1, dashes=(1,1))
ax.plot(x2, y, '-', color='white', linewidth=1, dashes=(1,1))

ax.set_xlabel('X (nm)')
ax.set_ylabel('Y (nm)')
plt.tick_params(axis='both', which='major')
ax.text(50, y[0]-20, 'A', fontsize=12, ha='center', color='white')
ax.text(150, y[0]-20, 'B', fontsize=12, ha='center', color='white')
ax.text(250, y[0]-20, 'C', fontsize=12, ha='center', color='white')

#plt.xlim([40, 200])
plt.ylim([30, 170])
#ax.legend(fontsize=10)
plt.tight_layout()


plt.savefig("fig5b.svg")

