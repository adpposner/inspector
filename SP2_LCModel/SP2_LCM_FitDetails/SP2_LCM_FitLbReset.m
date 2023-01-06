%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FitLbReset
%% 
%%  Reset selected LB parameters.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

FCTNAME = 'SP2_LCM_FitLbReset';


%--- init success flag ---
f_succ = 0;

%--- reset LCM fitting parameter: LB ---
lcm.anaLb(lcm.fit.applied) = (lcm.fit.lbMin(lcm.fit.applied)+lcm.fit.lbMax(lcm.fit.applied))/2;
fprintf('LCM fit: Selected LB parameters reset\n');

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
SP2_LCM_FitDetailsWinUpdate

%--- update success flag ---
f_succ = 1;



end
