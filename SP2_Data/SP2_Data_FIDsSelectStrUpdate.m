%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FIDsSelectStrUpdate
%% 
%%  Update function for FID (NR) selection vector and string
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_FIDsSelectStrUpdate';


%--- initial string assignment ---
dataSelectStr = get(fm.data.sumSelStr,'String');

%--- consistency check ---
if any(dataSelectStr==',') || any(dataSelectStr==';') || ...
   any(dataSelectStr=='[') || any(dataSelectStr==']') || ...
   any(dataSelectStr=='(') || any(dataSelectStr==')') || ...
   any(dataSelectStr=='''') || any(dataSelectStr=='.') || ...
   isempty(dataSelectStr)
    fprintf('\nExperiments have to be assigned as space\n');
    fprintf('separated list using the following format:\n');
    fprintf('min=1, max=NR, integer values & steps, no further formating\n');
    fprintf('example 1: 1:2:5\n');
    fprintf('example 2: 3:10 15:20 12\n\n');
    set(fm.data.sumSelStr,'String',data.selectStr)
    return
end

%--- calibration vector assignment ---
dataSelect  = eval(['[' dataSelectStr ']']);      % selection vector assignment
% dataSelectN = length(dataSelect);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(dataSelect)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME);
    set(fm.data.sumSelStr,'String',data.selectStr)
    return
end
if ~isnumeric(dataSelect)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    set(fm.data.sumSelStr,'String',data.selectStr)
    return
end
if any(dataSelect<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME);
    set(fm.data.sumSelStr,'String',data.selectStr)
    return
end
if isfield(data.spec1,'nr')
    if any(dataSelect>data.spec1.nr)
        fprintf('%s ->\nMaximum experiment exceeds number of available FIDs (NR=%.0f)!\n',FCTNAME,data.spec1.nr);
        set(fm.data.sumSelStr,'String',data.selectStr)
        return
    end
end
if isempty(dataSelect)
    fprintf('%s ->\nEmpty experiment (NR) vector detected.\nMinimum: 1 repetition!\n',FCTNAME);
    set(fm.data.sumSelStr,'String',data.selectStr)
    return
end

%--- data assignment ---
data.selectStr = dataSelectStr;
data.select    = eval(['[' data.selectStr ']']);      % selection vector assignment
data.selectN   = length(data.select);                 % number of selected FIDs (per receiver)

%--- figure update ---
SP2_Data_FigureUpdate;



