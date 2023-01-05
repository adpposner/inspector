%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowFidMrsi( f_new )
%%
%% Plot MRSI image based on integration of first FID points.
%%
%% 04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ShowFidMrsi';

%--- check data existence ---
if ~isfield(mrsi.spec1,'fidimg')
    fprintf('%s -> No FID matrix found. Load data first.\n',FCTNAME);
    return
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    specimg   = real(mrsi.spec1.fidimg);
    formatStr = 'Real Part';
elseif flag.mrsiFormat==2       % imaginary part
    fidimg   = imag(mrsi.spec1.fidimg);
    formatStr = 'Imaginary Part';
elseif flag.mrsiFormat==3       % magnitude
    fidimg   = abs(mrsi.spec1.fidimg);
    formatStr = 'Magnitude';
else                            % phase
    fidimg   = angle(mrsi.spec1.fidimg);
    formatStr = 'Phase';
end                                             
minVal = min(min(min(fidimg)));
maxVal = max(max(max(fidimg)));
fprintf('global min/max amplitudes: %f/%f\n',minVal,maxVal);

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid1Mrsi') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid1Mrsi)
        delete(mrsi.fhFid1Mrsi)
    end
    mrsi = rmfield(mrsi,'fhFid1Mrsi');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid1Mrsi') || ~ishandle(mrsi.fhFid1Mrsi)
    mrsi.fhFid1Mrsi = figure('IntegerHandle','off');
    set(mrsi.fhFid1Mrsi,'NumberTitle','off','Name',sprintf(' Spectral Matrix 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid1Mrsi)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid1Mrsi)
            return
        end
    end
end
clf(mrsi.fhFid1Mrsi)

%--- data assignment ---
% mrsiImg = squeeze(max(abs(mrsi.spec1.fidimg),[],1));
% mrsiImg = squeeze(mean(abs(mrsi.spec1.fidimg(1:50,:,:)),1));
%--- integrate center 20% of the magnitude spectrum ---
mrsiImg = squeeze(sum(fidimg,1));

%--- k-space visualization ---
nameStr = ' (Basic) FID MRSI';
set(gcf,'NumberTitle','off','Name',nameStr);

set(gcf,'Position',[200 15 560 560]);
imagesc(rot90(mrsiImg))
title(sprintf('%s',formatStr))
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);
