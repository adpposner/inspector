%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotSpec2Array( f_new )
%%
%%  Plot superposition of raw spectra from data set 2.
%% 
%%  07-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotSpec2Array';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec2,'fid')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end
if any(data.select>data.spec2.nr) && ~flag.dataAllSelect
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.select),data.spec2.nr)
    return
end
if max(data.rcvrInd)>data.spec2.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds experiment dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec2.nRcvrs)
    return
end

%--- repetition selection ---
if flag.dataAllSelect       % all repetitions
    dataSelectN = data.spec2.nr;
    dataSelect  = 1:data.spec2.nr;
else                        % selected repeitions
    dataSelectN = data.selectN;
    dataSelect  = data.select;
end

%--- check consistency of data dimension and display selection ---
fidSize = size(data.spec2.fid);
if length(fidSize)==2
    if any(fidSize(2)<data.rcvrInd)
        fprintf('FID 2 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet).\n\n');
        return
    end
end
if length(fidSize)==3
    if any(fidSize(2)<data.rcvrInd)
        fprintf('FID 2 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet)\n\n');
        return
    end
    if any(fidSize(3)<dataSelect)
        fprintf('FID 2 data size does not allow selected NR display\n(Hint: Make sure repetitions haven''t been combined yet)\n\n');
        return
    end
end

%--- check maximal array size ---
if dataSelectN*data.rcvrN>data.plotArrMaxElem
    fprintf('\n*** WARNING ***\n');
    fprintf('Figure update of Spec 2 array has been temporarily disabled\nsince requested array size has become unreasonable (%.0f>%.0f).\n\n',...
            dataSelectN*data.rcvrN,data.plotArrMaxElem);
    return
end

%--- ppm limit handling ---
if flag.dataPpmShow     % direct
    ppmMin = data.ppmShowMin;
    ppmMax = data.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -data.spec2.sw/2 + data.ppmCalib;
    ppmMax = data.spec2.sw/2  + data.ppmCalib;
end

%--- figure handling ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhSpec2Array')
    if ishandle(data.fhSpec2Array)
        delete(data.fhSpec2Array)
    end
    data = rmfield(data,'fhSpec2Array');
