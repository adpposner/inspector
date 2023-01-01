%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaGbFlagUpdate
%% 
%%  Switching on/off Gaussian line broadening for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaGb = get(fm.lcm.anaGbFlag,'Value');
set(fm.lcm.anaGbFlag,'Value',flag.lcmAnaGb)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end


