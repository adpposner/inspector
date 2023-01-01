%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AnaFrequDifference
%%
%%  Measure frequency separation of two spectral positions.
%% 
%%  09-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_AnaFrequDifference';


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
proc.anaPpmPos = zeros(1,2);

%--- position 1 ---
[proc.anaPpmPos(1),yFake] = ginput(1);          % frequency position
fprintf('\nFrequency position 1: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.anaPpmPos(1),...
        proc.ppmCalib,proc.anaPpmPos(1)-proc.ppmCalib,proc.spec1.sf*(proc.anaPpmPos(1)-proc.ppmCalib))
yLim = get(gca,'YLim');
hold on
plot([proc.anaPpmPos(1) proc.anaPpmPos(1)],[yLim(1) yLim(2)],'Color',[0 0 0])

%--- position 2 ---
[proc.anaPpmPos(2),yFake] = ginput(1);          % frequency position
fprintf('Frequency position 2: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.anaPpmPos(2),...
        proc.ppmCalib,proc.anaPpmPos(2)-proc.ppmCalib,proc.spec1.sf*(proc.anaPpmPos(2)-proc.ppmCalib))
plot([proc.anaPpmPos(2) proc.anaPpmPos(2)],[yLim(1) yLim(2)],'Color',[0 0 0])
hold off    
    
%--- info printout ---
fprintf('Frequency difference: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',proc.anaPpmPos(1),...
        proc.anaPpmPos(2),proc.anaPpmPos(2)-proc.anaPpmPos(1),proc.spec1.sf*(proc.anaPpmPos(2)-proc.anaPpmPos(1)))

%--- window update ---
SP2_Proc_ProcessWinUpdate

% %--- analysis update ---
% SP2_Proc_ProcAndPlotUpdate




