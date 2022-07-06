function [ Value ] = base64_decoding_fun_v3(str, scaleFactor, offset, samples)
% base64_decoding_fun_v3: Decode the EDR .xml raw data format
% 16 bit integer numbers (ADC values) are stored as base64 encoded 
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

result = base64decode2(str, '', 'matlab'); 
%fix 2020-03-07 2nd argument was missing resulted in java beeing used and
%orphaned file named matlab being written

% If the number of bytes is odd, floor...
if rem(length(result),2) == 1 
    result = result(1:(length(result)-1));
end

Value = ((double(typecast(uint8(result), 'uint16')) /65536)*20-offset)*scaleFactor;

%crop to length? good?
if length(Value) > samples
    Value = Value(1:samples);
end
    
end
