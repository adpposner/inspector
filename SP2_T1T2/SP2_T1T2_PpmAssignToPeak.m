%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  10-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2 flag fm

FCTNAME = 'SP2_T1T2_PpmAssignToPeak';


%--- check t1t2 existence ---
if ~isfield(t1t2,'fid')
    if ~SP2_T1T2_DataLoadAndReco
        return
    end
end

%--- repetition selection ---
% if flag.t1t2AllSelect       % all repetitions
    t1t2SelectN = t1t2.nr;
    t1t2Select  = 1:t1t2.nr;
% else                        % selected repeitions
%     t1t2SelectN = t1t2.selectN;
%     t1t2Select  = t1t2.select;
% end

%--- consistency check ---
if t1t2.delayNumber>t1t2SelectN
    fprintf('Selected spectrum (#delay) exceeds data dimension (%.0f>%.0f). Program aborted.\n',...
            t1t2.delayNumber,t1t2SelectN)
    return
end

%--- ppm limit handling ---
if ~flag.t1t2PpmShow     % direct
    ppmMin = t1t2.ppmShowMin;
    ppmMax = t1t2.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -t1t2.sw/2 + t1t2.ppmCalib;
    ppmMax = t1t2.sw/2  + t1t2.ppmCalib;
end

%--- data extraction ---
if flag.t1t2AnaFormat==1           % real part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                   t1t2.sw,real(t1t2.spec(:,t1t2.delayNumber)));
else                            % magnitude
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                   t1t2.sw,abs(t1t2.spec(:,t1t2.delayNumber)));
end
if ~f_succ
    fprintf('%s ->\nppm extraction  failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(t1t2,'fhPpmAssign')
    if ishandle(t1t2.fhPpmAssign)
        delete(t1t2.fhPpmAssign)
    end
    t1t2 = rmfield(t1t2,'fhPpmAssign');
end
% create figure if necessary
if ~isfield(t1t2,'fhPpmAssign') || ~ishandle(t1t2.fhPpmAssign)
    t1t2.fhPpmAssign = figure('IntegerHandle','off');
    set(t1t2.fhPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',t1t2.fhPpmAssign)
%     if flag.t1t2KeepFig
%         if ~SP2_KeepFigure(t1t2.fhPpmAssign)
%             return
%         end
%     end
end
clf(t1t2.fhPpmAssign)

%--- data visualization ---
plot(ppmZoom,specZoom)
set(gca,'XDir','reverse')
if flag.procAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = t1t2.amplMin;
    plotLim(4) = t1t2.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
end
if flag.procPpmShowPos
    hold on
    plot([t1t2.ppmShowPos t1t2.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
t1t2.ppmCalib = t1t2.ppmCalib + t1t2.ppmAssign - ppmPos;
set(fm.t1t2.ppmCalib,'String',sprintf('%.3f',t1t2.ppmCalib));

%--- remove figure ---
delete(t1t2.fhPpmAssign)
t1t2 = rmfield(t1t2,'fhPpmAssign');

%--- window update ---
SP2_T1T2_T1T2WinUpdate




