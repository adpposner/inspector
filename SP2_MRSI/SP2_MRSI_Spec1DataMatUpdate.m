%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1DataMatUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


FCTNAME = 'SP2_MRSI_Spec1DataMatUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.mrsi.spec1DataPath,'String');
dat1FidFileTmp = SP2_SlashWinLin(dat1FidFileTmp);
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathMat)
    return
end
if ~strcmp(dat1FidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathMat)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathMat)
    return
end
set(fm.mrsi.spec1DataPath,'String',dat1FidFileTmp)
mrsi.spec1.dataPathMat = get(fm.mrsi.spec1DataPath,'String');
mrsi.spec1.dataPathTxt = [mrsi.spec1.dataPathMat(1:end-4) '.txt'];

%--- update paths ---
if flag.OS>0                        % 1: linux, 2: mac
    slInd = find(mrsi.spec1.dataPathMat=='/');
else                                % 0: PC
    slInd = find(mrsi.spec1.dataPathMat=='\');
end
mrsi.spec1.dataDir     = mrsi.spec1.dataPathMat(1:slInd(end));
mrsi.spec1.dataFileMat = mrsi.spec1.dataPathMat(slInd(end)+1:end);
mrsi.spec1.dataFileTxt = mrsi.spec1.dataPathTxt(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate




