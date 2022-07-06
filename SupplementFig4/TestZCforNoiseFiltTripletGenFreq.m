%% Supplementary Fig. 4 --> Estimate frequencies from the generated test data
%
% For paper: "Microscopic fluctuations in power-grid frequency recordings 
% at the sub-second scale"
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

fileStructA = dir("Data/*SineAWG*");

list = struct2table(fileStructA);

%%
for k=1:height(list)
   myPath = list.folder(k,:);
   myName = list.folder(k,:)+"/"+list.name(k); 
   filesList = struct2table(dir(myName+"/*.xml"));
     
   rawFreqGenPartialTable(filesList,myName+"/",50,true,'EDR9999',120);

end