%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowPosMirrorUpdate
%% 
%%  Enable/disable additional visualization of mirrored frequency position.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag proc


%--- parameter update ---
flag.procPpmShowPosMirr = get(fm.proc.ppmShowPosMirr,'Value');

%--- window update ---
set(fm.proc.ppmShowPosMirr,'Value',flag.procPpmShowPosMirr)

%--- info printout ---
if flag.procPpmShowPosMirr
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.ppmShowPos,...
            proc.ppmCalib,proc.ppmShowPos-proc.ppmCalib,proc.spec1.sf*(proc.ppmShowPos-proc.ppmCalib))
    fprintf('Mirrored position:  %.3fppm/%.2fHz\n',proc.ppmShowPosMirr,...
            proc.spec1.sf*(proc.ppmShowPosMirr-proc.ppmCalib))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate


end
