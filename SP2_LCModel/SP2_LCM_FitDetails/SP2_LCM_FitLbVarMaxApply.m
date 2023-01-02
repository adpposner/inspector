%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbVarMaxApply
%% 
%%  Apply variation range to selected LB maximum settings.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global loggingfile fm lcm

FCTNAME = 'SP2_LCM_FitLbVarMaxApply';


%--- consistency check ---
if length(find(lcm.fit.select))<1
    fprintf('No metabolite selected. Nothing done.\n');
    return
end
    
%--- update minimum limits ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        lcm.fit.lbMax(mCnt) = lcm.anaLb(mCnt) + abs(lcm.fit.lbVarMax);
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
