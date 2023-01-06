%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_OffsetAssign
%%
%%  Manual assignment of amplitude offset.
%% 
%%  02-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_OffsetAssign';


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
[x,syn.offsetVal] = ginput(1);

%--- info printout ---
fprintf('Amplitude offset: %.1f\n',syn.offsetVal);

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate





end
