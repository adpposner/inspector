%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotSpec1Single( f_new )
%%
%%  Plot raw spectrum of data set 1.
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotSpec1Single';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME)
    return
end
if length(size(data.spec1.fid))~=3 && ~(length(size(data.spec1.fid))==2 && data.scrollRep==1)
    fprintf('%s ->\nSpectral data set 1 does not have 3 dimensions nor\n',FCTNAME)
    fprintf('is it 2D with repetition #1 selected.\n')
    return
end
if data.scrollRep>data.spec1.nr
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRep,data.spec1.nr)
    return
end
if data.scrollRcvr>data.spec1.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRcvr,data.spec1.nRcvrs)
    return
end


%--- ppm limit handling ---
if flag.dataPpmShow     % direct
    ppmMin = data.ppmShowMin;
    ppmMax = data.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -data.spec1.sw/2 + data.ppmCalib;
    ppmMax = data.spec1.sw/2  + data.ppmCalib;
end

%--- data processing ---
if data.spec1.nspecC<data.fidCut        % no apodization
    datSpec = fftshift(fft(data.spec1.fid(:,data.scrollRcvr,data.scrollRep)));
else                                    % apodization
    datSpec = fftshift(fft(data.spec1.fid(1:data.fidCut,data.scrollRcvr,data.scrollRep)));
    fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut)
end

%--- data extraction: spectrum 1 ---
if flag.dataFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,real(datSpec));
elseif flag.dataFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,imag(datSpec));
elseif flag.dataFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,abs(datSpec));
else                            % phase
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,angle(datSpec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhSpec1Single')
    if ishandle(data.fhSpec1Single)
        delete(data.fhSpec1Single)
    end
    data = rmfield(data,'fhSpec1Single');
end
% create figure if necessary
if ~isfield(data,'fhSpec1Single') || ~ishandle(data.fhSpec1Single)
    data.fhSpec1Single = figure('IntegerHandle','off');
    set(data.fhSpec1Single,'NumberTitle','off','Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhSpec1Single)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhSpec1Single)
            return
        end
    end
end
set(data.fhSpec1Single,'Name',sprintf(' Spectrum 1: Receiver %.0f, Repetition %.0f',data.scrollRcvr,data.scrollRep))
clf(data.fhSpec1Single)

%--- data visualization ---
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if flag.dataAmpl        % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    minY = data.amplMin;
    maxY = data.amplMax;
else                    % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
end
axis([minX maxX minY maxY])
if flag.dataFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- update success flag ---
f_succ = 1;
