%% Fig. 10
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

%% get raw data from: https://osf.io/by5hu/
% subfolder WaveformData/SE01
% Warning: This file is ~ 1Gb in size.
Samples = readmatrix("SE01raw_2019-05-09_20-35-00.csv");
Fs = 25000;

%% make an overview plot on how the spectrum of the voltage waveform looks like
% start with resampling to avoid scalloping loss and leakage
FsRsp = 32768;
rsp = resample(Samples,FsRsp,Fs);
rsp(1:100) = [];

%% check signal integrety  (resampling works)
figure
plot(0:1/Fs:1-1/Fs,Samples(1:Fs))
hold
plot(0:1/FsRsp:1-1/FsRsp,rsp(1:FsRsp))

%% Make a combined Spectrum and Signal Plot -requires the above figures for data generation
t = 0:1/25000:1-1/25000;
sref = -325.*sin(2*pi*50*t(1:1000));
sref = awgn(sref,30,'measured');

Nx = length(rsp);
nsc = floor(Nx/1);
nsc = 32768; %point FFT -> Freq Resolution 1Hz
nov = floor(nsc/2);
%nov = 0;
nff = max(256,2^nextpow2(nsc))
[pxx ,f] = pwelch(rsp,hann(nsc),nov,nff,FsRsp,"onesided","power");
% Plots the amplitude (V) of the sine components
pxxNorm = sqrt(pxx.*2)./max(sqrt(pxx.*2));

fig=figure;
subplot(2,1,1)
plot(t(1:1000)*1000,Samples((351:1350)))
xlim([0,30]);
xlabel("Time [ms]",Interpreter="latex")
ylabel("$u(t)$ [V]",Interpreter="latex")
xaxisproperties= get(gca, 'XAxis');
set(gca,'TickLabelInterpreter','latex')

subplot(2,1,2)

semilogx(f,20.*log(pxxNorm)./log(10))
xlim([1e1 12500])
ylim([-105 0])
xticks([10 20 50 100 200 500 1000 2000 5000])
yticks(fliplr([0 -20 -40 -60 -80 -100]))
% Plot the power in V^2:
%pxxNorm = pxx.*2./max(pxx.*2);
%loglog(f,pxxNorm) % Plots the amplitude of the sine components
xlabel("Frequency [Hz]",Interpreter="latex")
ylabel("$\mathcal{S}(u)$ [dB]",Interpreter="latex")
xaxisproperties= get(gca, 'XAxis');
set(gca,'TickLabelInterpreter','latex')


set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [0, 0, 10, 7]);
savefig('CombVoltFormAndSpect.fig');
saveas(gcf,'CombVoltFormAndSpect.pdf');
saveas(gcf,'CombVoltFormAndSpect.png');


%% Part 2: Extract all noise -> suppress 50 Hz compnent
Fn = Fs/2;                                                          % Nyquist Frequency
Wp = [49 51]/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 1.1].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'stop');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability

% Filter signal to extract only the noise
signal_filt = filtfilt(sos, g, Samples);    
% delete the initial ringing
signal_filt(1:10*Fs) = [];
% calculate signal properties
SignalProps.rmsAllButFund = rms(signal_filt);
SignalProps.SINAD_sub = rms(Samples(10*Fs+1:end))/rms(signal_filt);
SignalProps.SINADdb_sub = 20*log(SignalProps.SINAD_sub)/log(10);

%% Part 3: Reapeat but this time also suppress n odd harmonics
run("Make10HarmonicFilterCascade.m");
%%
s_filt = applyFilterStack(FilterStack,Samples);

%%
s_filt(1:10*Fs) = [];

%% Determine some noise figures
SignalProps.rmsNoise = rms(s_filt);
SignalProps.rmsAll = rms(Samples(10*Fs+1:end));
SignalProps.SINAD = SignalProps.rmsAll/SignalProps.rmsNoise;
SignalProps.SINADdb = 20*log(SignalProps.SINAD)/log(10);

