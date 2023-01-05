%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowPosAssign
%%
%%  Assign ppm value as display frequency (for vertical line).
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PpmShowPosAssign';


%--- data selection ---
switch flag.procFigSelect
    case 1          % spectrum 1
        if ~SP2_Proc_PlotSpec1(0)
            return
        end
    case 2          % spectrum 2
        if ~SP2_Proc_PlotSpec2(0)
            return
        end
    case 3          % superposition
        if ~SP2_Proc_PlotSpecSuperpos(0)
            return
        end
    case 4          % sum
        if ~SP2_Proc_PlotSpecSum(0)
            return
        end
    case 5          % difference
        if ~SP2_Proc_PlotSpecDiff(0)
            return
        end
end

%--- peak retrieval ---
[proc.ppmShowPos,y] = ginput(1);                                        % frequency position
proc.ppmShowPosMirr = proc.ppmCalib+(proc.ppmCalib-proc.ppmShowPos);    % mirrored frequency position

%--- info printout ---
fprintf('Frequency position: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.ppmShowPos,...
        proc.ppmCalib,proc.ppmShowPos-proc.ppmCalib,proc.spec1.sf*(proc.ppmShowPos-proc.ppmCalib))
if flag.procPpmShowPosMirr
    fprintf('Mirrored position:  %.3fppm/%.2fHz\n',proc.ppmShowPosMirr,...
            proc.spec1.sf*(proc.ppmShowPosMirr-proc.ppmCalib))
end    

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate




