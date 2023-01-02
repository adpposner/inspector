%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaPolyOrderInc
%% 
%%  Increase order of polynomial alignment.
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- keep old value ---
lcmAnaPolyOrder = lcm.anaPolyOrder;

%--- update percentage value ---
lcm.anaPolyOrder = min(lcm.anaPolyOrder + 1,10);
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
