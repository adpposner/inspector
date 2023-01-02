%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2DataTxtUpdate
%% 
%%  Update function for data path of FID data set 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


FCTNAME = 'SP2_MRSI_Spec2DataTxtUpdate';

%--- fid file assignment ---
dat2FidFileTmp = get(fm.mrsi.spec2DataPath,'String');
dat2FidFileTmp = SP2_SlashWinLin(dat2FidFileTmp);
if isempty(dat2FidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathTxt)
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
    fprintf('%s -> \nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME);
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathTxt)
    return
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s -> \nAssigned file can''t be found.\n',FCTNAME);
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathTxt)
    return
end
set(fm.mrsi.spec2DataPath,'String',dat2FidFileTmp)
mrsi.spec2.dataPathTxt = get(fm.mrsi.spec2DataPath,'String');
dotInd = find(mrsi.spec2.dataPathTxt=='.');
if isempty(dotInd)
    mrsi.spec2.dataPathMat = [mrsi.spec2.dataPathTxt '.mat'];
else
    mrsi.spec2.dataPathMat = [mrsi.spec2.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
end

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(mrsi.spec2.dataPathTxt=='/');
else                            % 0: PC
    slInd = find(mrsi.spec2.dataPathTxt=='\');
end
mrsi.spec2.dataDir     = mrsi.spec2.dataPathTxt(1:slInd(end));
mrsi.spec2.dataFileTxt = mrsi.spec2.dataPathTxt(slInd(end)+1:end);
mrsi.spec2.dataFileMat = mrsi.spec2.dataPathMat(slInd(end)+1:end);

%--- update flag display ---
SP2_MRSI_MrsiWinUpdate



