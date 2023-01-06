%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_CheckScanIndexFormat(dataSpec)
%% 
%%  Function to check the existence of a preceeding number plus underscore
%%  in the scan name definition
%%
%%  Note that this function only leads to a warning, but does not abort the
%%  program execution.
%%
%%  07-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_Data_Dat1FidFileLoad';


%--- retrieve/update data format ---
switch flag.dataManu
    case 1                  % Varian
        underInd = findstr(dataSpec.fidDir,'_');
    case 2                  % Bruker
        
    case 3                  % GE (works)
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)                
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end
    case 4                  % Siemens rda
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end
    case 5                  % DICOM
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end
    case 6                  % Siemens dat
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end
    case 7                  % Philips raw
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end
    case 8                  % Philips SDAT
        underInd = findstr(dataSpec.fidName,'_');
        if isempty(underInd)
            % no underscore
            DisplayWarning()
        elseif ~any(str2double(dataSpec.fidName(1:underInd(1)-1)))
            % no sole number before underscore
            DisplayWarning()
        end    
    end
end


function DisplayWarning()

fprintf('\n---   WARNING   ---\nPlease number individual MRS scans (e.g. 001_etc)\n');
fprintf('to allow the serial and sorting tools provided.\n');
fprintf('Compare the INSPECTOR manual for details.\n\n');
end


% 
% if strcmp(dataSpec.fidDir(end-4:end-1),'.fid')                % Varian
% elseif strcmp(dataSpec.fidName,'fid') || strcmp(dataSpec.fidName,'rawdata.job0')             % Bruker
% elseif strcmp(dataSpec.fidFile(end-1:end),'.7')               % GE
% elseif strcmp(dataSpec.fidFile(end-3:end),'.rda')             % Siemens
% elseif strcmp(dataSpec.fidFile(end-3:end),'.dcm')             % DICOM
% elseif strcmp(dataSpec.fidFile(end-3:end),'.dat')             % Siemens
% elseif strcmp(dataSpec.fidFile(end-3:end),'.raw')             % Philips raw
% elseif strcmp(dataSpec.fidFile(end-4:end),'.SDAT')            % Philips collapsed


