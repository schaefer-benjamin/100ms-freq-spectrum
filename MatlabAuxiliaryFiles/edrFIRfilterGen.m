function [filterKernel] = edrFIRfilterGen(f0,fs)
%% This function mimics the behavior of the EDR-Scope towards the 
% generation of the FIR filter coefficients used withing the ZC-processs 
% to estimate the power system frequency
%
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
%--------------------------------------------------------------------------

if ~or(f0 == 50, f0 == 60)
    warning("Nominal frequency "+f0+" Hz is neither 50 nor 60 Hz")
end

if ~or(fs == 25000, fs == 12800)
    warning("Samplerate "+fs+" is not one of the usual ones")
end

filterCutoffPercentage = 2 * f0 / fs;
% Kernelseitenbreite: 
filterKernelLength = (fs / f0) / 5 * 2 ;
% 
% Hilfswert: 
%filterKernelLength_2 = filterKernelLength / 2;
% RJU modification to ensure that the kernel is always uneven length. 
% "uneven" -> see below.
% It turns out the c-code has an error here: for e.g. 12800Hz the filter is
% not only missing the last coefficent but also the correct rounding for
% non-integer filterKernalLenth. Therefore the filter even with the added
% trailing coefficient has a sligth asymmetry. Fortunatly the groupdelay of
% that filter is also flat (51 samples) until ca. 300 Hz. 

% So, there we do the rounding to enforce an uneven filter order
filterKernelLength_2 = floor(filterKernelLength / 2);
filterKernelLength = 2 * filterKernelLength_2;

% +1 fixes the asymmetry noted in FilterGen.cpp (missing last coefficient)
filterKernel = zeros(1,filterKernelLength+1); 

for i = 0:filterKernelLength
    if (i == filterKernelLength_2) 
        filterKernel(i+1) = 2 * pi * filterCutoffPercentage;
    else 
        filterKernel(i+1) = sin(2 * pi * filterCutoffPercentage * ...
            (i - filterKernelLength_2)) / (i - filterKernelLength_2);
    end
    filterKernel(i+1) = filterKernel(i+1) * ...
        (0.54 - 0.46 * cos(2 * pi * i / filterKernelLength));
    % the first version of newFilterCoeffs.mat uses only the %lf output 
    % with 6 digits - that might cause some difference in the responses 
    % between EDR and MATLAB implementation. Now we have more digits. If it 
    % actually made a difference remains be investigated by looking at the
    % filter responses and some frequency comparisons
    
    % fprintf(fp,"%.20f\n", filterKernel[i]);
end


end
