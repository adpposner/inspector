%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaAmplitudeStrUpdate
%% 
%%  Update function for amplitude selection vector and string
%%
%%  04-2015, Christoph Juchem
%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm t1t2

FCTNAME = 'SP2_MM_AnaAmplitudeStrUpdate';


%--- initial string assignment ---
t1t2.anaAmpStr = get(fm.t1t2.anaAmpStr,'String');

%--- consistency check ---
if isempty(t1t2.anaAmpStr)
    fprintf('%s ->\nEmpty string detected.\nAt least one amplitude value is expected!\n',FCTNAME);
    return
end

%--- consistency check ---
if any(t1t2.anaAmpStr==',') || any(t1t2.anaAmpStr==';') || ...
   any(t1t2.anaAmpStr=='[') || any(t1t2.anaAmpStr==']') || ...
   any(t1t2.anaAmpStr=='(') || any(t1t2.anaAmpStr==')') || ...
   any(t1t2.anaAmpStr=='''')
    fprintf('\nThe amplitude vector has to be assigned as space-\n');
    fprintf('separated list (colon operator is supported)\n');
    fprintf('example 1: 0.1 1 3\n');
    fprintf('example 2: 0.1:0.1:1 2 3\n\n');
    return
end

%--- calibration vector assignment ---
t1t2.anaAmp  = eval(['[' t1t2.anaAmpStr ']']);      % vector assignment
t1t2.anaAmpN = length(t1t2.anaAmp);                 % number of T1 components
if t1t2.anaAmpN<16
    t1t2.anaAmpStr = SP2_Vec2PrintStr(t1t2.anaAmp,0,0);
else
    fprintf('Time selection:\n%s\n',SP2_Vec2PrintStr(t1t2.anaAmp,0,0));
end

%--- check for vector consistency ---
if ~isnumeric(t1t2.anaAmp)
    fprintf('%s ->\nVector formation failed\n',FCTNAME);
    return
end
if isempty(t1t2.anaAmp)
    fprintf('%s ->\nEmpty time vector detected.\n',FCTNAME);
    return
end

%--- window update ---
SP2_T1T2_T1T2WinUpdate


