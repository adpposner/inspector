%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaPolyFlagUpdate
%% 
%%  Switching on/off polynomial for spectrum alignment.
%%
%%  03-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update polynomial flag parameter ---
flag.lcmAnaPoly = get(fm.lcm.anaPolyFlag,'Value');
set(fm.lcm.anaPolyFlag,'Value',flag.lcmAnaPoly)

%--- update polynomial flag parameter ---
if flag.lcmAnaPoly
    flag.lcmAnaSpline = 0;
    set(fm.lcm.anaSplineFlag,'Value',flag.lcmAnaSpline)
end

% %--- reset polynomial coefficients ---
% if ~flag.lcmAnaPoly
%     lcm.anaPolyCoeff = zeros(1,11);      % polynomial coefficients 0..10th order
%     fprintf('Info: Polynomial coefficients reset\n');
% end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
if isfield(fm.lcm,'fit')
    if ishandle(fm.lcm.fit.fig)
        SP2_LCM_FitDetailsWinUpdate
    end
end
