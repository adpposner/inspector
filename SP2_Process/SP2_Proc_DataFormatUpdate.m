%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_DataFormatUpdate
%% 
%%  Update function for data format.
%%  1: binary (.mat)
%%  2: text (.txt or no extension)
%%  3: all moeities (.par)
%%  4: Provencher LCModel (.lcm/.raw)
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

FCTNAME = 'SP2_Proc_DataFormatUpdate';

%--- init success flag ---
f_succ = 0;

%--- retrieve parameter ---
flag.procDataFormat = get(fm.proc.dataFormat,'Value');

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

%--- update success flag ---
f_succ = 1;




