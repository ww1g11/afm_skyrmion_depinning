import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = 'Arial'
rcParams['savefig.dpi'] = 300
rcParams['font.size'] = 14

def read_data(name, n=50):
    data = np.loadtxt(name)
    eV = 1.602176565e-19

    x = data[:, 1]*1e9  
    y = data[:, 2]*1e9 
    energy = data[:, 3] / eV *1000
    x = x - x[0]
    energy = energy - energy[0]

    return x[:n], energy[:n]

plt.figure(figsize=(5, 3.3))
x4, energy4 = read_data('XY_Rd_4_lambda_0.05.txt', n=40)
x6, energy6 = read_data('XY_Rd_6_lambda_0.05.txt', n=67)
x8, energy8 = read_data('XY_Rd_8_lambda_0.05.txt', n=70)
plt.plot(x4, energy4, label=r'$R_d=4$ nm', linewidth=2)
plt.plot(x6, energy6, label=r'$R_d=6$ nm', linewidth=2)
plt.plot(x8, energy8, label=r'$R_d=8$ nm', linewidth=2)
plt.xlabel('r (nm)')
plt.ylabel(r'$\Delta E$ (meV)')
plt.tick_params(axis='both', which='major')
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.savefig("energy.svg")


f4 = interpolate.interp1d(x4, np.gradient(energy4, x4), kind='cubic')
x_smooth4 = np.linspace(min(x4), max(x4), 200)

f6 = interpolate.interp1d(x6, np.gradient(energy6, x6), kind='cubic')
x_smooth6 = np.linspace(min(x6), max(x6), 200)

f8 = interpolate.interp1d(x8, np.gradient(energy8, x8), kind='cubic')
x_smooth8 = np.linspace(min(x6), max(x6), 200)

print("Max8: ", np.max(np.gradient(energy8, x8)))

plt.figure(figsize=(5, 3.3))

plt.plot(x_smooth4, f4(x_smooth4), label=r'$R_d=4$ nm', linewidth=2)
plt.plot(x_smooth6, f6(x_smooth6), label=r'$R_d=6$ nm', linewidth=2)
plt.plot(x_smooth8, f8(x_smooth8), label=r'$R_d=8$ nm', linewidth=2)
plt.xlabel('Radius (nm)')
plt.ylabel(r'$\partial E/\partial r$ (meV/nm)')
plt.tick_params(axis='both', which='major')
plt.grid(True)
plt.legend()
plt.tight_layout()

plt.savefig("force.svg")


