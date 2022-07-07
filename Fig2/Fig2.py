# Created by Leonardo Rydin Gorjão. Most python libraries are standard (e.g. via
# Anaconda). If TeX is not present in the system comment out lines 20 to 23.

loc = 'data/'
import sys
sys.path.insert(0, loc)

import numpy as np
import pandas as pd
from scipy.signal import welch, sosfilt

# Note that these two packages are not standard installation and can be
# complicated to install. They are only used to plot the map in subplot a. To
# avoid overhead, avoid installing these, and comment the two lines below and
# the lines that plot the map: Lines 81-82
import geopandas
import geoplot

import matplotlib
matplotlib.rcParams['pgf.texsystem'] = 'pdflatex'
matplotlib.rcParams.update({'font.family': 'serif', 'font.size': 18,
    'axes.labelsize': 20,'axes.titlesize': 24, 'figure.titlesize' : 28})
matplotlib.rcParams['text.usetex'] = True
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.ticker import NullFormatter, LogLocator
from matplotlib.lines import Line2D

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
fig, ax = plt.subplots(2,2,figsize=(16,11))

# Comment these two lines to prevent the map from being plotted.
world = geopandas.read_file(geopandas.datasets.get_path("naturalearth_lowres"))
world.plot(ax = ax[0,0], color='#c6c6c6');

[ax[0,0].scatter(coord[i][0],coord[i][1], color = colours[i], s=120,
                 edgecolors='k') for i in range(len(labels))]
ax[0,0].set_xlim([-21,41]); ax[0,0].set_ylim([36,68]);

# [ax[1,0].loglog(f_p[i][0][10:], f_p[i][1][10:], lw=2, label=labels[i],
#                 color=colours[i]) for i in range(8)];
[ax[1,1].loglog(f_p[i][0][10:], f_p[i][1][10:], lw=2, label=labels[i+8],
                color=colours[i+8]) for i in range(4)];
[ax[0,1].loglog(f_p[i][0][10:], f_p[i][1][10:], lw=2, label=labels[i+8],
                color=colours[i+8]) for i in range(4,7)];
[ax[0,1].loglog(f_p[i][0][10:], 1000*f_p[i][1][10:], lw=2, label=labels[i+8],
                color=colours[i+8]) for i in range(7,10)];

ax[1,0].loglog(f_p[0][0][10:100],0.005*f_p[0][0][10:100]**-2.7,'--', lw=2.5,
               color='k')
ax[1,0].loglog(f_p[0][0][205:],0.04*f_p[0][0][205:]**.7,':', lw=2.5,
               color='k')
ax[1,1].loglog(f_p[0][0][10:100],0.005*f_p[0][0][10:100]**-2.7,'--', lw=2.5,
               color='k')
ax[1,1].loglog(f_p[0][0][205:],0.008*f_p[0][0][205:]**.7,':', lw=2.5,
               color='k')

ax[1,0].fill_betweenx([1e-8,1e3], 1, 5, fc='k', interpolate=True, alpha=0.1)
ax[0,1].fill_betweenx([1e-8,1e6], 1, 5, fc='k', interpolate=True, alpha=0.1)
ax[1,1].fill_betweenx([1e-8,1e6], 1, 5, fc='k', interpolate=True, alpha=0.1)
ax[0,1].set_ylabel(r'$\mathcal{S}(f)$ [$\frac{\mathrm{mHz}^2}{\mathrm{Hz}}$]',
    labelpad=3, fontsize=22)
ax[1,0].set_ylabel(r'$\mathcal{S}(f)$ [$\frac{\mathrm{mHz}^2}{\mathrm{Hz}}$]',
    labelpad=3, fontsize=22)
ax[1,1].set_ylabel(r'$\mathcal{S}(f)$ [$\frac{\mathrm{mHz}^2}{\mathrm{Hz}}$]',
    labelpad=3, fontsize=22)

ax[0,0].set_ylabel(r'Latitude', fontsize=22)
ax[0,0].set_xlabel(r'Longitude', fontsize=22)
ax[1,0].set_xlabel(r'$f$ [Hz]', fontsize=22)
ax[1,1].set_xlabel(r'$f$ [Hz]', fontsize=22)
ax[0,1].set_xlabel(r'$f$ [Hz]', fontsize=22)
ax[1,0].set_ylim([7e-3,2e2]);
ax[1,1].set_ylim([7e-3,2e2]);
ax[0,1].set_ylim([4e-4,8e4]);

