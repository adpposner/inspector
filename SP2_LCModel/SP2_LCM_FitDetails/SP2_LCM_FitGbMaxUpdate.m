%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbMaxUpdate(nMetab)
%% 
%%  Update function of minimum spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitMaxGbUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcm.fit.gbMax(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.gbMax' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.gbMax(' sprintf('%i',nMetab) ') = max([lcm.fit.gbMax(' sprintf('%i',nMetab) '), 1, lcm.fit.gbMin(' sprintf('%i',nMetab) ')+1]);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.gbMax(' sprintf('%i',nMetab) ')']))             % valid
    % do not allow max value if smaller than current value (obsolete)
    % eval(['lcm.fit.gbMax(' sprintf('%i',nMetab) ') = min(max(lcmGbMax,lcm.anaGb(' sprintf('%i',nMetab) ')),50);'])
    % reduce current value if larger than new max value:
    eval(['lcm.anaGb(' sprintf('%i',nMetab) ') = min(lcm.anaGb(' sprintf('%i',nMetab) '),lcm.fit.gbMax(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
