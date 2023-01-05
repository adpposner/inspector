%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2DataParUpdate
%% 
%%  Update function for data path update of metabolite (.par) file.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


FCTNAME = 'SP2_Proc_Spec2DataParUpdate';

%--- fid file assignment ---
dat2FidFileTmp = get(fm.proc.spec2DataPath,'String');
dat2FidFileTmp = dat2FidFileTmp;
if isempty(dat2FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathPar)
    return
end
if ~strcmp(dat2FidFileTmp(end-3:end),'.par')
    fprintf('%s ->\nAssigned file is not a <.par> file. Please try again...\n',FCTNAME);
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathPar)
    return
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathPar)
    return
end
set(fm.proc.spec2DataPath,'String',dat2FidFileTmp)
proc.spec2.dataPathPar   = get(fm.proc.spec2DataPath,'String');
proc.spec2.dataPathTxt   = [proc.spec2.dataPathPar(1:end-4) '.txt'];
proc.spec2.dataPathMat   = [proc.spec2.dataPathPar(1:end-4) '.mat'];
proc.spec2.dataPathCoord = [proc.spec2.dataPathPar(1:end-4) '.raw'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: PC
    slInd = find(proc.spec2.dataPathPar=='/');
else                            % 0: PC
    slInd = find(proc.spec2.dataPathPar=='\');
end
proc.spec2.dataDir       = proc.spec2.dataPathPar(1:slInd(end));
proc.spec2.dataFileMat   = proc.spec2.dataPathMat(slInd(end)+1:end);
proc.spec2.dataFileTxt   = proc.spec2.dataPathTxt(slInd(end)+1:end);
proc.spec2.dataFilePar   = proc.spec2.dataPathPar(slInd(end)+1:end);
proc.spec2.dataFileCoord = proc.spec2.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate




