%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_DataProcUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  1: Import from Data page
%%  2: Load directly from Processing page
%%  3: Import from MRSI page
%%  4: Import from Synthesis page
%%  5: Import from MARSS page
%%  6: Import from LCM page
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.procData = 2;

%--- switch radiobutton ---
set(fm.proc.datData,'Value',flag.procData==1)
set(fm.proc.datProc,'Value',flag.procData==2)
set(fm.proc.datMrsi,'Value',flag.procData==3)
set(fm.proc.datSyn,'Value',flag.procData==4)
set(fm.proc.datMarss,'Value',flag.procData==5)
set(fm.proc.datLcm,'Value',flag.procData==6)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
