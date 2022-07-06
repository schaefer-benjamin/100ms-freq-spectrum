function [sortedFNs] = sortFileNamesTable(input)
%sortFileNamesTable: Sorts filenames, so that a .xml files comes before 
%   a(2).xml etc
%   
% assumes the input to be ordered like this:
% a  b  c  d  e(2) e(3) e  f  g ... 
% output is
% a  b  c  d  e  e(2) e(3) f  g ...
%
% Author: Richard Jumar
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
input.name = convertCharsToStrings(input.name);

index = strfind(input.name, '(');
if isempty(index)
    index={};
end
%finde alle dinge, die bis zu Klammer den gleichen Namen haben
%
output = input;
bracesFound  = ~cellfun(@isempty,index);
k = find(bracesFound);
%k = index;
while ~isempty(k)   
    if height(input)-k(1) >10
        subArray = input(k(1):k(1)+10, :); %speed-up limitation here
    else
        subArray = input(k(1):end, :);
    end
    nameWithBrace = input.name(k(1));
    nameWithBrace = convertStringsToChars(nameWithBrace);
    nameWithoutBrace = nameWithBrace(1:index{k(1)}-1);
    followUpFound = contains(subArray.name,nameWithoutBrace);
    subArrayCut = subArray(followUpFound,:);
    if height(subArrayCut) == 1
        subArrayShift = subArrayCut;
    else
        subArrayShift = circshift(subArrayCut,1);
    end
    output(k(1):k(1)+height(subArrayShift)-1,:) = subArrayShift;
    proced = false(k(1)+height(subArrayShift)-1,1);
    notProced = true(length(bracesFound)-length(proced),1);
    bracesFound = bracesFound & [proced; notProced];
    k = find(bracesFound);
end
sortedFNs = output;
end
