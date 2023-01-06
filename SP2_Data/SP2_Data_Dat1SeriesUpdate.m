%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesUpdate
%% 
%%  Update function for experiment selection vector and string.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- init success flag ---
f_succ = 0;

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_Dat1SeriesUpdate';
SP2_Logger.log( "%s call\n",FCTNAME);

%--- initial string assignment ---
dataSpec1SeriesStr = get(fm.data.spec1SeriesStr,'String');
fprintf("SERIES STRING: %s\n",dataSpec1SeriesStr);
%--- consistency check ---
if any(dataSpec1SeriesStr==',') || any(dataSpec1SeriesStr==';') || ...
   any(dataSpec1SeriesStr=='[') || any(dataSpec1SeriesStr==']') || ...
   any(dataSpec1SeriesStr=='(') || any(dataSpec1SeriesStr==')') || ...
   any(dataSpec1SeriesStr=='''') || any(dataSpec1SeriesStr=='.') || ...
   isempty(dataSpec1SeriesStr)
    fprintf('\nExperiments have to be assigned as space\n');
    fprintf('separated list using the following format:\n');
    fprintf('min=1, integer values & steps, no further formating\n');
    fprintf('example 1: 1:2:5\n');
    fprintf('example 2: 3:10 15:20 12\n\n');
    set(fm.data.spec1SeriesStr,'String',data.spec1.seriesStr)
    return
end

%--- experiment vector assignment ---
dataSpec1SeriesVec = round(eval(['[' dataSpec1SeriesStr ']']));     % selection vector assignment
dataSpec1SeriesN   = length(dataSpec1SeriesVec);                    % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(dataSpec1SeriesVec)==0)
    fprintf('WARNING:\nMultiple assignments of the same experiment detected.\n');
end
if ~isnumeric(dataSpec1SeriesVec)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    set(fm.data.spec1SeriesStr,'String',data.spec1.seriesStr)
    return
end
if any(dataSpec1SeriesVec<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME);
    set(fm.data.spec1SeriesStr,'String',data.spec1.seriesStr)
    return
end
if isempty(dataSpec1SeriesVec)
    fprintf('%s ->\nEmpty experiment vector detected.\nMinimum: 2 scans!\n',FCTNAME);
    set(fm.data.spec1SeriesStr,'String',data.spec1.seriesStr)
    return
end
if  dataSpec1SeriesN<2
    fprintf('%s ->\nThe experiment vector has only 1 entry.\nMinimum: 1 scans!\n',FCTNAME);
    set(fm.data.spec1SeriesStr,'String',data.spec1.seriesStr)
    return
end
% note that the data existence is not checked here. This will be done when
% the data are to be loaded.

%--- data assignment ---
data.spec1.seriesStr = dataSpec1SeriesStr;
data.spec1.seriesVec = round(eval(['[' data.spec1.seriesStr ']']));     % selection vector assignment
data.spec1.seriesN   = length(data.spec1.seriesVec);                    % number of selected FIDs (per receiver)

%--- update success flag ---
f_succ = 1;



end
