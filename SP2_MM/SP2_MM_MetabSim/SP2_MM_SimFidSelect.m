%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SimFidSelect
%% 
%%  FID file selection for simulation of sat-rec. data array.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm

FCTNAME = 'SP2_MM_SimFidSelect';


%--- check directory access ---
if isempty(mm.sim.fidDir)
    if ispc
        mm.sim.fidDir = 'C:\';
    elseif ismac
        mm.sim.fidDir = '/Users/';
    else
        mm.sim.fidDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(mm.sim.fidDir);
    if ~f_succ
        mm.sim.fidDir = maxPath;
    end
end

%--- browse the fid file ---
[filename, pathname] = uigetfile('*','Select FID file for simulation of sat-rec. data',mm.sim.fidDir);       % select data file
if ~ischar(filename)             % buffer select cancelation
    if ~filename            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end

%--- update paths ---
mm.sim.fidDir  = pathname;
mm.sim.fidName = filename;
mm.sim.fidPath = [mm.sim.fidDir mm.sim.fidName];
set(fm.mm.simFidPath,'String',mm.sim.fidPath)

%--- update display ---
SP2_MM_MacroWinUpdate

