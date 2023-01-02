%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisT2Update(nMetab)
%% 
%%  Update function: T2 [s] of individual metabolite.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global loggingfile fm lcm

FCTNAME = 'SP2_LCM_BasisT2Update';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmBasisDataT2 = str2double(get(fm.lcm.basis.t2' sprintf('%02i',nMetab) ',''String''));'])
    
%--- consistency check ---
if ~isempty(lcmBasisDataT2)             % valid
    lcm.basis.data{nMetab}{3} = lcmBasisDataT2;
end

%--- update window ---
SP2_LCM_BasisWinUpdate
