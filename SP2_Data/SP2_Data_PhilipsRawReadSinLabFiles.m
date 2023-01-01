%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [procpar, f_succ] = SP2_Data_PhilipsRawReadSinLabFiles(sinFile,labFile)
%%
%%  Function to read Philips parameter files .sin and .lab.
%%
%%  05-2017, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Data_PhilipsRawReadSinLabFiles';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if ~SP2_CheckFileExistenceR(sinFile)
    return
end
if ~SP2_CheckFileExistenceR(labFile)
    return
end

%--- procpar structure init ---
procpar = {};

%--- procpar file reading and extraction of the above parameter values ---
% note: both, the 1st and 2nd line per parameter are extracted here
[fid,msg] = fopen(sinFile,'r');
if fid>0
    %--- consistency check ---
    tline = fgetl(fid);
    
    %--- info printout ---
    fprintf('%s ->\nReading <%s>\n',FCTNAME,sinFile);
    
    %--- parameter extraction ---
    while ~feof(fid) && isempty(strfind(tline,'End of header'))
        tline = fgetl(fid);
                
        %--- extraction of parameter name ---
        colonInd = find(tline==':');
        if length(colonInd)>=2
            parName = SP2_SubstStrPart(tline(colonInd(1)+1:colonInd(2)-1),' ','');
            if strcmp(parName,'start_scan_date_time')
                eval(['procpar.' parName ' = tline(colonInd(2)+1:end);'])
            elseif strcmp(parName,'coil_survey_cpx_file_names') || strcmp(parName,'coil_survey_rc_file_names') || ...
                   strcmp(parName,'scan_name') || strcmp(parName,'start_scan_date_time') || ...
                   strcmp(parName,'channel_names') || strcmp(parName,'receiving_coils') || ...
                   strcmp(parName,'multi_coil_element_names') || strcmp(parName,'channel_combinations') || ...
                   strcmp(parName,'immed_channel_combinations') || strcmp(parName,'ph_immed_channel_combination')
                eval(['procpar.' parName ' = SP2_SubstStrPart(tline(colonInd(2)+1:end),'' '','''');'])
            else            % numeric    
                cellTmp = textscan(tline(colonInd(2)+1:end),'%f%f%f%f%f%f%f%f%f%f');
                if isfield(procpar,parName)             % append if existing parameter
                    eval(['parIndOffset = length(procpar.' parName ');'])
                else
                    parIndOffset = 0;
                end 
                for cCnt = 1:length(cellTmp)
                    if ~isempty(cellTmp{cCnt})
                        eval(['procpar.' parName '(' num2str(parIndOffset+cCnt) ') = cellTmp{' num2str(cCnt) '};'])
                    end
                end
            end 
        end
    end
    fclose(fid);
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,sinFile,msg);
    return
end

%--- consistency check ---
if isempty(procpar)
    fprintf('%s ->\nParameter reading failed. Program aborted.\n\n',FCTNAME)
    return
end


%%%%%%%%%    L A B    F I L E    R E A D I N G    %%%%%%%%%%%%
% note: both, the 1st and 2nd line per parameter are extracted here
[fid,msg] = fopen(labFile,'r');
if fid>0
    %--- info printout ---
    fprintf('%s ->\nReading <%s>\n',FCTNAME,labFile);
        
    %--- read first 10 values ---
    % assuming that all data blocks have the same format
    nLabels         = 10;
    [labels,nBytes] = fread(fid,[16 nLabels],'uint32=>uint32');
    dataSize        = labels(1,:);
    offsetVec       = zeros(nLabels,1);
    offsetVec(1)    = 512;
    for lCnt=2:nLabels
        offsetVec(lCnt) = offsetVec(lCnt-1) + dataSize(lCnt-1);
    end
    offsetPosInd     = find(offsetVec>10000);
    procpar.datStart = offsetVec(offsetPosInd(1));
    fclose(fid);
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,file,msg);
    return
end


%%%%%%%%%    S P A R    R E A D I N G    %%%%%%%%%%%%
%--- (temporary) reading of Larmor frequency and bandwidth from SPAR file ---
%--- derive study path ---
if flag.OS==1            % Linux
    slashInd = find(sinFile=='/');
elseif flag.OS==2        % Mac
    slashInd = find(sinFile=='/');
else                     % PC
    slashInd = find(sinFile=='\');
end

%--- directory extraction ---
if length(slashInd)<1
    return
end
studyDir  = sinFile(1:slashInd(end));
dirStruct = dir(studyDir);
dirLen    = length(dirStruct);
altCnt    = 0;                  % alternative .fid directory counter (init)
altStruct = [];                 % init alternative fid (directory) structure

%--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
for sCnt = 1:dirLen             % all elements in folder
    if any(strfind(dirStruct(sCnt).name,'.SPAR') & dirStruct(sCnt).isdir==0);    % all .SPAR files
        underInd = findstr(dirStruct(sCnt).name,'_');
        % check for underscore and reasonable string-to-number conversion
        if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
            altCnt = altCnt + 1;
            altStruct(altCnt).name   = dirStruct(sCnt).name;
            altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
        end
    end
end
altN = altCnt;    % number of alternative .fid directories

%--- apply SPAR of the same scan number (if found) ---
if altN>0           % .SPAR found for .RAW scan number
    sparFile = altStruct(1).name;
else                % take any .SPAR
    %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
    for sCnt = 1:dirLen             % all elements in folder
        if any(strfind(dirStruct(sCnt).name,'.SPAR') & dirStruct(sCnt).isdir==0);    % all .SPAR files
            sparFile = dirStruct(sCnt).name;
            altCnt = altCnt + 1;
        end
    end
    if altCnt==0        % break if no .SPAR has been found
        return
    end
end

%--- read header from file ---
[spar,f_done] = SP2_Data_PhilipsSdatReadSparFile([studyDir sparFile]);
if ~f_done
    fprintf('%s ->\nReading Philips header from file failed. Program aborted.\n',FCTNAME)
    return
end

%--- parameter assignment ---
if isfield(spar,'sample_frequency')
    procpar.DwellTime   = 1/spar.sample_frequency*1e6;
else
    procpar.DwellTime   = 0;
end
if isfield(spar,'synthesizer_frequency')
    procpar.MRFrequency = spar.synthesizer_frequency/1e6;
else
    procpar.MRFrequency = 0;
end

%--- update success flag ---
f_succ = 1;


