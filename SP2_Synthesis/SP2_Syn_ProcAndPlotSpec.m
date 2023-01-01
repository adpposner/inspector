%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcAndPlotSpec
%%
%%  Process and plot manipulated spectrum.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag syn

FCTNAME = 'SP2_Syn_ProcAndPlotSpec';


%--- data processing ---
if flag.synUpdateCalc
    if ~SP2_Syn_ProcData
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME)
        return
    end
elseif ~isfield(syn,'spec')
    fprintf('%s ->\nNo spectral data found. Load/reconstruct first.\n',FCTNAME)
    return
end

%--- figure creation ---
SP2_Syn_PlotSpec(1);        % forced new figure

%--- figure selection ---
flag.synFigSelect = 3;

