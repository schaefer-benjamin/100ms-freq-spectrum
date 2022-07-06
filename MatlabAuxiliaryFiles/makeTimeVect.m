function tim = makeTimeVect(FS, number)
% makeTimeVect: make a time vector based on sampling rate and # of samples
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
TotalTime = number/FS;
tim = linspace(0,TotalTime-1/FS,number);

end