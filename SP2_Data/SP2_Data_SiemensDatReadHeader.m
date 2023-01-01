%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [procpar, f_succ] = SP2_Data_SiemensDatReadHeader(file)
%%
%%  Function to read file headers of Siemens .dat files.
%%
%%  10-2016, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Data_SiemensDatReadHeader';

%--- debugging option ---
flag.debug = 0;

%--- init success flag ---
f_succ = 0;

%--- init output pars ---
procpar = {};

%--- consistency check ---
if ~SP2_CheckFileExistenceR(file)
    return
end

%--- procpar structure init ---
procpar.Study                   = '';
procpar.StudyDescription        = '';               % IMA
procpar.PatientName             = '';
procpar.Patient                 = '';               % IMA
procpar.InstitutionName         = '';
procpar.SoftwareVersions        = '';
procpar.lFrequency              = 0;
procpar.aRxCoilSelectData0ID    = '';
procpar.tSequenceFileName       = '';
procpar.SequenceName            = '';               % IMA
procpar.tProtocolName           = '';
procpar.alTR0                   = 0;
procpar.alTE0                   = 0;
procpar.alTE1                   = 0;
procpar.alTD                    = 0;                % TM
procpar.aRxCoilSelectData0Size  = 0;
procpar.lRxChannelMax           = 0;                % not an original parameter 
procpar.lRetroGatedImages       = 0;
procpar.lAverages               = 0;
procpar.dAveragesDouble         = 0;
procpar.lTotalScanTimeSec       = 0;
procpar.alDwellTime0            = 0;
procpar.dThickness              = 0;
procpar.dPhaseFOV               = 0;
procpar.dReadoutFOV             = 0;
procpar.dInPlaneRot             = 0;
procpar.sPositionDSag           = 0;
procpar.sPositionDCor           = 0;
procpar.sPositionDTra           = 0;
procpar.lVectorSize             = 0;
procpar.dDeltaFrequency         = 0;
procpar.sVoIdThickness          = 0;
procpar.sVoIdPhaseFOV           = 0;
procpar.sVoIdReadoutFOV         = 0;
procpar.sVoIdInPlaneRot         = 0;
procpar.sVoIdInPlaneRot         = 0;
procpar.shimChannels            = 0;
procpar.shim0                   = 0;
procpar.shim1                   = 0;
procpar.shim2                   = 0;
procpar.shim3                   = 0;
procpar.shim4                   = 0;
procpar.lElementSelected        = 0;
procpar.overSamplFac            = 0;        % oversampling factor: .DAT
procpar.ReadoutOS               = 0;        % oversampling factor: DICOM
procpar.tSequenceFileName       = '';       % DICOM


%--- procpar file reading and extraction of the above parameter values ---
% note: both, the 1st and 2nd line per parameter are extracted here
[fid,msg] = fopen(file,'r');
fileID    = fread(fid,1,'uint32');
nMeas     = fread(fid,1,'uint32');                  % number of measurement blocks
nFound    = 0;                                      % number of measurement headers found
if fid>0
    %--- info printout ---
    fprintf('%s ->\nReading <%s>\n',FCTNAME,file);
    
    %--- parameter extraction ---
    acbVec    = 0;                      % pointer positions of ASCCONV BEGIN lines
    nACB      = 0;                      % appearance counter of ASCCONV BEGIN lines
    acbCell   = {};                     % cell of ASCONV BEGIN lines
    aceVec    = 0;                      % pointer positions of ASCCONV END lines
    nACE      = 0;                      % appearance counter of ASCCONV END lines
    aceCell   = {};                     % cell of ASCCONV END lines
    f_header  = 0;                      % last header found
    %--- locate last/relevant header ---
    while ~feof(fid) && ~f_header
        %--- next line ---
        tline = fgetl(fid);
