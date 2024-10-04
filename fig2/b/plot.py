import matplotlib.pyplot as plt
import numpy as np

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14


data1 = np.load("m0.npy")  
data2 = np.load("single.npy")
data3 = np.load("dual.npy")


data1 = np.reshape(data1, (3, 200, 160, 3), order='F')
data2 = np.reshape(data2, (3, 200, 160, 3), order='F')
data3 = np.reshape(data3, (3, 200, 160, 3), order='F')


mz1 = (data1[2, :, :, 2] + data2[2, :, :, 2] + data3[2, :, :, 2] + 2)
mz1 = np.roll(mz1, shift=(-30, 0), axis=(0, 1))

fig, ax = plt.subplots(figsize=(5, 3.3))

heatmap = ax.imshow(np.transpose(mz1), cmap="coolwarm", extent=[0, 200, 0, 160], origin='lower', vmax=1,vmin=-1, interpolation='lanczos')

file_path1 = 'single.txt'  
data1 = np.loadtxt(file_path1)
file_path2 = 'dual.txt'  
data2 = np.loadtxt(file_path2)


x1 = data1[:, 1]*1e9  
y1 = data1[:, 2]*1e9  
x2 = data2[:, 1]*1e9  
y2 = data2[:, 2]*1e9 

ax.plot(x1-30, y1, '--', label='single-layer current',color='white')  
ax.plot(x2-30, y2, '--', label='dual-layer currents', color='green')
circle = plt.Circle((x1[0]-30, y1[0]), 3, color='yellow', fill=True, alpha=0.8)
ax.add_patch(circle)

ax.set_xlabel('X (nm)')
ax.set_ylabel('Y (nm)')
plt.tick_params(axis='both', which='major')
ax.text(x1[0]-40, y1[0]-2, 'A', fontsize=12, ha='right', color='white')
ax.text(107-30, 132, 'B', fontsize=12, ha='right', color='white')
ax.text(166-30, 90, 'C', fontsize=12, ha='right', color='white')

plt.xlim([40, 200])
plt.ylim([60, 155])
ax.legend()
plt.tight_layout()


plt.savefig("fig2b.svg")

