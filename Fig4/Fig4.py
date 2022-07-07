# Created by Leonardo Rydin Gorjão. Most python libraries are standard (e.g. via
# Anaconda). If TeX is not present in the system comment out lines 12 to 15.

loc = 'data/'
import sys
sys.path.insert(0, loc)

import numpy as np
from scipy.signal import welch, sosfilt

import matplotlib
matplotlib.rcParams['pgf.texsystem'] = 'pdflatex'
matplotlib.rcParams.update({'font.family': 'serif', 'font.size': 18,
    'axes.labelsize': 20,'axes.titlesize': 24, 'figure.titlesize' : 28})
matplotlib.rcParams['text.usetex'] = True
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.lines import Line2D
import matplotlib.patheffects as mpe

colours = ['#e5f5f9', '#ccece6', '#99d8c9', '#66c2a4', '#41ae76', '#238b45',
           '#006d2c', '#00441b', '#fdcc8a', '#fc8d59', '#e34a33', '#b30000',
           '#8856a7', '#2ca25f', '#dd1c77', '#67a9cf', '#1c9099', '#016c59']

# This is based on the data used in the manuscript, from which not all the data
# can be fully made public. Adjust to your data accordingly. The first entries
# in this list will not the plotted.
labels = ['Ostrhauderfehn', 'Zeckern', 'Boretto', 'Großräschen', 'Dresden',
          'Lleida', 'Reisach', 'Meinerzhagen', 'Oldenburg', 'Karlsruhe',
          'Istanbul', 'Lisbon', 'Faroe Island', 'St.\,Petersburg', 'Stockholm',
          'Sweden North', 'Sweden Centre', 'Sweden South']

coord = [[7.618060 , 53.139870], [10.938350, 49.691860], [10.556290, 44.904259],
         [14.013620, 51.586971], [13.737262, 51.050407], [0.625800 , 41.614159],
         [13.153930, 46.649360], [7.640170 , 51.106709],
         [8.216540 , 53.136719], [8.403653 , 49.006889], [28.978359, 41.008240],
         [-9.139337, 38.722252], [-7.1, 62.1], [30.3, 59.8], [18.1,59.3],
         [19.323426, 66.353562], [15.205319, 63.126178], [14.511484, 58.310608]]

order = list(np.linspace(0,17,18,dtype=int).reshape(-1,6).T.flatten())

# %%
# with np.load(loc+'missing_locations_data.npz') as data:
#     ts = data['ts']
#
# ts = [ts[:,i] for i in range(8)]

with np.load(loc + 'data_100ms.npz') as data:
    OL = data['OL']
    KA = data['KA']
    IS = data['IS']
    LI = data['LI']
    FO = data['FO']
    RUS = data['RUS']
    SE = data['SE']

with np.load(loc+'swedish_data_100ms.npz') as data:
    north = data['north']
    mid = data['mid']
    south = data['south']

# Transform list to dictionary
ts = [elem for elem in [OL, KA, IS, LI, FO, RUS, SE, north, mid, south]]
ts = {key: ts[i] for i, key in enumerate(labels[8:])}

# %% Estimate the power spectral density with the Welch method
f_p = [welch(ts[ele],fs=10, nperseg=1024*2) for ele in ts]

# %%

def fits_to_spectrum_low(f, spectrum):
    line, b = np.polyfit(np.log(f[5:105]), np.log(spectrum[5:105]), 1)
    error = np.round(np.sqrt(np.diag(np.polyfit(np.log(f[5:105]),
        np.log(spectrum[5:105]), 1, cov = True)[1])[0]),3)
    print('{:.3f}'.format(line) + ' \pm ' + '{:.3f}'.format(error))
    return 0, line, b

def fits_to_spectrum_high(f, spectrum, cutoff = 0.01):
    mask = np.abs(np.gradient(spectrum[308:-10])) < cutoff
    line, b = np.polyfit(np.log(f[308:-10][mask]), np.log(spectrum[308:-10][mask]), 1)
    error = np.round(np.sqrt(np.diag(np.polyfit(np.log(f[308:-10][mask]),
        np.log(spectrum[308:-10][mask]), 1, cov = True)[1])[0]),3)
    print('{:.3f}'.format(line) + ' \pm ' + '{:.3f}'.format(error))
    return mask, line, b

# %%
fig, ax = plt.subplots(1,1,figsize=(7,4.5))

fancybox1 = mpatches.FancyBboxPatch( [1.7, -1.7], 1.5, 0.5,
    boxstyle=mpatches.BoxStyle("Round", pad=0.4), edgecolor='k', alpha=0.5,
    facecolor='None', lw=2, ls='--')

fancybox2 = mpatches.FancyBboxPatch( [1.7, -.3], 1.5, 0.5,
    boxstyle=mpatches.BoxStyle("Round", pad=0.4), edgecolor='k', alpha=0.5,
    facecolor='None', lw=2, ls='--')

fancybox3 = mpatches.FancyBboxPatch( [1.7, 1.1], 1.5, 0.5,
    boxstyle=mpatches.BoxStyle("Round", pad=0.4), edgecolor='k', alpha=0.5,
    facecolor='None', lw=2, ls='--')

[ax.scatter(-1.*mask_high[i][1], mask[i][1], marker = 'o', s=150,
            color=colours[i+8], edgecolor='k') for i in range(15-8)]
[ax.scatter(-1.*mask_high_sweden[i][1], mask_sweden[i][1], marker='o', s=150,
            color=colours[i+15], edgecolor='k') for i in range(3)]

ax.plot([3.5,1.5], [0,0], '--', color='k', alpha=1, lw=2)

ax.set_ylim([-2.2,2.2])
ax.set_xlim([1.2,3.7])

ax.add_artist(fancybox1)
ax.add_artist(fancybox2)
ax.add_artist(fancybox3)

ax.set_xlabel(r'$\beta$'); ax.set_ylabel(r'$\gamma$')

fig.text(0.82, 0.31,'decreasing', ha='left', fontsize=20)
fig.text(0.82, 0.24,'spectrum', ha='left', fontsize=20)
fig.text(0.82, 0.57,'flat', ha='left', fontsize=20)
fig.text(0.82, 0.5,'spectrum', ha='left', fontsize=20)
fig.text(0.82, 0.85,'increasing', ha='left', fontsize=20)
fig.text(0.82, 0.79,'spectrum', ha='left', fontsize=20)

fig.subplots_adjust(left=0.11, bottom=0.15, right=.80, top=0.99,
                    hspace=0.03, wspace=0.05)
fig.savefig(loc+'Fig4.pdf', dpi=600, transparent = True)
