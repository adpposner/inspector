%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2DataMatUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


FCTNAME = 'SP2_Proc_Spec2DataMatUpdate';

%--- fid file assignment ---
dat2FidFileTmp = get(fm.proc.spec2DataPath,'String');
dat2FidFileTmp = SP2_SlashWinLin(dat2FidFileTmp);
if isempty(dat2FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
    return
end
if ~strcmp(dat2FidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
    return
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
    return
end
set(fm.proc.spec2DataPath,'String',dat2FidFileTmp)
proc.spec2.dataPathMat   = get(fm.proc.spec2DataPath,'String');
proc.spec2.dataPathTxt   = [proc.spec2.dataPathMat(1:end-4) '.txt'];
proc.spec2.dataPathRaw   = [proc.spec2.dataPathMat(1:end-4) '.raw'];
proc.spec2.dataPathCoord = [proc.spec2.dataPathMat(1:end-4) '.coord'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(proc.spec2.dataPathMat=='/');
else                            % 0: PC
    slInd = find(proc.spec2.dataPathMat=='\');
end
proc.spec2.dataDir     = proc.spec2.dataPathMat(1:slInd(end));
proc.spec2.dataFileMat = proc.spec2.dataPathMat(slInd(end)+1:end);
proc.spec2.dataFileTxt = proc.spec2.dataPathTxt(slInd(end)+1:end);
proc.spec2.dataFileRaw = proc.spec2.dataPathRaw(slInd(end)+1:end);
proc.spec2.dataFileCoord = proc.spec2.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate



