%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_PpmAssignToPeak';


%--- data selection ---
switch flag.lcmFigSelect
    case 1          % target spectrum
        if ~SP2_LCM_ProcAndPlotSpec(1)
            return
        end
    case 2          % LCModel fit summary
        if ~SP2_LCM_PlotResultSpecSummary(1)
            return
        end
    case 3          % LCModel metabolite superposition
        if ~SP2_LCM_PlotResultSpecSuperpos(1)
            return
        end
    case 4          % sum of LCModel metabolite fits
        if ~SP2_LCM_PlotResultSpecSum(1)
            return
        end
    case 5          % individual LCModel metabolite fits
        if ~SP2_LCM_PlotResultSpecSingle(1)
            return
        end
    case 6          % LCModel fit residual
        if ~SP2_LCM_PlotResultSpecResid(1)
            return
        end
    case 7          % individual LCModel basis spectra
        if ~SP2_LCM_BasisPlotSpecSingle(lcm.basis.currShow,0)
            return
        end
end

%--- peak retrieval ---
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
lcm.ppmCalib = lcm.ppmCalib + lcm.ppmAssign - ppmPos;

%--- ppm position update ---
if flag.lcmPpmShowPos
    SP2_LCM_PpmShowPosValUpdate
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate




