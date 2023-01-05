%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotFid1Array( f_new )
%%
%%  Plot superposition of raw FIDs from data set 1.
%% 
%%  08-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotFid1Array';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nData set 1 does not exist. Load first.\n',FCTNAME);
    return
end
if any(data.select>data.spec1.nr) && ~flag.dataAllSelect
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.select),data.spec1.nr)
    return
end
if max(data.rcvrInd)>data.spec1.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds experiment dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec1.nRcvrs)
    return
end

%--- repetition selection ---
if flag.dataAllSelect       % all repetitions
    dataSelectN = data.spec1.nr;
    dataSelect  = 1:data.spec1.nr;
else                        % selected repeitions
    dataSelectN = data.selectN;
    dataSelect  = data.select;
end

%--- check maximal array size ---
if dataSelectN*data.rcvrN>data.plotArrMaxElem
    fprintf('\n*** WARNING ***\n');
    fprintf('Figure update of Fid 1 array has been temporarily disabled\nsince requested array size has become unreasonable (%.0f>%.0f).\n\n',...
            dataSelectN*data.rcvrN,data.plotArrMaxElem);
    return
end

%--- check consistency of data dimension and display selection ---
fidSize = size(data.spec1.fid);
if length(fidSize)==2
    if any(fidSize(2)<data.rcvrInd)
        fprintf('FID 1 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet).\n\n');
        return
    end
end
if length(fidSize)==3
    if any(fidSize(2)<data.rcvrInd)
        fprintf('FID 1 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet)\n\n');
        return
    end
    if any(fidSize(3)<dataSelect)
        fprintf('FID 1 data size does not allow selected NR display\n(Hint: Make sure repetitions haven''t been combined yet)\n\n');
        return
    end
end

%--- figure handling ---
% remove existing figure if new figure is forced 
if f_new && isfield(data,'fhFid1Array') && ~flag.procKeepFig
    if ishandle(data.fhFid1Array)
        delete(data.fhFid1Array)
    end
    data = rmfield(data,'fhFid1Array');
end
% create figure if necessary
if ~isfield(data,'fhFid1Array') || ~ishandle(data.fhFid1Array)
    data.fhFid1Array = figure('IntegerHandle','off');
    set(data.fhFid1Array,'NumberTitle','off','Name',sprintf(' FID 1: Array'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhFid1Array)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhFid1Array)
            return
        end
    end
end
clf(data.fhFid1Array)

%--- receiver and repetition loops ---
for rcvrCnt = 1:data.rcvrN            % number of selected receivers
    for repCnt = 1:dataSelectN       % number of selected spectra
        %--- data processing ---
        if data.spec1.dim==2    % 2D
            if data.spec1.nspecC<data.fidCut        % no apodization
                datFid = data.spec1.fid(:,data.rcvrInd(rcvrCnt));
            else                                    % apodization
                datFid = data.spec1.fid(1:data.fidCut,data.rcvrInd(rcvrCnt));
                if rcvrCnt==1 && repCnt==1
                    fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                end
            end
        else                    % 3D
            if data.spec1.nspecC<data.fidCut        % no apodization
                datFid = data.spec1.fid(:,data.rcvrInd(rcvrCnt),dataSelect(repCnt));
            else                                    % apodization
                datFid = data.spec1.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),dataSelect(repCnt));
                if rcvrCnt==1 && repCnt==1
                    fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
                end
            end
        end

        %--- real/imag/magn extraction ---
        if flag.dataFormat==1           % real part
            datFid = real(datFid);
        elseif flag.dataFormat==2       % imaginary part
            datFid = imag(datFid);
        elseif flag.dataFormat==3       % magnitude
            datFid = abs(datFid);
        else                            % phase
            datFid = angle(datFid);
            
            %--- linear detrend (i.e. frequency correction) ---
            if flag.dataPhaseLinCorr
                datFid = unwrap(datFid);
                coeff  = polyfit(1:length(datFid),datFid',1);         % 1st order fit
                datFid = datFid - polyval(coeff,1:length(datFid))';   % 1st order correction             
            end
        end
        
        %--- data visualization ---
        subplot(data.rcvrN,dataSelectN,(rcvrCnt-1)*dataSelectN+repCnt)
        plot(datFid)
        if flag.dataAmpl        % direct
            [minX maxX fake1 fake2] = SP2_IdealAxisValues(datFid);
            minY = data.amplMin;
            maxY = data.amplMax;
        else                    % automatic
            [minX maxX minY maxY] = SP2_IdealAxisValues(datFid);
        end
        axis([minX maxX minY maxY])
        
        %--- data/axis labels ---
        if repCnt==1
            if flag.dataFormat<4
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[a.u.]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAmpl [a.u.]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAmpl. [a.u.]',data.rcvrInd(rcvrCnt)))
                end
            else
                if data.rcvrN>10
                    ylabel(sprintf('Rx%.0f\n[rad]',data.rcvrInd(rcvrCnt)))
                elseif data.rcvrN>5
                    ylabel(sprintf('Rcvr %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                else
                    ylabel(sprintf('Receiver %.0f\n\nAngle [rad]',data.rcvrInd(rcvrCnt)))
                end
            end
        end
        if rcvrCnt==1
            if dataSelectN<10
                title(sprintf('Repetition %.0f',dataSelect(repCnt)))
            else
                title(sprintf('Rep. %.0f',dataSelect(repCnt)))
            end
        end
        if data.rcvrN>5 && rcvrCnt~=data.rcvrN
            set(gca,'XTickLabel',[])
        end
        if rcvrCnt==data.rcvrN
            xlabel('Time [pts]')
        end
    end
end

%--- update success flag ---
f_succ = 1;
