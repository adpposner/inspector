%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Tools_AnonDirPathUpdate
%% 
%%  Direct update of data directory to be anonymized
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag exm roi

FCTNAME = 'SP2_Tools_AnonDirPathUpdate';



fprintf('\nNOT IMPLEMENTED YET...\n\n');
return


% %--- check for existence of the assigned user name and adopt path name ---
% pathStudyTmp = get(fm.data.pathStudy,'String');
% if isempty(pathStudyTmp)
%     fprintf('%s -> An empty entry is useless.\n',FCTNAME);
%     set(fm.data.pathStudy,'String',exm.pathStudy)
%     return
% end
% pathStudyTmp = pathStudyTmp;
% pathStudyTmp = SP2_GuaranteeFinalSlash(pathStudyTmp);
% 
% %--- check directory accessibility ---
% if ~SP2_CheckDirAccessR(pathStudyTmp)
%     set(fm.data.pathStudy,'String',exm.pathStudy)
%     return
% end    
% set(fm.data.pathStudy,'String',pathStudyTmp);
% exm.pathStudy = get(fm.data.pathStudy,'String');
% 
% %--- study extraction ---
% if flag.OS>0
%     slashInd  = find(exm.pathStudy=='/');
% else
%     slashInd  = find(exm.pathStudy=='\');
% end
% exm.study = exm.pathStudy(slashInd(end-1)+1:end-1);
% 
% %--- retrieve data format: Varian ---
% if ~isempty(findstr(exm.study,'.fid'))
%     flag.exmDataFormat = 1;     % Varian
%     SP2_Data_NumOfExp1Update
% end
% 
% %--- deduce paths ---
% if flag.exmDataFormat           % Varian
%     %--- data directories ---
%     exm.dirFid1     = exm.pathStudy;
%     %--- data file path ---
%     exm.fid1        = [exm.dirFid1 'fid'];
%     %--- procpar(method) file path ---
%     exm.meth1       = [exm.dirFid1 'procpar'];
%     %--- text(acqp) file path ---
%     exm.acqp1       = [exm.dirFid1 'text'];
% 
%     %--- reference experiment path handling ---
%     roi.dirRefExp      = [exm.pathStudy num2str(roi.refScanNo) '\'];             % init reference experiment path
%     roi.methRefExp     = [roi.dirRefExp 'procpar'];
% else                        % Bruker
%     %--- data directories ---
%     exm.dirFid1     = SP2_GuaranteeFinalSlash([exm.pathStudy num2str(exm.fidScanNo1)]);
%     exm.dirFid2     = SP2_GuaranteeFinalSlash([exm.pathStudy num2str(exm.fidScanNo2)]);
%     exm.dirFid3     = SP2_GuaranteeFinalSlash([exm.pathStudy num2str(exm.fidScanNo3)]);
%     exm.dirFid4     = SP2_GuaranteeFinalSlash([exm.pathStudy num2str(exm.fidScanNo4)]);
%     %--- data file paths ---
%     exm.fid1        = [exm.dirFid1 'fid'];
%     %--- method file paths ---
%     exm.meth1       = [exm.dirFid1 'method'];
%     %--- acqp file paths ---
%     exm.acqp1       = [exm.dirFid1 'acqp'];
%     
%     %--- reference experiment path handling ---
%     roi.dirRefExp      = [exm.pathStudy num2str(roi.refScanNo) '\'];             % init reference experiment path
%     roi.methRefExp     = [roi.dirRefExp 'method'];
% end    
% 
% %--- path update for Bruker case ---
% %--- data file paths ---
% exm.fid2        = [exm.dirFid2 'fid'];
% exm.fid3        = [exm.dirFid3 'fid'];
% exm.fid4        = [exm.dirFid4 'fid'];
% %--- method file paths ---
% exm.meth2       = [exm.dirFid2 'method'];
% exm.meth3       = [exm.dirFid3 'method'];
% exm.meth4       = [exm.dirFid4 'method'];
% %--- acqp file paths ---
% exm.acqp2       = [exm.dirFid2 'acqp'];
% exm.acqp3       = [exm.dirFid3 'acqp'];
% exm.acqp4       = [exm.dirFid4 'acqp'];
% 
% %--- update all path visualization windows ---
% %--- data file paths ---
% set(fm.data.fidImg1,'String',exm.fid1)             % adopt image path
% set(fm.data.fidImg2,'String',exm.fid2)             % adopt image path
% set(fm.data.fidImg3,'String',exm.fid3)             % adopt image path
% set(fm.data.fidImg4,'String',exm.fid4)             % adopt image path
% 
