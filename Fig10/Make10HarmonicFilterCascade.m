%% Helper: Build a cascade of filters
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
Fs = 25000;                                                         % Sampling Frequency
Fn = Fs/2;                                                          % Nyquist Frequency

FilterStack = {};

freqEval = (1:2:11) * 50; %[100 150 200 etc.]

for i = 1:length(freqEval)
   CutOffFreqs(i,1) = freqEval(i)-1/50.*freqEval(i);
   CutOffFreqs(i,2) = freqEval(i)+1/50.*freqEval(i);
   
   Wp = [CutOffFreqs(i,1)  CutOffFreqs(i,2)]/Fn;      % Stopband Frequency (Normalised)
   Ws = [0.9 1.1].*Wp;                                % Passband Frequency (Normalised)
   Rp =  1;                                           % Passband Ripple
   Rs = 90;                                           % Passband Ripple (Attenuation)
   [n,Wp] = ellipord(Wp,Ws,Rp,Rs);                    % Elliptic Order Calculation
   [z,p,k] = ellip(n,Rp,Rs,Wp,'stop');                % Elliptic Filter Design: Zero-Pole-Gain 
   [sos,g] = zp2sos(z,p,k);
   FilterStack{i,1} = sos;
   FilterStack{i,2} = g; 
end