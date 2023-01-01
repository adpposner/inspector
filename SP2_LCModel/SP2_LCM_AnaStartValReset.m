%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaStartValReset
%% 
%%  Reset all fitting parameters.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag lcm

FCTNAME = 'SP2_LCM_AnaStartValReset';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if ~flag.lcmAnaLb && ~flag.lcmAnaGb && ~flag.lcmAnaPhc0 && ...
   ~flag.lcmAnaPhc1 && ~flag.lcmAnaShift && ~flag.lcmAnaPoly && ~flag.lcmAnaScale
    fprintf('%s ->\nNo LCM fitting parameter selected.\n',FCTNAME)
    return
end

%--- reset LCM scaling ---
if flag.lcmAnaScale
    lcm.anaScale = ones(1,lcm.fit.nLim);
    fprintf('LCM fit: Scaling reset\n')
end

%--- reset LCM fitting parameter: LB ---
if flag.lcmAnaLb
    % lcm.anaLb    = ones(1,lcm.fit.nLim);
    lcm.anaLb = (lcm.fit.lbMin+lcm.fit.lbMax)/2;
    fprintf('LCM fit: LB parameter reset\n')
end

%--- reset LCM fitting parameter: GB ---
if flag.lcmAnaGb
    % lcm.anaGb    = ones(1,lcm.fit.nLim);
    lcm.anaGb = (lcm.fit.gbMin+lcm.fit.gbMax)/2;
    fprintf('LCM fit: GB parameter reset\n')
end

%--- reset LCM fitting parameter: PHC0 ---
if flag.lcmAnaPhc0
    lcm.anaPhc0  = 0;
    fprintf('LCM fit: PHC0 parameter reset\n')
end
%--- reset LCM fitting parameter: PHC1 ---
if flag.lcmAnaPhc1
    lcm.anaPhc1  = 0;
    fprintf('LCM fit: PHC1 parameter reset\n')
end

%--- reset LCM fitting parameter: Shift ---
if flag.lcmAnaShift
    lcm.anaShift = zeros(1,lcm.fit.nLim);
    fprintf('LCM fit: Shift parameter reset\n')
end

%--- reset LCM fitting parameter: polynomial coefficients ---
if flag.lcmAnaPoly
    lcm.anaPolyCoeff     = zeros(1,11);      % polynomial coefficients 0..10th order
    lcm.anaPolyCoeffImag = zeros(1,11);      % polynomial coefficients 0..10th order
    fprintf('LCM fit: Polynomial coefficients reset\n')
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
SP2_LCM_FitDetailsWinUpdate

%--- update success flag ---
f_succ = 1;


