%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftMaxUpdate(nMetab)
%% 
%%  Update function of minimum spectral shift.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitMaxShiftUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- update single vector entry ---
eval(['lcm.fit.shiftMax(' sprintf('%i',nMetab) ') = str2double(get(fm.lcm.fit.shiftMax' sprintf('%02i',nMetab) ',''String''));'])
eval(['lcm.fit.shiftMax(' sprintf('%i',nMetab) ') = max([lcm.fit.shiftMax(' sprintf('%i',nMetab) '), 1, lcm.fit.shiftMin(' sprintf('%i',nMetab) ')+1]);'])
    
%--- consistency check ---
if ~isempty(eval(['lcm.fit.shiftMax(' sprintf('%i',nMetab) ')']))             % valid
    % do not allow max value if smaller than current value (obsolete)
    % eval(['lcm.fit.shiftMax(' sprintf('%i',nMetab) ') = min(max(lcmShiftMax,lcm.anaShift(' sprintf('%i',nMetab) ')),50);'])
    % reduce current value if larger than new max value:
    eval(['lcm.anaShift(' sprintf('%i',nMetab) ') = min(lcm.anaShift(' sprintf('%i',nMetab) '),lcm.fit.shiftMax(' sprintf('%i',nMetab) '));'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
