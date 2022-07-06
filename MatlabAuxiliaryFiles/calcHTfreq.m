function [outFreq, outFreq100] = calcHTfreq(inData,startIndex,len,resolution,FS)
% calcHTfreq: calculates the instantanous frequency based on the Hilbert
% Transform. 
% startIndex: First sample of inData that is used
% len: number of samples that are used
% resolution: resolution of the output frequency time-series in seconds
% FS: sampling Rate
%
% This function is probably rubbish since the HT needs special conditions 
% to be stable and settle. We only alow as much settling time as for the
% filter of the ZC methods and do not check for addtional conditions (like
% zero start and finish).
%
% Author: Richard Jumar
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
% Last revision: 31.01.2022

freq = transpose(instfreq(inData,FS,'method','hilbert'));

if length(freq) < startIndex+len
    freq = freq(startIndex:end);
else
    freq = freq(startIndex:startIndex+len);
end

outFreq = mean(freq);

%find the reshape dimension
outLen = length(freq);
segLen = FS*resolution;
fullSegments = floor(outLen / segLen);

outFreq100(1:1/resolution) = nan;

if fullSegments == 0
    outFreq100 = mean(freq);
elseif mod(outLen , segLen) ~= 0 && fullSegments > 0
    rshp = reshape(freq(1:(fullSegments-1)*segLen),[segLen,fullSegments-1]);
    outFreqInt = mean(rshp,1);
    rest = freq((fullSegments-1)*segLen+1 : end);
    outFreqInt = [outFreqInt, mean(rest)];
    outFreq100(1:fullSegments) = outFreqInt(1:fullSegments);
else
    rshp = reshape(freq(1:(fullSegments)*segLen),[segLen,fullSegments]);
    outFreqInt = mean(rshp,1);
    outFreq100(1:fullSegments) = outFreqInt(1:fullSegments);
end

end

