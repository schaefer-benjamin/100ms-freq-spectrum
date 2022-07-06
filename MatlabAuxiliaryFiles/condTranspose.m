function [output] = condTranspose(inputVector,ColOrRow)
%condTranspose: Transposes a vector to the desired output format
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------
inputSize = size(inputVector);
output = inputVector;

if numel(inputSize) > 2
    error("more than 2d input");
end

if ColOrRow == "col"
    if isrow(inputVector) > 0
        output = transpose(inputVector);
    end
elseif ColOrRow == "row"
    if isrow(inputVector) == 0
        output = transpose(inputVector);
    end
else
    error("unknown option " + ColOrRow);
end

end

