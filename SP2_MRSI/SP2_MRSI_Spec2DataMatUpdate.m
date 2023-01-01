%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2DataMatUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


FCTNAME = 'SP2_MRSI_Spec2DataMatUpdate';

%--- fid file assignment ---
dat2FidFileTmp = get(fm.mrsi.spec2DataPath,'String');
dat2FidFileTmp = SP2_SlashWinLin(dat2FidFileTmp);
if isempty(dat2FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathMat)
    return
end
if ~strcmp(dat2FidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME)
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathMat)
    return
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME)
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathMat)
    return
end
set(fm.mrsi.spec2DataPath,'String',dat2FidFileTmp)
mrsi.spec2.dataPathMat = get(fm.mrsi.spec2DataPath,'String');
mrsi.spec2.dataPathTxt = [mrsi.spec2.dataPathMat(1:end-4) '.txt'];

%--- update paths ---
if flag.OS>0                        % 1: linux, 2: mac
    slInd = find(mrsi.spec2.dataPathMat=='/');
else                                % 0: PC
    slInd = find(mrsi.spec2.dataPathMat=='\');
end
mrsi.spec2.dataDir     = mrsi.spec2.dataPathMat(1:slInd(end));
mrsi.spec2.dataFileMat = mrsi.spec2.dataPathMat(slInd(end)+1:end);
mrsi.spec2.dataFileTxt = mrsi.spec2.dataPathTxt(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate



