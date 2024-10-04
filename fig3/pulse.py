import matplotlib.pyplot as plt
import numpy as np

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

t = np.linspace(0, 20, 1000)
eps = 1e-9

pulse1 = np.where(((t-eps) % 10 <= 7), 10, 0)
pulse2 = np.where((t-eps) % 10 <= 0.5, 0, np.where(((t-eps) % 10 <= 7), 10.5, 0))

# 创建图形
plt.figure(figsize=(5, 3))



# 画两条线，一条在左边（pulse1），一条在右边（pulse2）
plt.plot(t, pulse1, label="Top layer", color='blue', linestyle='-', linewidth=1)
plt.plot(t, pulse2, label="Bottom layer", color='red', linestyle='-', linewidth=1)
plt.fill_between(t, pulse1, pulse2, where=(pulse1 > pulse2), color='blue', alpha=0.1,
                 interpolate=True)

plt.fill_between(t, pulse1, pulse2, where=(pulse1 < pulse2), color='red', alpha=0.1,
                 interpolate=True)
# 设置图例放在顶部
plt.legend(loc='upper center', bbox_to_anchor=(0.5, 1), ncol=2)

# 添加标签和设置范围
plt.xlabel("Time (ns)")
plt.ylabel("u (m/s)")
plt.ylim([-2, 15])
plt.xlim([0, 20])

# 网格和布局
#plt.grid(True)
plt.tight_layout()

# 保存图像
plt.savefig("fig5a.svg")
