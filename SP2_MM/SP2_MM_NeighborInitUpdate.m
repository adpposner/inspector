%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_NeighborInitUpdate
%% 
%%  Init multi-exponential fit result from neighboring frequency.
%%
%%  02-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.mmNeighInit = get(fm.mm.neighInit,'Value');

%--- window update ---
set(fm.mm.neighInit,'Value',flag.mmNeighInit)

%--- window update (not strictly necessary) ---
SP2_MM_MacroWinUpdate

