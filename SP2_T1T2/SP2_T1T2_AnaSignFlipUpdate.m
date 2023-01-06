%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaSignFlipUpdate
%% 
%%  Amplitude sign flip of first N time points (of magnitude data).
%%
%%  08-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2AnaSignFlip = get(fm.t1t2.anaSignFlip,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaSignFlip,'Value',flag.t1t2AnaSignFlip)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


end
