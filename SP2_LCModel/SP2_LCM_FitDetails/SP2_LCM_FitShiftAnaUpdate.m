%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftAnaUpdate(nMetab)
%% 
%%  Update function of current spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftAnaUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmAnaShift = str2double(get(fm.lcm.fit.anaShift' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmAnaShift)             % valid
    eval(['lcm.anaShift(' sprintf('%i',nMetab) ') = min(max(lcmAnaShift,lcm.fit.shiftMin(' sprintf('%i',nMetab) ')),lcm.fit.shiftMax(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
