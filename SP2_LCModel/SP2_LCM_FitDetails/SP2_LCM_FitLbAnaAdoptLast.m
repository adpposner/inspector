%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbAnaAdoptLast
%% 
%%  Update function copy maximum spectral linewidth (FWHM) selection from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitLbAnaAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n')
    return
end

%--- get last entry ---
eval(['lcmAnaLbLast = str2double(get(fm.lcm.fit.anaLb' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.anaLb(' sprintf('%i',mCnt) ') = lcmAnaLbLast;'])
        eval(['lcm.fit.lbMin(' sprintf('%i',mCnt) ') = min(lcm.anaLb(' sprintf('%i',mCnt) '),lcm.fit.lbMin(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.lbMax(' sprintf('%i',mCnt) ') = max(lcm.fit.lbMax(' sprintf('%i',mCnt) '),lcm.anaLb(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
