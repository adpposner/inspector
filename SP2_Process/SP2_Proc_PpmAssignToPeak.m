%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PpmAssignToPeak';


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
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
proc.ppmCalib = proc.ppmCalib + proc.ppmAssign - ppmPos;

%--- ppm position update ---
if flag.procPpmShowPos
    SP2_Proc_PpmShowPosValUpdate
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate




