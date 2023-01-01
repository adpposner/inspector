%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaPhc0FlagUpdate
%% 
%%  Switching on/off zero order phase correction for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaPhc0 = get(fm.lcm.anaPhc0Flag,'Value');
set(fm.lcm.anaPhc0Flag,'Value',flag.lcmAnaPhc0)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

