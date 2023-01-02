function [imgResult, f_succ] = SP2_SetRGBcolor(imgRaw,newColor)

% function imgResult = setRGBcolor(imgRraw,newColor)
% the gray scale image imgRaw (which has to be of RGB format!) to a particular color 'newColor'.
% 'imgRaw' can be 2D or 3D images (+1 color dimension). 'newColor' is a 1x3 vector in RGB format
% e.g. [1 1 0] for yellow
% Christoph Juchem, 05-2004

FCTNAME = 'SetRGBcolor';


%--- init success flag ---
f_succ    = 0;
imgResult = 0;

%--- parameter handling ---
if ~SP2_Check4Num(imgRaw)
    return
end
rawSize = size(imgRaw);
rawDim = length(rawSize);
if rawDim<3 || rawDim>4
    fprintf('%s -> image matrix must be 2D+1 or 3D+1 but is %i-dimensional',FCTNAME,rawDim);
    return
end
if rawSize(rawDim)~=3
    fprintf('%s -> image can''t be of RGB format since the highest dimension is not 3',FCTNAME);
    return
end
if ~SP2_Check4RowVec(newColor)
    return
end
if min(newColor)<0 || max(newColor)>1
    fprintf('%s -> RGB values must be between 0 and 1',FCTNAME);
    return
end

if rawDim==3
    multMat = zeros(rawSize(1),rawSize(2),3);
    multMat(:,:,1) = newColor(1);
    multMat(:,:,2) = newColor(2);
    multMat(:,:,3) = newColor(3);
    imgResult = imgRaw .* multMat;
else
    multMat = zeros(rawSize(1),rawSize(2),rawSize(3),3);
    multMat(:,:,:,1) = newColor(1);
    multMat(:,:,:,2) = newColor(2);
    multMat(:,:,:,3) = newColor(3);
    imgResult = imgRaw .* multMat;
end

%--- update success flag ---
f_succ = 1;
