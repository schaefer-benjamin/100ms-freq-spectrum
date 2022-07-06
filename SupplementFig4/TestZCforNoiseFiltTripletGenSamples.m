%% Supplementary Fig. 4 --> Test signal generation
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

%% Test signal generation
% Sampling
fs = 25e3; %Raw Data Sampling Frequency
fsM = 0.1; %Frequency Data Sampling Frequency
f0 = 50.0000;
phi0 = 0;
A0 = sqrt(2)*230;

guard = 5; % seconds

%%
%Definition of cut off frequencies and corresponding signal durations
lenInSec = 3600;

t = linspace(0,lenInSec+2*guard - 1/fs,(lenInSec+2*guard)*fs);

%% 1: Sinosoidal signal with added white noise
s = A0 .* sin(2*pi*f0.*t); 
sDist = awgn(s,30,'measured');

%% No filter
savestring="\0_LPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sDist,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)

%% Filter 1 50 Hz LPF
Fn = fs/2;                                                          % Nyquist Frequency
Wp = 51/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 ].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'low');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability
figure
freqz(sos, 2^18, fs)                                                % Filter Bode Plot
set(subplot(2,1,1), 'XLim',[30 70])                                % Optional
set(subplot(2,1,2), 'XLim',[30 70])                                % Optional

sFilt1 = filtfilt(sos, g, sDist);
sFilt1(1:fs*guard) = [];
sFilt1(end-fs*guard+1:end) = [];

savestring="\1_LPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sFilt1,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)


%% Filter 2 50 Hz HPF
Fn = fs/2;                                                          % Nyquist Frequency
Wp = 49/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 ].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'high');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability
figure
freqz(sos, 2^18, fs)                                                % Filter Bode Plot
set(subplot(2,1,1), 'XLim',[30 70])                                % Optional
set(subplot(2,1,2), 'XLim',[30 70])                                % Optional

sFilt2 = filtfilt(sos, g, sDist);
sFilt2(1:fs*guard) = [];
sFilt2(end-fs*guard+1:end) = [];

savestring="\2_HPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sFilt2,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)


%% Filter 3 50 Hz BandPass  BW = 1 Hz
Fn = fs/2;                                                          % Nyquist Frequency
Wp = [49.5 50.5]/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 1.1].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'bandpass');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability

figure
freqz(sos, 2^18, fs)                                                % Filter Bode Plot
set(subplot(2,1,1), 'XLim',[30 70])                                % Optional
set(subplot(2,1,2), 'XLim',[30 70])                                % Optional

sFilt3 = filtfilt(sos, g, sDist);
sFilt3(1:fs*guard) = [];
sFilt3(end-fs*guard+1:end) = [];

savestring="\3_HPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sFilt3,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)


%% Filter 4 50 Hz BandPass  BW = 2 Hz
Fn = fs/2;                                                          % Nyquist Frequency
Wp = [49 51]/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 1.1].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'bandpass');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability

figure
freqz(sos, 2^18, fs)                                                % Filter Bode Plot
set(subplot(2,1,1), 'XLim',[30 70])                                % Optional
set(subplot(2,1,2), 'XLim',[30 70])                                % Optional

sFilt4 = filtfilt(sos, g, sDist);
sFilt4(1:fs*guard) = [];
sFilt4(end-fs*guard+1:end) = [];

savestring="\4_HPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sFilt4,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)

%% Filter 5 50 Hz BandPass BW = 4 Hz
Fn = fs/2;                                                          % Nyquist Frequency
Wp = [48 52]/Fn;                                                    % Stopband Frequency (Normalised)
Ws = [0.9 1.1].*Wp;                                                 % Passband Frequency (Normalised)
Rp =  1;                                                            % Passband Ripple
Rs = 90;                                                            % Passband Ripple (Attenuation)
[n,Wp] = ellipord(Wp,Ws,Rp,Rs);                                     % Elliptic Order Calculation
[z,p,k] = ellip(n,Rp,Rs,Wp,'bandpass');                                 % Elliptic Filter Design: Zero-Pole-Gain 
[sos,g] = zp2sos(z,p,k);                                            % Second-Order Section For Stability

figure
freqz(sos, 2^18, fs)                                                % Filter Bode Plot
set(subplot(2,1,1), 'XLim',[30 70])                                % Optional
set(subplot(2,1,2), 'XLim',[30 70])                                % Optional

sFilt5 = filtfilt(sos, g, sDist);
sFilt5(1:fs*guard) = [];
sFilt5(end-fs*guard+1:end) = [];

savestring="\5_HPFSineAWG\";
mkdir(pwd+savestring);
export_edr_xml(sFilt5,fs,datetime('2020-01-01 00:00:00'),pwd+savestring)



%% Plot spectrum of the filterd signal - for checks
nsc = 32768*2;
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));
%%
[pxx ,f] = pwelch(sFilt1,rectwin(nsc),nov,nff,fs,"onesided","power");
%%
[pxx ,f] = pwelch(sFilt2,rectwin(nsc),nov,nff,fs,"onesided","power");
%%
[pxx ,f] = pwelch(sFilt3,rectwin(nsc),nov,nff,fs,"onesided","power");
%%
[pxx ,f] = pwelch(sFilt4,rectwin(nsc),nov,nff,fs,"onesided","power");
%%
[pxx ,f] = pwelch(sFilt5,rectwin(nsc),nov,nff,fs,"onesided","power");
%%
fig=figure;
loglog(f,sqrt(pxx.*2)) % Plots the amplitude of the sine components
%loglog(f,pxx.*2) % Plot the power in V^2

xlabel("Frequency (Hz)",'Interpreter','Latex');
ylabel("Voltage (V)",'Interpreter','Latex');
legend('spectrum','Location','northeast','Interpreter','Latex');
set(gca,'TickLabelInterpreter','latex')
set(gcf, 'units', 'centimeters');
set(gcf, 'Position', [0, 0, 15, 9]);

specs(i).pxx = pxx;
specs(i).f = f;
%specs(i).filter = d3;
savefig("SpectrumAWGNFreqCutAt"+namestring+"mHz.fig");
saveas(fig,"SpectrumAWGNFreqCutAt"+namestring+"mHz.pdf");
saveas(fig,"SpectrumAWGNFreqCutAt"+namestring+"mHz.png");
