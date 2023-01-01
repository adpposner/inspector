%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaShapeFlagUpdate
%% 
%%  Switching on/off amplitude shape modeling for LCM analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaShape = get(fm.lcm.anaShapeFlag,'Value');
set(fm.lcm.anaShapeFlag,'Value',flag.lcmAnaShape)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

