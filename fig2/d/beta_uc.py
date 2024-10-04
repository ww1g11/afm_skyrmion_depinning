import numpy as np
import matplotlib.pyplot as plt

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

def fun(lam, Q=1, eta=1.2, beta=0.05):
    Fmax = 102.3
    amp = Fmax / (4*np.pi)
    return amp / np.sqrt((1 + lam)**2*beta**2*eta**2+(1-lam)**2)

print(fun(1.0))

plt.figure(figsize=(5, 3.3))

data = np.loadtxt('uc_lambda.txt', delimiter=None, skiprows=1)
lam = data[:, 0]
ux = data[:, 1]

plt.scatter(lam, ux, marker='s', label='Simulation')

lam = np.linspace(0, 1, 100)
plt.plot(lam, fun(lam), color='C3', linestyle='-', label='Analytical')

plt.xlabel(r'$\lambda$')
plt.ylabel(r'$u_c$ (m/s)')
plt.legend()  
plt.tick_params(axis='both', which='major')
plt.xlim([0, 1])

plt.tight_layout()
plt.savefig('fig2e.svg')

