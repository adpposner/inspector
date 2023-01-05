%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowPosFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag proc


%--- parameter update ---
flag.procPpmShowPos = get(fm.proc.ppmShowPos,'Value');

%--- window update ---
set(fm.proc.ppmShowPos,'Value',flag.procPpmShowPos)

%--- info printout ---
if flag.procPpmShowPos && isfield(proc.spec1,'sf')
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.ppmShowPos,...
            proc.ppmCalib,proc.ppmShowPos-proc.ppmCalib,proc.spec1.sf*(proc.ppmShowPos-proc.ppmCalib))
    if flag.procPpmShowPosMirr
        fprintf('Mirrored position:  %.3fppm/%.2fHz\n',proc.ppmShowPosMirr,...
                proc.spec1.sf*(proc.ppmShowPosMirr-proc.ppmCalib))
    end
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

