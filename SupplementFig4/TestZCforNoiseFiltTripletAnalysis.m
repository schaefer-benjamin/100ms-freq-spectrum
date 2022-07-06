%% Supplementary Fig. 4 --> Analyse the frequency estimates and make plot
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

% Set up: We have superimposed a sine (const. freq) with noise.
% We used filters to restrict the bandwidth of the resulting signal:
% a) a low pass to eliminate everyting above 50 Hz
% b) a high pass to eliminate everything above 50 Hz 
% c) a bandpass to only let the 50 Hz component pass (in different 
% bandwidth settings)
% These data are in the numbered folders under /Data. 
% We now analyze the psd of the frequency estimates.
%
% Why dont we have steep filters like this in the estimation algorithm?
% Because they have poor (VERY long) step responses and therefore only 
% "work" for steady state conditions (=this test)

%%
listMeasured = MakeMatFileList("Data/**/*.mat");
%%

for k=1:height(listMeasured)
   myPath = listMeasured.name(k); 
   input(k,:) = load(listMeasured.folder(k,:)+"/"+listMeasured.name(k,:))

   freqPP(k,:) = input(k,:).out100TT.freqPP(1:36000); % manual curtailing, adjust / automate
   freqFP(k,:) = input(k,:).out100TT.freq(1:36000); 
end

%% Make plot
Nx = length(freqPP(1,:));
nsc = floor(Nx/18);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));

[pxx ,f] = pwelch(freqPP.',hann(nsc),nov,nff,10);
figure
time = 1./f;
loglog(time, pxx)
set ( gca, 'xdir', 'reverse' )
hold on

xlim([0.2 100])
ylim([1e-5 1e2])

xticks(fliplr([100 50 20 10 5 2 1 0.5 0.2]));
legend("51Hz LPF","49Hz HPF","50Hz BPF (BW 1Hz)","50Hz BPF (BW 2Hz)","50Hz BPF (BW 4Hz)",'location','nw','interpreter','latex')
xlabel("t [s]",'interpreter','latex')
ylabel("$S(f)~\left[\frac{\mathrm{mHz}}{\sqrt{\mathrm{Hz}}}\right]$",'interpreter','latex')
set(gca,'TickLabelInterpreter','latex')

set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [0, 0, 15, 9]);
savefig('FreqAddNoisePP.fig');
saveas(gcf,'FreqAddNoisePP.pdf');
saveas(gcf,'FreqAddNoisePP.png');
