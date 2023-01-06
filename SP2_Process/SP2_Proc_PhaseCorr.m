%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datSpec, f_done] = SP2_Proc_PhaseCorr(datSpec,nspecC,phc0,phc1)
%%
%%  Zero & 1st order phase correction
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_PhaseCorr';


%--- init success flag ---
f_done = 0;

%--- consistency check ---
if ~SP2_Check4ColVec(datSpec)
    return
end

%--- phase correction ---
if phc1~=0
    phaseVec = (0:phc1/(nspecC-1):phc1) + phc0; 
else
    phaseVec = ones(1,nspecC)*phc0;
end
datSpec = datSpec .* exp(1i*phaseVec*pi/180)';      % note: complex transpose, i.e. reformat and 1i->-1i

%--- update success flag ---
f_done = 1;

end
