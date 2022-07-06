function [outTT, out100TT, out200TT] = rawFreqGenPartialTable(inFileTable,...
    outpath,nomFreq,FileOutMode,saveNameIdentifier,saveSize)
%RAWFREQGENPARTIALTABLE function [outTT, out100TT, out200TT] = rawFreqGenTable(inFileTable,outpath,nomFreq,FileOutMode,outFCoffset)
% Reads xml RAW data files, provided by the EDR_Scope_N.exe that are
% listed inFileTable calculates 1s, 200ms ans 100ms resolution frequency
% time series using Zero-Crossing Algorithm as described in the 
% Data Descriptor. 
% Additionally, it also offers an output frequency timeseries calulated
% with the new partial frequency method.
%
% outpath: path to write the log files
% nomFreq: nominal frequency of the investigated power system
% FileOutMode = true: function writes acendingly numberd .mat files
% containing the data generated from saveSize .xml files
% saveNameIdentifier: Information added to the output file name
% saveSize: The information calculated from this number of .xml files is
% saved intermediately
%
% Author: Orhan Tanrikulu, Richard Jumar
% Institute for Automation and applied Informatics,
% Karlsruhe Institute of Technology
% Email address: richard.jumar@kit.edu
% Website: https://www.iai.kit.edu/
% Jan 2022; Last revision: 23.06.2022
%--------------------------------------------------------------------------

% Temporary fix: Nbr of real samples written incorrectly in .xml files for
% unknown versions of EDR-Scope. Causes 37s phenomenon. Accuracy is better
% if nominal sampling rate is used until this is fixed.
FSnomUsed = true;
firstBuffer = 1;

outTT = timetable();
out100TT = timetable();
out200TT = timetable();

minVoltLevel = 10;
minNumberOfZc = 4;
getFSdiag = 0;

% In the future, isBuffer should be a colum in the inFileTable.
% Now, we check if the input is a cell array
batches = inFileTable;
if iscell(inFileTable)
% legacy support for input being a cell array
    if size(batches,2) == 2
        inFileTable = batches{1,1};
        inFileTable.isBuffer = batches{1,2};
        
    elseif size(batches,2) == 1
        inFileTable = batches{1,1};
        inFileTable.isBuffer = zeros(height(inFileTable),1);
    end
else
% check for existing isBuffer colum
    if ~strcmp("isBuffer",inFileTable.Properties.VariableNames)
        inFileTable.isBuffer = zeros(height(inFileTable),1);
    end
end

inFiles = sortFileNamesTable(inFileTable);

list_size = height(inFiles);
if list_size == 0
    warning(char("Empty/File Table: Nothing to do"));
    return
end

%saveNameIdentifier is optional and only needed if the ouputMode "file" is
%used
if ~exist("saveNameIdentifier",'var')
    saveNameIdentifier = "EDRX";
end

%saveSize is optional so is nothing is given, resume the default from 
%before and save 60 files
if ~exist("saveSize",'var')
    saveSize = 60;
end

subBatchSize = floor(list_size./saveSize);
% if saveSize == hours(1)
    subBatchNo = 1;
%     filesHours = cell2table(cellfun(@(x) hour(datetime(x(end-16:end-4),'InputFormat','yyyyMMdd-HHmm')),inFiles.name,'UniformOutput',false));
%     temp = diff(filesHours.Var1)~=0;
%     temp(1) = 0; temp(end) = 0;
%     hourPos = find(temp);
%     
%     if ~isempty(hourPos)
%         hourPos(end+1) = list_size(1);
%     else
%         hourPos = list_size(1);
%     end
% else
%     error('Use only saveSize = 1 hour')
% end

fid = fopen(outpath +"/MatConvLog.txt",'at');
fprintf(fid, 'Matlab EDR .xml to freq converter with \nLast revision: 10.01.2022\n');
fprintf(fid, 'Started: %s\n\n', datetime(now,'ConvertFrom','datenum'));
fclose(fid);

fid = fopen(outpath +"/MatFileLog.txt",'at');
fprintf(fid, 'Matlab EDR .xml to freq converter\n');
fprintf(fid, 'Started: %s\n\n', datetime(now,'ConvertFrom','datenum'));
fclose(fid);

