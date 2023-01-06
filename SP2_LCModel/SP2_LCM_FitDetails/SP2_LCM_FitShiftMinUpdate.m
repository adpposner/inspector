%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftMinUpdate(nMetab)
%% 
%%  Update function of minimum spectral shift.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitShiftMinUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- update single vector entry ---
eval(['lcm.fit.shiftMin(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.shiftMin' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.shiftMin(' sprintf('%i',nMetab) ') = min([lcm.fit.shiftMin(' sprintf('%i',nMetab) '), 100, lcm.fit.shiftMax(' sprintf('%i',nMetab) ')-1]);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.shiftMin(' sprintf('%i',nMetab) ')']))             % valid
    % reduce current value if larger than new max value:
    eval(['lcm.anaShift(' sprintf('%i',nMetab) ') = max(lcm.anaShift(' sprintf('%i',nMetab) '),lcm.fit.shiftMin(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

end
