import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
from mpl_toolkits.axes_grid1.inset_locator import inset_axes

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

F_max = 102.29
#F_max = 103.35
eta = 1.2

data = np.loadtxt('uc_beta.txt', delimiter=None, skiprows=1)
beta = data[:, 0]
ux1 = data[:, 1]
ux2 = data[:, 2]

beta_r = np.linspace(min(beta), max(beta), 100)

fig, ax = plt.subplots(figsize=(5,3.3))
ax.plot(beta, ux1, 'o', color='C1', label='single-layer current', markersize=5)
ax.plot(beta_r, F_max/(np.pi*4*np.sqrt(1+beta_r**2*eta**2)), color='C2', linestyle='--', label='Eq. (10)')

ax.plot(beta, ux2, 's', color='C3', label='dual-layer currents',  markersize=5)
ax.plot(beta_r, F_max/(np.pi*8*eta*beta_r), color='C4', linestyle='-', label='Eq. (7)')

ax.set_xlabel(r'$\beta$')
ax.set_ylabel(r'$u_c$ (m/s)')
plt.tick_params(axis='both', which='major')
ax.legend()

plt.tight_layout()

beta_r = 0.05
print(F_max/(np.pi*8*eta*beta_r))

plt.savefig('ux_simulation.svg')