end
% create figure if necessary
if ~isfield(data,'fhSpec2Array') || ~ishandle(data.fhSpec2Array)
    data.fhSpec2Array = figure('IntegerHandle','off');
    set(data.fhSpec2Array,'NumberTitle','off','Name',sprintf(' Spectrum 2: Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhSpec2Array)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhSpec2Array)
            return
        end
    end
end
clf(data.fhSpec2Array)

%--- receiver and repetition loops ---
flag.dataRcvrArraySum = 0;          % add summation row
maxVec = zeros(1,dataSelectN);      % init vector for maximum analysis (either individual or from Rx sum)
if data.rcvrN>1 && flag.dataRcvrArraySum
    if dataSelectN<11                       % show spectra individually
        %--- individual receivers ---
        for rcvrCnt = 1:data.rcvrN          % number of selected receivers
            for repCnt = 1:dataSelectN      % number of selected spectra
                %--- data processing ---
                if data.spec2.dim==2    % 2D (1 spectral + 1 receiver)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                else                    % 3D (1 spectral + 1 receiver + 1 repetition)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                end

                %--- data extraction: spectrum 1 ---
                if flag.dataFormat==1           % real part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,real(datSpec));
                elseif flag.dataFormat==2       % imaginary part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,imag(datSpec));
                elseif flag.dataFormat==3       % magnitude
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,abs(datSpec));
                else                            % phase
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,angle(datSpec));
                end                                             
                if ~f_done
                    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
                    return
                end          
                
                %--- data visualization ---
                subplot(data.rcvrN+1,dataSelectN,(rcvrCnt-1)*dataSelectN+repCnt)
                plot(ppmZoom,specZoom)
                set(gca,'XDir','reverse')
                if flag.dataAmpl        % direct
                    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
                    minY = data.amplMin;
                    maxY = data.amplMax;
                else                    % automatic
                    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
                end
                axis([minX maxX minY maxY])

                %--- data/axis labels ---
                if repCnt==1
                    if flag.dataFormat<4
                        if data.rcvrN>10
                            ylabel(sprintf('Rx%.0f\n[a.u.]',data.rcvrInd(rcvrCnt)))
                        elseif data.rcvrN>5
                            ylabel(sprintf('Rcvr %.0f\n\nAmpl. [a.u.]',data.rcvrInd(rcvrCnt)))
                        else
                            ylabel(sprintf('Receiver %.0f\n\nAmpl [a.u.]',data.rcvrInd(rcvrCnt)))
                        end
                    else
                        if data.rcvrN>10
                            ylabel(sprintf('Rx%.0f\n[rad]',data.rcvrInd(rcvrCnt)))
                        elseif data.rcvrN>5
                            ylabel(sprintf('Rcvr %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                        else
                            ylabel(sprintf('Receiver %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                        end
                    end
                end
                if data.rcvrN>5 && rcvrCnt~=data.rcvrN
                    set(gca,'XTickLabel',[])
                end
                if rcvrCnt==1
                    if dataSelectN<10
                        title(sprintf('Repetition %.0f',dataSelect(repCnt)))
                    else
                        title(sprintf('Rep. %.0f',dataSelect(repCnt)))
                    end
                end
            end         % of repetition loop
        end             % of receivers loop
        
        %--- sum of receivers: FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            if flag.dataRcvrWeight      % weighted summation
                if length(size(data.spec2.fid))==3
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
                else
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
                end
                weightVec    = weightVec/sum(weightVec);
                weightMat    = repmat(weightVec,[data.spec2.nspecC 1 data.spec2.nr]);
                dataspec2Fid = squeeze(sum(data.spec2.fid(:,data.rcvrInd,:).*weightMat,2));
                % data.spec2.fid = mean(mean(data.spec2.fid(:,data.rcvrInd,:).*weightMat,3),2);
            else
                dataspec2Fid = squeeze(mean(data.spec2.fid(:,data.rcvrInd,:),2));
                % data.spec2.fid = mean(mean(data.spec2.fid(:,data.rcvrInd,:),3),2);
            end
        else                            % selected FID range
            if flag.dataRcvrWeight      % weighted summation
                if ~isfield(data.spec2,'fid')
                    fprintf('%s ->\nSpectrum 2 does not exist. Weighted summation is not possible.\n',FCTNAME);
                    return
                end
                if length(size(data.spec2.fid))==3
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
                else
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
                end
                weightVec    = weightVec/sum(weightVec);
                weightMat    = repmat(weightVec,[data.spec2.nspecC 1 length(data.select)]);
                dataspec2Fid = squeeze(sum(data.spec2.fid(:,data.rcvrInd,data.select).*weightMat,2));
                % data.spec2.fid = mean(mean(data.spec2.fid(:,data.rcvrInd,data.select).*weightMat,3),2);
            else
                dataspec2Fid = squeeze(mean(data.spec2.fid(:,data.rcvrInd,data.select),2));
                % data.spec2.fid = mean(mean(data.spec2.fid(:,data.rcvrInd,data.select),3),2);
            end
        end
        
        %--- sum of receivers: summation display ---
        for repCnt = 1:dataSelectN      % number of selected spectra
            %--- data processing ---
            if data.spec2.nspecC<data.fidCut        % no apodization
                datSpec = fftshift(fft(dataspec2Fid(:,repCnt),data.fidZf));
            else                                    % apodization
                datSpec = fftshift(fft(dataspec2Fid(1:data.fidCut,repCnt),data.fidZf));
            end

            %--- data extraction: spectrum 1 ---
            if flag.dataFormat==1           % real part
                [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec2.sw,real(datSpec));
            elseif flag.dataFormat==2       % imaginary part
                [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec2.sw,imag(datSpec));
            elseif flag.dataFormat==3       % magnitude
                [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec2.sw,abs(datSpec));
            else                            % phase
                [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec2.sw,angle(datSpec));
            end                                             
            if ~f_done
                fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
                return
            end          
            
            %--- maximum evaluation ---
            maxVec(repCnt) = max(specZoom);

            %--- data visualization ---
            subplot(data.rcvrN+1,dataSelectN,data.rcvrN*dataSelectN+repCnt)
            plot(ppmZoom,specZoom)
            set(gca,'XDir','reverse')
            if flag.dataAmpl        % direct
                [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
                minY = data.amplMin;
                maxY = data.amplMax;
            else                    % automatic
                [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
            end
            axis([minX maxX minY maxY])

            %--- data/axis labels ---
            if repCnt==1
                if flag.dataFormat<4
                    if data.rcvrN>10
                        ylabel(sprintf('Rx Mean\n[a.u.]'))
                    elseif data.rcvrN>5
                        ylabel(sprintf('Rcvr Mean\n\nAmpl. [a.u.]'))
                    else
                        ylabel(sprintf('Receiver Mean\n\nAmpl [a.u.]'))
                    end
                else
                    if data.rcvrN>10
                        ylabel(sprintf('Rx Mean\n[rad]'))
                    elseif data.rcvrN>5
                        ylabel(sprintf('Rcvr Mean\n\nAngle [rad]'))
                    else
                        ylabel(sprintf('Receiver Mean\n\nAngle [rad]'))
                    end
                end
            end
            if rcvrCnt==1
                if dataSelectN<10
                    title(sprintf('Repetition %.0f',dataSelect(repCnt)))
                else
                    title(sprintf('Rep. %.0f',dataSelect(repCnt)))
                end
            end
            if data.rcvrN>5 && rcvrCnt~=data.rcvrN
                set(gca,'XTickLabel',[])
            end
            if rcvrCnt==data.rcvrN
                xlabel('Frequency [ppm]')
            end
        end             % of sum of receivers
    else                                     % merge spectral display
        for rcvrCnt = 1:data.rcvrN           % number of selected receivers
            for repCnt = 1:dataSelectN       % number of selected spectra
                %--- data processing ---
                if data.spec2.dim==2    % 2D (1 spectral + 1 receiver)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt))));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt))));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                else                    % 3D (1 spectral + 1 receiver + 1 repetition)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt),dataSelect(repCnt))));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),dataSelect(repCnt))));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                end

                %--- data extraction: spectrum 1 ---
                if flag.dataFormat==1           % real part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,real(datSpec));
                elseif flag.dataFormat==2       % imaginary part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,imag(datSpec));
                elseif flag.dataFormat==3       % magnitude
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,abs(datSpec));
                else                            % phase
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,angle(datSpec));
                end                                             
                if ~f_done
                    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
                    return
                end

                %--- spectrum concatenation ---
                if repCnt==1
                    specComb = flipdim(specZoom,1);
                else
                    specComb = [specComb; flipdim(specZoom,1)];
                end
            end

            %--- data visualization ---
            subplot(data.rcvrN,1,rcvrCnt)
            nrComb = 0.5:dataSelectN/(length(specComb)-1):(dataSelectN+0.5);
            plot(nrComb,specComb)
            if flag.dataAmpl        % direct
                [minX maxX fake1 fake2] = SP2_IdealAxisValues(nrComb,specComb);
                minY = data.amplMin;
                maxY = data.amplMax;
            else                    % automatic
                [minX maxX minY maxY] = SP2_IdealAxisValues(nrComb,specComb);
            end
            axis([minX maxX minY maxY])

            %--- data/axis labels ---
            if flag.dataFormat<4
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[a.u.]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAmpl. [a.u.]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAmpl [a.u.]',data.rcvrInd(rcvrCnt)))
                end
            else
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[rad]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                end
            end
            if data.rcvrN>5 && rcvrCnt~=data.rcvrN
                set(gca,'XTickLabel',[])
            end
            if rcvrCnt==data.rcvrN
                xlabel('Repetition')
            end
        end
    end
