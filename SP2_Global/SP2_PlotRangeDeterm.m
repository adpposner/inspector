function SP2_PlotRangeDeterm(datArray)

% function valLims = FMx_PlotRangeDeterm(datArray)
% determination of plot range minimum/maximum values [min max]
% 01-2007, Christoph Juchem
%

global fm pars flag
FCTNAME = 'SP2_PlotRangeDeterm';


if ~SP2_Check4Num(datArray)
    return
end
datSize = size(datArray);

%--- determine global linear expression for correct color (re)scaling ([min max] <-> [0 1]) ---
minVal = min(min(min(min(datArray))));
maxVal = max(max(max(max(datArray))));
% y = mx + b
pars.colScaleB = minVal                     % y-intersection b
pars.colScaleM = maxVal - minVal;           % slope m: (max-min)/(1-0);

%--- calculation for consistent scaling ---
if length(datSize)==3
    sliceMaxVal = max(max(datArray(:,:,exm.slice)));
    sliceMinVal = min(min(datArray(:,:,exm.slice)));
    sliceMedVal = median(reshape(datArray(:,:,exm.slice),1,datSize(1)*datSize(2)));
    globMaxVal  = max(max(max(datArray)));
    globMinVal  = min(min(min(datArray)));
else
    sliceMaxVal = max(max(max(datArray(:,:,exm.slice,:))));
    sliceMinVal = min(min(min(datArray(:,:,exm.slice,:))));
    sliceMedVal = median(reshape(datArray(:,:,exm.slice,:),1,datSize(1)*datSize(2)*datSize(4)));
    globMaxVal  = max(max(max(max(datArray))));
    globMinVal  = min(min(min(min(datArray))));
end

%--- determination of color and plotting limits (colLims, valLims) ---
% the color limits mean the actual plotting range, the value limits give
% the color limits in terms of the [0 1] range of the RGB images
if flag.plotRange==1            % automatic search for 'reasonable' slice data range limits (median +/- 20% of max.difference)
    pars.colLims(1) = sliceMedVal - 0.2*(sliceMaxVal-sliceMinVal);
    pars.colLims(2) = sliceMedVal + 0.2*(sliceMaxVal-sliceMinVal);
    initStr   = 'automatic';
elseif flag.plotRange==2        % full data range of particular slice
    pars.colLims(1) = globMinVal;
    pars.colLims(2) = globMaxVal;
    initStr   = 'global';
elseif flag.plotRange==3        % full data range of all slices
    pars.colLims(1) = sliceMinVal;
    pars.colLims(2) = sliceMaxVal;
    initStr   = 'slice';
else    % manual
    pars.colLims(1) = pars.plotRgManMin;
    pars.colLims(2) = pars.plotRgManMax;
    initStr   = 'manual';
end
fprintf('%s -> %s color scaling: %.2f to %.2f\n',FCTNAME,initStr,pars.colLims(1),pars.colLims(2));
pars.valLims(1) = (pars.colLims(1) - pars.colScaleB) / pars.colScaleM;      % [0 1] range
pars.valLims(2) = (pars.colLims(2) - pars.colScaleB) / pars.colScaleM;      % [0 1] range


end
