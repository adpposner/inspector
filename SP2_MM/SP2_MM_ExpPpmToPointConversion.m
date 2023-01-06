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

global mm


%--- check data existence ---
if ~isfield(mm,'spec')
    return
end

%--- parameter update ---
[mm.expPointSelect,maxI,ppmZoom,specZoom,f_done] = ...
    SP2_MM_ExtractPpmRange(mm.expPpmSelect,mm.expPpmSelect+1,mm.ppmCalib,...
                           mm.sw,real(mm.spec(:,1)));
                       
end
