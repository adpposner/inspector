%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PpmAssignToPeak';



%--- check data existence ---
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end
if length(size(data.spec1.fid))~=3 && ~(length(size(data.spec1.fid))==2 && data.selectN==1 && data.select==1)
    fprintf('%s ->\nSpectral data set 1 does not have 3 dimensions nor\n',FCTNAME);
    fprintf('is it 2D with repetition #1 selected.\n');
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
datSpec = fftshift(fft(data.spec1.fid(:,data.scrollRcvr,data.scrollRep)));

%--- data extraction: spectrum 1 ---
if flag.dataFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,real(datSpec));
elseif flag.dataFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,imag(datSpec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                               data.spec1.sw,abs(datSpec));
end                                             
if ~f_succ
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(data,'fhPpmAssign')
    if ishandle(data.fhPpmAssign)
        delete(data.fhPpmAssign)
    end
    data = rmfield(data,'fhPpmAssign');
end
% create figure if necessary
if ~isfield(data,'fhPpmAssign') || ~ishandle(data.fhPpmAssign)
    data.fhPpmAssign = figure('IntegerHandle','off');
    set(data.fhPpmAssign,'NumberTitle','off','Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhPpmAssign)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhPpmAssign)
            return
        end
    end
end
set(data.fhPpmAssign,'Name',sprintf(' Spectrum 1: Receiver %.0f, Repetition %.0f',data.scrollRcvr,data.scrollRep))
clf(data.fhPpmAssign)

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
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
data.ppmCalib = data.ppmCalib + data.ppmAssign - ppmPos;

%--- remove figure ---
delete(data.fhPpmAssign)
data = rmfield(data,'fhPpmAssign');

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate





end
