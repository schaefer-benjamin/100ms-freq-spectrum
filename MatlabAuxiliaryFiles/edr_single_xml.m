function [OutData] = edr_single_xml(inFile, varargin)%
%% Reads EDR XML-Raw-DataFiles
%   [OutData] = edr_single_xml(inFile, varargin)
%
%   edr_single_xml(inFile) 
%       -> read the .xml at path given by inFile
%   edr_single_xml(inFile, outpath)
%       -> read the .xml at path given by inFile and convert the content to
%            .mat of the same name. (Will overwrite existing .mat files)
%       
% BlockTimes in OutData HAVE millisecond accuracy, although
% truncated in the display due to default settings of datetime
% change via:
% datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss.SSS')
%
% Author: Richard Jumar
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
% Last revision: 23.06.2022
%--------------------------------------------------------------------------


%% Input parameter processing
    outpath = [];
    if nargin == 2
        outpath = string(varargin{1});
        if ~exist(outpath, 'dir')
            mkdir(outpath);
            warning("Folder "+outpath+" did not exist. It was generated.");
        else
            warning("Folder "+outpath+" exists already. Content may be overwritten. Press any key to ack.");
            pause;
        end
    elseif nargin > 2
        error("Too many input argruments. Type: help edr_single_xml")
    end
    
    %% Reading input file
    B = fileread(inFile);
    C = transpose(strsplit(B,'\n'));
    % fast (141ms) but with empty lines (each line is a new raw)

    %% Check for ending
    Check_1 = find(contains(C,'<!-- File closed:'), 1);
    if isempty(Check_1) == 1
        disp("File: "+inFile+" has no formal ending (<!-- File closed:). Omitting any incomplete blocks.");
        % If there is no formal ending, stop at the end of the last full
        % block (the rest is deleted from the file content variable C)
        lastFullBlock = find(contains(C,'</data>'),1,'last');
        C = C(1:lastFullBlock); tmp = C{end}; C{end} = tmp(1:strfind(tmp,'</data>')+6);
    end

    %% Read keys - without structure
    FileVersionIndex = startsWith(C,'<evaluationVersion>');
    FileVersionstr = erase(erase(C(FileVersionIndex),'<evaluationVersion>'),'</evaluationVersion>');
    FileVersion = str2double(FileVersionstr(1));

    CapureTypeIndex = startsWith(C,'<captureType>');
    CapureTypestr = erase(erase(C(CapureTypeIndex),'<captureType>'),'</captureType>');
    CapureType = floor(str2double(CapureTypestr(1)));

    % number of channels is determined by caputre-type since in some
    % file-verions <channelCount> is not sets properly
    switch (CapureType)
        case 1
            NoC = 1;
        case 2
            NoC = 1;
        case 3
            NoC = 3;
        case 4
            NoC = 3;
        case 6
            NoC = 6;
        case 11
            NoC = 2;
        case 21
            NoC = 2;
        case 44
            NoC = 7;
        case 55
            warning('User-defined channel sequence. Channel number determined by #<data>-tags / #<acquision>-tags.')
            NoC = -1;% how? See below.
        otherwise
            warning('Unrecognized capure-type. Channel number determined by #<data>-tags / #<acquision>-tags.')
            NoC = -1;
    end

    PPSsyncIndex = startsWith(C,'<PPSsync>');
    PPSsyncStr = erase(erase(C(PPSsyncIndex),'<PPSsync>'),'</PPSsync>');
    PPSsync = floor(str2double(PPSsyncStr));
    OutData.Meta.PPSsync = PPSsync > 0;
    
    TimeSourceIndex = startsWith(C,'<timesource>');
    OutData.Meta.TimeSource = erase(erase(C(TimeSourceIndex),'<timesource>'),'</timesource>');
        
    %Problem: time is based on system clock - which may be totally off.
    %Hence, we should base our eval on <acq_datetime>. However this is only
    %available with GPS reception. Therefore, we now select the "best" time
    %stamp...

    %new Time Stuff rju 2020-02-04
    %revisions:
    %report 4 timestamps: 
    % 1) sys_datetime with ms (rounded to nearest second)
    % 2) sys_datetime without ms - so just as reported
    % 3) acq_datetime with ms (rounded to nearest second)
    % 4) acq_datetime without ms - so just as reported
    %the subsequent evaluation can decide which TS yields the least errors
    %(Assumption: Sampling is mostly correct, but TS are not)
    
    % 1)
    BlockTimeIndex = find(startsWith(C,'<sys_datetime>'));
    times = erase(erase(C(BlockTimeIndex),'<sys_datetime>'),'</sys_datetime>');
    %<sys_datetime_ms> (and all ms values) are based on when when the
    %system clock and should say when the entry was written.
    %Unfortunatly there seems to be some buffering so that the 
    %<acq_datetime> read at pps occurence might be off by < +-1s. I
    %don't fully understand this.
    %We therefore round the the _ms to the second and use the resulting
    %stamp - but also report the non-rounded TS.
    times_ms = erase(erase(C(BlockTimeIndex+1),'<sys_datetime_ms>'),'</sys_datetime_ms>');
    times = strrep(times,"ZT"," ");
    times_ms = strrep(times_ms,",","."); 
    BlockTimes_ms = str2double(times_ms);
    %Timestamp based on sys_datetime that includes the ms:
    OutData.BlockTimes = datetime(times,'Format','dd.MM.yyyy HH:mm:ss');
    % 2)
    %Timestamp based on sys_datetime without ms
    OutData.SysTsec = OutData.BlockTimes;
    % 1)
    %Timestamp based on sys_datetime with ms
    OutData.BlockTimes = OutData.BlockTimes + milliseconds(BlockTimes_ms);
    OutData.BlockTimes = dateshift(OutData.BlockTimes, 'start', 'second', 'nearest');

    AcqTimeIndex = find(startsWith(C,'<acq_datetime>'));
    AcqTimes = erase(erase(C(AcqTimeIndex),'<acq_datetime>'),'</acq_datetime>');
    %<sys_datetime_ms> (and all ms values) are based on when when the
    %system clock and should say when the entry was written.
    %Unfortunatly there seems to be some buffering so that the 
    %<acq_datetime> read at pps occurence might be off by < +-1s. I
    %don't fully understand this.
    %We therefore round the the _ms to the second and use the resulting
    %stamp - but also report the non-rounded TS.
    AcqTimes_ms = erase(erase(C(AcqTimeIndex+1),'<acq_datetime_ms>'),'</acq_datetime_ms>');
    AcqTimes = strrep(AcqTimes,"ZT"," ");
    AcqTimes_ms = strrep(AcqTimes_ms,",","."); 
    AcqTimes_ms = str2double(AcqTimes_ms);
    OutData.AcqTimes = datetime(AcqTimes,'Format','dd.MM.yyyy HH:mm:ss');
    % 4)
    %Timestamp based on acq_datetime without ms
    OutData.AcqTsec = OutData.AcqTimes;
    % 3)
    %Timestamp based on acq_datetime with ms
    OutData.AcqTimes = OutData.AcqTimes + milliseconds(AcqTimes_ms);
    OutData.AcqTimes = dateshift(OutData.AcqTimes, 'start', 'second', 'nearest');

    %% special block for acquiring the drift of the internal clock
    % normally this clock is irrelvant since it is not trustworthy
    % However, When PPS and GPS are available we can learn the drift of the
    % system-clock from comparing this with sys or acq datetime
    % when no trustworthy clock is available, this clock is used to define
    % sys and acq datetime
    SystemTimeIndex = find(startsWith(C,'<system_datetime>'));
    SystemTimes = erase(erase(C(SystemTimeIndex),'<system_datetime>'),'</system_datetime>');

    SystemTimes_ms = erase(erase(C(SystemTimeIndex+1),'<system_datetime_ms>'),'</system_datetime_ms>');
    SystemTimes = strrep(SystemTimes,"ZT"," ");
    SystemTimes_ms = strrep(SystemTimes_ms,",","."); 
    SystemTimes_ms = str2double(SystemTimes_ms);
    %Timestamp based on sys_datetime that includes the ms:
    OutData.SystemTimes = datetime(SystemTimes,'Format','dd.MM.yyyy HH:mm:ss');
    %Timestamp based on sys_datetime with ms
    OutData.SystemTimes = OutData.SystemTimes + milliseconds(SystemTimes_ms);
    
    
    %% Report the pre trigger time. Reported time stamps are not shifted.
    % Precision sample alignment must happen later - if required. 
    PPSpreTriggerTimeIndex = find(startsWith(C,'<PPSpreTriggerTime_ms>'));
    PPSpreTriggerTimeStrS = erase(erase(C(PPSpreTriggerTimeIndex),'<PPSpreTriggerTime_ms>'),'</PPSpreTriggerTime_ms>');
    % Is 0 when no pps is available - might break otherwise.
    % report in SI units (i.e. seconds)
    OutData.PPSpreTriggerTimes = str2double(PPSpreTriggerTimeStrS)/1000;
    
    %Block start times are evaluated using the sys_datetime
    %However, these are only for orientation - real checks are run blockwise
    % on TSs 1) to 4) 
    OutData.StartTime = OutData.BlockTimes(1);
    EndTimeReg = OutData.StartTime + minutes(1);
    OutData.EndTime = OutData.BlockTimes(length(OutData.BlockTimes));
    %Roughly check for length...
    if dateshift(EndTimeReg, 'start', 'minute', 'nearest')...
        ~= dateshift(OutData.EndTime, 'start', 'minute', 'nearest')

       disp("File does not contain 60 seconds. Number of Blocks: " + num2str(length(OutData.BlockTimes)));
       disp("First: " + datestr(OutData.BlockTimes(1)));
       disp("Last " + datestr(OutData.BlockTimes(length(OutData.BlockTimes))));
    end
    RealSampleRateIndex = startsWith(C,'<NrRealSamples>');
    RealSampleRatestr = erase(erase(C(RealSampleRateIndex),'<NrRealSamples>'),'</NrRealSamples>');
    OutData.RealSampleRate = str2double(RealSampleRatestr);

    % report the evaluationVersion so that subsequent processing can
    % choose processing algorithms depending on it
    OutData.evaluationVersion = FileVersion;

    if FileVersion == 2.67 || ...
            FileVersion == 2.68 || ...  
            FileVersion == 2.69 || ...
            FileVersion == 2.691 || ...
            FileVersion == 2.7 || ...
            FileVersion == 2.81 || ...
            FileVersion == 2.82 || ...
            FileVersion == 2.98 % starting with this version 
                                % RealSamplingRate and preTrigTime 
                                % should work correctly

        %tic
        Index = find(startsWith(C,'<data chnr=')); %find all datablocks
        % there are no checks to which acquisition block these belong
        Text_sep = cell(length(Index),9);
        for n = 1:length(Index)
            %read all and cut to fitting pieces   
            Text_sep(n,1:8) = textscan(C{Index(n)},'<data chnr="%d" name="%s samples="%d" scaleFactor="%f" offset="%f" voltageRange="%d" unit="%c"><![CDATA[%s');
            Text_sep(n,8) = erase(Text_sep{n,8},']]></data>');
            Text_sep(n,9) = num2cell(base64_decoding_fun_v3(Text_sep{n,8}, Text_sep{n,4}, Text_sep{n,5}, Text_sep{n,3}),2); 
        end

        if (NoC == -1)
            NoC = floor(length(Index)/length(BlockTimeIndex));
            fprintf('Assumed number of channels: %d',NoC);
        end
        
        OutData.data = transpose(reshape( Text_sep(:,9), NoC, length(Text_sep(:,9))/NoC));
        
        % here we could trigger an error, if not all sample rates for all 
        % channels within a block is not equal
        SamplesPerSec = reshape(Text_sep(:,3), NoC, length(Text_sep(:,3))/NoC);
        SamplesPerSec = cell2mat(SamplesPerSec);
        if size(unique(SamplesPerSec,'rows'),1) ~= 1
            disp("Not all channels have the same number of samples (in at least one block");
        end
        OutData.SamplesPerBlock = transpose(SamplesPerSec(1,:)); 

        % here we generate an error, if the labeling is 
        % not consistent throughout all blocks 
        Labels = reshape(Text_sep(:,2), NoC, length(Text_sep(:,3))/NoC);
        Labels = string(Labels);
        Labels = erase(Labels,'"');
        OutData.labels = transpose(Labels(:,1));
        
    
    elseif FileVersion == 2.61 || FileVersion == 2.5%worked before
        Index = find(startsWith(C,'<data chnr=')); %find all datablocks
        % there are no checks to which acquisition block these belong
        Text_sep = cell(length(Index),8);
        for n = 1:length(Index)
            %read all and cut to fitting pieces
            Text_sep(n,1:7) = textscan(C{Index(n)},'<data chnr="%d" name="%s samples="%d" scaleFactor="%f" offset="%f" unit="%c"><![CDATA[%s');
            Text_sep(n,7) = erase(Text_sep{n,7},']]></data>');
            %base64_decoding_fun_v3(str, scaleFactor, offset, samples)
            Text_sep(n,8) = num2cell(base64_decoding_fun_v3(Text_sep{n,7}, Text_sep{n,4}, Text_sep{n,5}, Text_sep{n,3}),2); 
        end
        %toc
        if (NoC == -1)
            NoC = floor(length(Index)/length(BlockTimeIndex));
            fprintf('Assumed number of channels: %d',NoC);
        end

        OutData.data = transpose(reshape( Text_sep(:,8), NoC, length(Text_sep(:,8))/NoC));

        % here we could trigger an error, if not all sample rates for all 
        % channels within a block is not equal
        SamplesPerSec = reshape(Text_sep(:,3), NoC, length(Text_sep(:,3))/NoC);
        SamplesPerSec = cell2mat(SamplesPerSec);
        if size(unique(SamplesPerSec,'rows'),1)~=1
            disp("Not all channels have the same number of samples (in at least one block");
        end
        OutData.SamplesPerBlock = transpose(SamplesPerSec(1,:)); 

        % here we generate an error, if the labeling is not consistent
        % throughout all blocks
        Labels = reshape(Text_sep(:,2), NoC, length(Text_sep(:,3))/NoC);
        Labels = string(Labels);
        Labels = erase(Labels,'"');
        OutData.labels = transpose(Labels(:,1));

    elseif FileVersion == 2.3 
        Index = find(startsWith(C,'<data channel=')); %find all datablocks
        % there are no checks to which acquisition block these belong
        Text_sep = cell(length(Index),8);
        for n = 1:length(Index)
            %read all and cut to fitting pieces
            Text_sep(n,1:5) = textscan(C{Index(n)},'<data channel="%s samples="%d" scaleFactor="%f" unit="%c"><![CDATA[%s');
            Text_sep(n,5) = erase(Text_sep{n,5},']]></data>');
            %Text_sep(n,6) = num2cell(base64_decoding_fun_v3(Text_sep{n,5}, Text_sep{n,3}, 10, Text_sep{n,2}),2); 
            Text_sep(n,6) = num2cell(base64_decoding_fun_v3(Text_sep{n,5}, Text_sep{n,3}*1.000015247138998, 10-1.525909413316259e-04, Text_sep{n,2}),2); 
        end
        %toc
        if (NoC == -1)
            NoC = floor(length(Index)/length(BlockTimeIndex));
            fprintf('Assumed number of channels: %d',NoC);
        end
        
        OutData.data = transpose(reshape( Text_sep(:,6), NoC, length(Text_sep(:,6))/NoC));

        % here we could trigger an error, if not all sample rates for all 
        % channels within a block is not equal
        SamplesPerSec = reshape(Text_sep(:,2), NoC, length(Text_sep(:,2))/NoC);
        SamplesPerSec = cell2mat(SamplesPerSec);
        if size(unique(SamplesPerSec,'rows'),1)~=1
            warning("Not all channels have the same number of samples (in at least one block");
        end
        OutData.SamplesPerBlock = transpose(SamplesPerSec(1,:)); 
        %assume all channels have the same number of samples like the
        %first channel (so far no problems with synchnonous sampling)

        % here we generate an error, if the labeling is not consistent
        % throughout all blocks
        Labels = reshape(Text_sep(:,1), NoC, length(Text_sep(:,1))/NoC);
        Labels = string(Labels);
        Labels = erase(Labels,'"');
        OutData.labels = transpose(Labels(:,1));

    else
        error("Non-tested-File-Version! Adapt special case!");
        %warning("Non-tested-File-Version! Adapt special case!");
        %continue
    end

    allRowsEqual = true;
    for q = 2:size(Labels,2)
        %combine all labels of one block for presumably faster comparison
        if ~strcmp(strjoin(Labels(:,q)),strjoin(Labels(:,1)))
            allRowsEqual = false;
        end
    end
    
    if ~allRowsEqual
        disp("Channel labeling is not consistent in this file: "+list_dir(k,:));
    end
    
    if ~isempty(outpath)
        [filepath, name, ext] = fileparts(inFile);
        save(outpath+"/"+name+".mat",'OutData','-v7.3')
    end
end
