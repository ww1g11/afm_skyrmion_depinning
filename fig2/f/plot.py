import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

data = np.loadtxt("uc.txt")
points = []

N = 18
for i in range(N):
    points.append([data[i, 0], data[i, 1]])

for i in range(N-1, 0, -1):
    points.append([-data[i, 0], data[i, 1]])

points = np.array(points)

b = points[:, 0]
u = points[:, 1]

b = np.append(b, b[0])
u = np.append(u, u[0])

fig, ax = plt.subplots(figsize=(5, 3.3))
plt.plot(u, b, marker='o', markersize=4)
plt.fill(u, b, alpha=0.4)
plt.xlabel('u (m/s)')
plt.ylabel('b (nm)')
plt.grid(True)
plt.text(27, -2.5, 'Pinned', fontsize=16)
plt.xlim([0, 80])
plt.ylim([-40, 40])
plt.tight_layout()

plt.savefig("fig2f.svg")
