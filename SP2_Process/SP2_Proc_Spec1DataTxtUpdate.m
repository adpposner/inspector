%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1DataTxtUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


FCTNAME = 'SP2_Proc_Spec1DataTxtUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.proc.spec1DataPath,'String');
dat1FidFileTmp = dat1FidFileTmp;
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathTxt)
    return
end
if ~strcmp(dat1FidFileTmp(end-3:end),'.txt') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin1') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin2') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin3') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin4') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin5') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin6') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin7') && ...
   ~strcmp(dat1FidFileTmp(end-5:end),'.spin8') && ...
   isempty(dat1FidFileTmp=='.')
    fprintf('%s ->\nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathTxt)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathTxt)
    return
end
set(fm.proc.spec1DataPath,'String',dat1FidFileTmp)
proc.spec1.dataPathTxt = get(fm.proc.spec1DataPath,'String');
dotInd = find(proc.spec1.dataPathTxt=='.');
if isempty(dotInd)
    proc.spec1.dataPathMat   = [proc.spec1.dataPathTxt '.mat'];
    proc.spec1.dataPathPar   = [proc.spec1.dataPathTxt '.par'];
    proc.spec1.dataPathRaw   = [proc.spec1.dataPathTxt '.raw'];
    proc.spec1.dataPathCoord = [proc.spec1.dataPathTxt '.coord'];
else
    proc.spec1.dataPathMat   = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
    proc.spec1.dataPathPar   = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.par'];
    proc.spec1.dataPathRaw   = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.raw'];
    proc.spec1.dataPathCoord = [proc.spec1.dataPathTxt(1:(dotInd(end)-1)) '.coord'];
end

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(proc.spec1.dataPathTxt=='/');
else                        % 0: PC
    slInd = find(proc.spec1.dataPathTxt=='\');
end
proc.spec1.dataDir       = proc.spec1.dataPathTxt(1:slInd(end));
proc.spec1.dataFileTxt   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFileMat   = proc.spec1.dataPathMat(slInd(end)+1:end);
proc.spec1.dataFilePar   = proc.spec1.dataPathMat(slInd(end)+1:end);
proc.spec1.dataFileRaw   = proc.spec1.dataPathRaw(slInd(end)+1:end);
proc.spec1.dataFileCoord = proc.spec1.dataPathCoord(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate




