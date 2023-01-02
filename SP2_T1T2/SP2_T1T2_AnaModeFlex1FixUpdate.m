%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaModeFlex1FixUpdate
%% 
%%  Flexible fit with 1st time constant set.
%%
%%  08-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.t1t2AnaFlex1Fix = get(fm.t1t2.anaModeFlex1Fix,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaModeFlex1Fix,'Value',flag.t1t2AnaFlex1Fix)

%--- update window ---
SP2_T1T2_T1T2WinUpdate

