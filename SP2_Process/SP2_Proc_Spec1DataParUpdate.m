%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1DataParUpdate
%% 
%%  Update function for data path update of metabolite (.par) file.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


FCTNAME = 'SP2_Proc_Spec1DataParUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.proc.spec1DataPath,'String');
dat1FidFileTmp = dat1FidFileTmp;
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathPar)
    return
end
if ~strcmp(dat1FidFileTmp(end-3:end),'.par')
    fprintf('%s ->\nAssigned file is not a <.par> file. Please try again...\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathPar)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathPar)
    return
end
set(fm.proc.spec1DataPath,'String',dat1FidFileTmp)
proc.spec1.dataPathPar   = get(fm.proc.spec1DataPath,'String');
proc.spec1.dataPathTxt   = [proc.spec1.dataPathPar(1:end-4) '.txt'];
proc.spec1.dataPathMat   = [proc.spec1.dataPathPar(1:end-4) '.mat'];
proc.spec1.dataPathRaw   = [proc.spec1.dataPathPar(1:end-4) '.raw'];
proc.spec1.dataPathCoord = [proc.spec1.dataPathPar(1:end-4) '.coord'];

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(proc.spec1.dataPathPar=='/');
else                        % 0: PC
    slInd = find(proc.spec1.dataPathPar=='\');
end
proc.spec1.dataDir       = proc.spec1.dataPathPar(1:slInd(end));
proc.spec1.dataFileMat   = proc.spec1.dataPathMat(slInd(end)+1:end);
proc.spec1.dataFileTxt   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFilePar   = proc.spec1.dataPathPar(slInd(end)+1:end);
proc.spec1.dataFileRaw   = proc.spec1.dataPathRaw(slInd(end)+1:end);
proc.spec1.dataFileCoord = proc.spec1.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate




