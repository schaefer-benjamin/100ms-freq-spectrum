function [evalResult] = freqPPcalc(inCrx, resolution, options)
%freqPPcalc Calculates the the frequency using the PP mathod.
% resolution: Sets the time resolution of the output in seconds
% output options
% option 1: freq
% option 2: sd
% option 3: weight
%
% ToDo: can we report all outputs at the same time without having to loop
% over it again?
%
% Author: Richard Jumar, Orhan Tanrikulu
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
% Last modified: 2022-01-31

len = length(inCrx);

if len < 3
    %the frequency so low, that we not have enougth points.
    evalResult = nan;
    return
end

offsets = floor(inCrx./ resolution);

%fix: for len==3 take the middle element, not the first. For len > 3
%it should not matter.
%midOffset = offsets(floor(len/2));
midOffset = offsets(ceil(len/2));

crxMO = inCrx - midOffset.* resolution; 

periods = diff(inCrx); 

if offsets(1) ~= midOffset 
    weightFirst = crxMO(2)./periods(1);
else
    weightFirst = 1;
end
   
if offsets(end) ~= midOffset 
    weigthLast = (resolution - crxMO(end-1))./periods(end);
else
    weigthLast = 1;
end

weights = [weightFirst; ones(len-3,1); weigthLast];

SumWeightedPeriods = sum(periods.* weights);
% Sum of weights equal the number of periods used
SumWeights = sum(weights);
freqPPc = SumWeights/SumWeightedPeriods;
% For SD Matlab has some build-in function to do the weighing
freqPPcSD = std(1./periods,weights);
% Quick and dirty test to see if the problem comes from weighting...
% not sure about the results tough.
% freqPPcSD = std(1./periods);

switch options
    case 1
       evalResult = freqPPc;
    case 2
        evalResult = freqPPcSD;
    case 3
        evalResult = SumWeights;
    otherwise
        error("option "+string(options)+" not supported");
end

end

