%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ExpFitAnalysisFlexible( f_new )
%%
%%  Analysis of multi-exponential fitting result for flexible T1s.
%% 
%%  10-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_ExpFitAnalysisFlexible';


%--- break condition ---
if ~f_new && (~isfield(mm,'fhExpFitAna') || ~ishandle(mm.fhExpFitAna))
    return
end

%--- check data existence ---
if ~isfield(mm,'t1spec')
    if f_new        % intention to display -> load data
        fprintf('%s ->\nNo T1 compents found. Run analysis first.\n',FCTNAME);
    end
    return
end

%--- extract T1 and amplitude information ---
fprintf('Analysis: point %.0f / %.4f ppm\n',mm.expPointSelect,mm.expPpmSelect);
for t1Cnt = 1:size(mm.t1spec,2)/2
    fprintf('T1 #%.0f: T1 %.3fs, amplitude %.1f\n',t1Cnt,...
            mm.t1spec(mm.expPointSelect,2*t1Cnt),mm.t1spec(mm.expPointSelect,2*t1Cnt-1)) 
end
fprintf('\n');

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mm,'fhExpFitAna') && ~flag.mmKeepFig
    if ishandle(mm.fhExpFitAna)
        delete(mm.fhExpFitAna)
    end
    mm = rmfield(mm,'fhExpFitAna');
end
% create figure if necessary
if ~isfield(mm,'fhExpFitAna') || ~ishandle(mm.fhExpFitAna)
    mm.fhExpFitAna = figure('IntegerHandle','off');
    nameStr = sprintf(' Multi-Exponential Fit Analysis (point %i, %.3f ppm)',mm.expPointSelect,mm.expPpmSelect);
    set(mm.fhExpFitAna,'NumberTitle','off','Name',nameStr,...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhExpFitAna)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhExpFitAna)
            return
        end
    end
    nameStr = sprintf(' Multi-Exponential Fit Analysis (point %i, %.3f ppm)',mm.expPointSelect,mm.expPpmSelect);
    set(mm.fhExpFitAna,'Name',nameStr);
end
clf(mm.fhExpFitAna)

%--- force update with first use ---
% if f_new
    

%--- data visualization: original fit ---
subplot(3,1,1)
hold on
plot(mm.satRecDelays,mm.satRecSpec(mm.expPointSelect,:),'r*')
plot(mm.satRecFine,mm.satRecSpecFine(mm.expPointSelect,:))
hold off
if flag.mmAmplShow          % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValuesXGap(mm.satRecDelays,mm.satRecSpec(mm.expPointSelect,:));
else                        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValuesXGap(mm.satRecDelays,mm.satRecSpec(mm.expPointSelect,:));
    plotLim(3) = mm.amplShowMin;
    plotLim(4) = mm.amplShowMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Saturation-Recovery Delay [s]')

%--- data visualization: difference original - fit ---
subplot(3,1,2)
yVec = mm.satRecSpec(mm.expPointSelect,:) - mm.satRecSpecFit(mm.expPointSelect,:);
plot(mm.satRecDelays,yVec,'r*')
if flag.mmAmplShow          % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValuesXGap(mm.satRecDelays,yVec);
else                        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValuesXGap(mm.satRecDelays,yVec);
    plotLim(3) = mm.amplShowMin;
    plotLim(4) = mm.amplShowMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Saturation-Recovery Delay [s]')

%--- data visualization: T1 distribution ---
subplot(3,1,3)
hold on
plot(mm.t1spec(mm.expPointSelect,2:2:end),mm.t1spec(mm.expPointSelect,1:2:end))
plot(mm.t1spec(mm.expPointSelect,2:2:end),mm.t1spec(mm.expPointSelect,1:2:end),'r*')
[plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValuesXGap(mm.t1spec(mm.expPointSelect,2:2:end),mm.t1spec(mm.expPointSelect,1:2:end));
if plotLim(1)~=plotLim(2)
    axis([plotLim(1) plotLim(2) 0 plotLim(4)])
elseif plotLim(1)~=plotLim(2) && plotLim(3)~=plotLim(4)
    axis([mm.t1spec(mm.expPointSelect,2)/2 3*mm.t1spec(mm.expPointSelect,2)/2 0 plotLim(4)])
end
xlabel('T1 components [s]')
ylabel('Amplitude [a.u.]')

%--- export handling ---
mm.expt.fid    = mm.satRecSpec(mm.expPointSelect,:);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

%--- optimality display for L1-norm ---
if 0
    fprintf('Optimality of L1-norm fit: %.5f\n',mm.l1normBestFitOpt(mm.expPointSelect));
end



