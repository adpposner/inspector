%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [rgbImage, f_succ] = SP2_TransferGray2RGB(grayImage,varargin)
%
%% function imgRGB = SP2_TransferGray2RGB(imgGray,varargin)
%% converts gray scale data arrays to true RGB color format
%% (the color is preserved!)
%% 
%% Christoph Juchem, 02-2007
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag exm syn pass impt ana reg pars

FCTNAME = 'SP2_TransferGray2RGB';


%--- init success flag ---
f_succ   = 0;
rgbImage = 0;       % init

%--- data check ---
if ~SP2_Check4Num(grayImage)
    return
end
graySize = size(grayImage);
grayDim  = length(graySize);

%--- explicite slice assignment ---
if nargin==2
    slice = SP2_Check4IntBigger0R(varargin{1});
else
    if flag.fmWin==1 || flag.fmWin==2 || flag.fmWin==3
        slice   = exm.slice;
        nSlices = exm.nSlices;
    elseif flag.fmWin==4
        slice   = syn.slice;
        nSlices = syn.nSlices;
    elseif flag.fmWin==5
        slice   = pass.slice;
        nSlices = pass.nSlices;
    elseif flag.fmWin==7
        slice   = impt.slice;
        nSlices = impt.nSlices;
    elseif flag.fmWin==8
        slice   = ana.slice;
        nSlices = ana.nSlices;
    elseif flag.fmWin==9 || flag.fmWin==10        % regional and/or optimization
        slice   = reg.slice;
        nSlices = reg.nSlices;
    else
        fprintf('%s -> flag.fmWin=%i not supported',FCTNAME,flag.fmWin)
        return
    end
end

%--- consistency check ---
if grayDim>2    % update slice value
    if slice>nSlices
        slice = round(nSlices/2);  % set to random/center value
        fprintf('%s -> slice number exceeded data set dimensions, reset to %i\n',FCTNAME,slice)
    end
    if slice<1
        slice = 1;
        fprintf('%s -> slice number <1, reset to %i\n',FCTNAME,slice)
    end
end

%--- calculation for consistent scaling ---
if grayDim==2       % used for pattern superposition
    sliceMaxVal = max(max(grayImage));
    sliceMinVal = min(min(grayImage));
    sliceMedVal = median(reshape(grayImage,1,graySize(1)*graySize(2)));
    globMaxVal  = max(max(grayImage));      % fake/slice value
    globMinVal  = min(min(grayImage));      % fake/slice value
elseif grayDim==3
    if flag.plotOrient==1               % sagittal
        sliceMaxVal = max(max(grayImage(slice,:,:)));
        sliceMinVal = min(min(grayImage(slice,:,:)));
        sliceMedVal = median(reshape(grayImage(slice,:,:),1,graySize(2)*graySize(3)));
    elseif flag.plotOrient==2           % coronal
        sliceMaxVal = max(max(grayImage(:,slice,:)));
        sliceMinVal = min(min(grayImage(:,slice,:)));
        sliceMedVal = median(reshape(grayImage(:,slice,:),1,graySize(1)*graySize(3)));
    else                                % axial
        sliceMaxVal = max(max(grayImage(:,:,slice)));
        sliceMinVal = min(min(grayImage(:,:,slice)));
        sliceMedVal = median(reshape(grayImage(:,:,slice),1,graySize(1)*graySize(2)));
    end
    globMaxVal  = max(max(max(grayImage)));
    globMinVal  = min(min(min(grayImage)));
else
    if flag.plotOrient==1               % sagittal
        sliceMaxVal = max(max(max(grayImage(slice,:,:,:))));
        sliceMinVal = min(min(min(grayImage(slice,:,:,:))));
        sliceMedVal = median(reshape(grayImage(slice,:,:,:),1,graySize(2)*graySize(3)*graySize(4)));
    elseif flag.plotOrient==2           % coronal
        sliceMaxVal = max(max(max(grayImage(:,slice,:,:))));
        sliceMinVal = min(min(min(grayImage(:,slice,:,:))));
        sliceMedVal = median(reshape(grayImage(:,slice,:,:),1,graySize(1)*graySize(3)*graySize(4)));
    else                                % axial
        sliceMaxVal = max(max(max(grayImage(:,:,slice,:))));
        sliceMinVal = min(min(min(grayImage(:,:,slice,:))));
        sliceMedVal = median(reshape(grayImage(:,:,slice,:),1,graySize(1)*graySize(2)*graySize(4)));
    end
    globMaxVal  = max(max(max(max(grayImage))));
    globMinVal  = min(min(min(min(grayImage))));
end

%--- determination of color limits ---
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
pars.colLimCenter = mean(pars.colLims);
fprintf('%s -> %s color scaling: %.2f to %.2f, center %.2f\n',FCTNAME,initStr,pars.colLims(1),pars.colLims(2),pars.colLimCenter);

%--- perform data transformation (to [0..1] range) ---
grayImage = (grayImage-pars.colLims(1))/(pars.colLims(2)-pars.colLims(1));

%--- generation of (index matrix and) colormap ---
[indexImage,map] = gray2ind(grayImage,pars.nColors);
if grayDim==3
    rgbImage = zeros(graySize(1),graySize(2),graySize(3),3);
	% loop structure since ind2rgb is defined only for 2D matrices...
	jetColMat = jet(pars.nColors);
	for slCnt = 1:graySize(3)
        rgbImage(:,:,slCnt,:) = ind2rgb(indexImage(:,:,slCnt,:),jetColMat);         % use the same indexing to encode the color map
    end
else
    rgbImage         = zeros(graySize(1),graySize(2),graySize(3),graySize(4),3);
	% loop structure since ind2rgb is defined only for 2D matrices...
	jetColMat = jet(pars.nColors);
	for slCnt = 1:graySize(3)
        for teCnt = 1:graySize(4)
            rgbImage(:,:,slCnt,teCnt,:) = ind2rgb(indexImage(:,:,slCnt,teCnt,:),jetColMat);         % use the same indexing to encode the color map
        end
	end
end

%--- update success flag ---
f_succ = 1;


