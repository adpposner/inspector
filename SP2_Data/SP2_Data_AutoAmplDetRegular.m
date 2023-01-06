%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [amplMat,f_succ] = SP2_Data_AutoAmplDetRegular(datSpec,refSpec,refVec,titleStr,varargin)
%% 
%%  Automated determination of optimal amplitude correction for the
%%  alignment of spectra with a reference.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_AutoAmplDetRegular';


%--- init success flag ---
f_succ = 0;

%--- verbose handling ---
f_show = 0;     % default: no figure display
if nargin==5    % verbose flag
    f_show = SP2_Check4FlagR( varargin{1} );
elseif nargin~=3
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin);
    return
end

%--- data formating ---
nrEff   = size(datSpec,3);               % effective nr, STEAM: nrEff=data.spec1.nr, JDE: nrEff=data.spec1.nr/2

%--- extraction of spectral range ---
[minI,maxI,ppmZoom,refSpecZoom,f_done] = SP2_Data_ExtractPpmRange(min(data.amAlignPpmMin),max(data.amAlignPpmMax),...
                                                                  data.ppmCalib,data.spec1.sw,abs(refSpec));
                               
%--- frequency extraction ---                                                              
datSpecZoom = abs(datSpec(minI:maxI,:,:));                         
                                           
%--- serial amplitude fitting ---
lb         = 0;
ub         = 5;
coeffStart = 1;

%--- least-squares fit ---
opt = optimset('Display','off');
for seriesCnt = 1:data.spec1.seriesN
    for nrCnt = 1:nrEff
        [amplMat(seriesCnt,nrCnt),resnorm,resid,exitflag,output] = ...
            lsqcurvefit('SP2_Data_AmplScaleOptFct',coeffStart,datSpecZoom(:,seriesCnt,nrCnt),refSpecZoom,lb,ub,opt);
    end
end
                                   
%--- display result ---
if f_show
    %--- extraction of spectral range ---
    [minI,maxI,ppmZoomDisplay,refSpecZoomDisplay,f_done] = SP2_Data_ExtractPpmRange(min(data.amAlignPpmMin)-0.1,max(data.amAlignPpmMax)+0.1,...
                                                                      data.ppmCalib,data.spec1.sw,abs(refSpec));
    %--- frequency extraction ---                                                              
    datSpecZoomDisplay = abs(datSpec(minI:maxI,:,:));    
        
    autoAmplFh = figure('IntegerHandle','off');
    if ~isempty(titleStr)
        if flag.amAlignExtraWin
            set(autoAmplFh,'NumberTitle','off','Name',sprintf(' Automated Amplitude Alignment: %s',titleStr),...
                'Position',[278 20 750 900],'Color',[1 1 1]);
        else
            set(autoAmplFh,'NumberTitle','off','Name',sprintf(' Automated Amplitude Alignment: %s',titleStr),...
                'Position',[278 20 750 800],'Color',[1 1 1]);
        end
    else
        if flag.amAlignExtraWin
            set(autoAmplFh,'NumberTitle','off','Name',sprintf(' Automated Amplitude Alignment'),...
                'Position',[278 20 750 900],'Color',[1 1 1]);
        else
            set(autoAmplFh,'NumberTitle','off','Name',sprintf(' Automated Amplitude Alignment'),...
                'Position',[278 20 750 800],'Color',[1 1 1]);
        end
    end
        
    %--- spectrum superposition: before, extra window ---
    if flag.amAlignExtraWin
        %--- extraction of spectral range ---
        [minI,maxI,ppmZoomExtra,refSpecZoomExtra,f_done] = SP2_Data_ExtractPpmRange(data.amAlignExtraPpm(1),data.amAlignExtraPpm(2),...
                                                                          data.ppmCalib,data.spec1.sw,abs(refSpec));
        if ~f_done
            fprintf('\n%s ->\nFrequency window extraction failed (%.2f-%.2f ppm). Program aborted.\n',...
                    data.amAlignExtraPpm(1),data.amAlignExtraPpm(2))
            return
        end
    
        %--- frequency extraction ---                                                              
        datSpecZoomExtra = abs(datSpec(minI:maxI,:,:));    
        
        subplot(5,1,1)
        hold on
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:nrEff
                plot(ppmZoomExtra,datSpecZoomExtra(:,seriesCnt,nrCnt));
            end
        end
        [minSpecXextra,maxSpecXextra,minYtmp,maxYtmp] = SP2_IdealAxisValues(ppmZoomExtra,datSpecZoomExtra(:,1,1));
        minSpecVal = min(min(min(datSpecZoomExtra)));
        maxSpecVal = max(max(max(datSpecZoomExtra)));
        minSpecYextra = minSpecVal-0.05*(maxSpecVal-minSpecVal);
        maxSpecYextra = maxSpecVal+0.05*(maxSpecVal-minSpecVal);
        for winCnt = 1:data.amAlignPpmN
            plot([data.amAlignPpmMin(winCnt) data.amAlignPpmMin(winCnt)],[minSpecYextra maxSpecYextra],'Color',[1 0.25 1])
            plot([data.amAlignPpmMax(winCnt) data.amAlignPpmMax(winCnt)],[minSpecYextra maxSpecYextra],'Color',[1 0.25 1])
        end
        plot(ppmZoomExtra,refSpecZoomExtra,'g');
        axis([minSpecXextra maxSpecXextra minSpecYextra maxSpecYextra])
        hold off
        ylabel('Amplitude [a.u.]')
        xlabel('Frequency [ppm]')
        set(gca,'XDir','reverse')
    end
        
    %--- spectrum superposition: before, zoomed ---
    if flag.amAlignExtraWin
        subplot(5,1,2)
    else
        subplot(3,1,1)
    end
    hold on
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:nrEff
            plot(ppmZoomDisplay,datSpecZoomDisplay(:,seriesCnt,nrCnt));
        end
    end
    [minSpecX,maxSpecX,minYtmp,maxYtmp] = SP2_IdealAxisValues(ppmZoomDisplay,datSpecZoomDisplay(:,1,1));
    minSpecVal = min(min(min(datSpecZoomDisplay)));
    maxSpecVal = max(max(max(datSpecZoomDisplay)));
    minSpecY = minSpecVal-0.05*(maxSpecVal-minSpecVal);
    maxSpecY = maxSpecVal+0.05*(maxSpecVal-minSpecVal);
    for winCnt = 1:data.amAlignPpmN
        plot([data.amAlignPpmMin(winCnt) data.amAlignPpmMin(winCnt)],[minSpecY maxSpecY],'Color',[1 0.25 1])
        plot([data.amAlignPpmMax(winCnt) data.amAlignPpmMax(winCnt)],[minSpecY maxSpecY],'Color',[1 0.25 1])
    end
    plot(ppmZoomDisplay,refSpecZoomDisplay,'g');
    axis([minSpecX maxSpecX minSpecY maxSpecY])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')

    %--- spectrum superposition: before ---
    if flag.amAlignExtraWin
        subplot(5,1,3)
    else
        subplot(3,1,2)
    end
    % reshuffled to serial/chronological order 1st series, 2nd series, ...
    amplVec = reshape(permute(amplMat,[2 1]),1,data.spec1.seriesN*nrEff);
    hold on
    plot(1:data.spec1.seriesN*nrEff,amplVec,'*')
    if any(refVec)              % reference is part of this series
        for refCnt = 1:length(refVec)
            plot(refVec(refCnt),amplVec(refVec(refCnt)),'ro')
        end
    else
        fprintf('Note: Amplitude reference for <%s> condition is not part of the series\n',titleStr);
    end
    [minX,maxX,minY,maxY] = SP2_IdealAxisValuesXGap(1:data.spec1.seriesN*nrEff,amplVec);
    plot([minX maxX],[1 1],'Color',[1 0.25 1])
    for seriesCnt = 1:data.spec1.seriesN-1
        plot([1 1]*seriesCnt*nrEff+0.5,[minY maxY],'Color',[1 0.25 1])
    end
    axis([minX maxX minY maxY])
    hold off
    ylabel('Applied Scaling [1]')
    xlabel('Repetition [1]')
    
    %--- spectrum superposition: after, extra window ---
    if flag.amAlignExtraWin
        subplot(5,1,4)
        hold on
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:nrEff
                plot(ppmZoomExtra,amplMat(seriesCnt,nrCnt)*datSpecZoomExtra(:,seriesCnt,nrCnt));
            end
        end 
        for winCnt = 1:data.amAlignPpmN
            plot([data.amAlignPpmMin(winCnt) data.amAlignPpmMin(winCnt)],[minSpecYextra maxSpecYextra],'Color',[1 0.25 1])
            plot([data.amAlignPpmMax(winCnt) data.amAlignPpmMax(winCnt)],[minSpecYextra maxSpecYextra],'Color',[1 0.25 1])
        end
        plot(ppmZoomExtra,refSpecZoomExtra,'g');
        axis([minSpecXextra maxSpecXextra minSpecYextra maxSpecYextra])
        hold off
        ylabel('Amplitude [a.u.]')
        xlabel('Frequency [ppm]')
        set(gca,'XDir','reverse')
    end
    
    %--- spectrum superposition: after, zoomed ---
    if flag.amAlignExtraWin
        subplot(5,1,5)
    else
        subplot(3,1,3)
    end
    hold on
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:nrEff
            plot(ppmZoomDisplay,amplMat(seriesCnt,nrCnt)*datSpecZoomDisplay(:,seriesCnt,nrCnt));
        end
    end 
    for winCnt = 1:data.amAlignPpmN
        plot([data.amAlignPpmMin(winCnt) data.amAlignPpmMin(winCnt)],[minSpecY maxSpecY],'Color',[1 0.25 1])
        plot([data.amAlignPpmMax(winCnt) data.amAlignPpmMax(winCnt)],[minSpecY maxSpecY],'Color',[1 0.25 1])
    end
    plot(ppmZoomDisplay,refSpecZoomDisplay,'g');
    axis([minSpecX maxSpecX minSpecY maxSpecY])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
end

%--- update success flag ---
f_succ = 1;

end