ax[0,1].set_xticks([0.05,0.1,0.2,0.5,1,2,5])
ax[0,1].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))
# ax[0,1].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))

ax[1,0].set_xticks([0.05,0.1,0.2,0.5,1,2,5])
ax[1,0].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))
# ax[1,0].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))
ax[1,1].set_xticks([0.05,0.1,0.2,0.5,1,2,5])
ax[1,1].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))
# ax[1,1].set_xticklabels(np.array([0.05,0.1,0.2,0.5,1,2,5]))

y_major = LogLocator(base = 10.0, numticks = 10)
ax[1,0].yaxis.set_major_locator(y_major)
ax[1,1].yaxis.set_major_locator(y_major)
y_minor = LogLocator(base=10.0, subs=np.arange(1,10)*0.1, numticks=10)
ax[0,1].yaxis.set_minor_locator(y_minor)
ax[1,0].yaxis.set_minor_locator(y_minor)
ax[1,1].yaxis.set_minor_locator(y_minor)
ax[1,0].yaxis.set_minor_formatter(NullFormatter())
ax[0,1].yaxis.set_minor_formatter(NullFormatter())
ax[1,1].yaxis.set_minor_formatter(NullFormatter())

L = [Line2D([0],[0],marker='o', markersize=11, lw = 0, color=colours[i],
            markeredgecolor='k', label=labels[i]) for i in order]
leg0 = ax[0,1].legend(handles=L,ncol=6,fontsize=18, handlelength=.8,
                    handletextpad = 0.5, columnspacing=0.6,
                    bbox_to_anchor=(.7,1.41))
ax[0,1].add_artist(leg0)
ax[1,0].set_xlim([1/20, 5]);
ax[0,1].set_xlim([1/20, 5])
ax[1,1].set_xlim([1/20, 5]);

ax[0,0].text(-0.12,0.93,r'\textbf{a}', fontsize=26,
    transform=ax[0,0].transAxes)
ax[0,1].text(-0.12,0.93,r'\textbf{b}', fontsize=26,
    transform=ax[0,1].transAxes)
ax[1,0].text(-0.12,0.93,r'\textbf{c}', fontsize=26,
    transform=ax[1,0].transAxes)
ax[1,1].text(-0.12,0.93,r'\textbf{d}', fontsize=26,
    transform=ax[1,1].transAxes)

ax[1,0].text(0.25,0.25,r'$-\beta$', fontsize=26,
    transform=ax[1,0].transAxes)
ax[1,0].text(0.87,0.13,r'$\gamma$', fontsize=26,
    transform=ax[1,0].transAxes)

ax[1,0].text(0.03,.05,r'\textbf{GridRadar}', fontsize=20,
    transform=ax[1,0].transAxes)
ax[1,1].text(0.03,.05,r'\textbf{EDR}', fontsize=20,
    transform=ax[1,1].transAxes)
ax[0,1].text(0.03,.25,r'\textbf{Faroe}', fontsize=20,
    transform=ax[0,1].transAxes)
ax[0,1].text(0.03,.15,r'\textbf{Russia}', fontsize=20,
    transform=ax[0,1].transAxes)
ax[0,1].text(0.03,.05,r'\textbf{Nordic\,Grid}', fontsize=20,
    transform=ax[0,1].transAxes)

ax_ = [ax[1,0].twiny(), ax[1,1].twiny()]

[ax_[i].xaxis.set_ticks_position("bottom") for i in [0,1]]
[ax_[i].xaxis.set_label_position("bottom") for i in [0,1]]
[ax_[i].set_xscale('log') for i in [0,1]]
[ax_[i].set_xlim([0.05,5]) for i in [0,1]]
[ax_[i].set_xticks([0.05,0.1,0.2,0.5,1,2,5]) for i in [0,1]]
[ax_[i].set_xticklabels(1/np.array([0.05,0.1,0.2,0.5,1,2,5])) for i in [0,1]]

[ax_[i].set_xlabel(r'$t$ [s]', fontsize=22) for i in [0,1]]
[ax_[i].spines["bottom"].set_position(("axes", -0.25)) for i in [0,1]]

fig.subplots_adjust(left=0.07, bottom=0.15, right=.99, top=0.86,
                    hspace=0.25, wspace=0.15)
fig.savefig(loc + 'Fig2.pdf', dpi=600, transparent = True)
