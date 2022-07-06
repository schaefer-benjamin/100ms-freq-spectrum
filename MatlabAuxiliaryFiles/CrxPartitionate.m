function [outCrx,outIdx] = CrxPartitionate(inCrx,NbrIntervals,PreBuf)
%CrxPartitionate: splits ZeroX within preBuf+1s+postBuf into interverals
% return values are either
% preBuf: -0.+ ... 1.0
% postBuf: 0.0 ... 1.+
% 
% if inCrx does not contain "enough" values in that rage, 
%   we report an empy cell for the corresponding intervall
% if we demand more intervalls than there are zero-crossings
%   we just report the one ZeroX adjacient (adj. to the front when 
%   PreBuf=true)(adj. to the rear, when PreBuf=false) to the corresponding
%   intervall is reported.
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
    
cmpVect = linspace(0,1,NbrIntervals+1); 
cmpVectLower = cmpVect(1:end-1);
cmpVectUpper = cmpVect(2:end);
if ~isempty(inCrx) 
    if islogical(PreBuf) && PreBuf == true %prebuffer
       loBound = inCrx > cmpVectLower;
       upBound = inCrx <= cmpVectUpper; 
       %der abschließende ND genau auf der Grenze wird noch mitgenommen
       %wenn der beginnende ND aber genau auf der Grenze liegt,
       %dann wird nur dieser und kein zusätzlicher mitgenommen. 
       %loBoundPlusOne = [loBound(2:end,:); true(1,NbrIntervals)];
       loBoundPlusOne = [loBound(2:end,:); any(loBound,1)]; 
       outIdx = and(upBound, loBoundPlusOne);

    elseif islogical(PreBuf) && PreBuf == false %postbuffer
       loBound = inCrx >= cmpVectLower;
       upBound = inCrx < cmpVectUpper; 
       %wenn der abschließende ND genau auf der trennstelle liegt, dann nicht
       %noch einen weiteren mitnehmen. deshalb < compVect.
       %upBoundPlusOne = [true(1,NbrIntervals); upBound(1:end-1,:)];
       upBoundPlusOne = [any(upBound,1); upBound(1:end-1,:)];
       outIdx = and(upBoundPlusOne, loBound);

    elseif PreBuf == 'LL'
        %LeadLag -> es werden sowohl pre als auch postbuffer benutzt
        %es muss immer noch ein zusätzlicher ND ausgegeben werden.
       loBound = inCrx > cmpVectLower;
       upBound = inCrx < cmpVectUpper; 
       
       loBoundPlusOne = [loBound(2:end,:); any(loBound,1)];
       upBoundPlusOne = [any(upBound,1); upBound(1:end-1,:)];
       outIdx = and(upBoundPlusOne, loBoundPlusOne);
       
    else
        error("Invalid leadLag option")
    end
    
    outCrx = cell(NbrIntervals,0);

    for i = 1:NbrIntervals
        outCrx(i) = {inCrx(outIdx(:,i))}; 
    end
    
else
    outCrx = cell(NbrIntervals,0);
    %just report empty cells
end

end