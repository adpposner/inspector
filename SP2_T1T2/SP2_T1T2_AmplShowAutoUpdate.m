%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AmplShowAutoUpdate
%% 
%%  Updates radiobutton setting: automatic assignmen of amplitude limits
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.t1t2AmplShow = get(fm.t1t2.amplShowAuto,'Value');

%--- switch radiobutton ---
set(fm.t1t2.amplShowAuto,'Value',flag.t1t2AmplShow)
set(fm.t1t2.amplShowDirect,'Value',~flag.t1t2AmplShow)

%--- update window ---
SP2_T1T2_T1T2WinUpdate



end
