%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbMaxAdoptLast
%% 
%%  Update function copy maximum spectral linewidth (FWHM) selection from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitLbMaxAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n');
    return
end

%--- get last entry ---
eval(['lcmLbMaxLast = str2double(get(fm.lcm.fit.lbMax' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.fit.lbMax(' sprintf('%i',mCnt) ') = lcmLbMaxLast;'])     % enforced
        eval(['lcm.anaLb(' sprintf('%i',mCnt) ')     = min(lcm.anaLb(' sprintf('%i',mCnt) '),lcm.fit.lbMax(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.lbMin(' sprintf('%i',mCnt) ') = min(lcm.fit.lbMin(' sprintf('%i',mCnt) '),lcm.anaLb(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

end
