%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaFrequDifference
%%
%%  Measure frequency separation of two spectral positions.
%% 
%%  09-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaFrequDifference';


%--- data selection ---
% switch flag.lcmFigSelect
%     case 1          % original FID
%         SP2_LCM_PlotFid(0)
%     case 2          % processed FID
%         SP2_LCM_PlotFidOrig(0)
%     case 3          % spectrum
        if ~SP2_LCM_PlotLcmSpec(0)
            return
        end
%     case 4          % analysis: superposition
%         SP2_LCM_PlotSpecLcmSuperpos(0)
%     case 5          % analysis: individual metabolite
%         SP2_LCM_PlotSpecLcmSingle(0)
%     case 6          % analysis: residual
%         SP2_LCM_PlotSpecLcmResid(0)
%     case 7          % basis: selected basis set
%         SP2_LCM_PlotSpecBasisSingle(0)
% end

%--- peak retrieval ---
lcm.anaPpmPos = zeros(1,2);

%--- position 1 ---
[lcm.anaPpmPos(1),yFake] = ginput(1);          % frequency position
fprintf('\nFrequency position 1: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',lcm.anaPpmPos(1),...
        lcm.ppmCalib,lcm.anaPpmPos(1)-lcm.ppmCalib,lcm.sf*(lcm.anaPpmPos(1)-lcm.ppmCalib))
yLim = get(gca,'YLim');
hold on
plot([lcm.anaPpmPos(1) lcm.anaPpmPos(1)],[yLim(1) yLim(2)],'Color',[0 0 0])

%--- position 2 ---
[lcm.anaPpmPos(2),yFake] = ginput(1);          % frequency position
fprintf('Frequency position 2: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',lcm.anaPpmPos(2),...
        lcm.ppmCalib,lcm.anaPpmPos(2)-lcm.ppmCalib,lcm.sf*(lcm.anaPpmPos(2)-lcm.ppmCalib))
plot([lcm.anaPpmPos(2) lcm.anaPpmPos(2)],[yLim(1) yLim(2)],'Color',[0 0 0])
hold off    
    
%--- info printout ---
fprintf('Frequency difference: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',lcm.anaPpmPos(1),...
        lcm.anaPpmPos(2),lcm.anaPpmPos(2)-lcm.anaPpmPos(1),lcm.sf*(lcm.anaPpmPos(2)-lcm.anaPpmPos(1)))

%--- window update ---
SP2_LCM_LCModelWinUpdate

% %--- analysis update ---
% SP2_LCM_ProcAndPlotUpdate





end
