%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_ClearSelExmArrays
%%
%%  Clearence of exm data array that (probably) are not longer needed.
%%  In case they are needed again, they are automatically recalculated
%%
%%  06-2007, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global exm
FCTNAME = 'SP2_ClearSelExmArrays';


%--- clear selected data arrays ---
if isfield(exm,'phaseImg')
    exm = rmfield(exm,'phaseImg');
end
if isfield(exm,'deltaPh1')
    exm = rmfield(exm,'deltaPh1');
end
if isfield(exm,'phUwrapImg')
    exm = rmfield(exm,'phUwrapImg');
end
if isfield(exm,'phSlope')
    exm = rmfield(exm,'phSlope');
end
if isfield(exm,'phUwErrImg')
    exm = rmfield(exm,'phUwErrImg');
end
if isfield(exm,'phSlopeErr')
    exm = rmfield(exm,'phSlopeErr');
end
if isfield(exm,'fmapErrImg')
    exm = rmfield(exm,'fmapErrImg');
end
pack
