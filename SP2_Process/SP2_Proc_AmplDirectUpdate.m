%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AmplDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignmen of amplitude limits
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.procAmpl = get(fm.proc.amplDirect,'Value');

%--- switch radiobutton ---
set(fm.proc.amplAuto,'Value',~flag.procAmpl)
set(fm.proc.amplDirect,'Value',flag.procAmpl)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
