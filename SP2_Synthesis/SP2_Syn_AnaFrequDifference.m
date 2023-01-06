%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AnaFrequDifference
%%
%%  Measure frequency separation of two spectral positions.
%% 
%%  11-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_AnaFrequDifference';


%--- data selection ---
% switch flag.synFigSelect
%     case 1          % spectrum 1
if ~SP2_Syn_PlotSpec(0)
    return
end
%     case 2          % spectrum 2
%         SP2_Syn_PlotSpec2(0)
%     case 3          % superposition
%         SP2_Syn_PlotSpecSuperpos(0)
%     case 4          % sum
%         SP2_Syn_PlotSpecSum(0)
%     case 5          % difference
%         SP2_Syn_PlotSpecDiff(0)
% end

%--- peak retrieval ---
syn.anaPpmPos = zeros(1,2);

%--- position 1 ---
[syn.anaPpmPos(1),yFake] = ginput(1);          % frequency position
fprintf('\nFrequency position 1: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.anaPpmPos(1),...
        syn.ppmCalib,syn.anaPpmPos(1)-syn.ppmCalib,syn.sf*(syn.anaPpmPos(1)-syn.ppmCalib))
yLim = get(gca,'YLim');
hold on
plot([syn.anaPpmPos(1) syn.anaPpmPos(1)],[yLim(1) yLim(2)],'Color',[0 0 0])

%--- position 2 ---
[syn.anaPpmPos(2),yFake] = ginput(1);          % frequency position
fprintf('Frequency position 2: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.anaPpmPos(2),...
        syn.ppmCalib,syn.anaPpmPos(2)-syn.ppmCalib,syn.sf*(syn.anaPpmPos(2)-syn.ppmCalib))
plot([syn.anaPpmPos(2) syn.anaPpmPos(2)],[yLim(1) yLim(2)],'Color',[0 0 0])
hold off    
    
%--- info printout ---
fprintf('Frequency difference: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.anaPpmPos(1),...
        syn.anaPpmPos(2),syn.anaPpmPos(2)-syn.anaPpmPos(1),syn.sf*(syn.anaPpmPos(2)-syn.anaPpmPos(1)))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

% %--- analysis update ---
% SP2_Syn_ProcAndPlotUpdate





end
