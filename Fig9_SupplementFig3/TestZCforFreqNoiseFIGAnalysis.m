%% Fig. 9 and Supplementary Fig. 3 --> PSD estimation and plot generation
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

%% Load data
q2 = load("Data\6\EDR9999_20200101-0000_20200101-0100.mat"); %snr 30 db
q3 = load("Data\7\EDR9999_20200101-0000_20200101-0100.mat"); %snr 60 db

%% Fig. 9
Nx = length(q2.out100TT.freqPP);
nsc = floor(Nx/50);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));
fToInput = [q2.out100TT.freqPP-mean(q2.out100TT.freqPP),...
    q3.out100TT.freqPP-mean(q3.out100TT.freqPP)];
[pxx ,f] = pwelch(fToInput,hann(nsc),nov,nff,10,"psd");

disp("100ms values power: " +rms(fToInput).^2);

fToInput = [q2.outTT.freqPP-mean(q2.outTT.freqPP),...
    q3.outTT.freqPP-mean(q3.outTT.freqPP)];
[pxx3 ,f3] = pwelch(fToInput,hann(nsc),nov,nff,1);

disp("1s RT values power: " +rms(fToInput).^2);

figure
loglog(f(1:end-1,:), pxx(1:end-1,:))
hold on
loglog(f3(1:end-1,:),pxx3(1:end-1,:))
line([1/20 1/0.2],[0.003 30],'color','k')
line([0.005 5],[1e-2 1e-2],'color','k','LineStyle','--');
xlim([0.005 5])
ylim([1e-7 1e2])
xticks([0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5]);
yticks([1e-6 1e-4 1e-2 1 1e2]);

legend("30dB 100ms","60dB 100ms","30dB 1s","60dB 1s",'location','nw','interpreter','latex')
xlabel("f [Hz]",'interpreter','latex')
ylabel("$\mathcal{S}(f)~\left[\frac{\mathrm{mHz}^2}{\mathrm{Hz}}\right]$",'interpreter','latex')
set(gca,'TickLabelInterpreter','latex')

set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [0, 0, 13, 7]);
savefig('FreqAddNoiseResolDepPP.fig');
saveas(gcf,'FreqAddNoiseResolDepPP.pdf');
saveas(gcf,'FreqAddNoiseResolDepPP.png');

%% Fig 13
Nx = length(q2.out100TT.freqPP);
nsc = floor(Nx/50);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));
fToInput = [q2.out100TT.freqPP-mean(q2.out100TT.freqPP),...
    q2.out100TT.freq-mean(q2.out100TT.freq)...
    q3.out100TT.freqPP-mean(q3.out100TT.freqPP),...
    q3.out100TT.freq-mean(q3.out100TT.freq)];
[pxx ,f] = pwelch(fToInput,hann(nsc),nov,nff,10);
time = 1./f;


fToInput = [q2.outTT.freqPP-mean(q2.outTT.freqPP),...
    q3.outTT.freqPP-mean(q3.outTT.freqPP)];
[pxx3 ,f3] = pwelch(fToInput,hann(nsc),nov,nff,1);
time3 = 1./f3;

figure
loglog(f(1:end-1,:), pxx(1:end-1,:))
hold on
line([1/10 1/0.2],[0.02 13],'color','k')
line([1/20 1/1],[1.5e-1 1.5e-1],'color','k')
xlim([0.005 5])
ylim([1e-7 1e2])

xticks([0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5]);
yticks([1e-6 1e-4 1e-2 1 1e2]);

legend("30dB PP","30dB FP","60dB PP","60dB FP",'location','se','interpreter','latex')
xlabel("f [Hz]",'interpreter','latex')
ylabel("$S(f)~\left[\frac{\mathrm{mHz^2}}{\mathrm{Hz}}\right]$",'interpreter','latex')
set(gca,'TickLabelInterpreter','latex')

set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [0, 0, 13, 7]);
savefig('FreqAddNoisePPvsFP.fig');
saveas(gcf,'FreqAddNoisePPvsFP.pdf');
saveas(gcf,'FreqAddNoisePPvsFP.png');
