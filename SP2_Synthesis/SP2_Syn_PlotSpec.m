%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_PlotSpec( f_new )
%%
%%  Plot processed spectrum.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_PlotSpec';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(syn,'spec')
    fprintf('%s ->\nSpectral data does not exist. Load/analyze first.\n',FCTNAME);
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
[minI,maxI,ppmZoom,specZoom,f_done] = SP2_Syn_ExtractPpmRange(ppmMin,ppmMax,syn.ppmCalib,...
                                                              syn.sw,real(syn.spec));
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(syn,'fhSynSpec') && ishandle(syn.fhSynSpec)
    syn.fig.fhSynSpec = get(syn.fhSynSpec,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(syn,'fhSynSpec') && ~flag.synKeepFig
    if ishandle(syn.fhSynSpec)
        delete(syn.fhSynSpec)
    end
    syn = rmfield(syn,'fhSynSpec');
end
% create figure if necessary
if ~isfield(syn,'fhSynSpec') || ~ishandle(syn.fhSynSpec)
    syn.fhSynSpec = figure('IntegerHandle','off');
    set(syn.fhSynSpec,'NumberTitle','off','Name',' Spectrum',...
        'Position',syn.fig.fhSynSpec,'Color',[1 1 1]);
else
    set(0,'CurrentFigure',syn.fhSynSpec)
    if flag.synKeepFig
        if ~SP2_KeepFigure(syn.fhSynSpec)
            return
        end
    end
end
clf(syn.fhSynSpec)

%--- data visualization ---
% plot(ppmZoom,specZoom,'LineWidth',2)
plot(ppmZoom,specZoom)
set(gca,'XDir','reverse')
if flag.synAmplShow        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = syn.amplShowMin;
    plotLim(4) = syn.amplShowMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
end
if flag.synPpmShowPos
    hold on
    plot([syn.ppmShowPos syn.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- show LCModel limits as vertical lines ---
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');

%--- spectrum analysis ---
if flag.synAnaSNR || flag.synAnaFWHM || flag.synAnaIntegr
    fprintf('ANALYSIS OF TARGET SPECTRUM\n');
    if ~SP2_Syn_Analysis(syn.spec,plotLim,[flag.synProcLb flag.synProcGb])
        return
    end
end

%--- info printout ---
if flag.verbose
    fprintf('MRS plot limits: %s\n',SP2_Vec2PrintStr(plotLim,4));
end

%--- export handling ---
syn.expt.fid    = ifft(ifftshift(syn.spec,1),[],1);
syn.expt.sf     = syn.sf;
syn.expt.sw_h   = syn.sw_h;
syn.expt.nspecC = syn.nspecC;

%--- update success flag ---
f_succ = 1;




end