%         if flag.debug
%             fprintf('%s\n',tline)
%         end

        %--- find anywhere ---
        if any(strfind(tline,'sGRADSPEC.alShimCurrent.__attribute__.size')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shimChannels = str2double(valStr);
        end
        
        if any(strfind(tline,'sGRADSPEC.alShimCurrent[0]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shim0 = str2double(valStr);
        end
        
        if any(strfind(tline,'sGRADSPEC.alShimCurrent[1]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shim1 = str2double(valStr);
        end
        
        if any(strfind(tline,'sGRADSPEC.alShimCurrent[2]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shim2 = str2double(valStr);
        end
        
        if any(strfind(tline,'sGRADSPEC.alShimCurrent[3]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shim3 = str2double(valStr);
        end
        
        if any(strfind(tline,'sGRADSPEC.alShimCurrent[4]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.shim4 = str2double(valStr);
        end
        
        %--- X shim ---
        if any(strfind(tline,'lOffsetX')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.x1    = str2double(valStr);
        end
        
        %--- Y shim ---
        if any(strfind(tline,'lOffsetY')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.y1    = str2double(valStr);
        end
        
        %--- Z shim ---
        if any(strfind(tline,'lOffsetZ')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.z1c   = str2double(valStr);
        end
        
        %--- software version ---
        if any(strfind(tline,'<ParamString."SoftwareVersions">')) && ~any(strfind(tline,'='))
            quoteInd = find(tline=='"');
            if length(quoteInd)==4
                procpar.SoftwareVersions = tline(quoteInd(3)+1:quoteInd(4)-1);
            end
        end
        
        if any(strfind(tline,'<ParamString."Study">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            [fake,valStr] = strtok(tline,'{');
            [fake,valStr] = strtok(valStr,'"');
            [valStr,fake] = strtok(valStr,'"');
            procpar.Study = valStr;
        end
        
        if any(strfind(tline,'<ParamString."Patient">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            [fake,valStr] = strtok(tline,'{');
            [fake,valStr] = strtok(valStr,'"');
            [valStr,fake] = strtok(valStr,'"');
            procpar.Patient = valStr;
        end
        
        if any(strfind(tline,'<ParamString."InstitutionName">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            [fake,valStr] = strtok(tline,'{');
            [fake,valStr] = strtok(valStr,'"');
            [valStr,fake] = strtok(valStr,'"');
            procpar.InstitutionName = valStr;
        end
        
        if any(strfind(tline,'<ParamBool."ReferenceFlag">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            if any(strfind(tline,'"true"'))         % { "true" }
                procpar.ReferenceFlag = 1;
            else                                    % { }
                procpar.ReferenceFlag = 0;
            end
        end
                
        if any(strfind(tline,'<ParamLong."NumberOfRefScan">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            [fake,valStr] = strtok(tline,'{');
            [valStr,fake] = strtok(valStr,'{');
            [valStr,fake] = strtok(valStr,'}');
            procpar.numberOfRefScan = str2double(valStr);
            if mod(procpar.numberOfRefScan,1)~=0 || procpar.numberOfRefScan<1     % integer >0
                fprintf('Conversion of number of reference scans failed. Program aborted.\n')
                return
            end
        end
        
        if any(strfind(tline,'lContrasts')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lContrasts = str2double(valStr);
        end
        
        if any(strfind(tline,'<ParamDouble."ReadoutOversamplingFactor">')) && any(strfind(tline,'{')) && any(strfind(tline,'}'))
            [fake,valStr] = strtok(tline,'{');
            [fake,valStr] = strtok(valStr,'>');
            [valStr,fake] = strtok(valStr,'>');
            [valStr,fake] = strtok(valStr,'}');
            [fake,valStr] = strtok(valStr,' ');
            if ~any(valStr=='.')             % double
                fprintf('Reading of oversampling factor failed. Program aborted.\n')
                return
            end
            procpar.overSamplFac = str2double(valStr);
            if mod(procpar.overSamplFac,1)~=0 || procpar.overSamplFac<1     % integer >0
                fprintf('Conversion of oversampling factor failed. Program aborted.\n')
                return
            end
        end
        
        %--- removal of oversampling (already applied) ---
        % sSpecPara.ucRemoveOversampling	 = 	0x1
        if any(strfind(tline,'sSpecPara.ucRemoveOversampling')) && any(strfind(tline,'=')) && any(strfind(tline,'x'))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            if ~any(findstr(valStr,'0x'))             % hexadecimal 0/1
                fprintf('Reading of Boolean for applied oversampling removal failed. Program aborted.\n')
                return
            end
            % procpar.rmOversampl = hex2dec(valStr);
            xInd = findstr(valStr,'x');
            if ~isempty(xInd)
                if length(valStr)>xInd
                    procpar.rmOversampl = str2double(valStr(xInd+1));
                end
            end
        end
        
        
        % notes and other related parameters
        % <ParamFunctor."SpecRoFt"> 
        %  {
        %    <Class> "SpecRoFtFunctor@SpecScanFunctors" 
        %    
        %    <ParamBool."RemoveOversampling">  { "true"  }
        %    <ParamLong."VectorSize">  { 2048  }

        % <ParamLong."ucRemoveOversampling"> 
        % {
        %   1 
        % }

        % <ParamLong."RemoveOversampling"> 
        % {
        %  1 
        % }
        
        %  <ParamBool."OnlineSendRHP"> 
        %  {
        %    <Comment> "Raw Data in RHP-Format (Low-Pass Filter + Oversampling removed) will be send to stand alone machine." 
        %    <LimitRange> { "false" "true" }
        %  }
                
        %--- ReadoutOS parameter ---
        % note that the extraction is a bit flimsy and therefore numerous checks are included
        if any(strfind(tline,'ReadoutOS')) && (strcmp(file(end-3:end),'.IMA') || strcmp(file(end-3:end),'.dcm'))
            rosInd  = strfind(tline,'ReadoutOS');
            snipLen = 150;
%             if length(tline)>rosInd+snipLen
%                 rosSnip = tline(rosInd:rosInd+snipLen);
%             else
%                 rosSnip = '';
%                 fprintf('Snip extraction of parameter <ReadoutOS> failed. Program aborted.\n')
%                 %return
%             end
%             dotInd = strfind(rosSnip,'.');            
            
            rosSnip = tline(rosInd:min(rosInd+snipLen,length(tline)));
            if isempty(rosSnip)
                fprintf('Snip extraction of parameter <ReadoutOS> failed. Program aborted.\n')
                procpar.ReadoutOS = 2;          % default
                %return
            end
            dotInd = strfind(rosSnip,'.00000000');
            % check if findstr is better as strfind does not look for
            % entire string, but for any of the strings
            if isempty(dotInd)
                
                % try to find in next line:
                for dotCnt = 1:10
                    if isempty(dotInd)
                        tline = fgetl(fid);
                        dotInd = strfind(tline,'.');
                    end
                end
                if isempty(dotInd)
                    fprintf('Value extraction of parameter <ReadoutOS> failed (no dot found). Program aborted.\n')
                    procpar.ReadoutOS = 2;          % default
                    %return
                else
                    valStr = tline(dotInd-3:dotInd+9);
                end
            elseif length(dotInd)>1
                fprintf('Value extraction of parameter <ReadoutOS> failed (>1 dots found). Program aborted.\n')
                %return
            elseif length(rosSnip)<dotInd+9
                fprintf('Value extraction of parameter <ReadoutOS> failed (dot too close to end of snip). Program aborted.\n')
                procpar.ReadoutOS = 2;          % default
                %return
            else
                valStr = rosSnip(dotInd-3:dotInd+9);
            end
            procpar.ReadoutOS = str2double(valStr);
            if procpar.ReadoutOS<1     % >0
                fprintf('Value extraction of parameter <ReadoutOS> failed (non-meaningful value: %.6f). Program aborted.\n',...
                        procpar.ReadoutOS)
                procpar.ReadoutOS = 2;          % default
                %return
            end
        end
                
        
        if any(strfind(tline,'tSequenceFileName')) && any(strfind(tline,'=')) && any(strfind(tline,'"')) && ...
           (strcmp(file(end-3:end),'.IMA') || strcmp(file(end-3:end),'.dcm'))
            slashInd = strfind(tline,'\');
%             if isempty(slashInd)
%                 fprintf('<tSequenceFileName> extraction failed (no slash found). Program aborted.\n')
%                 return
%             elseif length(slashInd)>1
%                 fprintf('<tSequenceFileName> extraction failed (more than 1 slash found). Program aborted.\n')
%                 return
%             end
%             hyphInd = strfind(tline,'"');
%             if length(hyphInd)<2
%                 fprintf('<tSequenceFileName> extraction failed (less than 2 hyphens found). Program aborted.\n')
%                 return
%             end
%             if hyphInd-1<=slashInd+1
%                 fprintf('<tSequenceFileName> extraction failed (inconsistent indexing). Program aborted.\n')
%                 return
%             end
%             procpar.tSequenceFileName = tline(slashInd+1:hyphInd(end-1)-1);
            if isempty(slashInd)
                fprintf('WARNING: <tSequenceFileName> extraction failed (no slash found).\n')
                procpar.tSequenceFileName = '';
            elseif length(slashInd)>1
                fprintf('WARNING: <tSequenceFileName> extraction failed (more than 1 slash found).\n')
                procpar.tSequenceFileName = '';
            end
            if length(slashInd)==1
                hyphInd = strfind(tline,'"');
                if length(hyphInd)<2
                    fprintf('<tSequenceFileName> extraction failed (less than 2 hyphens found). Program aborted.\n')
                    return
                end
                if hyphInd-1<=slashInd+1
                    fprintf('<tSequenceFileName> extraction failed (inconsistent indexing). Program aborted.\n')
                    return
                end
                procpar.tSequenceFileName = tline(slashInd+1:hyphInd(end-1)-1);
            end
        end
                     
        
        
%--- tmp ---
%         if length(tline)>9
%             if strcmp(tline(1:9),'lAverages') && any(strfind(tline,'='))
%                 [fake,valStr] = strtok(tline,'=');
%                 [valStr,fake] = strtok(valStr,'=');
%                 lAverages = str2double(valStr)
%             end
%         end
%         if any(strfind(tline,'16')) && any(strfind(tline,'='))
%             fprintf('%s\n',tline)
%         end
        
        %--- record appearances of ASCCONV BEGIN ---
        if any(strfind(tline,'### ASCCONV BEGIN'))
            nACB          = nACB + 1;
            acbVec(nACB)  = ftell(fid);     
            acbCell{nACB} = tline;                      % cell of ASCCONV END lines
            %if flag.verbose
            %    fprintf('\nacbVec = %s\n',SP2_Vec2PrintStr(acbVec,0))
            %end
        end

        %--- end of last header ---
        if any(strfind(tline,'### ASCCONV END ###'))
            nACE          = nACE + 1;
            aceVec(nACE)  = ftell(fid);                 % keep end of header position
            aceCell{nACE} = tline;                      % cell of ASCCONV END lines
    
            %--- break condition handling ---
            if any(strfind(tline,'Spice'))
                nFound = nFound + 1;                        % increase counter of nMeas
                if nFound==nMeas
                    f_header = 1;                           % exit while loop as last header has been found
                end
            end
        end
    end
    fseek(fid,acbVec(end),-1);                          % jump back to beginning of last header
    
    %--- info printout ---
    if flag.debug
        fprintf('ASCCON BEGIN positions:\n')
        for acbCnt = 1:nACB
            fprintf('%.0f) <%s> (%.0f)\n',acbCnt,acbCell{acbCnt},acbVec(acbCnt))
        end
        fprintf('\n')
        
        fprintf('ASCCON END positions:\n')
        for aceCnt = 1:nACE
            fprintf('%.0f) <%s> (%.0f)\n',aceCnt,aceCell{aceCnt},aceVec(aceCnt))
        end
        fprintf('\n')
    end

    %--- read relevant header ---
    while ~feof(fid) && ftell(fid)<aceVec(end)
        % ~end of file && ~passed end of last header && ~all parameters found
        
        %--- next line ---
        tline = fgetl(fid);
        if flag.debug
          fprintf('%s\n',tline)
        end
            
        %--- serial parameter check ---
        % due to irregular format 
        
        if any(strfind(tline,'sTXSPEC.asNucleusInfo[0].lFrequency')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lFrequency = str2double(valStr);
        end
        
        if any(strfind(tline,'alTR[0]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.alTR0 = str2double(valStr);
        end
        
        if any(strfind(tline,'alTE[0]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.alTE0 = str2double(valStr);
        end
        
        if any(strfind(tline,'alTE[1]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.alTE1 = str2double(valStr);
        end
        
        if any(strfind(tline,'alTD[0]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.alTD  = str2double(valStr);
        end
        
        %--- VD / VE ---
        % syngo MR E11 (Stony Brook, NYU)
        if any(strfind(tline,'sCoilSelectMeas.aRxCoilSelectData[0].asList.__attribute__.size')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.aRxCoilSelectData0Size = str2double(valStr);
        end
        
        %--- VB ---
        % note that the brackets are not really used other than to check
        % string consistency
        if any(strfind(tline,'asCoilSelectMeas[0].aFFT_SCALE[')) && any(strfind(tline,'].lRxChannel')) && any(strfind(tline,'='))
            braInd = find(tline=='[');
            ketInd = find(tline==']');
            if ~isempty(braInd) && ~isempty(ketInd) && length(braInd)==length(ketInd)
                if  ketInd(end)>braInd(end)+1
                    [fake,valStr] = strtok(tline,'=');
                    [valStr,fake] = strtok(valStr,'=');
                    procpar.lRxChannelMax = max(procpar.lRxChannelMax,str2double(valStr));
                end
            end
        end     
                
        if any(strfind(tline,'sCoilSelectMeas.aRxCoilSelectData[0].asList[0].sCoilElementID.tCoilID')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [fake,valStr] = strtok(valStr,'"');
            [valStr,fake] = strtok(valStr,'"');
            procpar.aRxCoilSelectData0ID = valStr;
        end
        
        if any(strfind(tline,'sPhysioImaging.lRetroGatedImages')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lRetroGatedImages = str2double(valStr);
        end
        
        if any(strfind(tline,'tSequenceFileName')) && any(strfind(tline,'='))
            slashInd = find(tline=='\');
            quoteInd = find(tline=='"');
            if length(slashInd)==1 && length(quoteInd)==2
                procpar.tSequenceFileName = tline(slashInd+1:quoteInd(2)-1);
            end
        end
        
        if any(strfind(tline,'tProtocolName')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [fake,valStr] = strtok(valStr,'"');
            [valStr,fake] = strtok(valStr,'"');
            procpar.tProtocolName = valStr;
        end
                
        if length(tline)>9
            if strcmp(tline(1:9),'lAverages') && any(strfind(tline,'='))
                [fake,valStr] = strtok(tline,'=');
                [valStr,fake] = strtok(valStr,'=');
                procpar.lAverages = str2double(valStr);
            end
        end
        
        if any(strfind(tline,'dAveragesDouble')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dAveragesDouble = str2double(valStr);
        end
        
        if any(strfind(tline,'lTotalScanTimeSec')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lTotalScanTimeSec = str2double(valStr);
        end
        
        if any(strfind(tline,'sRXSPEC.alDwellTime[0]')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.alDwellTime0 = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.dThickness')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dThickness = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.dPhaseFOV')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dPhaseFOV = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.dReadoutFOV')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dReadoutFOV = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.dInPlaneRot')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dInPlaneRot = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.sPosition.dSag')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sPositionDSag = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.sPosition.dCor')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sPositionDCor = str2double(valStr);
        end
        
        if any(strfind(tline,'sAdjData.sAdjVolume.sPosition.dTra')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sPositionDTra = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.lVectorSize')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lVectorSize = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.lPreparingScans')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.lPreparingScans = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.dDeltaFrequency')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.dDeltaFrequency = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.sVoI.dThickness')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sVoIdThickness = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.sVoI.dPhaseFOV')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sVoIdPhaseFOV = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.sVoI.dReadoutFOV')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sVoIdReadoutFOV = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.sVoI.dInPlaneRot')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sVoIdInPlaneRot = str2double(valStr);
        end
        
        if any(strfind(tline,'sSpecPara.sVoI.dInPlaneRot')) && any(strfind(tline,'='))
            [fake,valStr] = strtok(tline,'=');
            [valStr,fake] = strtok(valStr,'=');
            [valStr,fake] = strtok(valStr,'=');
            procpar.sVoIdInPlaneRot = str2double(valStr);
        end
        
        %--- info printout ---
%         if ~any(~foundVec)
%             fprintf('\nAll 35 parameters found.\n')
%         end
    end
    fclose(fid);
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,file,msg);
    return
end

%--- consistency check ---
if procpar.lFrequency==0 || procpar.lAverages==0 || procpar.lVectorSize==0 || procpar.alDwellTime0==0
    fprintf('%s ->\nEmpty parameter structure detected. Reading of header not successful.\n',FCTNAME)
    procpar
    return
else
%     procparNtags = length(fieldnames(procpar));
%     fprintf('%.0f selected parameters extracted from file header.\n',procparNtags)
    if flag.verbose
        procpar
    end
end

%--- debugging option ---
if flag.debug
    fprintf('\n\nprocpar.lVectorSize %.0f\n\n',procpar.lVectorSize)
end

%--- update success flag ---
f_succ = 1;


