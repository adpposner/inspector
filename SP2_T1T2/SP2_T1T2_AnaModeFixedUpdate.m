%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaModeFixedUpdate
%% 
%%  Leave T1 components flexible in multi-exponential fit.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2AnaMode = get(fm.t1t2.anaModeFix,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaModeFix,'Value',flag.t1t2AnaMode)
set(fm.t1t2.anaModeFlex,'Value',~flag.t1t2AnaMode)

%--- update window ---
SP2_T1T2_T1T2WinUpdate



end
