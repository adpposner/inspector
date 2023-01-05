%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbMaxUpdate(nMetab)
%% 
%%  Update function of minimum spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitMaxLbUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- update single vector entry ---
eval(['lcm.fit.lbMax(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.lbMax' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.lbMax(' sprintf('%i',nMetab) ') = max([lcm.fit.lbMax(' sprintf('%i',nMetab) '), 1, lcm.fit.lbMin(' sprintf('%i',nMetab) ')+1]);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.lbMax(' sprintf('%i',nMetab) ')']))             % valid
    % do not allow max value if smaller than current value (obsolete)
    % eval(['lcm.fit.lbMax(' sprintf('%i',nMetab) ') = min(max(lcmLbMax,lcm.anaLb(' sprintf('%i',nMetab) ')),50);'])
    % reduce current value if larger than new max value:
    eval(['lcm.anaLb(' sprintf('%i',nMetab) ') = min(lcm.anaLb(' sprintf('%i',nMetab) '),lcm.fit.lbMax(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
