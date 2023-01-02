%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SpatZeroFillUpdate
%% 
%%  Update function for spatial zero-filling size.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi


%--- update value spec 1 ---
mrsi.spatZF = max(str2num(get(fm.mrsi.spatZfVal,'String')),5);
set(fm.mrsi.spatZfVal,'String',num2str(mrsi.spatZF))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

