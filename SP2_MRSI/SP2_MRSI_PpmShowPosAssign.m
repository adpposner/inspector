%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowPosAssign
%%
%%  Assign ppm value as display frequency (for vertical line).
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_PpmShowPosAssign';



%--- data processing ---
if flag.mrsiUpdateCalc
    if ~SP2_MRSI_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(mrsi,'spec1')
    fprintf('%s ->\nSpectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
elseif ~isfield(mrsi.spec1,'spec')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.spec1.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.spec1.sw/2  + mrsi.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,real(mrsi.spec1.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,imag(mrsi.spec1.spec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,abs(mrsi.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(mrsi,'fhPpmAssign') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhPpmAssign)
        delete(mrsi.fhPpmAssign)
    end
    mrsi = rmfield(mrsi,'fhPpmAssign');
end
% create figure if necessary
if ~isfield(mrsi,'fhPpmAssign') || ~ishandle(mrsi.fhPpmAssign)
    mrsi.fhPpmAssign = figure('IntegerHandle','off');
    set(mrsi.fhPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhPpmAssign)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhPpmAssign)
            return
        end
    end
end
clf(mrsi.fhPpmAssign)

%--- data visualization ---
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if flag.mrsiAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
end
if flag.mrsiPpmShowPos
    hold on
    plot([mrsi.ppmShowPos mrsi.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[mrsi.ppmShowPos,y] = ginput(1);                                        % frequency position
mrsi.ppmShowPosMirr = mrsi.ppmCalib+(mrsi.ppmCalib-mrsi.ppmShowPos);    % mirrored frequency position

%--- info printout ---
fprintf('Frequency position: %.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mrsi.ppmShowPos,...
        mrsi.ppmCalib,mrsi.ppmShowPos-mrsi.ppmCalib,mrsi.spec1.sf*(mrsi.ppmShowPos-mrsi.ppmCalib))
if flag.mrsiPpmShowPosMirr
    fprintf('Mirrored position:  %.3fppm/%.2fHz\n',mrsi.ppmShowPosMirr,...
            mrsi.spec1.sf*(mrsi.ppmShowPosMirr-mrsi.ppmCalib))
end    

%--- remove figure ---
delete(mrsi.fhPpmAssign)
mrsi = rmfield(mrsi,'fhPpmAssign');

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate




