%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_T1T2_PlotSpecArray( f_new )
%%
%%  Plot spectral array of multi-delay experiment.
%% 
%%  02-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile t1t2 flag

FCTNAME = 'SP2_T1T2_PlotSpecArray';


%--- init success flag ---
f_done = 0;

%--- check t1t2 existence ---
if ~isfield(t1t2,'fid')
    if ~SP2_T1T2_DataLoadAndReco
        return
    end
end

%--- ppm limit handling ---
if ~flag.t1t2PpmShow     % direct
    ppmMin = t1t2.ppmShowMin;
    ppmMax = t1t2.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -t1t2.sw/2 + t1t2.ppmCalib;
    ppmMax = t1t2.sw/2  + t1t2.ppmCalib;
end

%--- figure handling ---
% remove existing figure if new figure is forced
if isfield(t1t2,'fhSpecArray')
    if ishandle(t1t2.fhSpecArray)
        delete(t1t2.fhSpecArray)
    end
    t1t2 = rmfield(t1t2,'fhSpecArray');
end
% create figure if necessary
if ~isfield(t1t2,'fhSpecArray') || ~ishandle(t1t2.fhSpecArray)
    t1t2.fhSpecArray = figure('IntegerHandle','off');
    set(t1t2.fhSpecArray,'NumberTitle','off','Name',sprintf(' Spectrum Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',t1t2.fhSpecArray)
%     if flag.t1t2KeepFig
%         if ~SP2_KeepFigure(t1t2.fhSpecArray)
%             return
%         end
%     end
end
clf(t1t2.fhSpecArray)

%--- repetition selection ---
% if flag.t1t2AllSelect       % all repetitions
    t1t2SelectN = t1t2.nr;
    t1t2Select  = 1:t1t2.nr;
% else                        % selected repeitions
%     t1t2SelectN = t1t2.selectN;
%     t1t2Select  = t1t2.select;
% end


%--- FID extraction ---
if flag.t1t2AnaData==1          % FID
    if flag.t1t2AnaFormat       % real part
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
    else                        % magnitude
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
else            % spectra
    %--- concatenation of selected ppm range ---
    for dCnt = 1:t1t2SelectN            % number of selected delays
        %--- t1t2 extraction: spectrum 1 ---
        if flag.t1t2AnaFormat==1            % real part
            if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,-real(t1t2.spec(:,dCnt)));
            else
                [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,real(t1t2.spec(:,dCnt)));
            end
        else                                % magnitude
            if flag.t1t2AnaSignFlip && dCnt<=t1t2.anaSignFlipN      % sign flip
                [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,-abs(t1t2.spec(:,dCnt)));
            else
                [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(ppmMin,ppmMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,abs(t1t2.spec(:,dCnt)));
            end
        end
        if ~f_succ
            fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
            return
        end
        
        %--- offset area extraction ---
        if flag.t1t2OffsetCorr
            if flag.t1t2AnaFormat==1        % real part
                [minOffsetI,maxOffsetI,ppmOffset1,specOffset1,f_succ] = SP2_T1T2_ExtractPpmRange(t1t2.ppmWinMin-8,t1t2.ppmWinMax-6,t1t2.ppmCalib,...
                                                                                                 t1t2.sw,real(t1t2.spec(:,dCnt)));
            else                            % magnitude
                [minOffsetI,maxOffsetI,ppmOffset1,specOffset1,f_succ] = SP2_T1T2_ExtractPpmRange(t1t2.ppmWinMin-8,t1t2.ppmWinMax-6,t1t2.ppmCalib,...
                                                                                                 t1t2.sw,abs(t1t2.spec(:,dCnt)));
            end
            if ~f_succ
                fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
                return
            end

            %--- offset calculation ---
            specZoom = specZoom - mean(specOffset1);
        end
        
        %--- spectrum concatenation ---
        if dCnt==1
            specComb = flipdim(specZoom,1);
        else
            specComb = [specComb; flipdim(specZoom,1)];
        end
    end
end
    
%--- visualization ---
vecLenSingle = maxI - minI + 1;
vecLenTotal  = length(specComb);
nrComb = 0.5:t1t2SelectN/(vecLenTotal-1):(t1t2SelectN+0.5);
plot(nrComb,specComb)
if flag.t1t2AmplShow        % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(nrComb,specComb);
else                        % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(nrComb,specComb);
    minY = t1t2.amplShowMin;
    maxY = t1t2.amplShowMax;
end
axis([minX maxX minY maxY])

%--- add lines ---
hold on
% zero, horizontal
plot([minX maxX],[0 0],'g')
% NR separation
for dCnt = 1:t1t2SelectN            % number of selected delays
    if dCnt==1
        plot((nrComb(vecLenSingle)+nrComb(vecLenSingle+1))/2 * [1 1],[minY maxY],'r')
    else
        plot(( (nrComb((dCnt-1)*vecLenSingle)+nrComb((dCnt-1)*vecLenSingle+1))/2) * [1 1],[minY maxY],'r')
    end
end
% integration limits, vertical, derivation of indices
[ppmWinMinI,ppmWinMaxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(t1t2.ppmWinMin,t1t2.ppmWinMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,abs(t1t2.spec(:,1)));
% lower integration limit
if ppmWinMinI-minI>=0                   % lower limit is within display range
    minOffset = ppmWinMinI-minI;        % offset from start of display window
    for dCnt = 1:t1t2SelectN            % number of selected delays
        plot(nrComb(vecLenSingle-minOffset+1+(dCnt-1)*vecLenSingle)*[1 1],[minY maxY],'g')
    end
end
% upper integration limit
if maxI-ppmWinMaxI>=0                   % upper limit is within display range
    maxOffset = maxI-ppmWinMaxI;        % offset from start of display window
    for dCnt = 1:t1t2SelectN            % number of selected delays
        if dCnt>1 || maxOffset>0        % avoid zero index for first line
            plot(nrComb(maxOffset+(dCnt-1)*vecLenSingle)*[1 1],[minY maxY],'g')
        end
    end
end
hold off

%--- axis labels ---
ylabel('Amplitude [a.u.]')
xlabel('Delays [1]')
    
%--- update success flag ---
f_done = 1;
