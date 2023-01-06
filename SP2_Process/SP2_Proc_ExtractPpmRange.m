%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [minI,maxI,ppmZoom,specZoom,f_succ] = ...
             SP2_Proc_ExtractPpmRange(minPpm,maxPpm,ppmCalib,SW,datSpec)
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

FCTNAME = 'SP2_Proc_ExtractPpmRange';


%--- success flag init ---
f_succ   = 0;
minI     = 1;                 % init
maxI     = 1;
ppmZoom  = 0;
specZoom = 0;

%--- consistency checks ---
if minPpm>maxPpm
    fprintf('%s -> minPpm > maxPpm. Program aborted.\n\n',FCTNAME);
    return
end
if ~SP2_Check4ColVec(datSpec)
    return
end

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

%--- consistency check ---
if any(isnan(ppmZoom)) || any(isinf(ppmZoom))
    fprintf('\n%s ->\ninf/nan detected for ppmZoom. Program aborted.\n\n',FCTNAME);
    return
end
if any(isnan(specZoom)) || any(isinf(specZoom))
    fprintf('\n%s ->\ninf/nan detected for specZoom. Program aborted.\n\n',FCTNAME);
    return
end

%--- update success flag ---
f_succ = 1;

end
