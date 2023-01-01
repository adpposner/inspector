%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftVarMaxApply
%% 
%%  Apply variation range to selected shift maximum settings.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftVarMaxApply';


%--- consistency check ---
if length(find(lcm.fit.select))<1
    fprintf('No metabolite selected. Nothing done.\n')
    return
end
    
%--- update minimum limits ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        lcm.fit.shiftMax(mCnt) = lcm.anaShift(mCnt) + abs(lcm.fit.shiftVarMax);
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
