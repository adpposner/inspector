%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaTOneStrUpdate
%% 
%%  Update function for T1 selection vector and string
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm

FCTNAME = 'SP2_MM_AnaTOneStrUpdate';


%--- initial string assignment ---
mm.anaTOneStr = get(fm.mm.anaTOneStr,'String');

%--- consistency check ---
if isempty(mm.anaTOneStr)
    fprintf('%s ->\nEmpty string detected.\nAt least one T1 value is expected!\n',FCTNAME);
    return
end

%--- consistency check ---
if any(mm.anaTOneStr==',') || any(mm.anaTOneStr==';') || ...
   any(mm.anaTOneStr=='[') || any(mm.anaTOneStr==']') || ...
   any(mm.anaTOneStr=='(') || any(mm.anaTOneStr==')') || ...
   any(mm.anaTOneStr=='''')
    fprintf('\nSpectra have to be assigned as space-\n');
    fprintf('separated list (colon operator is supported)\n');
    fprintf('example 1: 0.1 1 3\n');
    fprintf('example 2: 0.1:0.1:1 2 3\n\n');
    return
end

%--- calibration vector assignment ---
mm.anaTOne  = eval(['[' mm.anaTOneStr ']']);      % vector assignment
mm.anaTOneN = length(mm.anaTOne);                 % number of T1 components
if mm.anaTOneN<16
    mm.anaTOneStr = SP2_Vec2PrintStr(mm.anaTOne,2,0);
else
    fprintf('T1 selection (%.0f values):\n%s\n',mm.anaTOneN,SP2_Vec2PrintStr(mm.anaTOne,2,0));
end

%--- check for vector consistency ---
if any(diff(mm.anaTOne)==0)
    fprintf('%s ->\nMultiple assignments of the same T1 detected...\n',FCTNAME);
    return
end
if ~isnumeric(mm.anaTOne)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(mm.anaTOne<0)
    fprintf('%s ->\nAt least one T1 is negative!\n',FCTNAME);
    return
end
if isempty(mm.anaTOne)
    fprintf('%s ->\nEmpty T1 vector detected.\nAt least one T1 value is expected!\n',FCTNAME);
    return
end

%--- window update ---
SP2_MM_MacroWinUpdate


