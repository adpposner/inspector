%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowFid2Img( f_new )
%%
%% Plot FID matrix.
%%
%% 04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ShowFid2Img';

%--- check data existence ---
if ~isfield(mrsi.spec2,'fidimg')
    fprintf('%s -> Spectral matrix not found. Load data first.\n',FCTNAME)
    return
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    fidimg = real(mrsi.spec2.fidimg);
elseif flag.mrsiFormat==2       % imaginary part
    fidimg = imag(mrsi.spec2.fidimg);
elseif flag.mrsiFormat==3       % magnitude
    fidimg = abs(mrsi.spec2.fidimg);
else                            % phase
    fidimg = angle(mrsi.spec2.fidimg);
end                                             
fidImgSize = size(fidimg);
minVal = min(min(min(fidimg)));
maxVal = max(max(max(fidimg)));
%--- info printout ---
if f_new
    fprintf('Global min/max amplitudes: %f/%f\n',minVal,maxVal)
end
    
%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid2Img') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid2Img)
        delete(mrsi.fhFid2Img)
    end
    mrsi = rmfield(mrsi,'fhFid2Img');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid2Img') || ~ishandle(mrsi.fhFid2Img)
    mrsi.fhFid2Img = figure('IntegerHandle','off');
    set(mrsi.fhFid2Img,'NumberTitle','off','Name',sprintf(' Spectral Matrix 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid2Img)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid2Img)
            return
        end
    end
end
clf(mrsi.fhFid2Img)

%--- data visualization: on subplot per row of spectra ---
for pCnt = 1:mrsi.spec2.nEncP
    subplot(mrsi.spec2.nEncR,1,mrsi.spec2.nEncP-pCnt+1)
    %--- data display ---
    rowOfFids = reshape(fidimg(:,:,pCnt),1,fidImgSize(1)*fidImgSize(3));
    plot(1:length(rowOfFids),rowOfFids)
    set(gca,'XTick',[],'YTick',[],'box','off');
   
    %--- plot axis handling ---
    if pCnt==1
        [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(1:length(rowOfFids),rowOfFids);
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
        for rCnt = 1:mrsi.spec2.nEncR
            if (isfield(mrsi,'fhSpec1') || isfield(mrsi,'fhFid1') || isfield(mrsi,'fhFid1Orig')) && ...
               (mrsi.selectLR==rCnt || mrsi.selectLR==rCnt-1) && mrsi.selectPA==pCnt
                plot([0.5+(rCnt-1)*fidImgSize(1) 0.5+(rCnt-1)*fidImgSize(1)],[plotLim(3) plotLim(4)],'Color',[1 0 0])
            else
                plot([0.5+(rCnt-1)*fidImgSize(1) 0.5+(rCnt-1)*fidImgSize(1)],[plotLim(3) plotLim(4)],'Color',[0 0 0])
            end
        end
        hold off
    end
    axis(plotLim)
    if pCnt==1
        xlabel('P')
    end
    if pCnt==round(mrsi.spec2.nEncP/2)
        ylabel('L')
    end
%     axis off
end



% %--- data visualization: one subplot per spectrum ---
% for rCnt = 1:mrsi.spec2.nEncR
%     for pCnt = 1:mrsi.spec2.nEncP
%         subplot(mrsi.spec2.nEncR,mrsi.spec2.nEncP,(rCnt-1)*mrsi.spec2.nEncR+pCnt)
%         %--- data display ---
%         plot(ppmZoom,fidimg(:,rCnt,pCnt))
%         set(gca,'XDir','reverse','XTick',[],'YTick',[]);
% 
%         %--- amplitude handling ---
%         if flag.mrsiAmpl        % direct
%             [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,fidimg(:,rCnt,pCnt));
%             plotLim(3) = mrsi.amplMin;
%             plotLim(4) = mrsi.amplMax;
%         else                    % automatic
%             [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,fidimg(:,rCnt,pCnt));
%         end
%         
%         %--- vertical (ppm) line ---
%         if flag.mrsiPpmShowPos
%             hold on
%             plot([mrsi.ppmShowPos mrsi.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
%             if flag.mrsiPpmShowPosMirr
%                 plot([mrsi.ppmShowPosMirr mrsi.ppmShowPosMirr],[plotLim(3) plotLim(4)],'Color',[0 0 0])
%             end
%             hold off
%         end
%         axis(plotLim)
%     end
% end


% %--- spectrum analysis ---
% if flag.mrsiAnaSNR || flag.mrsiAnaFWHM || flag.mrsiAnaIntegr
%     fprintf('ANALYSIS OF SPECTRUM 1\n')
%     if ~SP2_MRSI_Analysis(mrsi.spec2.spec,mrsi.spec2,plotLim,[flag.mrsiSpec1Lb flag.mrsiSpec1Gb])
%         return
%     end
% end

% %--- export handling ---
% mrsi.expt.fid    = ifft(ifftshift(mrsi.spec2.spec,1),[],1);
% mrsi.expt.sf     = mrsi.spec2.sf;
% mrsi.expt.sw_h   = mrsi.spec2.sw_h;
% mrsi.expt.nspecC = mrsi.spec2.nspecC;



