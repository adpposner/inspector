%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_FigureUpdate
%% 
%%  Figure update function.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

%--- init success flag ---
f_done = 0;

%--- update existing figures ---
if isfield(mrsi,'fhFid1Orig') 
    if ishandle(mrsi.fhFid1Orig)
        SP2_MRSI_PlotFid1Orig(0)
    end
end
if flag.mrsiNumSpec && isfield(mrsi,'fhFid2Orig')
    if ishandle(mrsi.fhFid2Orig)
        SP2_MRSI_PlotFid2Orig(0)
    end
end
if isfield(mrsi,'fhFid1')
    if ishandle(mrsi.fhFid1)
        SP2_MRSI_PlotFid1(0)
    end
end
if flag.mrsiNumSpec && isfield(mrsi,'fhFid2')
    if ishandle(mrsi.fhFid2)
        SP2_MRSI_PlotFid2(0)
    end
end
if isfield(mrsi,'fhSpec1')
    if ishandle(mrsi.fhSpec1)
        SP2_MRSI_PlotSpec1(0)
    end
end
if flag.mrsiNumSpec && isfield(mrsi,'fhSpec2')
    if ishandle(mrsi.fhSpec2)
        SP2_MRSI_PlotSpec2(0)
    end
end

%--- combination of spectra ---
if flag.mrsiNumSpec && mrsi.spec1.nspecC==mrsi.spec2.nspecC
    if isfield(mrsi,'fhFidSuper')
        if ishandle(mrsi.fhFidSuper)
            SP2_MRSI_PlotFidSuperpos(0)
        end
    end
    if isfield(mrsi,'fhSpecSuper')
        if ishandle(mrsi.fhSpecSuper)
            SP2_MRSI_PlotSpecSuperpos(0)
        end
    end
    if isfield(mrsi,'fhFidSum')
        if ishandle(mrsi.fhFidSum)
            SP2_MRSI_PlotFidSum(0)
        end
    end
    if isfield(mrsi,'fhFidDiff')
        if ishandle(mrsi.fhFidDiff)
            SP2_MRSI_PlotFidDiff(0)
        end
    end
    if isfield(mrsi,'fhSpecSum')
        if ishandle(mrsi.fhSpecSum)
            SP2_MRSI_PlotSpecSum(0)
        end
    end
    if isfield(mrsi,'fhSpecDiff')
        if ishandle(mrsi.fhSpecDiff)
            SP2_MRSI_PlotSpecDiff(0)
        end
    end
end

%--- update success flag ---
f_done = 1;


end
