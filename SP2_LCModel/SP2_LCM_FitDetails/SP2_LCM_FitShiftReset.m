%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FitShiftReset
%% 
%%  Reset selected shift parameters.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

FCTNAME = 'SP2_LCM_FitShiftReset';


%--- init success flag ---
f_succ = 0;

%--- reset LCM fitting parameter: LB ---
lcm.anaShift(lcm.fit.applied) = (lcm.fit.shiftMin(lcm.fit.applied)+lcm.fit.shiftMax(lcm.fit.applied))/2;
fprintf('LCM fit: Selected LB parameters reset\n')

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
SP2_LCM_FitDetailsWinUpdate

%--- update success flag ---
f_succ = 1;


