%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [method, f_succ] = SP2_Data_PvReadMethod(varargin)
%%
%%  Function to read ParaVision 'method' parameter files. Parameters are
%%  returned in a struct called 'method'.
%%
%%  01-2003 / 08-2007 / 10/2017, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars


%--- init success flag ---
f_succ = 0;


FCTNAME = 'SP2_Data_PvReadMethod';
PARCHAR = '##$';
PARFILE = 'method';     % needs path separator "\" upfront


%--- file path assignment ---
% as:
% 1) the full path of the parameter file (1 function argument)
% 2) assign 'study' and 'expNo' to use the pars.stdpath handling for path composition (2 args)
narg = nargin;
if narg==1
    file = SP2_Check4StrR( varargin{1} );
elseif narg==2
    study = SP2_Check4StrR( varargin{1} );
    expNo = SP2_Check4NumR( varargin{2} );
    file  = [pars.stdpath study '\' num2str(expNo) '\method'];
else
    fprintf('%s -> more than 2 input arguments are not allowed!...',FCTNAME);
    return
end

%--- method structure init ---
method.Method = '';
method.PVM_EchoTime = 0;
method.PVM_EchoTime1 = 0;
method.PVM_EchoTime2 = 0;
method.PVM_MinEchoTime = 0;
method.PVM_RepetitionTime = 0;
method.PVM_MinRepetitionTime = 0;
method.StTM = 0;
method.PVM_NAverages = 0;
method.IsisNAverages = 0;
method.AverageList = 0;
method.PVM_NRepetitions = 1;
method.PVM_UserType = '';
method.PVM_ScanTimeStr = '';
method.Y_Mode = '';
method.PVM_NVoxels = 0; 
method.PVM_VoxArrPosition = 0;
method.PVM_VoxArrSize = 0;
method.Y_VoxelSpacing = 0;
method.Y_VoxelEdges = 0;
method.SE90PulseEnum = '';
method.SE90Pulse = {};
method.SE180PulseEnum = '';
method.SE180Pulse = {};
method.Y_Csd = 0;
method.Y_PosFrequ = 0;
method.Y_ExcOffset = 0;
method.Y_AppliedFrequ = 0;
method.Y_CsiMode = '';
method.Y_SliceOrient = '';
method.Y_CsiFov = 0;
method.Y_CsiMatrix = 0;
method.Y_CsiListSize = 0;
method.Y_CsiAcqTime = 0;
method.Y_CsiBlockSize = 0;
method.Y_CsiBlocks = 0;
method.Y_CsiBlock = 0;
method.Y_CsiCurrBlockSize = 0;
method.Y_CsiBlockDurMin = 0;
method.Y_CsiEncDur = 0;
method.Y_CsiDurMin = 0;
method.Y_CsiGradLim = 0;
method.Y_CsiList0 = 0;
method.Y_CsiList1 = 0;
method.Y_CsiList2 = 0;
method.Y_CsiCircOffset = 0;
method.Y_CsiWeightOffset = 0;
method.Y_CsiAdjGrad = 0;
method.Y_CsiAdjDur = 0;
method.Y_ProfileDir = '';
method.PVM_Fov = 0;
method.Y_ProfileEffSWh = 0;
method.Y_ProfileAcqSize = 0;
method.PVM_ReadDephaseTime = 0;
method.Y_ProfileReadPre = 0;
method.Y_ProfileRead = 0;
method.Y_ImagingOrientation = '';
method.Y_ImagingFov = 0;
method.Y_ImagingAcqTime = 0;
method.Y_ImagingEffSWh = 0;
method.Y_ImagingAcqSize = 0;
method.Y_ImagingPhase = 0;
method.Y_ImagingReadDephaseTime = 0;
method.Y_ImagingReadPre = 0;
method.Y_ImagingRead = 0;
method.Y_MaxGrad = '';
method.Y_gs = 0;
method.Y_gr = 0;
method.Y_tr = 0;
method.Y_gxsp = 0;
method.Y_gysp = 0;
method.Y_gzsp = 0;
method.Y_tsp = 0;
method.Y_tramp = 0;
method.Y_trampi = 0;
method.Y_unbl = 0;
method.Y_bl = 0;
method.Y_setf = 0;
method.Y_delay = 0;
method.Y_tpart = 0;
method.Y_flagEdit = '';
method.Y_EditNI = 0;
method.EditPulseEnum = '';
method.EditPulse = {};
method.Y_EditFrequ = 0;
method.PVM_EffSWh = 0;
method.Y_SpecAcqSize = 0;
method.Y_AcqOffset = 0;
method.Y_flagPhaseMode = '';
method.Y_flagPhaseCyclNA = '';
method.Y_flagPhaseCyclNR = '';
method.PVM_AcquisitionTime = 0;
method.Y_EffDwellTime = 0;
method.Y_flagWS = '';
method.Y_flagRF = '';
method.WSPulseEnum = '';
method.WSPulse = {};
method.Y_WsRrel99 = 0;
method.Y_WsRrel1 = 0;
method.Y_WsBandwidth99 = 0;
method.Y_WsBandwidth1 = 0;
method.Y_WsOffset = 0;
method.Y_WsAtt = 0;
method.Y_WsAttOffset = 0;
method.Y_WsSpoilerDur = 0;
method.Y_WsGx = 0;
method.Y_WsGy = 0;
method.Y_WsGz = 0;
method.Y_WsNumberOfModules = 0;
method.Y_WsModuleDuration = 0;
method.Y_WsTotalDuration = 0;
method.Y_sp01list = 0;
method.Y_sp4list = 0;
method.Y_sp5list = 0;
method.Y_flagOVS = '';
method.PVM_GeoMode = '';
method.PVM_FovSatNSlices = 0;
method.PVM_FovSatThick = 0;
method.PVM_FovSatOffset = 0;
method.PVM_FovSatSliceVec = 0;
method.Y_OvsSliceEdges = 0;
method.Y_OvsCsd = 0;
method.Y_OvsSliceGradient = 0;
method.Y_OvsFrequOffset = 0;
method.Y_OvsSpoilerDuration = 0;
method.Y_OvsSpoilerStrength = 0;
method.Y_OvsAttDefault = 0;
method.Y_OvsAttOffset = 0;
method.Y_OvsAtt = 0;
method.Y_OvsModuleDuration = 0;
method.Y_OvsTotalDuration = 0;
method.OVS0PulseEnum = '';
method.OVS1PulseEnum = '';
method.OVS2PulseEnum = '';
method.OVS3PulseEnum = '';
method.OVS4PulseEnum = '';
method.OVS5PulseEnum = '';
method.OVS6PulseEnum = '';
method.OVS7PulseEnum = '';
method.OVS0Pulse = {};
method.OVS1Pulse = {};
method.OVS2Pulse = {};
method.OVS3Pulse = {};
method.OVS4Pulse = {};
method.OVS5Pulse = {};
method.OVS6Pulse = {};
method.OVS7Pulse = {};
method.Y_AdjTrim = '';
method.Y_ShimReps = 0;
method.Y_flagShimX = '';
method.Y_flagShimY = '';
method.Y_flagShimZ = '';
method.Y_flagGradX = '';
method.Y_flagGradY = '';
method.Y_flagGradZ = '';
method.Y_flagPrintDBLOG = '';
method.Y_flagWriteShimFile = '';
method.PVM_GradCalConst = 0;
method.PVM_Nucleus1Enum = '';
method.PVM_Nucleus1 = '';
method.PVM_EcgTriggerModuleOnOff = '';
method.Y_SyncACPowerLine = '';
method.Y_SyncGradientPS = '';
method.Y_Version = '';
method.Y_flagFrequLock = '';
method.VoxPul1 = '';
method.VoxPul2 = '';
method.VoxPul3 = '';
method.VoxPul1Enum = '';
method.VoxPul2Enum = '';
method.VoxPul3Enum = '';
method.VoxPul1Ampl = 0;
method.VoxPul2Ampl = 0;
method.VoxPul3Ampl = 0;
method.JDEOnOff = '';
method.JDEPul1Enum = '';
method.JDEPul2Enum = '';
method.JDEPul1 = '';
method.JDEPul2 = '';
method.JDEPul1Ampl = 0;
method.JDEPul2Ampl = 0;
method.JDEFrequency1 = 0;
method.JDEFrequency2 = 0;
method.PVM_SpecMatrix = 0;              % new Bruker format
method.IsisNAverages = 0;
method.PVM_DigShift = 0;
method.PVM_RefScanYN = '';
method.PVM_RefScanNA = 0;
method.PVM_RefScan = 0;
method.PVM_EncSpectroscopy = '';
method.PVM_EncUseMultiRec = '';
method.PVM_EncActReceivers = {};
method.PVM_EncNReceivers = 0;
method.PVM_EncAvailReceivers = 0;
method.PVM_EncChanScaling = 0;


%--- generation of method struct field tags ---
methodNames = fieldnames(method);
methodNtags = length(methodNames);

%--- method file reading and parameter extraction ---
fid        = fopen(file,'r');
parKeyStr  = '##$';
parKeyStrN = length(parKeyStr);
f_multi    = 1;                 % multi-line parameter, next line belongs to same parameter
if fid>0
    %--- info printout ---
    fprintf('%s -> reading <%s>\n',FCTNAME,file);
   
    %--- go through file ---
    while ~feof(fid)
        %--- next line ---
        if f_multi                                      % go to next line after 2-line parameter
            tline   = fgetl(fid);
        else                                            % shift line assignment
            tline   = tlineNext;                    
            f_multi = 1;                                % fake assignment to force new line with next iteration
        end        
        
        %--- check for parameter ---
        if ~isempty(strfind(tline,parKeyStr))
            %--- extract field name ---
            equInd = find(tline=='=');
            fName  = tline(parKeyStrN+1:equInd-1);
                        
            %--- check parameter validity ---  
            if isfield(method,fName)
                %--- two-line parameter assignment, 1st line: parameter name, 2nd line: parameter values ---
                if ~isempty(tline=='=') && ~isempty(strfind(tline,'(')) && ~isempty(strfind(tline,')'))             % parenthesis
                    %--- single/multi-line handling ---
                    tlineNext = fgetl(fid);
                    if isempty(find(tlineNext=='='))          % 2-line parameter
                        f_multi = 1;
                        
                        % get parameter value
                        if isnumeric(eval(['method.' fName]))                 % numeric
                            eval(['method.' fName ' = str2num(tlineNext);'])
                        elseif ischar(eval(['method.' fName]))                % string
                            eval(['method.' fName ' = StrStripBracket(tlineNext);'])
                        else                                                  % cell
                            cellTmp = textscan(tlineNext,'%s');
                            eval(['method.' fName ' = cellTmp{1};'])
                        end
                    else                                    % single line parameter
                        f_multi = 0;
                        
                        % get number of elements
                        if isnumeric(eval(['method.' fName]))                 % numeric
                            [parValStr,fake] = strtok(tline(equInd(end)+1:end),'(');
                            [parValStr,fake] = strtok(parValStr,')');
                            eval(['method.' fName ' = str2num(parValStr);'])
                        elseif ischar(eval(['method.' fName]))                % string
                            eval(['method.' fName ' = StrStripBracket(tlineNext);'])
                        else                                                  % cell
                            cellTmp = textscan(tlineNext,'%s');
                            eval(['method.' fName ' = cellTmp{1};'])
                        end
                    end
                %--- two-line parameter assignment, 1st line: parameter name + part of values, 2nd line: rest of parameter values ---
                % example: RF pulses
                elseif ~isempty(tline=='=') && ~isempty(strfind(tline,'(')) && ~isempty(strfind(tline,',')) && isempty(strfind(tline,')'))             % parenthesis
                    %--- single/multi-line handling ---
                    tlineNext = fgetl(fid);
                    if isempty(find(tlineNext=='='))          % no additional equal sign in next line
                        tlineComb = [tline tlineNext];
                        braInd = find(tlineComb=='(');
                        ketInd = find(tlineComb==')');
                        if ~isempty(braInd) && ~isempty(ketInd) && length(tlineComb)>2
                            cellTmp = textscan(SP2_SubstStrPart(tlineComb(braInd(1)+1:ketInd(end)-1),',',''),'%s');
                            for cCnt = 1:length(cellTmp{1})
                                eval(['method.' fName '{' num2str(cCnt) '} = StrStripBracket(cellTmp{1}{cCnt});'])
                            end
                        end
                    end
                %--- single-line parameter assignment ---    
                elseif ~isempty(tline=='=') && isempty(strfind(tline,'(')) && isempty(strfind(tline,')'))         % same line
                    if isnumeric(eval(['method.' fName]))                 % numeric
                        % tline
                        eval(['method.' fName ' = str2num(tline(equInd(end)+1:end));'])
                    elseif ischar(eval(['method.' fName]))                % string
                        eval(['method.' fName ' = StrStripBracket(tline(equInd(end)+1:end));'])
                    else                                                % cell
                        cellTmp = textscan(tline(equInd(end)+1:end),'%s');
                        eval(['method.' fName ' = cellTmp{1};'])
                    end
                end        
            end
        end
    end
    fclose(fid);
    f_succ = 1;
else
   fprintf('%s -> Opening file failed:\n<%s>\n',FCTNAME,file);
end


% %--- method file reading and parameter extraction ---
% fid = fopen(file,'r');
% if (fid > 0)
%     fprintf('%s -> reading <%s>\n',FCTNAME,file);
%    
%     while (~feof(fid))
%         tline = fgetl(fid);
%         %--- remove line breaks of single parameters ---
%         if length(findstr(tline,'('))~=length(findstr(tline,')'))             % opened, but not closed
%             while length(findstr(tline,'('))~=length(findstr(tline,')'))
%                 tline = [tline fgetl(fid)];                     % add next line    
%             end
%         end
%         
%         strncmp(PARCHAR, tline, length(PARCHAR));
%         if (strncmp(PARCHAR, tline, length(PARCHAR)))   % check if parameter
%             par = tline( length(PARCHAR)+1 : findstr(tline,'=')-1 );
%             parvalStr = tline( findstr(tline,'=')+1 : length(tline) );
%             %---  insert for format transformation: ( 1, 3 ) to ( 3 ) for PVM_VoxArrSize/Position
%             if isempty(findstr(parvalStr,','))==0 && isempty(findstr(parvalStr,'( '))==0
%                 parvalStr = SP2_ConvertList2Product(parvalStr);  % e.g. ( 1, 3 ) -> ( 3 ), ( 60, 3 ) -> ( 180 )
%             end
%             for itag=1:methodNtags      % searching method STRUCT
%                 if (strcmp(par, methodNames(itag)))      
%                     %--- discrimination string/numeric/cell and data
%           
%                     % string
%                     if ischar( getfield(method, char(methodNames(itag))) ) 
%                         if isempty( findstr('(', parvalStr) )  
%                             parval = parvalStr;
%                         else        % read only until the first '>'
%                             parval = '';                 
%                             ch = fscanf(fid, '%c',1);
%                             while (ch ~= '#' && ch~='$')
%                                 parval = [parval ch];
%                                 if (ch == '>')
%                                     tline = fgetl(fid);     % get rest of line
%                                 end
%                                 ch = fscanf(fid, '%c',1);
%                             end
%                             stat = fseek(fid,-1,'cof');   % reposition fid
%                         end              
%                     elseif  isnumeric( getfield(method, char(methodNames(itag))) )      % numeric
%                         if any( findstr('(', parvalStr) )
%                             [parvalStr,fake] = strtok(parvalStr,'(');
%                         end
%                         if any( findstr(')', parvalStr) )
%                             [parvalStr,fake] = strtok(parvalStr,')');
%                         end
%                         parvalStr
%                         parval = str2num(parvalStr);
%                     else                                                                % cell array
%                         if isempty( findstr('(', parvalStr) )  
%                             parval{1} = parvalStr;
%                         else        % read only until the first '>'
%                             iStartVec = findstr(tline,'(');
%                             iStartInd = iStartVec(1);
%                             iEndVec   = findstr(tline,')');
%                             iEndInd   = iEndVec(end);
%                             tline = tline(iStartInd+1:iEndInd-1);
%                             icnt = 1;   % init index counter
%                             while findstr(tline,',')
%                                 [val,tline] = strtok(tline,',');
%                                 if isempty(str2num(val))    % string
%                                     parval{icnt} = SP2_DeleteStrPart(val,' ');
%                                 else                        % numeric
%                                     parval{icnt} = str2num(val);
%                                 end
%                                 icnt = icnt + 1;
%                             end
%                         end          
%                     end
%                     if ischar(parval)
%                         parval = deblank(parval);
%                     end
%                     method = setfield(method, char(methodNames(itag)), parval);
%                 end   %
%             end   % for 
%         end   % else ignore line
%     end
%     fclose(fid);
%     f_succ = 1;  
% else
%    fprintf('%s -> can not open <%s>\n',FCTNAME,file);
%    f_succ = 0;
% end

%--- remove large phase encoding lists if not required ---
if ~strcmp(method.Y_Mode,'Y_CSI') && ~strcmp(method.Y_Mode,'Y_Imaging')
    method = rmfield(method,'Y_CsiList0');
    method = rmfield(method,'Y_CsiList1');
    method = rmfield(method,'Y_CsiList2');
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L     F U N C T I O N                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strClean = StrStripBracket(strRaw)

braInd = find(strRaw=='<');
if ~isempty(braInd)
    if braInd(1)<length(strRaw)
        strRaw = strRaw(braInd(1)+1:end);
    end
end

ketInd = find(strRaw=='>');
if ~isempty(ketInd)
    if ketInd(end)<=length(strRaw)
        strRaw = strRaw(1:ketInd(end)-1);
    end
end

strClean = strRaw;



