%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_DataMetabUpdate
%% 
%%  Data type:
%%  1: metabolite spectra
%%  0: reference (water) spectra
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.mmMetabRef = get(fm.mm.dataMetab,'Value');

%--- switch radiobutton ---
set(fm.mm.dataMetab,'Value',flag.mmMetabRef)
set(fm.mm.dataRef,'Value',~flag.mmMetabRef)

%--- update window ---
SP2_MM_MacroWinUpdate
