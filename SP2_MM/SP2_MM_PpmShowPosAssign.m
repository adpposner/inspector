%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_PpmShowPosAssign
%%
%%  Assign ppm value as display frequency (for vertical line).
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_PpmShowPosAssign';


%--- check data existence ---
if ~isfield(mm,'spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME)
    return
end

%--- ppm limit handling ---
if flag.mmPpmShow       % full sweep width (symmetry assumed)
    ppmMin = -mm.sw/2 + mm.ppmCalib;
    ppmMax = mm.sw/2  + mm.ppmCalib;
else                    % direct
    ppmMin = mm.ppmShowMin;
    ppmMax = mm.ppmShowMax;
end

%--- data extraction: spectrum 1 ---
if flag.mmFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                  mm.sw,real(mm.spec(:,mm.satRecSelect)));
elseif flag.mmFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                  mm.sw,imag(mm.spec(:,mm.satRecSelect)));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                  mm.sw,abs(mm.spec(:,mm.satRecSelect)));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(mm,'fhMmPpmAssign') && ~flag.mmKeepFig
    if ishandle(mm.fhMmPpmAssign)
        delete(mm.fhMmPpmAssign)
    end
    mm = rmfield(mm,'fhMmPpmAssign');
end
% create figure if necessary
if ~isfield(mm,'fhMmPpmAssign') || ~ishandle(mm.fhMmPpmAssign)
    mm.fhMmPpmAssign = figure('IntegerHandle','off');
    set(mm.fhMmPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhMmPpmAssign)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhMmPpmAssign)
            return
        end
    end
end
clf(mm.fhMmPpmAssign)

%--- data visualization ---
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if flag.mmAmplShow      % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
else                    % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = mm.amplShowMin;
    plotLim(4) = mm.amplShowMax;
end
if flag.mmPpmShowPos
    hold on
    plot([mm.ppmShowPos mm.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[mm.ppmShowPos,y] = ginput(1);                                        % frequency position
mm.ppmShowPosMirr = mm.ppmCalib+(mm.ppmCalib-mm.ppmShowPos);    % mirrored frequency position

%--- info printout ---
fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mm.ppmShowPos,...
        mm.ppmCalib,mm.ppmShowPos-mm.ppmCalib,mm.sf*(mm.ppmShowPos-mm.ppmCalib))

%--- remove figure ---
delete(mm.fhMmPpmAssign)
mm = rmfield(mm,'fhMmPpmAssign');

%--- parameter update ---
if flag.mmExpPpmLink
    mm.expPpmSelect = mm.ppmShowPos;     % frequency update
end

%--- figure updates ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate




