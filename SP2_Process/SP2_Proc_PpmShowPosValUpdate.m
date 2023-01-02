%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowPosValUpdate
%% 
%%  Update value for frequency visualization.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update percentage value ---
proc.ppmShowPos = str2num(get(fm.proc.ppmShowPosVal,'String'));         % frequency update
proc.ppmShowPosMirr = proc.ppmCalib+(proc.ppmCalib-proc.ppmShowPos);    % mirrored frequency position

%--- display update ---
set(fm.proc.ppmShowPosVal,'String',num2str(proc.ppmShowPos))

%--- info printout ---
if isfield(proc.spec1,'sf')
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
