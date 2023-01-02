%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc0VarUpdate(nMetab)
%% 
%%  Update function of zero-order phase variation range (applied to both sides).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global loggingfile fm lcm

FCTNAME = 'SP2_LCM_FitPhc0VarUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmPhc0Var = str2double(get(fm.lcm.fit.phc0Var' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmPhc0Var)             % valid
    eval(['lcm.fit.phc0Var(' sprintf('%i',nMetab) ') = min(max(lcmPhc0Var,-359.9),360);'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
