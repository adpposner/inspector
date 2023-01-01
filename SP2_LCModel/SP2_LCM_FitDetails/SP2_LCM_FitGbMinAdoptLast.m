%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbMinAdoptLast
%% 
%%  Update function copy minimum spectral linewidth (FWHM) selection from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitGbMinAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n')
    return
end

%--- get last entry ---
eval(['lcmGbMinLast = str2double(get(fm.lcm.fit.gbMin' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.fit.gbMin(' sprintf('%i',mCnt) ') = lcmGbMinLast;'])
        eval(['lcm.anaGb(' sprintf('%i',mCnt) ')     = max(lcm.anaGb(' sprintf('%i',mCnt) '),lcm.fit.gbMin(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.gbMax(' sprintf('%i',mCnt) ') = max(lcm.fit.gbMax(' sprintf('%i',mCnt) '),lcm.anaGb(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
