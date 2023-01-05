%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_FigureUpdate
%% 
%%  Figure update function.
%%
%%  12-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

%--- init success flag ---
f_done = 0;

%--- update existing figures: data set 1 ---
if isfield(data,'fhFid1Single')
    if ishandle(data.fhFid1Single)
        if ~SP2_Data_PlotFid1Single(0)
            return
        end
    end
end
if isfield(data,'fhFid1Super')
    if ishandle(data.fhFid1Super)
        if ~SP2_Data_PlotFid1Superposition(0)
            return
        end
    end
end
if isfield(data,'fhFid1Array')
    if ishandle(data.fhFid1Array)
        if ~SP2_Data_PlotFid1Array(0)
            return
        end
    end
end
if isfield(data,'fhSpec1Single')
    if ishandle(data.fhSpec1Single)
        if ~SP2_Data_PlotSpec1Single(0)
            return
        end
    end
end
if isfield(data,'fhSpec1Super')
    if ishandle(data.fhSpec1Super)
        if ~SP2_Data_PlotSpec1Superposition(0)
            return
        end
    end
end
if isfield(data,'fhSpec1Array')
    if ishandle(data.fhSpec1Array)
        if ~SP2_Data_PlotSpec1Array(0)
            return
        end
    end
end

%--- update existing figures: data set 2 ---
if isfield(data,'fhFid2Single')
    if ishandle(data.fhFid2Single)
        if ~SP2_Data_PlotFid2Single(0)
            return
        end
    end
end
if isfield(data,'fhFid2Super')
    if ishandle(data.fhFid2Super)
        if ~SP2_Data_PlotFid2Superposition(0)
            return
        end
    end
end
if isfield(data,'fhFid2Array')
    if ishandle(data.fhFid2Array)
        if ~SP2_Data_PlotFid2Array(0)
            return
        end
    end
end
if isfield(data,'fhSpec2Single')
    if ishandle(data.fhSpec2Single)
        if ~SP2_Data_PlotSpec2Single(0)
            return
        end
    end
end
if isfield(data,'fhSpec2Super')
    if ishandle(data.fhSpec2Super)
        if ~SP2_Data_PlotSpec2Superposition(0)
            return
        end
    end
end
if isfield(data,'fhSpec2Array')
    if ishandle(data.fhSpec2Array)
        if ~SP2_Data_PlotSpec2Array(0)
            return
        end
    end
end

%--- update success flag ---
f_done = 1;
