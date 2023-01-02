%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowSpec2Mrsi( f_new )
%%
%% Plot MRSI image based on (proper) spectral integration.
%%
%% 04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_ShowSpec2Mrsi';

%--- check data existence ---
if ~isfield(mrsi.spec2,'specimg')
    fprintf('%s -> No spectral matrix found. Load data first.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmTargetMin;
    ppmMax = mrsi.ppmTargetMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.spec2.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.spec2.sw/2  + mrsi.ppmCalib;
end

%--- spectral indexing ---
[minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                mrsi.spec2.sw,mrsi.spec2.specimg(:,1,1));
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    specimg   = real(mrsi.spec2.specimg(minI:maxI,:,:));
    formatStr = 'Real Part';
elseif flag.mrsiFormat==2       % imaginary part
    specimg   = imag(mrsi.spec2.specimg(minI:maxI,:,:));
    formatStr = 'Imaginary Part';
elseif flag.mrsiFormat==3       % magnitude
    specimg   = abs(mrsi.spec2.specimg(minI:maxI,:,:));
    formatStr = 'Magnitude';
else                            % phase
    specimg   = angle(mrsi.spec2.specimg(minI:maxI,:,:));
    formatStr = 'Phase';
end                                             
specImgSize = size(specimg);
minVal = min(min(min(specimg)));
maxVal = max(max(max(specimg)));
fprintf('global loggingfile min/max amplitudes: %f/%f\n',minVal,maxVal);

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpec2Mrsi') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpec2Mrsi)
        delete(mrsi.fhSpec2Mrsi)
    end
    mrsi = rmfield(mrsi,'fhSpec2Mrsi');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpec2Mrsi') || ~ishandle(mrsi.fhSpec2Mrsi)
    mrsi.fhSpec2Mrsi = figure('IntegerHandle','off');
    set(mrsi.fhSpec2Mrsi,'NumberTitle','off','Name',sprintf(' Spectral Matrix 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpec2Mrsi)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpec2Mrsi)
            return
        end
    end
end
clf(mrsi.fhSpec2Mrsi)

%--- data assignment ---
% mrsiImg = squeeze(max(abs(mrsi.spec2.specimg),[],1));
% mrsiImg = squeeze(mean(abs(mrsi.spec2.specimg(1:50,:,:)),1));
%--- integrate center 20% of the magnitude spectrum ---
mrsiImg = squeeze(sum(specimg,1));

%--- k-space visualization ---
nameStr = ' MR Spectroscopic Image: Data Set 2';
set(gcf,'NumberTitle','off','Name',nameStr);

set(gcf,'Position',[200 15 560 560]);
imagesc(rot90(mrsiImg))
title(sprintf('MRSI (%s)',formatStr))
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);

%--- vertical lines for spectrum separation ---
flag.mrsiShowSpecGrid = 1;
if flag.mrsiShowSpecGrid
    hold on
    plot([mrsi.selectLR-0.5 mrsi.selectLR+0.5],specImgSize(2)-[mrsi.selectPA-0.5 mrsi.selectPA-0.5]+1,'Color',[1 0 0])
    plot([mrsi.selectLR+0.5 mrsi.selectLR+0.5],specImgSize(2)-[mrsi.selectPA-0.5 mrsi.selectPA+0.5]+1,'Color',[1 0 0])
    plot([mrsi.selectLR+0.5 mrsi.selectLR-0.5],specImgSize(2)-[mrsi.selectPA+0.5 mrsi.selectPA+0.5]+1,'Color',[1 0 0])
    plot([mrsi.selectLR-0.5 mrsi.selectLR-0.5],specImgSize(2)-[mrsi.selectPA+0.5 mrsi.selectPA-0.5]+1,'Color',[1 0 0])
    hold off
end
xlabel('P')
ylabel('L')



