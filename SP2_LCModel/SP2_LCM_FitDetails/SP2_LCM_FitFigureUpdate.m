%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitFigureUpdate
%% 
%%  Figure update function for LCModel result.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm


%--- update existing figures ---
if isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        if ~SP2_LCM_PlotResultSpecSummary(0)
            return
        end
    end
end

%--- update existing figures ---
if isfield(lcm,'fhLcmFitSpecSuperpos')
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        if ~SP2_LCM_PlotResultSpecSuperpos(0)
            return
        end
    end
end

%--- update existing figures ---
if isfield(lcm,'fhLcmFitSpecSum')
    if ishandle(lcm.fhLcmFitSpecSum)
        if ~SP2_LCM_PlotResultSpecSum(0)
            return
        end
    end
end

%--- update existing figures ---
if isfield(lcm,'fhLcmFitSpecSingle')
    if ishandle(lcm.fhLcmFitSpecSingle)
        if ~SP2_LCM_PlotResultSpecSingle(0)
            return
        end
    end
end

%--- update existing figures ---
if isfield(lcm,'fhLcmFitSpecResid')
    if ishandle(lcm.fhLcmFitSpecResid)
        if ~SP2_LCM_PlotResultSpecResidual(0)
            return
        end
    end
end

