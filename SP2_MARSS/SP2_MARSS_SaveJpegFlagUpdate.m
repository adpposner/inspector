%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SaveJpegFlagUpdate
%% 
%%  Saves figures not only as Matlab figures (.fig), but also as jpeg for
%%  direct visual inspection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag handling ---
flag.marssSaveJpeg = get(fm.marss.saveJpeg,'Value');

%--- update flag displays ---
set(fm.marss.saveJpeg,'Value',flag.marssSaveJpeg)

%--- window update ---
SP2_MARSS_MARSSWinUpdate


end
