%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_T1ConsStrUpdate
%% 
%%  Update function for selection of T1 components to be considered for
%%  display/summation.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

FCTNAME = 'SP2_MM_T1ConsStrUpdate';


%--- initial string assignment ---
mm.tOneConsStr = get(fm.mm.tOneConsStr,'String');

%--- consistency check ---
if any(mm.tOneConsStr==',') || any(mm.tOneConsStr==';') || ...
   any(mm.tOneConsStr=='[') || any(mm.tOneConsStr==']') || ...
   any(mm.tOneConsStr=='(') || any(mm.tOneConsStr==')') || ...
   any(mm.tOneConsStr=='''') || any(mm.tOneConsStr=='.')
    fprintf('\nT1 components have to be assigned as space-\n')
    fprintf('separated list using the following format:\n')
    fprintf('min=1, max=# of T1 compenents, no further formating\n')
    fprintf('example 1: 1:2:5\n')
    fprintf('example 2: 3:10 15:20 12\n\n')
    return
end

%--- calibration vector assignment ---
mm.tOneCons  = eval(['[' mm.tOneConsStr ']']);          % vector assignment
mm.tOneConsStr = SP2_Vec2PrintStr(mm.tOneCons,0,0);     % string update
mm.tOneConsN = length(mm.tOneCons);                     % total number

%--- check for vector consistency ---
if any(diff(mm.tOneCons)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME)
    return
end
if ~isnumeric(mm.tOneCons)
    fprintf('%s ->\nVector formation failed\n',FCTNAME)
    return
end
if any(mm.tOneCons<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME)
    return
end
if any(mm.tOneCons>mm.anaTOneN)
    fprintf('%s ->\nAt least T1 component exceeds total number of T1 components\n',FCTNAME)    
    fprintf('Total number of T1 components: %.0f\n',mm.anaTOneN)
    return
end
if isempty(mm.tOneCons)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME)
    return
end

%--- figure update ---
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate



