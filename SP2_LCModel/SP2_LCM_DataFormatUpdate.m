%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_DataFormatUpdate
%% 
%%  Update function for data format.
%%  1: binary (.mat)
%%  2: text (.txt or no extension)
%%  3: all moeities (.par)
%%  4: Provencher LCModel (.lcm/.raw)
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

FCTNAME = 'SP2_Proc_DataFormatUpdate';


%--- retrieve parameter ---
flag.lcmDataFormat = get(fm.lcm.dataFormat,'Value');

%--- update window ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate






end
