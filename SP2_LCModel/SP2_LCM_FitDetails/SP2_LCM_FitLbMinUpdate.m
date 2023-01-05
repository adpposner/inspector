%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbMinUpdate(nMetab)
%% 
%%  Update function of minimum spectral linewidth (FWHM).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitLbMinUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- update single vector entry ---
eval(['lcm.fit.lbMin(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.lbMin' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.lbMin(' sprintf('%i',nMetab) ') = max(min([lcm.fit.lbMin(' sprintf('%i',nMetab) '), 100, lcm.fit.lbMax(' sprintf('%i',nMetab) ')-1]),-10);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.lbMin(' sprintf('%i',nMetab) ')']))             % valid
    % reduce current value if larger than new max value:
    eval(['lcm.anaLb(' sprintf('%i',nMetab) ') = max(lcm.anaLb(' sprintf('%i',nMetab) '),lcm.fit.lbMin(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
