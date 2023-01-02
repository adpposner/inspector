%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ShowSelStrUpdate
%% 
%%  Update function for metabolites selection for superposition / summation.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss flag

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_MARSS_ShowSelStrUpdate';


%--- initial string assignment ---
marss.showSelStr = get(fm.marss.showSelStr,'String');

%--- consistency check ---
if any(marss.showSelStr==',') || any(marss.showSelStr==';') || ...
   any(marss.showSelStr=='[') || any(marss.showSelStr==']') || ...
   any(marss.showSelStr=='(') || any(marss.showSelStr==')') || ...
   any(marss.showSelStr=='''') || any(marss.showSelStr=='.')
    fprintf('\nMetabolite index selection has to be assigned as\n');
    fprintf('space separated list of integers without further formating\n');
    fprintf('Note that the colon operator is supported.\n');
    return
end

%--- calibration vector assignment ---
marss.showSel  = eval(['[' marss.showSelStr ']']);      % selection vector assignment
marss.showSelN = length(marss.showSel);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(marss.showSel)==0)
    fprintf('%s ->\nMultiple assignments of the same metabolite detected...\n',FCTNAME);
    return
end
if ~isnumeric(marss.showSel)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(marss.showSel<1)
    fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME);
    return
end
if isempty(marss.showSel)
    fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME);
    return
end

%--- figure update ---
SP2_MARSS_ProcAndPlotUpdate





