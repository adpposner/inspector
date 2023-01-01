%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FigureUpdate
%% 
%%  Figure update function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

%--- init success flag ---
f_succ = 0;

%--- update existing figures ---
if isfield(lcm,'fhLcmFidOrig') 
    if ishandle(lcm.fhLcmFidOrig)
        if ~SP2_LCM_PlotLcmFidOrig(0)
            return
        end
    end
end
if isfield(lcm,'fhLcmFid')
    if ishandle(lcm.fhLcmFid)
        if ~SP2_LCM_PlotLcmFid(0)
            return
        end
    end
end
if isfield(lcm,'fhLcmSpec')
    if ishandle(lcm.fhLcmSpec)
        if ~SP2_LCM_PlotLcmSpec(0)
            return
        end
    end
end
if isfield(lcm,'fhLcmFitSpecSuperpos')
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        if ~SP2_LCM_PlotResultSpecSuperpos(0)
            return
        end
    end
end
if isfield(lcm,'fhLcmFitSpecSum')
    if ishandle(lcm.fhLcmFitSpecSum)
        if ~SP2_LCM_PlotResultSpecSum(0)
            return
        end
    end
end
if isfield(lcm,'fhLcmFitSpecSingle')
    if ishandle(lcm.fhLcmFitSpecSingle)
        if ~SP2_LCM_PlotResultSpecSingle(0)
            return
        end
    end
end

%--- update success flag ---
f_succ = 1;

