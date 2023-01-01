%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_LcmBasisSelect
%% 
%%  Basis selection.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm

FCTNAME = 'SP2_LCM_LcmBasisSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.basisDir)
    if ispc
        lcm.basisDir = 'C:\';
    elseif ismac
        lcm.basisDir = '/Users/';
    else
        lcm.basisDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(lcm.basisDir);
    if ~f_succ
        lcm.basisDir = maxPath;
    end
end

%--- browse the fid file ---
[lcmBasisFile, lcmBasisDir] = uigetfile('*.mat','Select LCM basis file',lcm.basisDir);       % select data file
if ~ischar(lcmBasisFile)             % buffer select cancelation
    if ~lcmBasisFile            
        fprintf('%s aborted.\n',FCTNAME)
        return
    end
end
lcm.basisFile = lcmBasisFile;
lcm.basisDir  = lcmBasisDir;
lcm.basisPath = [lcm.basisDir lcm.basisFile];          % update .mat path

%--- window update ---
set(fm.lcm.basisPath,'String',lcm.basisPath)
lcm.basisPath = get(fm.lcm.basisPath,'String');

%--- update display ---
SP2_LCM_LCModelWinUpdate
