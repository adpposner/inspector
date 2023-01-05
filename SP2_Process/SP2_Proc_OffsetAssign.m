%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_OffsetAssign
%%
%%  Manual assignment of amplitude offset.
%% 
%%  02-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_OffsetAssign';


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
[x,proc.offsetVal] = ginput(1);

%--- info printout ---
fprintf('Amplitude offset: %.3f\n',proc.offsetVal);
% set(fm.proc.offsetVal,'String',num2str(proc.offsetVal))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate




