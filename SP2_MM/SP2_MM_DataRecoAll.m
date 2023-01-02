%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DataRecoAll
%%
%%  Load parameters and data of saturation-recovery experiment from 'Data'
%%  page and perform all reco steps: resorting, correction and processing.
%%
%%  02-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_MM_DataRecoAll';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if ~SP2_MM_DataLoad
    return
end
if ~SP2_MM_DataResort
    return
end
if ~SP2_MM_DataCorr(0)
    return
end
if ~SP2_MM_DataReco
    return
end

%--- update success flag ---
f_succ = 1;