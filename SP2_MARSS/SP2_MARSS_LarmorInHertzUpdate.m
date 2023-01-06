%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_LarmorInHertzUpdate
%% 
%%  Update function for Larmor frequency in [Hertz].
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss pars


%--- Larmor frequency in [Hertz] ---
marss.sf = max(str2num(get(fm.marss.sf,'String')),1);
set(fm.marss.sf,'String',sprintf('%.2f',marss.sf))

%--- Larmor frequency in [Tesla] ---
marss.b0 = marss.sf / pars.gyroRatio;
set(fm.marss.b0,'String',sprintf('%.3f',marss.b0))

%--- bandwidth in [Hertz] ---
marss.sw_h  = marss.sw * marss.sf;                              % sweep width in [Hz]
marss.dwell = 1/marss.sw_h;                                     % dwell time
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

end
