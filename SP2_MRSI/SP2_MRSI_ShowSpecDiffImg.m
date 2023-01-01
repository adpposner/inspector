%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowSpecDiffImg( f_new )
%%
%% Plot spectral matrix.
%%
%% 04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ShowSpecDiffImg';

%--- check data existence ---
if ~isfield(mrsi.diff,'specimg')
    fprintf('%s -> Spectral matrix not found. Load data first.\n',FCTNAME)
    return
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.diff.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.diff.sw/2  + mrsi.ppmCalib;
end

%--- spectral indexing ---
[minI,maxI,ppmZoom,diffZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                mrsi.diff.sw,mrsi.diff.specimg(:,1,1));
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- quick-and-dirty fix of 180deg display discrepancy ---
mrsiSpec1Specimg = exp(-1i*pi) * mrsi.diff.specimg;

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    specimg = real(mrsiSpec1Specimg(minI:maxI,:,:));
elseif flag.mrsiFormat==2       % imaginary part
    specimg = imag(mrsiSpec1Specimg(minI:maxI,:,:));
elseif flag.mrsiFormat==3       % magnitude
    specimg = abs(mrsiSpec1Specimg(minI:maxI,:,:));
else                            % phase
    specimg = angle(mrsi.diff.specimg(minI:maxI,:,:));
end                                             
specImgSize = size(specimg);
minVal = min(min(min(specimg)));
maxVal = max(max(max(specimg)));
%--- info printout ---
if f_new
    fprintf('Global min/max amplitudes: %f/%f\n',minVal,maxVal)
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpecDiffImg') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpecDiffImg)
        delete(mrsi.fhSpecDiffImg)
    end
    mrsi = rmfield(mrsi,'fhSpecDiffImg');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpecDiffImg') || ~ishandle(mrsi.fhSpecDiffImg)
    mrsi.fhSpecDiffImg = figure('IntegerHandle','off');
    set(mrsi.fhSpecDiffImg,'NumberTitle','off','Name',sprintf(' Spectral Image: Difference'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpecDiffImg)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpecDiffImg)
            return
        end
    end
end
clf(mrsi.fhSpecDiffImg)

%--- data visualization: on subplot per row of spectra ---
specimg = flipdim(specimg,1);       % invert spectral axis (similar to 'XDir','reverse')
for pCnt = 1:mrsi.diff.nEncP
    subplot(mrsi.diff.nEncR,1,mrsi.diff.nEncP-pCnt+1)
    %--- data display ---
    rowOfSpec = reshape(specimg(:,:,pCnt),1,specImgSize(1)*specImgSize(3));
    plot(1:length(rowOfSpec),rowOfSpec)
    set(gca,'XTick',[],'YTick',[],'box','off');

    %--- plot axis handling ---
    if pCnt==1
        [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(1:length(rowOfSpec),rowOfSpec);
        if flag.mrsiAmpl        % direct
            plotLim(3) = mrsi.amplMin;
            plotLim(4) = mrsi.amplMax;
        else                    % automatic
            plotLim(3) = minVal - (maxVal-minVal)/20;
            plotLim(4) = maxVal + (maxVal-minVal)/20;

            %--- info printout ---
            if f_new
                fprintf('Amplitude plot limits %s\n',SP2_Vec2PrintStr(plotLim(3:4),0))
            end
        end
    end

    
%     %--- vertical (ppm) line ---
%     if flag.mrsiPpmShowPos
%         hold on
%         plot([mrsi.ppmShowPos mrsi.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
%         if flag.mrsiPpmShowPosMirr
%             plot([mrsi.ppmShowPosMirr mrsi.ppmShowPosMirr],[plotLim(3) plotLim(4)],'Color',[0 0 0])
%         end
%         hold off
%     end
    
    %--- vertical lines for spectrum separation ---
    flag.mrsiShowSpecGrid = 1;
    if flag.mrsiShowSpecGrid
        hold on
        for rCnt = 1:mrsi.diff.nEncR
            if (isfield(mrsi,'fhSpec1') || isfield(mrsi,'fhFid1') || isfield(mrsi,'fhFid1Orig')) && ...
               (mrsi.selectLR==rCnt || mrsi.selectLR==rCnt-1) && mrsi.selectPA==pCnt
                plot([0.5+(rCnt-1)*specImgSize(1) 0.5+(rCnt-1)*specImgSize(1)],[plotLim(3) plotLim(4)],'Color',[1 0 0])
            else
                plot([0.5+(rCnt-1)*specImgSize(1) 0.5+(rCnt-1)*specImgSize(1)],[plotLim(3) plotLim(4)],'Color',[0 0 0])
            end
        end
        hold off
    end
    axis(plotLim)
    if pCnt==1
        xlabel('P')
    end
    if pCnt==round(mrsi.diff.nEncP/2)
        ylabel('L')
    end
end




