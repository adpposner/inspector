%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_PpmShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignment of (zoomed) ppm range
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2PpmShow = ~get(fm.t1t2.ppmShowDirect,'Value');

%--- switch radiobutton ---
set(fm.t1t2.ppmShowFull,'Value',flag.t1t2PpmShow)
set(fm.t1t2.ppmShowDirect,'Value',~flag.t1t2PpmShow)

%--- update window ---
SP2_T1T2_T1T2WinUpdate

