%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1DataTxtUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


FCTNAME = 'SP2_MRSI_Spec1DataTxtUpdate';

%--- fid file assignment ---
dat1FidFileTmp = get(fm.mrsi.spec1DataPath,'String');
dat1FidFileTmp = dat1FidFileTmp;
if isempty(dat1FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathTxt)
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
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathTxt)
    return
end
if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathTxt)
    return
end
set(fm.mrsi.spec1DataPath,'String',dat1FidFileTmp)
mrsi.spec1.dataPathTxt = get(fm.mrsi.spec1DataPath,'String');
dotInd = find(mrsi.spec1.dataPathTxt=='.');
if isempty(dotInd)
    mrsi.spec1.dataPathMat = [mrsi.spec1.dataPathTxt '.mat'];
else
    mrsi.spec1.dataPathMat = [mrsi.spec1.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
end

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(mrsi.spec1.dataPathTxt=='/');
else                            % 0: PC
    slInd = find(mrsi.spec1.dataPathTxt=='\');
end
mrsi.spec1.dataDir     = mrsi.spec1.dataPathTxt(1:slInd(end));
mrsi.spec1.dataFileTxt = mrsi.spec1.dataPathTxt(slInd(end)+1:end);
mrsi.spec1.dataFileMat = mrsi.spec1.dataPathMat(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate





end
