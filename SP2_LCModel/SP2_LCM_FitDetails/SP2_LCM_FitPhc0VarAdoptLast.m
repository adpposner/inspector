%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc0VarAdoptLast
%% 
%%  Update function copy limit of zero order phase variation from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitPhc0VarAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n')
    return
end

%--- get last entry ---
eval(['lcmPhc0VarLast = str2double(get(fm.lcm.fit.phc0Var' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.fit.phc0Var(' sprintf('%i',mCnt) ') = lcmPhc0VarLast;'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
