%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SimParsUpdate
%% 
%%  General parameter update for MARSS page.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- Larmor frequency ---
%--- frequency calibration ---
marss.ppmCalib = str2num(get(fm.marss.ppmCalib,'String'));
set(fm.marss.ppmCalib,'String',num2str(marss.ppmCalib))

%--- basic number of points ---
marss.nspecCBasic = max(round(str2num(get(fm.marss.nspecCBasic,'String'))),16);
set(fm.marss.nspecCBasic,'String',num2str(marss.nspecCBasic))

%--- Voxel dimension per spatial dimension ---
marss.voxDim = max(round(str2num(get(fm.marss.voxDim,'String'))),5);
set(fm.marss.voxDim,'String',num2str(marss.voxDim))

%--- Simulatiton dimension per spatial dimension ---
marss.simDim = max(round(str2num(get(fm.marss.simDim,'String'))),1);
set(fm.marss.simDim,'String',num2str(marss.simDim))

%--- Lorentzian line broadening ---
marss.lb = max(str2num(get(fm.marss.lb,'String')),0);
set(fm.marss.lb,'String',num2str(marss.lb))

%--- Echo time ---
marss.te = max(str2num(get(fm.marss.te,'String')),0);
set(fm.marss.te,'String',num2str(marss.te))

%--- Mixing time ---
if isfield(fm.marss,'tm')
    marss.tm = max(str2num(get(fm.marss.tm,'String')),0);
    set(fm.marss.tm,'String',num2str(marss.tm))
end

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
% SP2_MARSS_ProcAndPlotUpdate

end
