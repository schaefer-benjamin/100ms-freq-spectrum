# Created by Leonardo Rydin Gorjão. Most python libraries are standard (e.g. via
# Anaconda). If TeX is not present in the system comment out lines 13 to 16.

loc = 'data/'
import sys
sys.path.insert(0, loc)

import numpy as np
from numpy.polynomial.polynomial import polyfit

import matplotlib
import matplotlib.pyplot as plt
matplotlib.rcParams['pgf.texsystem'] = 'pdflatex'
matplotlib.rcParams.update({'font.family': 'serif', 'font.size': 18,
    'axes.labelsize': 20,'axes.titlesize': 24, 'figure.titlesize' : 28})
matplotlib.rcParams['text.usetex'] = True

colours = ['#e5f5f9', '#ccece6', '#99d8c9', '#66c2a4', '#41ae76', '#238b45',
           '#006d2c', '#00441b', '#fdcc8a', '#fc8d59', '#e34a33', '#b30000',
           '#8856a7', '#2ca25f', '#dd1c77', '#67a9cf', '#1c9099', '#016c59']

# This is based on the data used in the manuscript, from which not all the data
# can be fully made public. Adjust to your data accordingly.
labels = ['Ostrhauderfehn', 'Zeckern', 'Boretto', 'Großräschen', 'Dresden',
          'Lleida', 'Reisach', 'Meinerzhagen', 'Oldenburg', 'Karlsruhe',
          'Istanbul', 'Lisbon', 'Faroe Island', 'St.\,Petersburg', 'Stockholm',
          'Sweden North', 'Sweden Centre', 'Sweden South']

# %%
data = np.load('mfdfa_100ms.npz')
lag = data['lag']
q_list = data['q_list']
mfdfa = data['mfdfa']
slopes = np.zeros((15,80,3))
tau = np.zeros((15,80,3))
hq = np.zeros((15,80,3))
f = np.zeros((15,80,3))

for i in range(15):
    for j in range(80):
        slopes[i,j,0] = polyfit(np.log(lag)[2:7],
            np.log(mfdfa[i][2:7,j]),1)[1]   # -72
    tau[i,:,0] = q_list*slopes[i,:,0]-1
    hq[i,:,0] = np.gradient(tau[i,:,0])/np.gradient(q_list)
    f[i,:,0] = q_list*hq[i,:,0] - tau[i,:,0]

    for j in range(80):
        slopes[i,j,1] = polyfit(np.log(lag)[7:37],
            np.log(mfdfa[i][7:37,j]),1)[1]   # -72
    tau[i,:,1] = q_list*slopes[i,:,1]-1
    hq[i,:,1] = np.gradient(tau[i,:,1])/np.gradient(q_list)
    f[i,:,1] = q_list*hq[i,:,1] - tau[i,:,1]

    for j in range(80):
        slopes[i,j,2] = polyfit(np.log(lag)[37:],
            np.log(mfdfa[i][37:,j]),1)[1]   # -72
    tau[i,:,2] = q_list*slopes[i,:,2]-1
    hq[i,:,2] = np.gradient(tau[i,:,2])/np.gradient(q_list)
    f[i,:,2] = q_list*hq[i,:,2] - tau[i,:,2]


# %%
data = np.load('mfdfa_100ms_shuffle.npz')
lag_shuffle = data['lag']
q_list_shuffle = data['q_list']
mfdfa_shuffle = data['mfdfa']
slopes_shuffle = np.zeros((15,80,3))
tau_shuffle = np.zeros((15,80,3))
hq_shuffle = np.zeros((15,80,3))
f_shuffle = np.zeros((15,80,3))

for i in range(15):
    for j in range(80):
        slopes_shuffle[i,j,0] = polyfit(np.log(lag_shuffle)[2:7],
            np.log(mfdfa_shuffle[i][2:7,j]),1)[1]   # -72
    tau_shuffle[i,:,0] = q_list_shuffle*slopes_shuffle[i,:,0]-1
    hq_shuffle[i,:,0] = np.gradient(tau_shuffle[i,:,0])\
        /np.gradient(q_list_shuffle)
    f_shuffle[i,:,0] = q_list_shuffle*hq_shuffle[i,:,0] - tau_shuffle[i,:,0]

    for j in range(80):
        slopes_shuffle[i,j,1] = polyfit(np.log(lag_shuffle)[7:37],
            np.log(mfdfa_shuffle[i][7:37,j]),1)[1]   # -72
    tau_shuffle[i,:,1] = q_list_shuffle*slopes_shuffle[i,:,1]-1
    hq_shuffle[i,:,1] = np.gradient(tau_shuffle[i,:,1])\
        /np.gradient(q_list_shuffle)
    f_shuffle[i,:,1] = q_list_shuffle*hq_shuffle[i,:,1] - tau_shuffle[i,:,1]

    for j in range(80):
        slopes_shuffle[i,j,2] = polyfit(np.log(lag_shuffle)[37:],
            np.log(mfdfa_shuffle[i][37:,j]),1)[1]   # -72
    tau_shuffle[i,:,2] = q_list_shuffle*slopes_shuffle[i,:,2]-1
    hq_shuffle[i,:,2] = np.gradient(tau_shuffle[i,:,2])\
        /np.gradient(q_list_shuffle)
    f_shuffle[i,:,2] = q_list_shuffle*hq_shuffle[i,:,2] - tau_shuffle[i,:,2]

# %%
fig, ax = plt.subplots(3,2, figsize=(7,7));

for j in range(3):
    ax[j,0].plot(q_list,q_list*0 + 0.5,'--', color='k',zorder=2)
    ax[j,1].plot(q_list,q_list*0 + 0.5,'--', color='k',zorder=2)
    for i in range(11,12):
        ax[j,0].plot(q_list[:], hq[i,:,j], '-', lw=3, color=colours[i],
                     zorder=1)
        ax[j,1].plot(q_list[:], hq_shuffle[i,:,j], ':', lw=3, color=colours[i],
                     zorder=1)


ax[0,0].set_ylim([-1.2,4.2])
ax[1,0].set_ylim([-1.2,4.2])
ax[2,0].set_ylim([-0.3,2.1])

ax[0,1].set_ylim([-1.2,4.2])
ax[1,1].set_ylim([-1.2,4.2])
ax[2,1].set_ylim([-0.3,2.1])
ax[0,1].set_yticks([0,4,8])

[[ax[i,j].set_xticklabels([]) for i in range(2)] for j in range(2)]

[ax[i,1].yaxis.set_label_position('right') for i in range(3)]
[ax[i,1].yaxis.tick_right() for i in range(3)];

ax[0,0].patch.set_facecolor('k')
ax[0,0].patch.set_alpha(0.1)

ax[0,1].patch.set_facecolor('k')
ax[0,1].patch.set_alpha(0.1)

ax[0,0].text(.95,0.8,r'$0.4\sim1$ secs', fontsize=20,
             transform=ax[0,0].transAxes, ha ='right')
ax[1,0].text(.95,0.8,r'$1\sim4$ secs', fontsize=20,
             transform=ax[1,0].transAxes, ha ='right')
ax[2,0].text(.95,0.1,r'$4\sim10$ secs', fontsize=20,
             transform=ax[2,0].transAxes, ha ='right')

ax[0,1].text(.95,0.8,r'$0.4\sim1$ secs', fontsize=20,
             transform=ax[0,1].transAxes, ha ='right')
ax[1,1].text(.95,0.8,r'$1\sim4$ secs', fontsize=20,
             transform=ax[1,1].transAxes, ha ='right')
ax[2,1].text(.95,0.1,r'$4\sim10$ secs', fontsize=20,
             transform=ax[2,1].transAxes, ha ='right')

#
[ax[i,0].set_ylabel(r'$h(q)$') for i in range(3)]
[ax[i,1].set_ylabel(r'$h^{\mathrm{shuffled}}(q)$') for i in range(3)]
[ax[2,i].set_xlabel(r'$q$') for i in range(2)]

fig.subplots_adjust(left=0.11, bottom=0.1, right=.87, top=0.98,
                    hspace=0.05, wspace=0.05)
fig.savefig('Fig5.pdf', dpi=600, transparent = False)
