%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_BandwidthInPpmUpdate
%% 
%%  Update function of simulation bandwidth in [ppm].
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- bandwidth in [ppm] ---
marss.sw    = max(str2num(get(fm.marss.sw,'String')),1);        % sweep width in [ppm]
set(fm.marss.sw,'String',sprintf('%.3f',marss.sw))

%--- bandwidth in [Hertz] ---
marss.sw_h  = marss.sw * marss.sf;                              % sweep width in [Hz]
marss.dwell = 1/marss.sw_h;                                     % dwell time
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

