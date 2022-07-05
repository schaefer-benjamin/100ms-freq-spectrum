function [output] = condTranspose(inputVector,ColOrRow)
%CONDTRANSPOSE Transposes a vector to the desired output format
%  
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

