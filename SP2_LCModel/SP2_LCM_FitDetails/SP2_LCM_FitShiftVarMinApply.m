%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftVarMinApply
%% 
%%  Apply variation range to selected shift minimum settings.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftVarMinApply';


%--- consistency check ---
if length(find(lcm.fit.select))<1
    fprintf('No metabolite selected. Nothing done.\n')
    return
end
    
%--- update minimum limits ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        lcm.fit.shiftMin(mCnt) = lcm.anaShift(mCnt) - abs(lcm.fit.shiftVarMin);
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
