%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_MmStructSelect
%% 
%%  Data file selection of mm struct.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

FCTNAME = 'SP2_MM_MmStructSelect';


%--- check directory access ---
if isempty(mm.mmStructDir)
    if ispc
        mm.mmStructDir = 'C:\';
    elseif ismac
        mm.mmStructDir = '/Users/';
    else
        mm.mmStructDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(mm.mmStructDir);
    if ~f_succ
        mm.mmStructDir = maxPath;
    end
end

%--- browse the fid file ---
[filename, pathname] = uigetfile('*.mat','Select MM data structure',mm.mmStructDir);       % select data file
if ~ischar(filename)             % buffer select cancelation
    if ~filename            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end

%--- update paths ---
mm.mmStructDir  = pathname;
mm.mmStructFile = filename;
mm.mmStructPath = [mm.mmStructDir mm.mmStructFile];
set(fm.mm.mmStructPath,'String',mm.mmStructPath)

%--- update display ---
SP2_MM_MacroWinUpdate


end
