%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FitGbReset
%% 
%%  Reset selected GB parameters.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

FCTNAME = 'SP2_LCM_FitGbReset';


%--- init success flag ---
f_succ = 0;

%--- reset LCM fitting parameter: GB ---
lcm.anaGb(lcm.fit.applied) = (lcm.fit.gbMin(lcm.fit.applied)+lcm.fit.gbMax(lcm.fit.applied))/2;
fprintf('LCM fit: Selected GB parameters reset\n');

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
SP2_LCM_FitDetailsWinUpdate

%--- update success flag ---
f_succ = 1;


