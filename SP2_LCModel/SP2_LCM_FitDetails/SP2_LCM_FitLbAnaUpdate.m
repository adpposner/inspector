%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbAnaUpdate(nMetab)
%% 
%%  Update function of current spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitLbAnaUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab)
    return
end
%--- update single vector entry ---
eval(['lcmAnaLb = str2double(get(fm.lcm.fit.anaLb' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmAnaLb)             % valid
    eval(['lcm.anaLb(' sprintf('%i',nMetab) ') = min(max(lcmAnaLb,lcm.fit.lbMin(' sprintf('%i',nMetab) ')),lcm.fit.lbMax(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
