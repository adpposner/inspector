%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_BandwidthInHertzUpdate
%% 
%%  Update function of simulation bandwidth in [Hertz].
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- bandwidth in [Hertz] ---
marss.sw_h  = max(str2num(get(fm.marss.sw_h,'String')),100);
marss.dwell = 1/marss.sw_h;                % dwell time
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))

%--- bandwidth in [ppm] ---
marss.sw    = marss.sw_h/marss.sf;         % sweep width in [ppm]
set(fm.marss.sw,'String',sprintf('%.3f',marss.sw))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

