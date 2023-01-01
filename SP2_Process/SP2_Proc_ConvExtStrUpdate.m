%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ConvExtStrUpdate
%% 
%%  Potential file extension for above .par-to-.mat data conversion.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


FCTNAME = 'SP2_Proc_ConvExtStrUpdate';


%--- get extension string ---
proc.convExtStr = get(fm.proc.convExtStr,'String');

%--- reassign for consistency ---
set(fm.proc.convExtStr,'String',proc.convExtStr)

%--- update flag display ---
SP2_Proc_ProcessWinUpdate