else                % do not add summation row
    if dataSelectN<11                       % show spectra individually
        for rcvrCnt = 1:data.rcvrN          % number of selected receivers
            for repCnt = 1:dataSelectN      % number of selected spectra
                %--- data processing ---
                if data.spec2.dim==2    % 2D (1 spectral + 1 receiver)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                else                    % 3D (1 spectral + 1 receiver + 1 repetition)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                end

                %--- data extraction: spectrum 1 ---
                if flag.dataFormat==1           % real part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,real(datSpec));
                elseif flag.dataFormat==2       % imaginary part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,imag(datSpec));
                elseif flag.dataFormat==3       % magnitude
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,abs(datSpec));
                else                            % phase
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,angle(datSpec));
                end                                             
                if ~f_done
                    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
                    return
                end
                
                %--- maximum evaluation ---
                maxVec(repCnt) = max(specZoom);

                %--- data visualization ---
                subplot(data.rcvrN,dataSelectN,(rcvrCnt-1)*dataSelectN+repCnt)
                plot(ppmZoom,specZoom)
                set(gca,'XDir','reverse')
                if flag.dataAmpl        % direct
                    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
                    minY = data.amplMin;
                    maxY = data.amplMax;
                else                    % automatic
                    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
                end
                axis([minX maxX minY maxY])

                %--- data/axis labels ---
                if repCnt==1
                    if flag.dataFormat<4
                        if data.rcvrN>10
                            ylabel(sprintf('Rx%.0f\n[a.u.]',data.rcvrInd(rcvrCnt)))
                        elseif data.rcvrN>5
                            ylabel(sprintf('Rcvr %.0f\n\nAmpl. [a.u.]',data.rcvrInd(rcvrCnt)))
                        else
                            ylabel(sprintf('Receiver %.0f\n\nAmpl [a.u.]',data.rcvrInd(rcvrCnt)))
                        end
                    else
                        if data.rcvrN>10
                            ylabel(sprintf('Rx%.0f\n[rad]',data.rcvrInd(rcvrCnt)))
                        elseif data.rcvrN>5
                            ylabel(sprintf('Rcvr %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                        else
                            ylabel(sprintf('Receiver %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                        end
                    end
                end
                if rcvrCnt==1
                    if dataSelectN<10
                        title(sprintf('Repetition %.0f',dataSelect(repCnt)))
                    else
                        title(sprintf('Rep. %.0f',dataSelect(repCnt)))
                    end
                end
                if data.rcvrN>5 && rcvrCnt~=data.rcvrN
                    set(gca,'XTickLabel',[])
                end
                if rcvrCnt==data.rcvrN
                    xlabel('Frequency [ppm]')
                end
            end
        end
    else                                     % merge spectral display
        for rcvrCnt = 1:data.rcvrN           % number of selected receivers
            for repCnt = 1:dataSelectN       % number of selected spectra
                %--- data processing ---
                if data.spec2.dim==2    % 2D (1 spectral + 1 receiver)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 2 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                else                    % 3D (1 spectral + 1 receiver + 1 repetition)
                    if data.spec2.nspecC<data.fidCut        % no apodization
                        datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                    else                                    % apodization
                        datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),dataSelect(repCnt)),data.fidZf));
                        if rcvrCnt==1 && repCnt==1
