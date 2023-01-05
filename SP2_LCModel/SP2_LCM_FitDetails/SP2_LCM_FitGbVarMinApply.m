%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbVarMinApply
%% 
%%  Apply variation range to selected GB minimum settings.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitGbVarMinApply';


%--- consistency check ---
if length(find(lcm.fit.select))<1
    fprintf('No metabolite selected. Nothing done.\n');
    return
end
    
%--- update minimum limits ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        lcm.fit.gbMin(mCnt) = lcm.anaGb(mCnt) - abs(lcm.fit.gbVarMin);
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
