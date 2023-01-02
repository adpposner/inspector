%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaPolyOrderUpdate
%% 
%%  Update order of polynomial used for LCModel analysis.
%%
%%  03-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- init success flag ---
f_succ = 0;

%--- keep old value ---
lcmAnaPolyOrder = lcm.anaPolyOrder;

%--- update percentage value ---
lcm.anaPolyOrder = min(max(str2double(get(fm.lcm.anaPolyOrder,'String')),0),10);
set(fm.lcm.anaPolyOrder,'String',num2str(lcm.anaPolyOrder))

%--- reset polynomial coefficients ---
if lcm.anaPolyOrder<lcmAnaPolyOrder
    lcm.anaPolyCoeff     = zeros(1,11);      % polynomial coefficients 0..10th order
    lcm.anaPolyCoeffImag = zeros(1,11);      % polynomial coefficients 0..10th order
    fprintf('Info: Polynomial coefficients reset\n');
end

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

