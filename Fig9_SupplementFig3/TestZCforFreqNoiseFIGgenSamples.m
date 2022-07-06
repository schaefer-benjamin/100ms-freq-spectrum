%% Fig. 9 and Supplementary Fig. 3 --> Test signal generation
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

% Sampling and length
fs = 25e3;
lenInSec = 3600;
t = linspace(0,lenInSec-1/fs,lenInSec*fs);

% Sampling (reporting rate) of the aggregated data
fsAgg = 10;

% Signal setup
f0 = 50.000;
phi0 = 0;
A0 = sqrt(2)*230;

%% 6: Sinosoidal signal with quantization noise (in the export)
s = A0 .* sin(2*pi*f0.*t); 
sDist = awgn(s,30,'measured');
mkdir(pwd + "/Data/6/")
export_edr_xml(sDist,fs,datetime('2020-01-01 00:00:00'),"Data\6\");

%% 7: Sinosoidal signal with quantization noise (in the export)
s = A0 .* sin(2*pi*f0.*t); 
sDist = awgn(s,60,'measured');
mkdir(pwd + "/Data/7/")
export_edr_xml(sDist,fs,datetime('2020-01-01 00:00:00'),"Data\7\");