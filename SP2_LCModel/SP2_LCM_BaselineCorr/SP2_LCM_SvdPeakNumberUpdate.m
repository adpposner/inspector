%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SvdPeakNumberUpdate
%% 
%%  Update number of peaks (main components) to be considered with the SVD-
%%  based removal algorithm.
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update amplitude window ---
lcm.baseSvdPeakN = str2double(get(fm.lcm.base.svdPeakN,'String'));
set(fm.lcm.base.svdPeakN,'String',num2str(lcm.baseSvdPeakN))

%--- window update ---
SP2_LCM_ProcessWinUpdate

end
