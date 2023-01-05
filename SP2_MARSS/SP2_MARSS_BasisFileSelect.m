%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_BasisFileSelect
%% 
%%  Basis file selection.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss fm

FCTNAME = 'SP2_MARSS_BasisFileSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(marss.basis.fileDir)
    if ispc
        marss.basis.fileDir = 'C:\';
    elseif ismac
        marss.basis.fileDir = '/Users/';
    else
        marss.basis.fileDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(marss.basis.fileDir);
    if ~f_succ
        marss.basis.fileDir = maxPath;
    end
end

%--- browse the fid file ---
[basisFileName, basisFileDir] = uigetfile('*.mat','Select simulation basis file',marss.basis.fileDir);       % select data file
if ~ischar(basisFileName)             % buffer select cancelation
    if ~basisFileName      
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end
marss.basis.fileName = basisFileName;
marss.basis.fileDir  = basisFileDir;
marss.basis.filePath = [marss.basis.fileDir marss.basis.fileName];          % update .mat path

%--- window update ---
set(fm.marss.basisFileName,'String',marss.basis.fileName)
marss.basis.fileName = get(fm.marss.basisFileName,'String');

%--- update display ---
SP2_MARSS_MARSSWinUpdate
