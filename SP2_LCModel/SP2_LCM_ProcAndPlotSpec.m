%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ProcAndPlotSpec( varargin )
%%
%%  Process and plot manipulated spectrum.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag lcm

FCTNAME = 'SP2_LCM_ProcAndPlotSpec';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
if narg==0
    f_new = 1;          % default
elseif narg==1
    f_new = SP2_Check4FlagR( varargin{1} );
else
    fprintf('%s: Supported number of function arguments: 0 & 1\n',FCTNAME);
    fprintf('but %.0f arguments have been assigned. Program aborted.\n',narg);
    return
end

%--- data processing ---
if flag.lcmUpdateCalc
    if ~SP2_LCM_ProcLcmData
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(lcm,'spec')
    fprintf('%s ->\nNo spectral data found. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- figure creation ---
if ~SP2_LCM_PlotLcmSpec(f_new)        % forced new figure
    return
end

%--- update success flag ---
f_succ = 1;





end
