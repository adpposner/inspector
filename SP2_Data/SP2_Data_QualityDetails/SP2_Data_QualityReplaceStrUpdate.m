%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityReplaceStrUpdate
%% 
%%  Update function for FID (NR) selection vector and string
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_QualityReplaceStrUpdate';


%--- initial string assignment ---
data.quality.replaceStr = get(fm.data.qualityDet.replaceStr,'String');

%--- consistency check ---
if any(data.quality.replaceStr==',') || any(data.quality.replaceStr==';') || ...
   any(data.quality.replaceStr=='[') || any(data.quality.replaceStr==']') || ...
   any(data.quality.replaceStr=='(') || any(data.quality.replaceStr==')') || ...
   any(data.quality.replaceStr=='''') || any(data.quality.replaceStr=='.')
    fprintf('\nSpectra have to be assigned as space-\n')
    fprintf('separated list using the following format:\n')
    fprintf('min=1, max=NR, integer values & steps, no further formating\n')
    fprintf('example 1: 1:2:5\n')
    fprintf('example 2: 3:10 15:20 12\n\n')
    return
end

%--- calibration vector assignment ---
data.quality.replace  = eval(['[' data.quality.replaceStr ']']);      % selection vector assignment
data.quality.replaceN = length(data.quality.replace);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(data.quality.replace)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME)
    return
end
if ~isnumeric(data.quality.replace)
    fprintf('%s ->\nVector formation failed\n',FCTNAME)
    return
end
if any(data.quality.replace<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME)
    return
end
if isfield(data.spec1,'nr') && isfield(data.spec1,'seriesN')
    if any(data.quality.replace>data.spec1.nr*data.spec1.seriesN)
        fprintf('%s ->\nMaximum experiment exceeds number of available spectra:\n',FCTNAME)
        fprintf('NR (%.0f) x scans (%.0f) = %.0f\n',data.spec1.nr,data.spec1.seriesN,...
                data.spec1.nr*data.spec1.seriesN)
        return
    end
end
if isempty(data.quality.replace)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME)
    return
end

%--- info printout ---
if data.quality.excludeN~=data.quality.replaceN
    fprintf('\nWARNING:\nInconsistent number of exclusion/replacement FIDs detected (%.0f~=%.0f).\n\n',...
            FCTNAME,data.quality.excludeN,data.quality.replaceN)
end

%--- window update ---
SP2_Data_QualityDetailsWinUpdate


