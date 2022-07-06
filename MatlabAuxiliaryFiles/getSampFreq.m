% This function extracts the sampling frequency from the Information given
% in the .xml raw data file by averaging over all blocks in one file.
% It also compares different sources (SamplesPerBlock and RealSampleRate)
% with the expected sampling rates which are 12800 Hz or 25000 Hz
%
% Input: Needs the output of the edr_single_xml() function as input, which
% means the present function can only be used AFTER the .xml file has bin
% imported
% Output: Function returns the sampling frequency FS as integer and a
% quality indicator OI
% Please evaluate success using the function interpretQI() below
% 
% Author: Ellen Förstner
% Institute for Automation and Applied Informatics,
% Karlsruhe Institute of Technology
% Email address: ellen.foerstner@kit.edu
% March 2021; Last revision: 24.09.2021
%--------------------------------------------------------------------------

function [FS, QI] = getSampFreq(XMLcontent,output)
    if nargin<2
        output = 0;
    end
    FS_SPB = (mean(XMLcontent.SamplesPerBlock));
    FS_RSR = (mean(XMLcontent.RealSampleRate));
    FS_SPB_MED = median(XMLcontent.SamplesPerBlock);
    FS_RSR_MED = median(XMLcontent.RealSampleRate);
    
    % Use the median - is better than mean since FS is a setting
    % - not a measurement
    % so we basically only allow a selection here.
    % Selections are made based on majority votes.
    availSampRates = [5, 8, 10, 12.8, 25, 44.1, 50, 62.5, 100]*10^3;
    
    idx(1,:) = and(availSampRates < (FS_SPB *1.01), availSampRates > (FS_SPB * 0.99));
    idx(2,:) = and(availSampRates < (FS_RSR *1.01), availSampRates > (FS_RSR * 0.99));
    idx(3,:) = and(availSampRates < (FS_SPB_MED *1.01), availSampRates > (FS_SPB_MED * 0.99));
    idx(4,:) = and(availSampRates < (FS_RSR_MED *1.01), availSampRates > (FS_RSR_MED * 0.99));
    
    idxPointer = find(sum(idx));
    
    if isempty(idxPointer)
        error("Sampling rate: " + FS_SPB_MED + " Hz is not among the "+...
        "expected ones. Add it to the list if it makes sense to you.");
    end
    
    % use the FSB that the most blocks have
    FS = availSampRates(idx(3,:));
    
    if size(idxPointer) ~= [1,1]
        % not all FS indicators are pointing to the same sampling rate. 
        % report a warning
        warning("Sampling rate indicators diagree by 1% or more. Using FS = " + FS);
    end   

    if output
        disp("Sampling rate majority vote = "+ FS);
    end
end