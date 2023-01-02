%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpPointToPpmConversion
%% 
%%  Conversion of frequency position in [points] to corresponding spectral
%%  position in [ppm].
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm


%--- check data existence ---
if ~isfield(mm,'spec')
    return
end

%--- parameter update ---
ppmVec = (-mm.sw/2:mm.sw/(mm.nspecC-1):mm.sw/2) + mm.ppmCalib;
mm.expPpmSelect = ppmVec(mm.expPointSelect);