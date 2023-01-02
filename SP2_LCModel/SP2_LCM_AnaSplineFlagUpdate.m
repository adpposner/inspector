%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaSplineFlagUpdate
%% 
%%  Switching on/off spline baseline for spectrum quantification.
%%
%%  11-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update spline flag parameter ---
flag.lcmAnaSpline = get(fm.lcm.anaSplineFlag,'Value');
set(fm.lcm.anaSplineFlag,'Value',flag.lcmAnaSpline)

%--- update polynomial flag parameter ---
if flag.lcmAnaSpline
    flag.lcmAnaPoly = 0;
    set(fm.lcm.anaPolyFlag,'Value',flag.lcmAnaPoly)
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end
