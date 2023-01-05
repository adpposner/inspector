%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbMinUpdate(nMetab)
%% 
%%  Update function of minimum spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitGbMinUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcm.fit.gbMin(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.gbMin' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.gbMin(' sprintf('%i',nMetab) ') = max(min([lcm.fit.gbMin(' sprintf('%i',nMetab) '), 100, lcm.fit.gbMax(' sprintf('%i',nMetab) ')-1]),-10);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.gbMin(' sprintf('%i',nMetab) ')']))             % valid
    % reduce current value if larger than new max value:
    eval(['lcm.anaGb(' sprintf('%i',nMetab) ') = max(lcm.anaGb(' sprintf('%i',nMetab) '),lcm.fit.gbMin(' sprintf('%i',nMetab) '));'])
end


%--- update window ---
SP2_LCM_FitDetailsWinUpdate
