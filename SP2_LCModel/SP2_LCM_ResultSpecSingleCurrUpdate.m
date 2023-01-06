%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ResultSpecSingleCurrUpdate
%% 
%%  Update of current metabolite selection.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag


%--- update current metabolite ---
if flag.lcmAnaPoly
    lcm.fit.currShow = max(min(str2double(get(fm.lcm.singleCurr,'String')),max(lcm.fit.appliedN+1,1)),1);
else
    lcm.fit.currShow = max(min(str2double(get(fm.lcm.singleCurr,'String')),max(lcm.fit.appliedN,1)),1);
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
