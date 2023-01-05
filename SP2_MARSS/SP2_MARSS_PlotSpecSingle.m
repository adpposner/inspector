%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_PlotSpecSingle( f_new )
%%
%%  Plot selected metabolite simulation result.
%% 
%%  01-2020, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss flag

FCTNAME = 'SP2_MARSS_PlotSpecSingle';


%--- init success flag ---
f_succ = 0;

%--- check data existence and parameter consistency ---
if ~isfield(marss,'basis')
    fprintf('%s ->\nNo basis data found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sf')
    fprintf('%s ->\nLarmor frequency of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sw')
    fprintf('%s ->\nSweep width of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'spec')
    fprintf('%s ->\nBasis spectra not found. Program aborted.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.marssPpmShow        % full
    ppmMin = -marss.sw/2 + marss.ppmCalib;
    ppmMax = marss.sw/2  + marss.ppmCalib;
else                        % direct
    ppmMin = marss.ppmShowMin;
    ppmMax = marss.ppmShowMax;
end

%--- consistency check ---
if marss.currShow>marss.basis.n            % 
    fprintf('\n%s ->\nSelected spectrum exceeds number of basis spectra (%.0f>%.0f).\nMetabolite selection limited to %.0f.\n',...
            FCTNAME,marss.currShow,marss.basis.n,marss.basis.n)
    marss.currShow = marss.basis.n;
end

%--- data extraction: selected metabolite ---
[minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_MARSS_ExtractPpmRange(ppmMin,ppmMax,marss.ppmCalib,...
                                                                      marss.basis.sw,real(marss.basis.spec(:,marss.currShow)));
if ~f_done
    fprintf('%s ->\nppm extraction of basis spectrum failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(marss,'fhMarssSpecSingle') && ishandle(marss.fhMarssSpecSingle)
    marss.fig.fhMarssSpecSingle = get(marss.fhMarssSpecSingle,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(marss,'fhMarssSpecSingle') && ~flag.marssKeepFig
    if ishandle(marss.fhMarssSpecSingle)
        delete(marss.fhMarssSpecSingle)
    end
    marss = rmfield(marss,'fhMarssSpecSingle');
end
% create figure if necessary
if ~isfield(marss,'fhMarssSpecSingle') || ~ishandle(marss.fhMarssSpecSingle)
    marss.fhMarssSpecSingle = figure('IntegerHandle','off');
    if isfield(marss,'fig')
        if isfield(marss.fig,'fhMarssSpecSingle')
            set(marss.fhMarssSpecSingle,'NumberTitle','off','Name',sprintf(' Single Basis Spectrum <%s>',SP2_PrVersionUscore(marss.basis.metabNames{marss.currShow})),...
                'Position',marss.fig.fhMarssSpecSingle,'Color',[1 1 1],'Tag','MARSS');
        else
            set(marss.fhMarssSpecSingle,'NumberTitle','off','Name',sprintf(' Single Basis Spectrum <%s>',SP2_PrVersionUscore(marss.basis.metabNames{marss.currShow})),...
                'Color',[1 1 1],'Tag','MARSS');
        end
    else
        set(marss.fhMarssSpecSingle,'NumberTitle','off','Name',sprintf(' Single Basis Spectrum <%s>',SP2_PrVersionUscore(marss.basis.metabNames{marss.currShow})),...
            'Color',[1 1 1],'Tag','MARSS');
    end
else
    set(0,'CurrentFigure',marss.fhMarssSpecSingle)
    if flag.marssKeepFig
        if ~SP2_KeepFigure(marss.fhMarssSpecSingle)
            return
        end
    end
end
clf(marss.fhMarssSpecSingle)

%--- data visualization ---
% plot(ppmZoom,specSingleZoom,'LineWidth',marss.lineWidth,'Color',[1 0 0])
plot(ppmZoom,specSingleZoom)
set(gca,'XDir','reverse')
[minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
if flag.marssAmplShow                         % direct
    minY = marss.amplShowMin;
    maxY = marss.amplShowMax;
end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
if flag.marssLegend
    lh = legend(SP2_PrVersionUscore(marss.basis.metabNames{marss.currShow}));
    set(lh,'Location','Northwest')
end

%--- spectrum analysis ---
% if (flag.marssAnaSNR || flag.marssAnaFWHM || flag.marssAnaIntegr) && marss.currShow<=marss.basis.n         % metab only, no baseline
%     fprintf('ANALYSIS OF BASIS SPECTRUM\n');
%     if flag.marssPlotBaseCorr && (flag.marssAnaPoly || flag.marssAnaSpline) && isfield(marss,'polySpec')
%         if ~SP2_MARSS_Analysis(marss.basis.spec(:,marss.currShow)+marss.polySpec,[minX maxX minY maxY],[flag.marssSpecLb flag.marssSpecGb])
%             return
%         end
%     else
%         if ~SP2_MARSS_Analysis(marss.basis.spec(:,marss.currShow),[minX maxX minY maxY],[flag.marssSpecLb flag.marssSpecGb])
%             return
%         end
%     end
% end

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of single plot %s\n',SP2_Vec2PrintStr([minX maxX minY maxY],3,1));
end

%--- figure selection ---
flag.marssFigSelect = 1;

%--- export handling ---
marss.expt.fid    = ifft(ifftshift(marss.basis.spec(:,marss.currShow),1),[],1);
marss.expt.sf     = marss.basis.sf;
marss.expt.sw_h   = marss.basis.sw_h;
marss.expt.nspecC = marss.basis.nspecC;

%--- update success flag ---
f_succ = 1;
