%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmShowPosAssign
%%
%%  Assign ppm value as display frequency (for vertical line).
%% 
%%  11-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_PpmShowPosAssign';


%--- check data existence ---
if ~isfield(syn,'spec')
    fprintf('%s ->\nNo spectral data found.\nSimulate first. Program aborted.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.synPpmShow      % full sweep width (symmetry assumed)
    ppmMin = -syn.sw/2 + syn.ppmCalib;
    ppmMax = syn.sw/2  + syn.ppmCalib;
else                    % direct
    ppmMin = syn.ppmShowMin;
    ppmMax = syn.ppmShowMax;
end

%--- data extraction: spectrum 1 ---
if flag.synFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Syn_ExtractPpmRange(ppmMin,ppmMax,syn.ppmCalib,...
                                                                  syn.sw,real(syn.spec));
elseif flag.synFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Syn_ExtractPpmRange(ppmMin,ppmMax,syn.ppmCalib,...
                                                                  syn.sw,imag(syn.spec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Syn_ExtractPpmRange(ppmMin,ppmMax,syn.ppmCalib,...
                                                                  syn.sw,abs(syn.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(syn,'fhSynPpmAssign') && ~flag.synKeepFig
    if ishandle(syn.fhSynPpmAssign)
        delete(syn.fhSynPpmAssign)
    end
    syn = rmfield(syn,'fhSynPpmAssign');
end
% create figure if necessary
if ~isfield(syn,'fhSynPpmAssign') || ~ishandle(syn.fhSynPpmAssign)
    syn.fhSynPpmAssign = figure('IntegerHandle','off');
    set(syn.fhSynPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',syn.fhSynPpmAssign)
    if flag.synKeepFig
        if ~SP2_KeepFigure(syn.fhSynPpmAssign)
            return
        end
    end
end
clf(syn.fhSynPpmAssign)

%--- data visualization ---
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if ~flag.synAmplShow      % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
else                    % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = syn.amplShowMin;
    plotLim(4) = syn.amplShowMax;
end
if flag.synPpmShowPos
    hold on
    plot([syn.ppmShowPos syn.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[syn.ppmShowPos,y] = ginput(1);                                        % frequency position
syn.ppmShowPosMirr = syn.ppmCalib+(syn.ppmCalib-syn.ppmShowPos);    % mirrored frequency position

%--- info printout ---
fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',syn.ppmShowPos,...
        syn.ppmCalib,syn.ppmShowPos-syn.ppmCalib,syn.sf*(syn.ppmShowPos-syn.ppmCalib))

%--- remove figure ---
delete(syn.fhSynPpmAssign)
syn = rmfield(syn,'fhSynPpmAssign');

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate



