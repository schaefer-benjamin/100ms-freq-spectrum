# Created by Leonardo Rydin Gorjão. Most python libraries are standard (e.g. via
# Anaconda). If TeX is not present in the system comment out lines 11 to 24.

loc = 'data/'
import sys
sys.path.insert(0, loc)

import numpy as np

import matplotlib
matplotlib.rcParams['pgf.texsystem'] = 'pdflatex'
matplotlib.rcParams.update({'font.family': 'serif', 'font.size': 18,
    'axes.labelsize': 20,'axes.titlesize': 24, 'figure.titlesize' : 28})
matplotlib.rcParams['text.usetex'] = True
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

colours = ['#e41a1c','#377eb8','#4daf4a','#984ea3']
labels = ['Karlsruhe', 'Oldenburg', 'Istanbul', 'Lisbon']

with np.load(loc + 'data_100ms.npz') as data:
    OL = data['OL'][:200]
    KA = data['KA'][:200]
    IS = data['IS'][:200]
    LI = data['LI'][:200]

with np.load(loc+'data_1s.npz')as data:
    OL1s = data['OL'].flatten()[:20]
    KA1s = data['KA'].flatten()[:20]
    IS1s = data['IS'].flatten()[:20]
    LI1s = data['LI'].flatten()[:20]

# %%
fig, ax = plt.subplots(figsize=(7,4))

ax0 = ax.inset_axes([0.043, 0.64, 0.33, 0.33])
ax0.set_xticks([]); ax0.set_yticks([])

ax.plot(np.linspace(0,20,OL[:200].size), OL[:200], label=labels[0],
        color=colours[0])
ax.plot(np.linspace(0,20,OL1s[:20].size), OL1s[:20], 'o-',
        color=colours[0], lw=2)
ax.plot(np.linspace(0,20,KA[:200].size), KA[:200], label=labels[1],
        color=colours[1])
ax.plot(np.linspace(0,20,KA1s[:20].size), KA1s[:20], 'o-',
        color=colours[1], lw=2)
ax.plot(np.linspace(0,20,IS[:200].size), IS[:200], label=labels[2],
        color=colours[2])
ax.plot(np.linspace(0,20,IS1s[:20].size), IS1s[:20], 'o-',
        color=colours[2], lw=2)
ax.plot(np.linspace(0,20,LI[:200].size), LI[:200], label=labels[3],
        color=colours[3])
ax.plot(np.linspace(0,20,LI1s[:20].size), LI1s[:20], 'o-',
        color=colours[3], lw=2)

ax0.plot(np.linspace(6,11,LI[:50].size), LI[60:110], label=labels[3],
    color=colours[3],lw=2);
ax0.plot(np.linspace(6,11,LI1s[:5].size), LI1s[6:11], 'o-',
    color=colours[3], lw=3, ms=10)
ax0.set_xlim([6.7,10.3])
ax0.set_ylim([20.5,25.5])

rect = mpatches.Rectangle((6.7,20.5), 3.6, 5, linewidth=0.7, edgecolor='black',
                          facecolor='none',zorder=10)
ax.add_patch(rect)
ax.plot([6.7,0],[25.5,28.5],color='black', lw =0.7)
ax.plot([10.3,7.2],[25.5,28.5],color='black', lw =0.7)
ax.set_ylim([None,40])

ax.set_ylabel(r'$f(t)-50$Hz [mHz]')
ax.set_xlabel(r'$t$ [s]')
ax.legend(loc=2, ncol=4,fontsize=18, handlelength=.5, handletextpad=0.2,
          columnspacing=0.6, bbox_to_anchor=(0.07,1.24))
fig.subplots_adjust(left=0.14, bottom=0.18, right=.99, top=0.86,
    hspace=0.38, wspace=0.1)
fig.savefig('Fig1.pdf', transparent=True)
