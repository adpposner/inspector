%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc1VarAdoptLast
%% 
%%  Update function copy limit of first order phase variation from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitPhc1VarAdoptLast';



%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n')
    return
end

%--- get last entry ---
eval(['lcmPhc1VarLast = str2double(get(fm.lcm.fit.phc1Var' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.fit.phc1Var(' sprintf('%i',mCnt) ') = lcmPhc1VarLast;'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
