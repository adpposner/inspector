%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotSpec2Single( f_new )
%%
%%  Plot raw spectrum of data set 2.
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotSpec2Single';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec2,'fid')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end
if length(size(data.spec2.fid))~=3 && ~(length(size(data.spec2.fid))==2 && data.scrollRep==1)
    fprintf('%s ->\nSpectral data set 2 does not have 3 dimensions nor\n',FCTNAME);
    fprintf('is it 2D with repetition #1 selected.\n');
    return
end
if data.scrollRep>data.spec2.nr
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRep,data.spec2.nr)
    return
end
if data.scrollRcvr>data.spec2.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRcvr,data.spec2.nRcvrs)
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

%--- data processing ---
if data.spec2.nspecC<data.fidCut        % no apodization
    datSpec = fftshift(fft(data.spec2.fid(:,data.scrollRcvr,data.scrollRep)));
else                                    % apodization
    datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.scrollRcvr,data.scrollRep)));
    fprintf('%s ->\nApodization of FID 2 to %.0f points applied.\n',FCTNAME,data.fidCut);
end

%--- data extraction: spectrum 2 ---
if flag.dataFormat==1           % real part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec2.sw,real(datSpec));
elseif flag.dataFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec2.sw,imag(datSpec));
elseif flag.dataFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec2.sw,abs(datSpec));
else                            % phase
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec2.sw,angle(datSpec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhSpec2Single') && ~flag.procKeepFig
    if ishandle(data.fhSpec2Single)
        delete(data.fhSpec2Single)
    end
    data = rmfield(data,'fhSpec2Single');
end
% create figure if necessary
if ~isfield(data,'fhSpec2Single') || ~ishandle(data.fhSpec2Single)
    data.fhSpec2Single = figure('IntegerHandle','off');
    set(data.fhSpec2Single,'NumberTitle','off','Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhSpec2Single)
end
set(data.fhSpec2Single,'Name',sprintf(' Spectrum 2: Receiver %.0f, Repetition %.0f',data.scrollRcvr,data.scrollRep))
clf(data.fhSpec2Single)

%--- data visualization ---
plot(ppmZoom,spec2Zoom)
set(gca,'XDir','reverse')
if flag.dataAmpl        % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    minY = data.amplMin;
    maxY = data.amplMax;
else                    % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
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

end
