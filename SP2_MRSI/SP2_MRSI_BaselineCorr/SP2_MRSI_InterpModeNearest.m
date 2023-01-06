%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_InterpModeNearest
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
flag.mrsiBaseInterpMode = 1;

%--- window update ---
set(fm.mrsi.base.interpNearest,'Value',1)
set(fm.mrsi.base.interpLinear,'Value',0)
set(fm.mrsi.base.interpSpline,'Value',0)
set(fm.mrsi.base.interpCubic,'Value',0)

end
