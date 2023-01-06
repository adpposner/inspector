%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftMaxAdoptLast
%% 
%%  Update function copy maximum spectral shift selection from
%%  last applied basis function to all basis functions.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftMaxAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n');
    return
end

%--- get last entry ---
eval(['lcmShiftMaxLast = str2double(get(fm.lcm.fit.shiftMax' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.fit.shiftMax(' sprintf('%i',mCnt) ') = lcmShiftMaxLast;'])     % enforced
        eval(['lcm.anaShift(' sprintf('%i',mCnt) ')     = min(lcm.anaShift(' sprintf('%i',mCnt) '),lcm.fit.shiftMax(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.shiftMin(' sprintf('%i',mCnt) ') = min(lcm.fit.shiftMin(' sprintf('%i',mCnt) '),lcm.anaShift(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

end
