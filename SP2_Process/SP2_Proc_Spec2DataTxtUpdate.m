%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2DataTxtUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


FCTNAME = 'SP2_Proc_Spec2DataTxtUpdate';

%--- fid file assignment ---
dat2FidFileTmp = get(fm.proc.spec2DataPath,'String');
dat2FidFileTmp = SP2_SlashWinLin(dat2FidFileTmp);
if isempty(dat2FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathTxt)
    return
end
if ~strcmp(dat2FidFileTmp(end-3:end),'.txt') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin1') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin2') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin3') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin4') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin5') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin6') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin7') && ...
   ~strcmp(dat2FidFileTmp(end-5:end),'.spin8') && ...
   isempty(dat2FidFileTmp=='.')
    fprintf('%s -> \nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathTxt)
    return
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s -> \nAssigned file can''t be found.\n',FCTNAME)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathTxt)
    return
end
set(fm.proc.spec2DataPath,'String',dat2FidFileTmp)
proc.spec2.dataPathTxt = get(fm.proc.spec2DataPath,'String');
dotInd = find(proc.spec2.dataPathTxt=='.');
if isempty(dotInd)
    proc.spec2.dataPathMat   = [proc.spec2.dataPathTxt '.mat'];
    proc.spec2.dataPathPar   = [proc.spec2.dataPathTxt '.par'];
    proc.spec2.dataPathRaw   = [proc.spec2.dataPathTxt '.raw'];
    proc.spec2.dataPathCoord = [proc.spec2.dataPathTxt '.coord'];
else
    proc.spec2.dataPathMat   = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
    proc.spec2.dataPathPar   = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.par'];
    proc.spec2.dataPathRaw   = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.raw'];
    proc.spec2.dataPathCoord = [proc.spec2.dataPathTxt(1:(dotInd(end)-1)) '.coord'];
end

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(proc.spec2.dataPathTxt=='/');
else                            % 0: PC
    slInd = find(proc.spec2.dataPathTxt=='\');
end
proc.spec2.dataDir       = proc.spec2.dataPathTxt(1:slInd(end));
proc.spec2.dataFileTxt   = proc.spec2.dataPathTxt(slInd(end)+1:end);
proc.spec2.dataFileMat   = proc.spec2.dataPathMat(slInd(end)+1:end);
proc.spec2.dataFilePar   = proc.spec2.dataPathPar(slInd(end)+1:end);
proc.spec2.dataFileRaw   = proc.spec2.dataPathRaw(slInd(end)+1:end);
proc.spec2.dataFileCoord = proc.spec2.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate



