%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_FigureUpdate
%% 
%%  Figure update function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

%--- init success flag ---
f_done = 0;

%--- update existing figures ---
if isfield(proc,'fhFid1Orig') 
    if ishandle(proc.fhFid1Orig)
        if ~SP2_Proc_PlotFid1Orig(0)
            return
        end
    end
end
if flag.procNumSpec && isfield(proc,'fhFid2Orig')
    if ishandle(proc.fhFid2Orig)
        if ~SP2_Proc_PlotFid2Orig(0)
            return
        end
    end
end
if isfield(proc,'fhFid1')
    if ishandle(proc.fhFid1)
        if ~SP2_Proc_PlotFid1(0)
            return
        end
    end
end
if flag.procNumSpec && isfield(proc,'fhFid2')
    if ishandle(proc.fhFid2)
        if ~SP2_Proc_PlotFid2(0)
            return
        end
    end
end
if isfield(proc,'fhSpec1')
    if ishandle(proc.fhSpec1)
        if ~SP2_Proc_PlotSpec1(0)
            return
        end
    end
end
if flag.procNumSpec && isfield(proc,'fhSpec2')
    if ishandle(proc.fhSpec2)
        if ~SP2_Proc_PlotSpec2(0)
            return
        end
    end
end

%--- combination of spectra ---
if flag.procNumSpec && proc.spec1.nspecC==proc.spec2.nspecC
    if isfield(proc,'fhFidSuper')
        if ishandle(proc.fhFidSuper)
            if ~SP2_Proc_PlotFidSuperpos(0)
                return
            end
        end
    end
    if isfield(proc,'fhSpecSuper')
        if ishandle(proc.fhSpecSuper)
            if ~SP2_Proc_PlotSpecSuperpos(0)
                return
            end
        end
    end
    if isfield(proc,'fhFidSum')
        if ishandle(proc.fhFidSum)
            if ~SP2_Proc_PlotFidSum(0)
                return
            end
        end
    end
    if isfield(proc,'fhFidDiff')
        if ishandle(proc.fhFidDiff)
            if ~SP2_Proc_PlotFidDiff(0)
                return
            end
        end
    end
    if isfield(proc,'fhSpecSum')
        if ishandle(proc.fhSpecSum)
            if ~SP2_Proc_PlotSpecSum(0)
                return
            end
        end
    end
    if isfield(proc,'fhSpecDiff')
        if ishandle(proc.fhSpecDiff)
            if ~SP2_Proc_PlotSpecDiff(0)
                return
            end
        end
    end
end

%--- update success flag ---
f_done = 1;

