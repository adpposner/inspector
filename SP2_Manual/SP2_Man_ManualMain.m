%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Man_ManualMain
%% 
%%  Function to open INSPECTOR manual PDF.
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global man

FCTNAME = 'SP2_Man_ManualMain';


%--- check file existence ---
if SP2_CheckFileExistenceR(man.filePath)
    open(man.filePath)
else                            
    %--- select manual file ---
    if ~SP2_CheckDirAccessR(man.fileDir)
        if ispc
            man.fileDir = 'C:\';
        elseif ismac
            man.fileDir = '/Users/';
        else
            man.fileDir = '/home/';
        end
    else
        [f_succ,maxPath] = SP2_CheckDirAccessR(man.fileDir);
        if ~f_succ
            man.fileDir = maxPath;
        end
    end

    %--- browse PDF files ---
    [filename, pathname] = uigetfile('*.pdf','Select manual file',man.fileDir);
    if ~ischar(filename)             % buffer select cancelation
        if ~filename            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    while ~strcmp('.pdf',filename(end-3:end))
      fprintf('%s ->\nAssigned file is not a PDF file, try again...\n',FCTNAME);
        [filename, pathname] = uigetfile('*.pdf','Select manual file',man.fileDir);   % select data file
        if ~ischar(filename)             % buffer select cancelation
            if ~filename            
                fprintf('%s aborted.\n',FCTNAME);
                return
            end
        end
    end

    %--- update paths ---
    man.fileDir  = pathname;            
    man.fileName = filename;
    man.filePath = [man.fileDir man.fileName];
    
    if SP2_CheckFileExistenceR(man.filePath)
        open(man.filePath)
    else   
        fprintf('%s ->\nManual file could not be found:\n%s',FCTNAME,man.filePath);
        return
    end
end

