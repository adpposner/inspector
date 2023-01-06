%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_PlotSpecSum( f_new )
%%
%%  Plot sum of metabolite selection.
%% 
%%  01-2020, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss flag

FCTNAME = 'SP2_MARSS_PlotResultSpecSum';


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

%--- metabolite selection ---
if flag.marssShowSelAll           % selection
    if any(marss.showSel<1)
        fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME);
        return
    end
    if any(marss.showSel>marss.basis.n)
        fprintf('%s ->\nAt least one metabolite number exceeds number of\nfitted spectral components (%.0f metabs)\n',...
                FCTNAME,marss.basis.n)
        return
    end
    if isempty(marss.showSel)
        fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME);
        return
    end
end

%--- ppm limit handling ---
if flag.marssPpmShow        % full
    ppmMin = -marss.sw/2 + marss.ppmCalib;
    ppmMax = marss.sw/2  + marss.ppmCalib;
else                        % direct
    ppmMin = marss.ppmShowMin;
    ppmMax = marss.ppmShowMax;
end

%--- dimension handling ---
if flag.marssShowSelAll             % spectrum selection
    nSum = marss.showSelN;
else                                % all metabolites
    nSum = marss.basis.n;
end 
   
%--- spectrum summation ---
if flag.marssShowSelAll             % spectrum selection
    specSumFull = sum(marss.basis.spec(:,marss.showSel),2);
else                                % all spectra
    specSumFull = sum(marss.basis.spec,2);
end

%--- index extraction  ---
[minI,maxI,ppmZoom,specSumZoom,f_done] = SP2_MARSS_ExtractPpmRange(ppmMin,ppmMax,marss.ppmCalib,...
                                                                   marss.sw,real(specSumFull));
if ~f_done
    fprintf('%s ->\nppm extraction of basis spectra failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(marss,'fhMarssSpecSum') && ishandle(marss.fhMarssSpecSum)
    marss.fig.fhMarssSpecSum = get(marss.fhMarssSpecSum,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(marss,'fhMarssSpecSum') && ~flag.marssKeepFig
    if ishandle(marss.fhMarssSpecSum)
        delete(marss.fhMarssSpecSum)
    end
    lcm = rmfield(marss,'fhMarssSpecSum');
end
% create figure if necessary
if ~isfield(marss,'fhMarssSpecSum') || ~ishandle(marss.fhMarssSpecSum)
    marss.fhMarssSpecSum = figure('IntegerHandle','off');
    if isfield(marss,'fig')
        if isfield(marss.fig,'fhMarssSpecSum')
            set(marss.fhMarssSpecSum,'NumberTitle','off','Name',sprintf(' Spectrum Sum'),...
                'Position',marss.fig.fhMarssSpecSum,'Color',[1 1 1],'Tag','MARSS');
        else
            set(marss.fhMarssSpecSum,'NumberTitle','off','Name',sprintf(' Spectrum Sum'),...
                'Color',[1 1 1],'Tag','MARSS');
        end
    else
        set(marss.fhMarssSpecSum,'NumberTitle','off','Name',sprintf(' Spectrum Sum'),...
            'Color',[1 1 1],'Tag','MARSS');
    end
else
    set(0,'CurrentFigure',marss.fhMarssSpecSum)
    if flag.marssKeepFig
        if ~SP2_KeepFigure(marss.fhMarssSpecSum)
            return
        end
    end
end
clf(marss.fhMarssSpecSum)

[minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
if flag.marssAmplShow                         % direct
    minY = marss.amplShowMin;
    maxY = marss.amplShowMax;
end

%--- serial plot of individual traces ---
plot(ppmZoom,specSumZoom,'LineWidth',marss.lineWidth)
set(gca,'XDir','reverse')
% if flag.marssPpmShowPos
%     hold on
%     plot([marss.ppmShowPos marss.ppmShowPos],[minY maxY],'Color',[0 0 0])
%     hold off
% end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- data label ---
if flag.marssLegend
    legCell = {};
    for bCnt = 1:nSum
        if bCnt==1
            if flag.marssShowSelAll                             % selected metabolites
                legCell{1} = marss.basis.metabNames{marss.showSel(1)};
            else                                                % all metabolites
                legCell{1} = marss.basis.metabNames{1};
            end
        else
            if flag.marssShowSelAll                             % selected metabolites
                legCell{1} = sprintf('%s + %s',legCell{1},marss.basis.metabNames{marss.showSel(bCnt)});
            else                                                % all metabolites
                legCell{1} = sprintf('%s + %s',legCell{1},marss.basis.metabNames{bCnt});
            end
        end
    end
    lh = legend(SP2_PrVersionUscoreCell(legCell));
    set(lh,'Location','Northwest')
end

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of summation plot %s\n',SP2_Vec2PrintStr([minX maxX minY maxY],3,1));
end

%--- figure selection ---
flag.marssFigSelect = 3;

%--- export handling ---
marss.expt.fid    = ifft(ifftshift(specSumFull,1),[],1);
marss.expt.sf     = marss.basis.sf;
marss.expt.sw_h   = marss.basis.sw_h;
marss.expt.nspecC = marss.basis.nspecC;

%--- update success flag ---
f_succ = 1;



end