%                             fprintf('%s ->\nApodization of FID 2 to %.0f points applied.\n',FCTNAME,data.fidCut);
                        end
                    end
                end

                %--- data extraction: spectrum 2 ---
                if flag.dataFormat==1           % real part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,real(datSpec));
                elseif flag.dataFormat==2       % imaginary part
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,imag(datSpec));
                elseif flag.dataFormat==3       % magnitude
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,abs(datSpec));
                else                            % phase
                    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                               data.spec2.sw,angle(datSpec));
                end                                             
                if ~f_done
                    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
                    return
                end

                %--- maximum evaluation ---
                maxVec(repCnt) = max(specZoom);

                %--- spectrum concatenation ---
                if repCnt==1
                    specComb = flipdim(specZoom,1);
                else
                    specComb = [specComb; flipdim(specZoom,1)];
                end
            end

            %--- data visualization ---
            subplot(data.rcvrN,1,rcvrCnt)
            nrComb = 0.5:dataSelectN/(length(specComb)-1):(dataSelectN+0.5);
            plot(nrComb,specComb)
            if flag.dataAmpl        % direct
                [minX maxX fake1 fake2] = SP2_IdealAxisValues(nrComb,specComb);
                minY = data.amplMin;
                maxY = data.amplMax;
            else                    % automatic
                [minX maxX minY maxY] = SP2_IdealAxisValues(nrComb,specComb);
            end
            axis([minX maxX minY maxY])

            %--- data/axis labels ---
            if flag.dataFormat<4
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[a.u.]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAmpl. [a.u.]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAmpl [a.u.]',data.rcvrInd(rcvrCnt)))
                end
            else
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[rad]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                end
            end
            if data.rcvrN>5 && rcvrCnt~=data.rcvrN
                set(gca,'XTickLabel',[])
            end
            if rcvrCnt==data.rcvrN
                xlabel('Repetition')
            end
        end
    end
end

%--- info printout ---
fprintf('\n%s',data.spec2.fidFile);
fprintf('\nMaximum analysis: mean %.1f, SD %.1f (%.1f%% of mean)\n',mean(maxVec),std(maxVec),100*std(maxVec)/mean(maxVec));
fprintf('Absolute: %s\n',SP2_Vec2PrintStr(maxVec));
fprintf('Relative: %s\n',SP2_Vec2PrintStr(maxVec/max(maxVec),4));

%--- update success flag ---
f_succ = 1;

end
