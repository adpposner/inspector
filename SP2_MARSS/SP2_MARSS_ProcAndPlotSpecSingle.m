%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_ProcAndPlotSpecSingle( f_new )
%%
%%  Process basis spectra and plot selected metabolite simulation result.
%% 
%%  11-2020, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile marss flag

FCTNAME = 'SP2_MARSS_ProcAndPlotSpecSingle';


%--- init success flag ---
f_succ = 0;

%--- check data existence and parameter consistency ---
if ~isfield(marss.basis,'fidOrig')
    fprintf('%s ->\nNo basis spectrum found (fid). Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sf')
    fprintf('%s ->\nNo basis spectrum found (sf). Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sw')
    fprintf('%s ->\nNo basis spectrum found (sw). Program aborted.\n',FCTNAME);
    return
end

%--- spectral processing ---
if ~SP2_MARSS_ProcComplete
    fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
if ~SP2_MARSS_PlotSpecSingle(f_new)             % forced new figure
    return
end

%--- update success flag ---
f_succ = 1;
