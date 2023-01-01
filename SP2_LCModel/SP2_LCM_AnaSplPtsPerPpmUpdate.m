%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaSplPtsPerPpmUpdate
%% 
%%  Update number of spline grid points per ppm used for LCM analysis.
%%
%%  03-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- init success flag ---
f_succ = 0;

%--- update percentage value ---
lcm.anaSplPtsPerPpm = min(max(str2double(get(fm.lcm.anaSplPtsPerPpm,'String')),1),5);
set(fm.lcm.anaSplPtsPerPpm,'String',num2str(lcm.anaSplPtsPerPpm))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end

%--- update success flag ---
f_succ = 1;

