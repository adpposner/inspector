%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaTimeStrUpdate
%% 
%%  Update function for time selection vector and string
%%
%%  04-2015, Christoph Juchem
%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm t1t2

FCTNAME = 'SP2_MM_AnaTimeStrUpdate';


%--- initial string assignment ---
t1t2.anaTimeStr = get(fm.t1t2.anaTimeStr,'String');

%--- consistency check ---
if isempty(t1t2.anaTimeStr)
    fprintf('%s ->\nEmpty string detected.\nAt least one time value is expected!\n',FCTNAME);
    return
end

%--- consistency check ---
if any(t1t2.anaTConstStr==',') || any(t1t2.anaTConstStr==';') || ...
   any(t1t2.anaTConstStr=='[') || any(t1t2.anaTConstStr==']') || ...
   any(t1t2.anaTConstStr=='(') || any(t1t2.anaTConstStr==')') || ...
   any(t1t2.anaTConstStr=='''')
    fprintf('\nThe time vector has to be assigned as space-\n');
    fprintf('separated list (colon operator is supported)\n');
    fprintf('example 1: 0.1 1 3\n');
    fprintf('example 2: 0.1:0.1:1 2 3\n\n');
    return
end

%--- calibration vector assignment ---
t1t2.anaTime  = eval(['[' t1t2.anaTimeStr ']']);      % vector assignment
t1t2.anaTimeN = length(t1t2.anaTime);                 % number of T1 components
if t1t2.anaTimeN<16
    t1t2.anaTimeStr = SP2_Vec2PrintStr(t1t2.anaTime,0,0);
else
    fprintf('Time selection:\n%s\n',SP2_Vec2PrintStr(t1t2.anaTime,0,0));
end

%--- check for vector consistency ---
if ~isnumeric(t1t2.anaTime)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if isempty(t1t2.anaTime)
    fprintf('%s ->\nEmpty time vector detected.\n',FCTNAME);
    return
end

%--- window update ---
SP2_T1T2_T1T2WinUpdate


