%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SatRecConsStrUpdate
%% 
%%  Update function for selection of saturation-recovery spectra to be
%   considered for display/summation.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm

FCTNAME = 'SP2_MM_SatRecConsStrUpdate';


%--- initial string assignment ---
mm.satRecConsStr = get(fm.mm.satRecConsStr,'String');

%--- consistency check ---
if any(mm.satRecConsStr==',') || any(mm.satRecConsStr==';') || ...
   any(mm.satRecConsStr=='[') || any(mm.satRecConsStr==']') || ...
   any(mm.satRecConsStr=='(') || any(mm.satRecConsStr==')') || ...
   any(mm.satRecConsStr=='''') || any(mm.satRecConsStr=='.')
    fprintf('\nSaturation-recovery components have to be assigned as\n');
    fprintf('space-separated list using the following format:\n');
    fprintf('min=1, max=# of saturation delays, no further formating\n');
    fprintf('example 1: 1:2:5\n');
    fprintf('example 2: 3:10 15:20 12\n\n');
    return
end

%--- calibration vector assignment ---
mm.satRecCons  = eval(['[' mm.satRecConsStr ']']);          % vector assignment
mm.satRecConsStr = SP2_Vec2PrintStr(mm.satRecCons,0,0);     % string update
mm.satRecConsN = length(mm.satRecCons);                     % total number

%--- check for vector consistency ---
if any(diff(mm.satRecCons)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME);
    return
end
if ~isnumeric(mm.satRecCons)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(mm.satRecCons<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME);
    return
end
if any(mm.satRecCons>mm.satRecN)
    fprintf('%s ->\nAt least on saturation-recovery spectrum exceeds total number of experiments\n',FCTNAME);
    return
end
if isempty(mm.satRecCons)
    fprintf('%s ->\nEmpty calibration vector detected.\nMinimum: 1 calibration experiment!\n',FCTNAME);
    return
end

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate



