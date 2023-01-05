%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbAnaAdoptLast
%% 
%%  Update function copy maximum spectral linewidth (FWHM) selection from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitGbAnaAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n');
    return
end

%--- get last entry ---
eval(['lcmAnaGbLast = str2double(get(fm.lcm.fit.anaGb' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.anaGb(' sprintf('%i',mCnt) ') = lcmAnaGbLast;'])
        eval(['lcm.fit.gbMin(' sprintf('%i',mCnt) ') = min(lcm.anaGb(' sprintf('%i',mCnt) '),lcm.fit.gbMin(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.gbMax(' sprintf('%i',mCnt) ') = max(lcm.fit.gbMax(' sprintf('%i',mCnt) '),lcm.anaGb(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
