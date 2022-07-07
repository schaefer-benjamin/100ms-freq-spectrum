# Created by Leonardo Rydin Gorjão. Most python libraries are standard (e.g. via
# Anaconda). If TeX is not present in the system comment out lines 15 to 18.

loc = 'data/'
import sys
sys.path.insert(0, loc)

import numpy as np
from scipy.signal import welch, sosfilt

from MFDFA import fgn

import matplotlib
import matplotlib.pyplot as plt
matplotlib.rcParams['pgf.texsystem'] = 'pdflatex'
matplotlib.rcParams.update({'font.family': 'serif', 'font.size': 18,
    'axes.labelsize': 20,'axes.titlesize': 24, 'figure.titlesize' : 28})
matplotlib.rcParams['text.usetex'] = True
from matplotlib.lines import Line2D

colours = ['#e5f5f9', '#ccece6', '#99d8c9', '#66c2a4', '#41ae76', '#238b45',
           '#006d2c', '#00441b', '#fdcc8a', '#fc8d59', '#e34a33', '#b30000',
           '#8856a7', '#2ca25f', '#dd1c77', '#67a9cf', '#1c9099', '#016c59']

labels = ['Ostrhauderfehn', 'Zeckern', 'Boretto', 'Großräschen', 'Dresden',
          'Lleida', 'Reisach', 'Meinerzhagen', 'Oldenburg', 'Karlsruhe',
          'Istanbul', 'Lisbon', 'Faroe Island', 'St.\,Petersburg', 'Stockholm',
          'Sweden North', 'Sweden Centre', 'Sweden South']

# %%
with np.load(loc + 'data_100ms.npz') as data:
    LI = data['LI']

ts = [LI]
ts = {key: ts[i] for i, key in enumerate([labels[11]])}

f_p = [welch(ts[ele],fs=10, nperseg=1024*2) for ele in ts]

# %%
t_final = 3456000/1000
delta_t = 0.001

# Some drift theta and diffusion sigma parameters
theta = 0
sigma = 20
# The time array of the trajectory
time = np.arange(0, t_final, delta_t)

# The fractional Gaussian noise
H = 0.65
dB = (t_final ** H) * fgn(N = time.size, H = H)

# Initialise the array y
y = np.zeros([time.size])

# Integrate the process
for i in range(1, time.size):
   y[i] = y[i-1] - theta * y[i-1] * delta_t + sigma * dB[i]

# %%
fig, ax = plt.subplots(1,1,figsize=(7,5.5))
[ax.loglog(f_p[i][0][10:-1], f_p[i][1][10:-1], lw=2, label=labels[i+11],
              color=colours[i+11]) for i in [0]];

f_, w_ = welch((y),fs=10, nperseg=1024*2)
ax.loglog(f_[10:-1],w_[10:-1], '--', color='black', lw=2)
f_, w_ = welch((y + 7*fgn(y.size, H=0.1)),fs=10, nperseg=1024*2)
ax.loglog(f_[10:-1], w_[10:-1], color='black', lw=2)

ax.fill_betweenx([1e-4,1e3], 1, 5, fc='black', interpolate=True, alpha = 0.1)
ax.set_xlim([None, 5]);
ax.set_ylim([2e-3, 2e2]);

ax.set_xticks([0.05,0.1,0.2,0.5,1,2,5])
ax.set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))

y_major = matplotlib.ticker.LogLocator(base = 10.0, numticks = 10)
ax.yaxis.set_major_locator(y_major);
y_minor = matplotlib.ticker.LogLocator(base=10.0, subs=np.arange(1,10)*0.1,
                                       numticks=10)
ax.yaxis.set_minor_locator(y_minor);
ax.yaxis.set_minor_formatter(matplotlib.ticker.NullFormatter())


L = [Line2D([0],[0],ls='--', lw = 2, color='black', label='Power law'),
     Line2D([0],[0],ls='-', lw = 2, color='black',
        label='Power law + fluctuations')]
leg0 = ax.legend(handles=L, ncol=1, loc=3, fontsize=18, handlelength=1,
                 handletextpad=0.5, columnspacing=0.6)

ax.add_artist(leg0)
ax.set_xlim([0.05,5])
ax_ = ax.twiny()

ax_.xaxis.set_ticks_position("bottom")
ax_.xaxis.set_label_position("bottom")
ax_.set_xscale('log')
ax_.set_xlim([0.05,5])
ax_.set_xticks([0.05,0.1,0.2,0.5,1,2,5])
ax_.set_xticklabels(1/np.array([0.05,0.1,0.2,0.5,1,2,5]))
ax_.set_xlabel(r'$t$ [s]', fontsize=22)
ax_.spines["bottom"].set_position(("axes", -0.19))

ax.set_ylabel(r'$\mathcal{S}(f)$ [$\frac{\mathrm{mHz}^2}{\mathrm{Hz}}$]',
    labelpad=3, fontsize=22)
ax.set_xlabel(r'$f$ [Hz]', fontsize=20)
ax.legend(loc=1,ncol=1,fontsize=22, handlelength=.5,
          handletextpad=0.2, columnspacing=0.6)
fig.subplots_adjust(left=0.15, bottom=0.27, right=.97, top=0.99,
                    hspace=0.03, wspace=0.05)
# fig.savefig('Fig6.pdf', transparent = True)
