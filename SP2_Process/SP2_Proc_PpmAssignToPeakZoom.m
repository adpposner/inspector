%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmAssignToPeakZoom
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PpmAssignToPeakZoom';



%--- keep current ppm settings ---
procPpmShowMin = proc.ppmShowMin;
procPpmShowMax = proc.ppmShowMax;

%--- zoomed window ---
proc.ppmShowMin = proc.ppmAssign - 0.3;
proc.ppmShowMax = proc.ppmAssign + 0.3;

%--- make sure the direct ppm mode is selected ---
flagProcPpmShow  = flag.procPpmShow;
flag.procPpmShow = 1;       % direct    
    
%--- data selection ---
switch flag.procFigSelect
    case 1          % spectrum 1
        if ~SP2_Proc_PlotSpec1(0)
            proc.ppmShowMin = procPpmShowMin;
            proc.ppmShowMax = procPpmShowMax;
            SP2_Proc_ProcessWinUpdate
            return
        end
    case 2          % spectrum 2
        if ~SP2_Proc_PlotSpec2(0)
            proc.ppmShowMin = procPpmShowMin;
            proc.ppmShowMax = procPpmShowMax;
            SP2_Proc_ProcessWinUpdate
            return
        end
    case 3          % superposition
        if ~SP2_Proc_PlotSpecSuperpos(0)
            proc.ppmShowMin = procPpmShowMin;
            proc.ppmShowMax = procPpmShowMax;
            SP2_Proc_ProcessWinUpdate
            return
        end
    case 4          % sum
        if ~SP2_Proc_PlotSpecSum(0)
            proc.ppmShowMin = procPpmShowMin;
            proc.ppmShowMax = procPpmShowMax;
            SP2_Proc_ProcessWinUpdate
            return
        end
    case 5          % difference
        if ~SP2_Proc_PlotSpecDiff(0)
            proc.ppmShowMin = procPpmShowMin;
            proc.ppmShowMax = procPpmShowMax;
            SP2_Proc_ProcessWinUpdate
            return
        end
end

%--- peak retrieval ---
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
proc.ppmCalib = proc.ppmCalib + proc.ppmAssign - ppmPos;

%--- restore ppm window ---
proc.ppmShowMin = procPpmShowMin;
proc.ppmShowMax = procPpmShowMax;

%--- restore ppm window mode ---
flag.procPpmShow = flagProcPpmShow;

%--- ppm position update ---
if flag.procPpmShowPos
    SP2_Proc_PpmShowPosValUpdate
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate





end
