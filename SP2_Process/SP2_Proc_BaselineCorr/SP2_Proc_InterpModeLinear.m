%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_InterpModeLinear
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

global fm flag


%--- flag handling ---
flag.procBaseInterpMode = 2;

%--- window update ---
set(fm.proc.base.interpNearest,'Value',0)
set(fm.proc.base.interpLinear,'Value',1)
set(fm.proc.base.interpSpline,'Value',0)
set(fm.proc.base.interpCubic,'Value',0)
