%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SvdPeakNumberUpdate
%% 
%%  Update number of peaks (main components) to be considered with the SVD-
%%  based removal algorithm.
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update amplitude window ---
mrsi.baseSvdPeakN = str2double(get(fm.mrsi.base.svdPeakN,'String'));
set(fm.mrsi.base.svdPeakN,'String',num2str(mrsi.baseSvdPeakN))

%--- window update ---
SP2_MRSI_MrsiWinUpdate
