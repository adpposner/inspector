%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1DataMatUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


FCTNAME = 'SP2_Proc_Spec1DataMatUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.proc.spec1DataPath,'String');
dat1FidFileTmp = SP2_SlashWinLin(dat1FidFileTmp);
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
    return
end
if ~strcmp(dat1FidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
    return
end
set(fm.proc.spec1DataPath,'String',dat1FidFileTmp)
proc.spec1.dataPathMat   = get(fm.proc.spec1DataPath,'String');
proc.spec1.dataPathTxt   = [proc.spec1.dataPathMat(1:end-4) '.txt'];
proc.spec1.dataPathPar   = [proc.spec1.dataPathMat(1:end-4) '.par'];
proc.spec1.dataPathRaw   = [proc.spec1.dataPathMat(1:end-4) '.raw'];
proc.spec1.dataPathCoord = [proc.spec1.dataPathMat(1:end-4) '.coord'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(proc.spec1.dataPathMat=='/');
else                            % 0: PC
    slInd = find(proc.spec1.dataPathMat=='\');
end
proc.spec1.dataDir       = proc.spec1.dataPathMat(1:slInd(end));
proc.spec1.dataFileMat   = proc.spec1.dataPathMat(slInd(end)+1:end);
proc.spec1.dataFileTxt   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFilePar   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFileRaw   = proc.spec1.dataPathRaw(slInd(end)+1:end);
proc.spec1.dataFileCoord = proc.spec1.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate




