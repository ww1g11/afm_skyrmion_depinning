import matplotlib.pyplot as plt
import numpy as np

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14


data = np.load("../b/m0.npy")

data = np.reshape(data, (3, 200, 160, 3), order='F')

mz = data[2, :, :, 2]


fig, ax = plt.subplots(figsize=(5, 3.3))
heatmap = ax.imshow(np.transpose(mz), cmap='coolwarm', extent=[0, 200, 0, 160])

circle = plt.Circle((150, 50), 4, color='yellow', fill=True, alpha=0.8)
ax.add_patch(circle)

ax.axhline(y=80, color='white', linestyle='--', linewidth=1)
ax.axhline(y=50, color='white', linestyle='--', linewidth=1)


arrow_x = 110*2  
arrow_y = 115*2  
arrow_length = 20*2 

ax.annotate('', xy=(50, 50), xytext=(50, 80),
            arrowprops=dict(arrowstyle='<->', color='white', lw=1))


ax.text(40, 65, 'b', ha='center', va='center', color='white')


ax.set_xlabel('X(nm)')
ax.set_ylabel('Y(nm)')
plt.tick_params(axis='both', which='major')
plt.ylim([20, 120])
plt.tight_layout()

plt.savefig("fig2e.svg")

