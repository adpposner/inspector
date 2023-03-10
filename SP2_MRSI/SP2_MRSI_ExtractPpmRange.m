%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [minI,maxI,ppmZoom,specZoom,f_done] = ...
             SP2_MRSI_ExtractPpmRange(minPpm,maxPpm,ppmCalib,SW,datSpec)
%%
%%  Extraction of ppm range from a spectrum.
%%  Function arguments are the min/max values of the selected ppm range,
%%  the center/calibration ppm value (i.e. the synthesizer frequency), the
%%  experiment sweep width in ppm and the frequency domain data with
%%  increasing frequency for increasing vector index position as 1xN vector.
%%
%%  Return values are the indices of the zoomed spectral band as well as
%%  a success flag.
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_ExtractPpmRange';


%--- success flag init ---
f_done = 0;

%--- consistency checks ---
if minPpm>maxPpm
    fprintf('%s -> minPpm > maxPpm. Program aborted.\n\n',FCTNAME);
    return
end
SP2_Check4ColVec(datSpec)

%--- ppm window extraction ---
datSize = size(datSpec);
ppmVec  = -SW/2+ppmCalib:(SW/(datSize(1)-1)):SW/2+ppmCalib;
[fake,minI] = min( (ppmVec-minPpm).*(ppmVec-minPpm) );
[fake,maxI] = min( (ppmVec-maxPpm).*(ppmVec-maxPpm) );
if minI>maxI
    fprintf('%s -> minInd > maxInd. Program aborted.\n\n',FCTNAME);
    return
end
ppmZoom  = ppmVec(1,minI:maxI)';
specZoom = datSpec(minI:maxI);

%--- update success flag ---
f_done = 1;

end
