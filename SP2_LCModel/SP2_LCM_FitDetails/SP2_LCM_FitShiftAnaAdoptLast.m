%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftAnaAdoptLast
%% 
%%  Update function copy maximum spectral linewidth (FWHM) selection from
%%  last applied basis function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftAnaAdoptLast';


%--- consistency check ---
if length(find(lcm.fit.select))<2
    fprintf('The transfer of metabolite selections requires\nthe selection of two or more basis functions.\n');
    return
end

%--- get last entry ---
eval(['lcmAnaShiftLast = str2double(get(fm.lcm.fit.anaShift' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    if lcm.fit.select(mCnt)
        eval(['lcm.anaShift(' sprintf('%i',mCnt) ') = lcmAnaShiftLast;'])
        eval(['lcm.fit.shiftMin(' sprintf('%i',mCnt) ') = min(lcm.anaShift(' sprintf('%i',mCnt) '),lcm.fit.shiftMin(' sprintf('%i',mCnt) '));'])
        eval(['lcm.fit.shiftMax(' sprintf('%i',mCnt) ') = max(lcm.fit.shiftMax(' sprintf('%i',mCnt) '),lcm.anaShift(' sprintf('%i',mCnt) '));'])
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

end
