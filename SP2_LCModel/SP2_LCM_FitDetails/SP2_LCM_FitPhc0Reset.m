%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_FitPhc0Reset
%% 
%%  Reset zero-order phase PHC0.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

FCTNAME = 'SP2_LCM_FitPhc0Reset';


%--- init success flag ---
f_succ = 0;

%--- reset LCM fitting parameter: PHC0 ---
lcm.anaPhc0 = 0;

%--- info printout ---
fprintf('LCM fit: PHC0 parameter reset\n')

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- fit window update ---
SP2_LCM_FitDetailsWinUpdate

%--- update success flag ---
f_succ = 1;


