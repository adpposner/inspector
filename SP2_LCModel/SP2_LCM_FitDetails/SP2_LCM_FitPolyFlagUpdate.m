%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyFlagUpdate
%% 
%%  Switching on/off polynomial baseline in LCModel analysis.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.lcmAnaPoly = get(fm.lcm.fit.polynomial,'Value');
set(fm.lcm.fit.polynomial,'Value',flag.lcmAnaPoly)

%--- update polynomial flag parameter ---
if flag.lcmAnaPoly
    flag.lcmAnaSpline = 0;
    if isfield(fm.lcm,'anaSplineFlag')
        set(fm.lcm.anaSplineFlag,'Value',flag.lcmAnaSpline)
    end
end

%--- window update ---
SP2_LCM_FitDetailsWinUpdate
SP2_LCM_LCModelWinUpdate

