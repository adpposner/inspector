%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFidDiff( f_new )
%%
%%  Plot difference FID of data sets.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotFidDiff';


%--- check data existence ---
if flag.mrsiNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(mrsi.spec1,'fid')
        fprintf('%s ->\nData of spectrum 1 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
end

%--- consistency checks ---
% dwell time (and SW) check
if mrsi.spec1.dwell~=mrsi.spec2.dwell
    fprintf('%s -> Dwell time mismatch detected (%.6fHz ~= %.6fHz)\n',FCTNAME,...
            mrsi.spec1.dwell,mrsi.spec2.dwell)
    return
end
% number of points check
if mrsi.spec1.nspecC~=mrsi.spec2.nspecC
    fprintf('%s -> Mismatch between number of points detected (%.0f ~= %.0f)\n',FCTNAME,...
            mrsi.spec1.nspecC,mrsi.spec2.nspecC)
    return
end

% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFidDiff') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFidDiff)
        delete(mrsi.fhFidDiff)
    end
    mrsi = rmfield(mrsi,'fhFidDiff');
end
% create figure if necessary
if ~isfield(mrsi,'fhFidDiff') || ~ishandle(mrsi.fhFidDiff)
    mrsi.fhFidDiff = figure('IntegerHandle','off');
    set(mrsi.fhFidDiff,'NumberTitle','off','Name',sprintf(' FID Sum'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFidDiff)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFidDiff)
            return
        end
    end
end
clf(mrsi.fhFidDiff)
timeVec = mrsi.spec1.dwell*(0:mrsi.spec1.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mrsiFormat==1           % real part
    plot(real(mrsi.fidDiff))
elseif flag.mrsiFormat==2       % imaginary part
    plot(imag(mrsi.fidDiff))
elseif flag.mrsiFormat==3       % magnitude
    plot(abs(mrsi.fidDiff))
else                            % angle
    plot(angle(mrsi.fidDiff))
end   
xlabel('time [pts]')
if flag.mrsiFormat<4
    ylabel('FID 1 [a.u.]')
else
    ylabel('FID 1 [rad]')
end
if flag.mrsiFormat==1           % real
    [minX maxX minY maxY] = SP2_IdealAxisValues(real(mrsi.fidDiff));
elseif flag.mrsiFormat==2       % imag
    [minX maxX minY maxY] = SP2_IdealAxisValues(imag(mrsi.fidDiff));
elseif flag.mrsiFormat==3       % magnitude
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mrsi.fidDiff));
else                            % phase
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mrsi.fidDiff));
end
axis([minX maxX minY maxY])
set(gca,'XGrid','on','YGrid','On')
%--- add time axis ---
timeStep = 0.1*round(timeVec(end)/(8*0.1));     % 8 full 0.1s steps
timeAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
                'Color','none','XLim',[min(timeVec) max(timeVec)],...
                'XTick',min(timeVec):timeStep:max(timeVec),...
                'YTick',[]);
xlabel('time [s]')

%--- export handling ---
mrsi.expt.fid    = mrsi.spec1.fidDiff;
mrsi.expt.sf     = mrsi.spec1.sf;
mrsi.expt.sw_h   = mrsi.spec1.sw_h;
mrsi.expt.nspecC = mrsi.spec1.nspecC;


