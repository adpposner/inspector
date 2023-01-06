%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BasisCommentUpdate(nMetab)
%% 
%%  Update function: Text comment of individual metabolite.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_BasisCommentUpdate';


%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.nLim
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end
%--- update single vector entry ---
eval(['lcmBasisDataCom = get(fm.lcm.basis.com' sprintf('%02i',nMetab) ',''String'');'])
    
%--- consistency check ---
if ~isempty(lcmBasisDataCom) && ischar(lcmBasisDataCom)             % valid
    lcm.basis.data{nMetab}{5} = lcmBasisDataCom;
end

%--- update window ---
SP2_LCM_BasisWinUpdate

end
