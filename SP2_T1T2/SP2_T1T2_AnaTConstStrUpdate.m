%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaTConstStrUpdate
%% 
%%  Update function for T1 selection vector and string
%%
%%  10-2014, Christoph Juchem
%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm t1t2

FCTNAME = 'SP2_MM_AnaTConstStrUpdate';


%--- initial string assignment ---
t1t2.anaTConstStr = get(fm.t1t2.anaTConstStr,'String');

%--- consistency check ---
if isempty(t1t2.anaTConstStr)
    fprintf('%s ->\nEmpty string detected.\nAt least one T1 value is expected!\n',FCTNAME);
    return
end

%--- consistency check ---
if any(t1t2.anaTConstStr==',') || any(t1t2.anaTConstStr==';') || ...
   any(t1t2.anaTConstStr=='[') || any(t1t2.anaTConstStr==']') || ...
   any(t1t2.anaTConstStr=='(') || any(t1t2.anaTConstStr==')') || ...
   any(t1t2.anaTConstStr=='''')
    fprintf('\nSpectra have to be assigned as space-\n');
    fprintf('separated list (colon operator is supported)\n');
    fprintf('example 1: 0.1 1 3\n');
    fprintf('example 2: 0.1:0.1:1 2 3\n\n');
    return
end

%--- calibration vector assignment ---
t1t2.anaTConst  = eval(['[' t1t2.anaTConstStr ']']);      % vector assignment
t1t2.anaTConstN = length(t1t2.anaTConst);                 % number of T1 components
if t1t2.anaTConstN<16
    t1t2.anaTConstStr = SP2_Vec2PrintStr(t1t2.anaTConst,2,0);
else
    fprintf('T1 selection (%.0f values):\n%s\n',t1t2.anaTConstN,SP2_Vec2PrintStr(t1t2.anaTConst,2,0));
end

%--- check for vector consistency ---
if any(diff(t1t2.anaTConst)==0)
    fprintf('%s ->\nMultiple assignments of the same T1 detected...\n',FCTNAME);
    return
end
if ~isnumeric(t1t2.anaTConst)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if any(t1t2.anaTConst<0)
    fprintf('%s ->\nAt least one T1 is negative!\n',FCTNAME);
    return
end
if isempty(t1t2.anaTConst)
    fprintf('%s ->\nEmpty T1 vector detected.\nAt least one T1 value is expected!\n',FCTNAME);
    return
end

%--- window update ---
SP2_T1T2_T1T2WinUpdate


