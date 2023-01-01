%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitScaleAnaAdoptLast
%% 
%%  Update function copy scaling from last selected metabolite to all other
%%  metabolites.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitScaleAnaAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n')
    return
end

%--- get first entry ---
eval(['lcmAnaScaleLast = str2double(get(fm.lcm.fit.anaScale' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.anaScale(' sprintf('%i',mCnt) ') = max(lcmAnaScaleLast,0);'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
