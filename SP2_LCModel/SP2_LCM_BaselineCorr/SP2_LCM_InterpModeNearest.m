%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_InterpModeNearest
%% 
%%  Selection of the interpolation mode:
%%  1: nearest neighbor
%%  2: linear
%%  3: piece-wise cubic spline
%%  4: shape-preserving piecewise cubic
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- flag handling ---
flag.lcmBaseInterpMode = 1;

%--- window update ---
set(fm.lcm.base.interpNearest,'Value',1)
set(fm.lcm.base.interpLinear,'Value',0)
set(fm.lcm.base.interpSpline,'Value',0)
set(fm.lcm.base.interpCubic,'Value',0)
