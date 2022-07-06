%% Fig. 9 and Supplementary Fig. 3 --> Frequency estimation on test data
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

listXML = MakeMatFileList("Data\6\*.xml");

rawFreqGenPartialTable(listXML,"Data\6",50,true,"EDR9999",100);

%%
listXML = MakeMatFileList("Data\7\*.xml");

rawFreqGenPartialTable(listXML,"Data\7",50,true,"EDR9999",100);
