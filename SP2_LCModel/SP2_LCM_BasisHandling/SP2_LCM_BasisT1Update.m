%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisT1Update(nMetab)
%% 
%%  Update function: T1 [s] of individual metabolite.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_BasisT1Update';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmBasisDataT1 = str2double(get(fm.lcm.basis.t1' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmBasisDataT1)             % valid
    lcm.basis.data{nMetab}{2} = lcmBasisDataT1;
end

%--- update window ---
SP2_LCM_BasisWinUpdate
