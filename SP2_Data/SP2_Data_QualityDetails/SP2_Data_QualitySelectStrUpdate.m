%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualitySelectStrUpdate
%% 
%%  Update function for FID (NR) selection vector and string
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_QualitySelectStrUpdate';


%--- initial string assignment ---
data.quality.selectStr = get(fm.data.qualityDet.selectStr,'String');

%--- consistency check ---
if any(data.quality.selectStr==',') || any(data.quality.selectStr==';') || ...
   any(data.quality.selectStr=='[') || any(data.quality.selectStr==']') || ...
   any(data.quality.selectStr=='(') || any(data.quality.selectStr==')') || ...
   any(data.quality.selectStr=='''') || any(data.quality.selectStr=='.')
    fprintf('\nSpectra have to be assigned as space-\n');
    fprintf('separated list using the following format:\n');
    fprintf('min=1, max=NR, integer values & steps, no further formating\n');
    fprintf('example 1: 1:2:5\n');
    fprintf('example 2: 3:10 15:20 12\n\n');
    return
end

%--- calibration vector assignment ---
data.quality.select  = eval(['[' data.quality.selectStr ']']);      % selection vector assignment
data.quality.selectN = length(data.quality.select);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(data.quality.select)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME);
    return
end
if ~isnumeric(data.quality.select)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(data.quality.select<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr') && isfield(data.spec1,'seriesN')
    if any(data.quality.select>data.spec1.nr*data.spec1.seriesN)
        fprintf('%s ->\nMaximum experiment exceeds number of available spectra:\n',FCTNAME);
        fprintf('NR (%.0f) x scans (%.0f) = %.0f\n',data.spec1.nr,data.spec1.seriesN,...
                data.spec1.nr*data.spec1.seriesN)
        return
    end
end
if isempty(data.quality.select)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME);
    return
end

%--- info printout ---
fprintf('\nQ&A data selection: %.0f traces\n',data.quality.selectN);
fprintf('Current display limit %.0f rows * %.0f columns = %.0f traces\n',...
        data.quality.rows,data.quality.cols,data.quality.rows*data.quality.cols)

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);


