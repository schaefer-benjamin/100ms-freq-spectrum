function [crxFP, crxPP] = crxFinder(crx,minNumberOfZc,startTime)
%crxFinder Finds the zerocrossings for the full second
% Assumes backwards calculation 
% Last modified: 2022-01-28

if length(crx) <= minNumberOfZc %magic number
    %if there are no zero crossings - or not enougth - then we don't do a
    %frequency reading
    crxFP = nan;
    crxPP = nan;
else
    crxMinPos = find(crx <= 0);
    crxMaxPos = find(crx < 1);
    crxPPmaxPos = find(crx >= 1);

    if isempty (crxMinPos)
        % no data and no ZC before zero time. 
        % So start with the first we have
        if startTime ~= 0
            % We have to wait some additional time because there is some
            % filter etc. that needs to settle
            crxMinPos = find(crx > startTime);
            crxMinPosToUse = crxMinPos(1);
        else
            % Should never happen!
            crxMinPosToUse = 1;
        end
    else
        %last one before 0
        crxMinPosToUse = crxMinPos(end);
    end
    
    if isempty(crxPPmaxPos)
        % no data after the second/intervall
        % use last zero crossing
        crxPPmaxPosToUse = crxMaxPos(end);
    else
        % use the first after the 1 second/intervall mark
        crxPPmaxPosToUse = crxPPmaxPos(1);
    end
    
    crxFP = crx(crxMinPosToUse:crxMaxPos(end));
    crxPP = crx(crxMinPosToUse:crxPPmaxPosToUse);
    
end

end

