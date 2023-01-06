%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [procpar, f_succ] = SP2_Data_SiemensRdaReadHeader(file)
%%
%%  Function to read file headers of Siemens .dat files.
%%
%%  11-2016, Ch. Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_SiemensDatReadHeader';


%--- init success flag ---
f_succ = 0;
procpar = {};

%--- consistency check ---
if ~SP2_CheckFileExistenceR(file)
    return
end

%--- procpar structure init ---
procpar.PatientName         = {};              
procpar.PatientID           = {};                
procpar.PatientSex          = {};               
procpar.PatientBirthDate    = {};
procpar.StudyDate           = {};
procpar.StudyTime           = {};
procpar.StudyDescription    = {};
procpar.PatientAge          = {};
procpar.PatientWeight       = {};
procpar.SeriesDate          = {};
procpar.SeriesTime          = {};
procpar.SeriesDescription   = {};
procpar.ProtocolName        = {};
procpar.PatientPosition     = {};
procpar.SeriesNumber        = {};
procpar.InstitutionName     = {};
procpar.StationName         = {};
procpar.ModelName           = {};
procpar.DeviceSerialNumber  = {};
procpar.SoftwareVersion     = {};
procpar.InstanceDate        = {};
procpar.InstanceTime        = {};
procpar.InstanceNumber      = {};
procpar.InstanceComments    = {};
procpar.AcquisitionNumber   = {};
procpar.SequenceName        = {};
procpar.SequenceDescription = {};
procpar.TR                  = {};
procpar.TE                  = {};
procpar.TM                  = {};
procpar.TI                  = {};
procpar.DwellTime           = {};
procpar.EchoNumber          = {};
procpar.NumberOfAverages    = {};
procpar.MRFrequency         = {};
procpar.Nucleus             = {};
procpar.MagneticFieldStrength = {};
procpar.NumOfPhaseEncodingSteps = {};
procpar.FlipAngle           = {};
procpar.VectorSize          = {};
procpar.CSIMatrixSize       = 0;
procpar.CSIMatrixSizeOfScan = 0;
procpar.CSIGridShift        = 0;
procpar.HammingFilter       = {};
procpar.FrequencyCorrection = {};
procpar.TransmitCoil        = {};
procpar.TransmitRefAmplitude = {};
procpar.SliceThickness      = {};
procpar.PositionVector      = 0;
procpar.RowVector           = 0;
procpar.ColumnVector        = 0;
procpar.VOIPositionSag      = {};
procpar.VOIPositionCor      = {};
procpar.VOIPositionTra      = {};
procpar.VOIThickness        = {};
procpar.VOIPhaseFOV         = {};
procpar.VOIReadoutFOV       = {};
procpar.VOINormalSag        = {};
procpar.VOINormalCor        = {};
procpar.VOINormalTra        = {};
procpar.VOIRotationInPlane  = {};
procpar.FoVHeight           = {};
procpar.FoVWidth            = {};
procpar.FoV3D               = {};
procpar.PercentOfRectFoV    = {};
procpar.NumberOfRows        = {};
procpar.NumberOfColumns     = {};
procpar.NumberOf3DParts     = {};
procpar.PixelSpacingRow     = {};
procpar.PixelSpacingCol     = {};
procpar.PixelSpacing3D      = {};


%--- generation of procpar struct field tags ---
procparNames = fieldnames(procpar);
procparNtags = length(procparNames);

%--- procpar file reading and extraction of the above parameter values ---
% note: both, the 1st and 2nd line per parameter are extracted here
[fid,msg] = fopen(file,'r');
if fid>0
    %--- consistency check ---
    tline = fgetl(fid);
    if isempty(strfind(tline,'Begin of header'))
        fprintf('%s ->\nThe assigned file <%s> seems not to have a header. Program aborted.\n\n',FCTNAME,file)
        return
    end
    
    %--- info printout ---
    fprintf('%s ->\nReading <%s>\n',FCTNAME,file);
    
    %--- parameter extraction ---
    while ~feof(fid) && isempty(strfind(tline,'End of header'))
        tline = fgetl(fid);
                
        %--- extraction of parameter name ---
        colonInd = find(tline==':');
        if ~isempty(colonInd)
            parName = tline(1:colonInd(1)-1);

            %--- square bracket handling ---
            if ~isempty(strfind(tline,'[')) && ~isempty(strfind(tline,']'))
                %--- vector index extraction ---
                braInd = find(parName=='[');
                ketInd = find(parName==']');
                parIndStr = tline(braInd(end)+1:ketInd(end)-1);
                parIndVal = str2double(parIndStr);                  % either value or NaN   
                
                %--- parameter value extraction ---
                parName = parName(1:braInd(end)-1);
                
                %--- if parameter is to be retrieved, read and extract value(s) ---
                if isfield(procpar,parName)
                    [parNameTmp,valueStr] = strtok(tline,': ');
                    if isnan(parIndVal)         % e.g. [1H]
                        if isnan(str2double(valueStr(3:end)))
                            eval(['procpar.' parName parIndStr ' = ''' valueStr(3:end) ''';'])
                        else
                            eval(['procpar.' parName parIndStr ' = ' valueStr(3:end) ';'])
                        end
                    else                        % pure index
                        % note indexing: 0,1,2,... to 1,2,3,... conversion
                        if isnan(str2double(valueStr(3:end)))
                            eval(['procpar.' parName '{' num2str(parIndVal+1) '} = ''' valueStr(3:end) ''';'])
                        else
                            eval(['procpar.' parName '(' num2str(parIndVal+1) ') = ' valueStr(3:end) ';'])
                        end
                    end
                end
            else   
                %--- if parameter is to be retrieved, read and extract value(s) ---
                if isfield(procpar,parName)
                    [parNameTmp,valueStr] = strtok(tline,': ');
                    if isnan(str2double(valueStr(3:end)))
                        eval(['procpar.' parName ' = ''' valueStr(3:end) ''';'])
                    else
                        eval(['procpar.' parName ' = ' valueStr(3:end) ';'])
                    end
                end
            end
        end
    end
    fclose(fid);
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,file,msg);
    return
end

%--- erase empty fields ---
procparNames = fieldnames(procpar);
procparNtags = length(procparNames);
for nCnt = 1:procparNtags
    if isempty(eval(['procpar.' procparNames{nCnt}]))
        eval(['procpar = rmfield(procpar,''' procparNames{nCnt} ''');'])
    end
end

%--- update success flag ---
f_succ = 1;



end
