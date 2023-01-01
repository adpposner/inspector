%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_T1T2_PlotFidArray( f_new )
%%
%%  Plot spectral array of multi-delay experiment.
%% 
%%  02-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2 flag

FCTNAME = 'SP2_T1T2_PlotFidArray';


%--- init success flag ---
f_done = 0;

%--- check t1t2 existence ---
if ~isfield(t1t2,'fid')
    if ~SP2_T1T2_DataLoadAndReco
        return
    end
end

%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(t1t2,'fhFidArray')
    if ishandle(t1t2.fhFidArray)
        delete(t1t2.fhFidArray)
    end
    t1t2 = rmfield(t1t2,'fhFidArray');
end
% create figure if necessary
if ~isfield(t1t2,'fhFidArray') || ~ishandle(t1t2.fhFidArray)
    t1t2.fhFidArray = figure('IntegerHandle','off');
    set(t1t2.fhFidArray,'NumberTitle','off','Name',sprintf(' FID Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',t1t2.fhFidArray)
%     if flag.t1t2KeepFig
%         if ~SP2_KeepFigure(t1t2.fhFidArray)
%             return
%         end
%     end
end
clf(t1t2.fhFidArray)

%--- repetition selection ---
% if flag.t1t2AllSelect       % all repetitions
    t1t2SelectN = t1t2.nr;
    t1t2Select  = 1:t1t2.nr;
% else                        % selected repeitions
%     t1t2SelectN = t1t2.selectN;
%     t1t2Select  = t1t2.select;
% end

%--- receiver and repetition loops ---
if flag.t1t2AnaFormat       % real part of FID
    if t1t2.anaFidMax>t1t2.anaFidMin
        for dCnt = 1:t1t2SelectN            % number of selected delays
            %--- spectrum concatenation ---
            if dCnt==1
                if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                    fidComb = -real(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt));
                else
                    fidComb = real(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt));
                end
            else
                if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                    fidComb = [fidComb; 0; -real(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt))];
                else
                    fidComb = [fidComb; 0; real(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt))];
                end
            end
        end
    else
        fidComb = real(t1t2.fid(t1t2.anaFidMin,:));
    end
else                        % magnitude FID
    if t1t2.anaFidMax>t1t2.anaFidMin
        for dCnt = 1:t1t2SelectN            % number of selected delays
            %--- spectrum concatenation ---
            if dCnt==1
                if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                    fidComb = -abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt));
                else
                    fidComb = abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt));
                end
            else
                if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                    fidComb = [fidComb; 0; -abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt))];
                else
                    fidComb = [fidComb; 0; abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,dCnt))];
                end
            end
        end
    else
        if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
            fidComb = -abs(t1t2.fid(t1t2.anaFidMin,:));
        else
            fidComb = abs(t1t2.fid(t1t2.anaFidMin,:));
        end
    end
end

%--- visualization ---
hold on
if t1t2.anaFidMax>t1t2.anaFidMin
    nrComb = 0.5:t1t2SelectN/(length(fidComb)-1):(t1t2SelectN+0.5);
    nPts   = length(nrComb);
    for nCnt = 1:nPts-1
        if fidComb(nCnt)~=0 && fidComb(nCnt+1)~=0       % quick and (somewhat) dirty
            plot(nrComb(nCnt:nCnt+1),fidComb(nCnt:nCnt+1))
            plot(nrComb(nCnt:nCnt+1),fidComb(nCnt:nCnt+1),'ro')
        end
    end
else
    nrComb = 1:length(fidComb);
    plot(nrComb,fidComb)
    plot(nrComb,fidComb,'ro')
end
hold off
if flag.t1t2AmplShow        % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(nrComb,fidComb);
else                        % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(nrComb,fidComb);
    minY = t1t2.amplShowMin;
    maxY = t1t2.amplShowMax;
end
axis([minX maxX minY maxY])

%--- axis labels ---
ylabel('Amplitude [a.u.]')
xlabel('Delays [1]')
    
%--- update success flag ---
f_done = 1;
