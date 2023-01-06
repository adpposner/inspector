%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_PpmShowFullUpdate
%% 
%%  Updates radiobutton setting: full sweep width visualization
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2PpmShow = get(fm.t1t2.ppmShowFull,'Value');

%--- switch radiobutton ---
set(fm.t1t2.ppmShowFull,'Value',flag.t1t2PpmShow)
set(fm.t1t2.ppmShowDirect,'Value',~flag.t1t2PpmShow)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


end
