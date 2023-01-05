%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ConvdtaFlagUpdate
%% 
%%  Switching on/off digital to analog conversion (convdta) of the
%%  metabolite data
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.dataConvdta = get(fm.data.convdta,'Value');
set(fm.data.convdta,'Value',flag.dataConvdta)
