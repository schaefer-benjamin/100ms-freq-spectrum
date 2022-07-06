function [FileTable] = MakeMatFileList(FileName)
% MakeMatFileList: Makes a table of files, so that
%   the rawFreqGenPartialTable functions can process it properly
%   originally intended for .mat files only, but works with any file type
%
% Author: Richard Jumar
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

FileName = string(FileName);

fileStructA = dir(FileName);

FileTable = struct2table(fileStructA);

end

