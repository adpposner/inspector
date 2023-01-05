%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisReorderUpdate(nMetab)
%% 
%%  Update function: Rearrangement of metabolite order in basis set.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_BasisReorderUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmBasisReorder = str2double(get(fm.lcm.basis.reorder' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
lcm.basis.reorder(nMetab) = min(max(lcmBasisReorder,1),lcm.basis.n);

%--- update window ---
SP2_LCM_BasisWinUpdate
