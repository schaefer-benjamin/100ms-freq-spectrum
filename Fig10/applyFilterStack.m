function out = applyFilterStack(stack,samples)
%applyFilterStack: sequentially filter input with a set of cascaded filters
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
    for i = 1:length(stack)
        disp("Filter: "+i);
        if i == 1
            out = filtfilt(stack{i,1}, stack{i,2}, samples);    
        else 
            out = filtfilt(stack{i,1}, stack{i,2}, out);    
        end
    end
end
