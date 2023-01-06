%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SpinSysLibSelect
%% 
%%  Selection of spin system library file.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_SpinSysLibSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(marss.spinSys.libDir)
    if ispc
        marss.spinSys.libDir = 'C:\';
    elseif ismac
        marss.spinSys.libDir = '/Users/';
    else
        marss.spinSys.libDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(marss.spinSys.libDir);
    if ~f_succ
        marss.spinSys.libDir = maxPath;
    end
end

%--- browse the fid file ---
[marssSpinSysLibName, marssSpinSysLibDir] = uigetfile('*.mat','Select simulation basis file',marss.spinSys.libDir);       % select data file
if ~ischar(marssSpinSysLibName)             % buffer select cancelation
    if ~marssSpinSysLibName      
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end
marss.spinSys.libName = marssSpinSysLibName;
marss.spinSys.libDir  = marssSpinSysLibDir;
marss.spinSys.libPath = [marss.spinSys.libDir marss.spinSys.libName];          % update .mat path

%--- window update ---
set(fm.marss.spinSysLibPath,'String',marss.spinSys.libPath)
marss.spinSys.libPath = get(fm.marss.spinSysLibPath,'String');

%--- update display ---
SP2_MARSS_MARSSWinUpdate

end
