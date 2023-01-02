%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AmplShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignmen of amplitude limits
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


flag.t1t2AmplShow = ~get(fm.t1t2.amplShowDirect,'Value');

%--- switch radiobutton ---
set(fm.t1t2.amplShowAuto,'Value',flag.t1t2AmplShow)
set(fm.t1t2.amplShowDirect,'Value',~flag.t1t2AmplShow)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


