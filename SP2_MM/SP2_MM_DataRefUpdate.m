%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_DataRefUpdate
%% 
%%  Data type:
%%  1: metabolite spectra
%%  0: reference (water) spectra
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mmMetabRef = ~get(fm.mm.dataRef,'Value');

%--- switch radiobutton ---
set(fm.mm.dataMetab,'Value',flag.mmMetabRef)
set(fm.mm.dataRef,'Value',~flag.mmMetabRef)

%--- update window ---
SP2_MM_MacroWinUpdate


end
