%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcAndPlotUpdate
%% 
%%  Global processing update function.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss

FCTNAME = 'SP2_MARSS_ProcAndPlotUpdate';


%--- figure update ---
if isfield(marss,'fhMarssSpecSingle') || isfield(marss,'fhMarssSpecSuperpos') || ...
   isfield(marss,'fhMarssSpecSum')
    %--- processing update ---
    if ~SP2_MARSS_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME)
        return
    end

    %--- figure update ---
    if ~SP2_MARSS_FigureUpdate
        fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME)
        return
    end
end        
