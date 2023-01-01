%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc1VarUpdate(nMetab)
%% 
%%  Update function of first-order phase variation range (applied to both sides).
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitPhc1VarUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab)
    return
end
%--- update single vector entry ---
eval(['lcmPhc1Var = str2double(get(fm.lcm.fit.phc1Var' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmPhc1Var)             % valid
    eval(['lcm.fit.phc1Var(' sprintf('%i',nMetab) ') = lcmPhc1Var;'])
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

