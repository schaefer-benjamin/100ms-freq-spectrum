%PHASECALCULATION function [phase,phaseMean,sdPhase,actualPhase] = phaseCalculation(crxPP100,nomFreq)
% Uses zero-crossings time values calculated by crxFinder and nominal
% frequency to find phases.
%
% Data Descriptor:
% Let be the positive ZC time of the pure cosine: 0.1 sec and the time of the
% last positive ZC of the signal : 0.0942 sec
%
% phase: Phase difference between the pure cosine signal and actual signal at
% where the last zero-crossing observed within the 100 ms.
% phase = (0.1-0.0942)*2*pi*nominal frequency - (pi/2)
%
% phaseExt = Instead of compared to pure cosine, extrapolated phase can be
% calculated by using the mean frequency value of the corresponding 100 ms.
% phaseExt = (0.1-0.0942)*2*pi*mean frequency - (pi/2)
%
% phaseExtMean: Mean value of the extrapolated phases in the time resolution 
% usign the all positive zero crossings in the corresponding 100 ms.
% phaseExtMean = mean((0.1-timeOfEachPosZC)*2*pi*mean frequency - (pi/2))
%
% phaseExtSd = Standard deviation of the extrapolated phases 
% within one time resolution as explained above.

% Author: Richard Jumar, Orhan Tanrikulu
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
% Feb 2022; Last revision: 24.02.2022

function [phase,phaseExtMean,phaseExtSd,phaseExt] = phaseCalculation(crxPP100,nomFreq,freq100PP)

% It can happen, that only several a few 100ms cells are filled and others
% not, e.g. only the last 3 100ms are filled in
% KIT-EDR-RAWLOG_EDR0013_T20190304-1058.xml block 30
% EF: I changed the if to return all zeros if any one of the cells is empty

if any(cellfun(@(v) isempty(v),crxPP100)) %isempty(crxPP100{end})
    phase = zeros(10,1);
    phaseExtMean = zeros(10,1);
    phaseExtSd = zeros(10,1);
    phaseExt = zeros(10,1);
else
    phase = wrapToPi((round(cellfun(@(v) v(end-1),crxPP100),1)-cellfun(@(v) v(end-1),crxPP100))*2*pi*nomFreq - (pi/2))*(180/pi);
    phaseExt = wrapToPi((round(cellfun(@(v) v(end-1),crxPP100),1)-cellfun(@(v) v(end-1),crxPP100))*2*pi.*((freq100PP/1000)+nomFreq) - (pi/2))*(180/pi);
    phaseExtMean = cell2mat(...
        cellfun(@mean,...
        cellfun(@wrapToPi,...
        cellfun(@plus,num2cell(-(pi/2)*ones(1,length(freq100PP))),...
        cellfun(@times,num2cell(2*pi.*((freq100PP/1000)+nomFreq)),...
        cellfun(@(v) round(v(end-1),1)-v(2:end-1),crxPP100,...
        'UniformOutput',false),'UniformOutput',false),'UniformOutput',false),'UniformOutput',false),'UniformOutput',false))*(180/pi);
    phaseExtSd = cell2mat(...
        cellfun(@std,...
        cellfun(@wrapToPi,...
        cellfun(@plus,num2cell(-(pi/2)*ones(1,length(freq100PP))),...
        cellfun(@times,num2cell(2*pi.*((freq100PP/1000)+nomFreq)),...
        cellfun(@(v) round(v(end-1),1)-v(2:end-1),crxPP100,...
        'UniformOutput',false),'UniformOutput',false),'UniformOutput',false),'UniformOutput',false),'UniformOutput',false))*(180/pi);
end

end

