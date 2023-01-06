%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ResultSpecSingleCurrIncr
%% 
%%  Lower number of metabolite to be displayed.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag


%--- update display value ---
if flag.lcmAnaPoly
    lcm.fit.currShow = min(lcm.fit.currShow+1,max(lcm.fit.appliedN+1,1));      % current metabolite
else
    lcm.fit.currShow = min(lcm.fit.currShow+1,max(lcm.fit.appliedN,1));        % current metabolite
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
