%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisNameUpdate(nMetab)
%% 
%%  Update function: Individual metabolite name.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_BasisNameUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmBasisDataName = get(fm.lcm.basis.name' sprintf('%02i',nMetab) ',''String'');'])
    
%--- consistency check ---
if ~isempty(lcmBasisDataName)           % valid
    lcm.basis.data{nMetab}{1} = lcmBasisDataName;
end

%--- update window ---
SP2_LCM_BasisWinUpdate

end
