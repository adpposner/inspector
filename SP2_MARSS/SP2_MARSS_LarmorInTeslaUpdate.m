%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_LarmorInTeslaUpdate
%% 
%%  Update function for Larmor frequency in [Tesla].
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss pars


%--- Larmor frequency in [Tesla] ---
marss.b0 = max(str2num(get(fm.marss.b0,'String')),0.1);
set(fm.marss.b0,'String',sprintf('%.3f',marss.b0))

%--- Larmor frequency in [Hertz] ---
marss.sf = marss.b0 * pars.gyroRatio;
set(fm.marss.sf,'String',sprintf('%.2f',marss.sf))

%--- bandwidth in [Hertz] ---
marss.sw_h  = marss.sw * marss.sf;                              % sweep width in [Hz]
marss.dwell = 1/marss.sw_h;                                     % dwell time
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))

%--- window update ---
SP2_MARSS_MARSSWinUpdate