for k = 1:list_size(1)
    disp(inFiles.name(k));
    %tic   
    fid = fopen(outpath +"/MatFileLog.txt",'a');
    fprintf(fid, '%s: ', datetime(now,'ConvertFrom','datenum'));
    fprintf(fid, '%s\n', inFiles.name(k));
    fclose(fid);
    
    if k ~= 1 && k ~= list_size(1) 
        % regular case, in the middle of the files
        PreFile = CurFile;
        CurFile = PostFile;
        PostFile = edr_single_xml(string(inFiles.folder(k+1,:))+"/"+inFiles.name(k+1));
        
        blockData = [PreFile.data(end,1) ; ...
            CurFile.data(:,1); ...
            PostFile.data(1,1)]; % for ind. blocks
        blockTimes = [PreFile.BlockTimes(end) ; ...
            CurFile.BlockTimes; ...
            PostFile.BlockTimes(1)];
        SysTsec = [PreFile.SysTsec(end) ; ...
            CurFile.SysTsec; ...
            PostFile.SysTsec(1)];
        AcqTimes = [PreFile.AcqTimes(end) ; ...
            CurFile.AcqTimes; ...
            PostFile.AcqTimes(1)];
        AcqTsec = [PreFile.AcqTsec(end) ; ...
            CurFile.AcqTsec; ...
            PostFile.AcqTsec(1)];
        blockSR = [PreFile.RealSampleRate(end); ...
            CurFile.RealSampleRate; ...
            PostFile.RealSampleRate(1)];    
        blockSamples = [PreFile.SamplesPerBlock(end); ...
            CurFile.SamplesPerBlock; ...
            PostFile.SamplesPerBlock(1)];
        blockPPS = [PreFile.Meta.PPSsync(end); ...
            CurFile.Meta.PPSsync; ...
            PostFile.Meta.PPSsync(1)];
        TimeSource = [PreFile.Meta.TimeSource(end); ...
            CurFile.Meta.TimeSource; ...
            PostFile.Meta.TimeSource(1)];
        FS = getSampFreq(CurFile,getFSdiag); %EF: Get sampling frequency from file
        PPSpreTriggerTimes = [PreFile.PPSpreTriggerTimes(end); ...
            CurFile.PPSpreTriggerTimes; ...
            PostFile.PPSpreTriggerTimes(1)];
        
        CurNbrBlocks = size(CurFile.data(:,1),1);
        availPreBuf = true(CurNbrBlocks,1);
        availPostBuf = true(CurNbrBlocks,1);
        
    elseif k == 1 && k == list_size(1)
        % there is only one file
        PreFile = NaN;
        CurFile = edr_single_xml(string(inFiles.folder(k,:))+"/"+inFiles.name(k));
        
        PostFile = NaN;
        
        blockData = [CurFile.data(:,1)]; % for ind. blocks
        blockTimes = [CurFile.BlockTimes];
        SysTsec = CurFile.SysTsec;
        AcqTimes = CurFile.AcqTimes;
        AcqTsec = CurFile.AcqTsec;
        blockSR = [CurFile.RealSampleRate]; 
        blockSamples = [CurFile.SamplesPerBlock]; 
        blockPPS = [CurFile.Meta.PPSsync];
        TimeSource = [CurFile.Meta.TimeSource(end)];
        FS = getSampFreq(CurFile,getFSdiag); %EF: Get sampling frequency from file
        PPSpreTriggerTimes = [CurFile.PPSpreTriggerTimes];
        
        CurNbrBlocks = size(CurFile.data(:,1),1);
        availPreBuf = [false; true(CurNbrBlocks-1,1)];
        availPostBuf = [true(CurNbrBlocks-1,1); false];

    elseif k == list_size(1)
        % this is the last file
        PreFile = CurFile;
        CurFile = PostFile;
        PostFile = NaN;
        
        blockData = [PreFile.data(end,1); CurFile.data(:,1)];%use the UCh1
        blockTimes = [PreFile.BlockTimes(end); CurFile.BlockTimes];
        SysTsec = [PreFile.SysTsec(end); CurFile.SysTsec]; 
        AcqTimes = [PreFile.AcqTimes(end); CurFile.AcqTimes];
        AcqTsec = [PreFile.AcqTsec(end); CurFile.AcqTsec]; 
        blockSR = [PreFile.RealSampleRate(end); CurFile.RealSampleRate];
        blockSamples = [PreFile.SamplesPerBlock(end); CurFile.SamplesPerBlock];
        blockPPS = [PreFile.Meta.PPSsync(end); CurFile.Meta.PPSsync];
        TimeSource = [PreFile.Meta.TimeSource(end); CurFile.Meta.TimeSource];
        FS = getSampFreq(CurFile,getFSdiag); %EF: Get sampling frequency from file
        PPSpreTriggerTimes = [PreFile.PPSpreTriggerTimes(end); CurFile.PPSpreTriggerTimes];
        
        CurNbrBlocks = size(CurFile.data(:,1),1);
        availPreBuf = true(CurNbrBlocks,1);
        availPostBuf = [true(CurNbrBlocks-1,1); false];
        
    else % k == 1
        % this is the first file and there are more
        PreFile = NaN;
        CurFile = edr_single_xml(string(inFiles.folder(k,:))+"/"+inFiles.name(k));
        PostFile = edr_single_xml(string(inFiles.folder(k+1,:))+"/"+inFiles.name(k+1));
                      
        blockData = [CurFile.data(:,1); ...
            PostFile.data(1,1)]; % for ind. blocks
        blockTimes = [CurFile.BlockTimes;...
            PostFile.BlockTimes(1)];    
        SysTsec = [CurFile.SysTsec; ...
            PostFile.SysTsec(1)];
        AcqTimes = [CurFile.AcqTimes; ...
            PostFile.AcqTimes(1)];
        AcqTsec = [CurFile.AcqTsec; ...
            PostFile.AcqTsec(1)];
        blockSR = [CurFile.RealSampleRate;...
            PostFile.RealSampleRate(1)];    
        blockSamples = [CurFile.SamplesPerBlock;...
            PostFile.SamplesPerBlock(1)];
        blockPPS = [CurFile.Meta.PPSsync;...
            PostFile.Meta.PPSsync(1)];  
        TimeSource = [CurFile.Meta.TimeSource;...
            PostFile.Meta.TimeSource(1)]; 
        FS = getSampFreq(CurFile,getFSdiag); %EF: Get sampling frequency from file
        PPSpreTriggerTimes = [CurFile.PPSpreTriggerTimes;...
            PostFile.PPSpreTriggerTimes(1)];
        
        CurNbrBlocks = size(CurFile.data(:,1),1);
        availPreBuf = [false ; true(CurNbrBlocks-1,1)];
        availPostBuf = true(CurNbrBlocks,1);
        
    end

    %Disable the use of pre-trigger-times:
    %Per 2022-02-04 we have the best agreement with 
    %EDR-ScopeFromFile F_X10v2.94 2022-01-21 when 
    %we do not use it (error < 0.5 10^-6Hz) on SingleFile test.
    PPSpreTriggerTimes = zeros(size(PPSpreTriggerTimes));
    
    %Disable the use NumberOfRealSamples
    %Per 2022-05-04 we have the 37 second phenomenon since number of real
    %samples is not written correctly by EDR. Fix and workaround for
    %data pending. Meanwhile using nominal FS produces better results.
    if FSnomUsed == true
        blockSR = FS * ones(size(blockSR));
    end
    
    filtCoef = edrFIRfilterGen(nomFreq,FS);
    filterDelay = (length(filtCoef)-1) /2;
    
    % Decision on forward calculation or backward calculation 
    backwards = false;
    backwards = true;
    
    if backwards
        % Backward calculation
        
        % Data structure is
        % prebuffer | data      | nothing
        % per block this means
        % t < 0     | 0... 1-Ts | 
        % size of pre buffer: enough for the filter to settle ~10ms
        %                      +  ~1.5 periods so that the beginning of the
        %                       beginning of first period is also captured
        % size of post buffer: not needed
        sz100 = [CurNbrBlocks*10 18];

        varTypes = {...
            'datetime','double','double','double',...
            'double','double','double','double','double',...
            'double','double','double','logical','logical',...
            'logical','logical','logical','logical'};
         block100 = table('Size',sz100,'VariableTypes',varTypes,...
             'VariableNames', {...
             'Time', 'freq', 'sdFreq', 'periodsUsed',...
             'freqPP', 'sdFreqPP', 'periodsUsedPP','phase','phaseExt'... 'sdPhase',
             'phaseExtMean','phaseExtSd','freqHT','usePreBuf', 'usePostBuf',...
             'PPSlocked', 'TimeSeqError', 'SRerror', 'LenError'});

        % Check for length of blocks: The block has to have 25000 +-2 samples
        % Check performed on all relevant blocks including pre and post
        % buffers. 
        % Since this is the backwards calculation, only the pre buffer 
        % consistency will be evaluated later on.
        blockLenError = (blockSamples < FS-1) | ...
            (blockSamples > FS+1);
        if ~isempty(find(blockLenError, 1))
            for i = find(blockLenError)

                dispstr = "File: " + ...
                    datestr(CurFile.StartTime,'yyyy-mm-dd HH:MM:ss') + ...
                    " --> Block "+ ...
                    datestr(blockTimes(i),'ss')+ ...
                    " is "+blockSamples(i)+" samples long.";

                disp(dispstr);
                fid = fopen(outpath +"/MatConvLog.txt",'a');
                fprintf(fid, '%s\n', dispstr);
                fclose(fid);
            end
        end
        % Checking for samplerate deviations of more than +-0.1%
        % Check performed on all relevant blocks including pre and post
        % buffers. 
        % Since this is the backwards calculation, only the pre buffer 
        % consistency will be evaluated later on.
        blockSRerror = (blockSR < FS*0.999) | ...
            (blockSR > FS*1.001);
        if ~isempty(find(blockSRerror, 1))
            for i = find(blockSRerror)
                dispstr = "File: " + ...
                    datestr(CurFile.StartTime,'yyyy-mm-dd HH:MM:ss') + ...
                    " --> Block "+ ...
                    datestr(blockTimes(i),'ss')+ ...
                    " SR Error: Was "+blockSR(i)+" 1/s. 'Correcetd' to: "+FS+" 1/s";

                disp(dispstr);
                fid = fopen(outpath +"/MatConvLog.txt",'a');
                fprintf(fid, '%s\n', dispstr);
                fclose(fid);
                % if SR is not OK use default SR, not the reported real SR
                blockSR(i) = FS;
            end
        end
        
        % Here we go fancy:
        % Test all TS possibilities on their "quality"
        % choose the ts that causes the least breaks in the timeline
        timeIncErrorBlock = diff(blockTimes) ~= seconds(1);
        timeIncErrorSysTsec = diff(SysTsec) ~= seconds(1);
        timeIncErrorAcqTimes = diff(AcqTimes) ~= seconds(1);
        timeIncErrorAcqTsec = diff(AcqTsec) ~= seconds(1);
        tIncMat = [timeIncErrorBlock, timeIncErrorSysTsec, ...
            timeIncErrorAcqTimes,timeIncErrorAcqTsec];
        [nbrOfErrors, UsedTS] = min(sum(tIncMat));
        
        switch(UsedTS)
            case 1
                blockTimes = blockTimes;
            case 2
                blockTimes = SysTsec;
            case 3
                blockTimes = AcqTimes;
            case 4
                blockTimes = AcqTsec;
            otherwise
                error("None of the avialable TS");
        end
        % maybe it would also be wise to check for some "core" property
        % of the TS, not only for the incements - but if nbrOfErrors is
        % 0, the continuity between files is granted.
        % 
        % maybe it makes sense to integrate some add. weighing on the 
        % top and bottom elemens, so that the continuity is stronger
        % enforced / wins over internal flip-flopping

        % Detecting a break of the time line:
        % Get block starting times -> last starting time has to be
        % 1 sec after the previous one
        timeIncError = diff(blockTimes) ~= seconds(1);
        if ~isempty(find(timeIncError, 1))
            for i = find(timeIncError)
                dispstr = "File: " + ...
                    datestr(CurFile.StartTime,'yyyy-mm-dd HH:MM:ss') + ...
                    " --> Successor of the current Block "+ ...
                    datestr(blockTimes(i),'yyyy-mm-dd HH:MM:ss')+ ...
                    " has time " + ...
                    datestr(blockTimes(i+1),'yyyy-mm-dd HH:MM:ss')+ ...
                    " . dT is not a 1 second increment. Used TSmode: "+UsedTS+"." ;
                disp(dispstr);
                fid = fopen(outpath +"/MatConvLog.txt",'a');
                fprintf(fid, '%s\n', dispstr);
                fclose(fid);
                %add error to Quality Indicator
            end
        end
        %its ok to iterate over all blocks in the file.
        %However, if the chain of blocks is broken we need to detect that.
        %The pre or post buffer needs to handle this
        %Also if a break occurs we need to set the corresponding flag in
        %the output data point
     
        %len errors: one entry per block
        %inc errors: first holds distance to next, -> one less than #
        % --> append a false-entry
        %length(availPreBuf) is length(CurFile)
        
        % later: iterate over blocks in file
        % for each block memorize wheather we use pre, post, or no buffer 
        % --> usePreBuf's length equals CurFile's number of blocks
        
        %check: PPSsync set? no -> disable buffer, set indicator
        
        usePreBuf = true(length(blockLenError),1);
        % extend by one entry so -> shift without overflow
        %shiftBLEfw = circshift([blockLenError; false],1);
        shiftBLEfw = [false; blockLenError(1:end-1)];
        %shiftTIEfw = circshift([timeIncError; false ; false],1);
        shiftTIEfw = [false; timeIncError;];
        %shiftSREfw = circshift([blockSRerror; false],1);
        shiftSREfw = [false; blockSRerror(1:end-1)];
        %shiftPPSfw = circshift([blockPPS; true],1);
        shiftPPSfw = [true; blockPPS(1:end-1)];
        
        % use of PRE buffers:
%         length(usePreBuf)
%         length(blockLenError)
%         length(shiftBLEfw)
%         length(shiftTIEfw)
%         length(blockSRerror)
%         length(shiftSREfw)
%         length(blockPPS)
%         length(shiftPPSfw)

        %use pre buffer always except...
        usePreBuf = usePreBuf & ...
            ~blockLenError & ...    %the current block has LenError
            ~shiftBLEfw & ...       %the previous block has LenError (assume something is missing at the end...)
            ~shiftTIEfw &...        %this block does not follow the previous
            ~blockSRerror & ...     %the SR is wrong
            ~shiftSREfw &...        %the SR of the previous block is wrong
            blockPPS &...           %the current block has no PPS
            shiftPPSfw;             %the previous block has no PPS    
        
        %2022 now also enable PostBuf for backwards
        %reason: for FP-method: we acutally need at least one sample from
        %the next block, so that the ZC can lie on the end of an intervall
        %(100ms, 1s etc.)
        %reason: for PP-method: we need one period after the end of the
        %intervall (100ms, 1s etc.)
        usePostBuf = true(length(blockLenError),1);
        
        %use post buffer always except...
        %check if the 'false' is at the correct place...
        %this logic is probably broken...
        %circshift should be replaced by array extension in general...
        shiftBLEbw = [blockLenError(2:end); false];
        shiftSREbw = [blockSRerror(2:end); false];
        shiftPPSbw = [blockPPS(2:end);true];
        usePostBuf = usePostBuf & ...
            ~blockLenError & ...        %the current block has LenError
            ~shiftBLEbw & ...           %following block has LenError
            ~[timeIncError; false]& ... %next block does not follow directly  
            ~blockSRerror & ...         %the current block has SR wrong
            ~shiftSREbw &...            %the following block has wrong SR
            blockPPS &...               %the current block has no PPS
            shiftPPSbw;                 %the following block has no PPS
        

        if availPreBuf(1) && availPostBuf(end)
            %pre and post buffer available
            %now the normal case
            usePreBuf = usePreBuf(2:end-1) & availPreBuf;
            usePostBuf = usePostBuf(2:end-1) & availPostBuf;
            PPSlocked = blockPPS(2:end-1);
            TimeSeqError = timeIncError(2:end); %OK, tIE always 1 short
            SRerror = blockSRerror(2:end-1);
            LenError = blockLenError(2:end-1);
            OS = 1; %Offset, since data of current block are in second place 
            
        elseif availPreBuf(1)
            %pre buffer available
            usePreBuf = usePreBuf(2:end) & availPreBuf;
            usePostBuf = usePostBuf(2:end) & availPostBuf;
            PPSlocked = blockPPS(2:end);
            TimeSeqError = timeIncError(2:end); 
            TimeSeqError = [TimeSeqError;false];
            SRerror = blockSRerror(2:end);
            LenError = blockLenError(2:end);
            OS = 1;
        elseif availPostBuf(end)
            %post buffer available
            usePreBuf = usePreBuf(1:end-1) & availPreBuf;
            usePostBuf = usePostBuf(1:end-1) & availPostBuf;
            PPSlocked = blockPPS(1:end-1);
            TimeSeqError = timeIncError(1:end); 
            SRerror = blockSRerror(1:end-1);
            LenError = blockLenError(1:end-1);
            OS = 0;
        else
            %no buffer available
            %number of blocks = number of blocks in current file
            usePreBuf = usePreBuf & availPreBuf;
            usePostBuf = usePostBuf & availPostBuf;
            PPSlocked = blockPPS;
            TimeSeqError = [timeIncError;false]; 
            SRerror = blockSRerror;
            LenError = blockLenError;
            OS = 0;
        end
        
        PreBufLen = round(FS*0.05);
        FiltSettleTime = 10e-3;
        % length of buffer @ 50 Hz ~50ms ~2,5 periods -> sufficient
        % ToDo auto-adapt to nominal freq.
        %Post length only determined by expected frequency values
        %(at least one full period)
        PostBufLen = ceil(FS*2./nomFreq); 
        
        NbrBlocksInFile = size(CurFile.data(:,1),1);
        % Initialization
        freq = nan(NbrBlocksInFile,1);
        sdFreq = nan(NbrBlocksInFile,1);
        periodsUsed = nan(NbrBlocksInFile,1);
        freqPP = nan(NbrBlocksInFile,1);
        sdFreqPP = nan(NbrBlocksInFile,1);
        periodsUsedPP = nan(NbrBlocksInFile,1);
        freqHT = nan(NbrBlocksInFile,1);
        
        for p = 1:NbrBlocksInFile
            % Formatting of data arrays (BlockData, blockTimes, blockSR,
            % blockSamples:
            % file in between:      1 | 1...NbrBlocksInFile | 1
            % file at the end:      1 | 1...NbrBlocksInFile
            % file at the begining:     1...NbrBlocksInFile | 1
            % only one file             1...NbrBlocksInFile
            
            % UsePreBuf and usePostBuf's length -> NbrBlocksInFile
            if usePreBuf(p) && usePostBuf(p)
                % disp("Block: "+string(p)+" Pre and Post");
                % pre and post buffer
                totalData = [blockData{p-1+OS}(end-PreBufLen+1:end),...
                    blockData{p+OS},...
                    blockData{p+1+OS}(1:PostBufLen)];  
                %Modified: for the buffers, use the respective
                %SR of the central piece.
                %Rationale: SR only changes slowly over time, so the SR
                %value is an average anyhow.
                timeVectCur = makeTimeVect(blockSR(p+OS), ...
                                size(blockData{p+OS},2)) ...
                                + PPSpreTriggerTimes(p+OS);
                % we don not care if the PreTriggerTimes together with
                % RealSamplingRate and number of points is consitent - and
                % simply make the Pre-TS "fit" the current one
                % OLD(1)
                timeVectPre = makeTimeVect(blockSR(p+OS), PreBufLen) ...
                                   - PreBufLen/blockSR(p+OS) ...
                                   + timeVectCur(1);
                timeVectPost = makeTimeVect(blockSR(p+OS), PostBufLen)...
                                   + timeVectCur(end) ...
                                   + 1/blockSR(p+OS);

                timeVect = [timeVectPre timeVectCur timeVectPost];
                
                filtData = filter(filtCoef,1,totalData);
                filtData(1:filterDelay) = [];
                                
                if mean(abs(filtData)) >= minVoltLevel
                    crx = ZeroX(timeVect, filtData);
                    [crxFP, crxPP] = crxFinder(crx,minNumberOfZc,0);
                    
                    [freqHT(p),freq100HT] = calcHTfreq(filtData,...
                        length(timeVectPre)+1, length(timeVectCur),...
                        0.1, FS);
                else
                     crxFP = nan;
                     crxPP = nan;
                end

            elseif usePreBuf(p)
                % pre buffer only: now only before gaps and the end
                % disp("Block: "+string(p)+" Pre");
                totalData = [blockData{p-1+OS}(end-PreBufLen+1:end),...
                    blockData{p+OS}];
                
                timeVectCur = makeTimeVect(blockSR(p+OS), ...
                                    size(blockData{p+OS},2))...
                                    + PPSpreTriggerTimes(p+OS);
                timeVectPre = makeTimeVect(blockSR(p+OS), PreBufLen) ...
                                   - PreBufLen/blockSR(p+OS) ...
                                   + timeVectCur(1);
                timeVect = [timeVectPre timeVectCur];
                
                filtData = filter(filtCoef,1,totalData);
                filtData(1:filterDelay) = [];
                
                if mean(abs(filtData)) >= minVoltLevel
                    crx = ZeroX(timeVect, filtData);
                    [crxFP, crxPP] = crxFinder(crx,minNumberOfZc,0);
                    
                    [freqHT(p),freq100HT] = calcHTfreq(filtData,...
                    length(timeVectPre)+1, length(timeVectCur),...
                    0.1, FS);
                else
                     freq100HT = nan(1,10);
                     crxFP = nan;
                     crxPP = nan;
                end
                    
            elseif usePostBuf(p)
                % post buffer only
                % disp("Block: "+string(p)+" Post");
                
                totalData = [blockData{p+OS},...
                    blockData{p+1+OS}(1:PostBufLen)];
                
                timeVectCur = makeTimeVect(blockSR(p+OS), ...
                                    size(blockData{p+OS},2))...
                                    + PPSpreTriggerTimes(p+OS);
                timeVectPost = makeTimeVect(blockSR(p+OS), PostBufLen)...
                                   + timeVectCur(end) ...
                                   + 1/blockSR(p+OS);
                timeVect = [timeVectCur timeVectPost];
                
                filtData = filter(filtCoef,1,totalData);
                filtData(1:filterDelay) = [];

                if mean(abs(filtData)) >= minVoltLevel
                    crx = ZeroX(timeVect, filtData);
                    [crxFP, crxPP] = crxFinder(crx,minNumberOfZc,FiltSettleTime);
                    
                    [freqHT(p),freq100HT] = calcHTfreq(filtData,...
                    floor(FiltSettleTime*FS), length(timeVectCur),...
                    0.1, FS);
                else
                    freq100HT = nan(1,10);
                     crxFP = nan;
                     crxPP = nan;
                end

            else
                % no buffer, anywhere
                % number of blocks: nubmer blöcke in current file
                % disp("Block: "+string(p)+" no buffer");
                totalData = [blockData{p+OS}];
                timeVectCur = makeTimeVect(blockSR(p+OS), ...
                                       size(blockData{p+OS},2))...
                                       + PPSpreTriggerTimes(p+OS);
                timeVect = [timeVectCur];

                filtData = filter(filtCoef,1,totalData);
                filtData(1:filterDelay) = [];
                
                if mean(abs(filtData)) >= minVoltLevel
                    crx = ZeroX(timeVect, filtData);
                    [crxFP, crxPP] = crxFinder(crx,minNumberOfZc,FiltSettleTime);
                    [freqHT(p),freq100HT] = calcHTfreq(filtData,...
                    floor(FiltSettleTime*FS), length(timeVectCur),...
                    0.1, FS);
                else
                    freq100HT = nan(1,10);
                     crxFP = nan;
                     crxPP = nan;
                end
            end
            
            crx100 = CrxPartitionate(crxFP,10,true);

            periods100 = cellfun(@diff,crx100,'UniformOutput',false);

            empties100 = cellfun('isempty',periods100);
            
            % needs to be 0 if freq == []
            % there do this before NaN-casting
            periodsUsed100 = (cellfun(@length, periods100));
            
            % what if periods contains empty elemet?
            % happens only if input signal does strange things
            % replace empty entries with nan -> allows to use double-array
            periods100(empties100) = {NaN};
            
            %% PP method
            crxPP100 = CrxPartitionate(crxPP,10,'LL');
            
            wrapper = @(x) freqPPcalc( x, 0.1, 1 ) ;
            freq100PP = (cellfun(wrapper,crxPP100)-nomFreq) *1000;
            
            wrapper = @(x) freqPPcalc( x, 0.1, 2 ) ;
            sdFreq100PP = cellfun(wrapper,crxPP100) *1000;
            
            wrapper = @(x) freqPPcalc( x, 0.1, 3 ) ;
            periodsUsed100PP = cellfun(wrapper,crxPP100);
            
            [phase,phaseExtMean,phaseExtSd,phaseExt] = phaseCalculation(crxPP100,nomFreq,freq100PP);
            
            %%
            
            freq100 = ...
                (cellfun(@(x) mean(((1./x)-nomFreq)*1000),periods100));
            sdFreq100 = ...
                (cellfun(@(x) std(((1./x)-nomFreq)*1000),periods100));
            blockTimes100 = (blockTimes(p+OS)-seconds(0.9):seconds(0.1):...
                blockTimes(p+OS));

            % Assign 100ms variables
            q = 10*p-9;
            block100.Time(q:q+9) = blockTimes100;
            block100.freq(q:q+9) = freq100;
            block100.sdFreq(q:q+9) = sdFreq100;
            block100.periodsUsed(q:q+9) = periodsUsed100;
            
            block100.phase(q:q+9) = phase;
            block100.phaseExtMean(q:q+9)= phaseExtMean;
            block100.phaseExtSd(q:q+9) = phaseExtSd;
            block100.phaseExt(q:q+9) = phaseExt;
            
            block100.freqPP(q:q+9) = freq100PP;
            block100.sdFreqPP(q:q+9) = sdFreq100PP;
            block100.periodsUsedPP(q:q+9) = periodsUsed100PP;
            
            block100.freqHT(q:q+9) = (freq100HT-nomFreq)*1000;
            block100.usePreBuf(q:q+9)=...
                true(length(freq100),1)& usePreBuf(p);
            block100.usePostBuf(q:q+9)=...
                true(length(freq100),1)& usePostBuf(p);
            block100.PPSlocked(q:q+9)=...
                true(length(freq100),1)& PPSlocked(p);
            block100.TimeSeqError(q:q+9)=...
                true(length(freq100),1)& TimeSeqError(p);
            block100.SRerror(q:q+9)=...
                true(length(freq100),1)& SRerror(p);
            block100.LenError(q:q+9)=...
                true(length(freq100),1)& LenError(p);
 
            %Assign 1 second variables
            periods = diff(crxFP);
            freq(p) = mean(((1./periods)-nomFreq)*1000);
            sdFreq(p) = std(((1./periods)-nomFreq)*1000);
            periodsUsed(p) = length(periods);
            freqPP(p) = (freqPPcalc(crxPP, 1, 1 ) -nomFreq) *1000;
            sdFreqPP(p) = freqPPcalc( crxPP, 1, 2 ) *1000;
            periodsUsedPP(p) = freqPPcalc( crxPP, 1, 3 );
            
                        
        end %loop files
        
    else 
        % Forward calculation goes here... 
    end
    %Things to to per file:
    
    % Ignore the results if the current file was processed to only provide
    % the overleap buffer. Otherwise save results to output (is the usual 
    % case).
    if ~inFileTable.isBuffer(k)
            out100TT = [out100TT; table2timetable(block100)];
            
            outTT = [outTT; timetable(...
                blockTimes(1+OS:length(freq)+OS), freq, sdFreq, periodsUsed,...% phase, sdPhase,
                freqPP, sdFreqPP, periodsUsedPP,...
                (freqHT-nomFreq)*1000,...
                usePreBuf, usePostBuf,...
                PPSlocked, TimeSeqError, SRerror, LenError, ones(length(freq),1).*UsedTS,CurFile.Meta.TimeSource,...
                'VariableNames',...
                {'freq','sdFreq','periodsUsed',...
                'freqPP','sdFreqPP','periodsUsedPP',...
                'freqHT',...
                'usedPreBuf', 'usePostBuf','PPSlocked',...
                'TimeSeqError', 'SRerror', 'LenError','UsedTS','TimeSource'})];
    end
    % after each File, we end up here
    % save the result from 60 files in one mat - if something goes wrong
    if ((mod(k,saveSize) == 0 && subBatchNo ~= subBatchSize) ||  k == list_size(1)) && FileOutMode == true %(k == hourPos(subBatchNo)) && FileOutMode == true
        savestring = strcat(saveNameIdentifier,'_',datestr(outTT.Time(1),'yyyymmdd-HHMM'),...
            '_',datestr(outTT.Time(end),'yyyymmdd-HHMM'),'.mat');
        save(outpath+"/"+savestring,'outTT','out100TT','out200TT');
        outTT = timetable();
        out100TT = timetable();
        out200TT = timetable();
        subBatchNo = subBatchNo + 1;
    end

end

fid = fopen(outpath +"/MatConvLog.txt",'a');
fprintf(fid, '\nFinished w/o crash!\n');
fprintf(fid, '%s', datetime(now,'ConvertFrom','datenum'));
fclose(fid);

fid = fopen(outpath +"/MatFileLog.txt",'a');
fprintf(fid, '\nFinished w/o crash!\n');
fprintf(fid, '%s\n', datetime(now,'ConvertFrom','datenum'));
fclose(fid);

end