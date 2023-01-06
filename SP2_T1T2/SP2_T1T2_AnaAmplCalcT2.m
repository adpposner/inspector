%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaAmplCalcT2
%%
%%	Calcuate T2 amplitude vector for given time delay vector.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm t1t2


%--- find relative amplitude ---
t1t2.anaAmp = 1e4*exp(-t1t2.anaTime/t1t2.t2decT2);

%--- calibration vector assignment ---
t1t2.anaAmpStr = num2str(t1t2.anaAmp);              % string generation
t1t2.anaAmpN   = length(t1t2.anaAmp);               % number of T1 components
if t1t2.anaAmpN<16
    t1t2.anaAmpStr = SP2_Vec2PrintStr(t1t2.anaAmp,0,0);
else
    fprintf('Time selection:\n%s\n',SP2_Vec2PrintStr(t1t2.anaAmp,0,0));
end

%--- display update ---
set(fm.t1t2.anaAmpStr,'String',t1t2.anaAmpStr)

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


end
