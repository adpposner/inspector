%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1DataCoordUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


FCTNAME = 'SP2_Proc_Spec1DataCoordUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.proc.spec1DataPath,'String');
dat1FidFileTmp = dat1FidFileTmp;
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathCoord)
    return
end
if ~strcmp(dat1FidFileTmp(end-5:end),'.coord') && ~strcmp(dat1FidFileTmp(end-5:end),'.COORD')
    fprintf('%s ->\nAssigned file is not a <.coord> file. Please try again...\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathCoord)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathCoord)
    return
end
set(fm.proc.spec1DataPath,'String',dat1FidFileTmp)
proc.spec1.dataPathCoord = get(fm.proc.spec1DataPath,'String');
proc.spec1.dataPathTxt   = [proc.spec1.dataPathCoord(1:end-6) '.txt'];
proc.spec1.dataPathPar   = [proc.spec1.dataPathCoord(1:end-6) '.par'];
proc.spec1.dataPathMat   = [proc.spec1.dataPathCoord(1:end-6) '.mat'];
proc.spec1.dataPathRaw   = [proc.spec1.dataPathCoord(1:end-6) '.raw'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(proc.spec1.dataPathCoord=='/');
else                            % 0: PC
    slInd = find(proc.spec1.dataPathCoord=='\');
end
proc.spec1.dataDir       = proc.spec1.dataPathCoord(1:slInd(end));
proc.spec1.dataFileCoord = proc.spec1.dataPathCoord(slInd(end)+1:end);
proc.spec1.dataFileTxt   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFilePar   = proc.spec1.dataPathTxt(slInd(end)+1:end);
proc.spec1.dataFileMat   = proc.spec1.dataPathMat(slInd(end)+1:end);
proc.spec1.dataFileRaw   = proc.spec1.dataPathRaw(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate





end
