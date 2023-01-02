%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoT1Analysis_L1Norm
%%
%%  Multi-exponential T1 analysis based on l1-norm.
%%
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_DoT1Analysis_L1Norm';

%--- neighbor init ---
flag.mmNeighInit = 1;           % init fit with result of neighboring optimization 

%--- info printout ---
f_verbose = 0;

%--- init read flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mm,'spec')
    if ~SP2_MM_DataReco
        return
    end
end

%--- consistency checks ---
if mm.anaTOneN>10 && mm.anaTOneN~=15 && mm.anaTOneN~=20 && ...
   mm.anaTOneN~=30 && mm.anaTOneN~=40 && mm.anaTOneN~=50
    fprintf('%s ->\nThe number of T1 components must be 1..10, 15, 20, 30, 40 or 50. Program aborted.\n',FCTNAME);
    return
end

%--- info printout ---
tic
fprintf('%s started ...\n',FCTNAME);

%--- ppm extraction ---
if flag.mmAnaFrequMode      % full sweep width
    anaPpmMin = -mm.sw/2 + mm.ppmCalib;
    anaPpmMax = mm.sw/2  + mm.ppmCalib;
else                        % direct
    anaPpmMin = mm.anaFrequMin;
    anaPpmMax = mm.anaFrequMax;
end
[mm.anaMinI,mm.anaMaxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(anaPpmMin,anaPpmMax,mm.ppmCalib,...
                                                                         mm.sw,abs(mm.spec(:,1)));
                                                                     
%--- offset removal: amplitude ---
if 1
    mm.satRecDelays = mm.satRecDelays - mm.satRecDelays(1);                                                                     
end
                                                                     
%--- multi-exponential T1 analysis ---
mm.nFit           = mm.anaMaxI-mm.anaMinI+1;                    % number of spectral points (ie. T1 fits)
if flag.mmAnaTOneMode           % fixed T1 components
    mm.t1spec = zeros(mm.nspecC,mm.anaTOneN);                   % T1 spectral matrix
else                            % flexible T1s
    mm.t1spec = zeros(mm.nspecC,mm.anaTOneFlexN);               % T1 spectral matrix
end
fineN             = 100;                                        % number of fine resolution points
mm.t1specFit      = zeros(mm.nspecC,fineN);                     % fitted T1 spectral matrix
mm.res2norm       = zeros(1,mm.anaTOneN);                       % fit residuals
mm.satRecSpecFit  = complex(zeros(mm.nspecC,mm.satRecN));       % exponential fitting result at original SR delays (for difference calculation)
mm.satRecFine     = 0:max(mm.satRecDelays)/(fineN-1):max(mm.satRecDelays);  % delay grid for fitting result
% note that the order is not necessarily increasing
mm.satRecSpecFine = complex(zeros(mm.nspecC,fineN));        % exponential fitting result at fine resolution (for display)
mm.res2norm       = 1e15*ones(mm.nspecC,mm.anaOptN);        % fit residues, dimensions: spectral, optimization
mm.anaOptApplInd  = zeros(1,mm.nspecC);                     % optimal index eventually applied

%--- best L1-norm results ---
mm.l1normBestT       = zeros(mm.nspecC,mm.anaTOneFlexN);        % best L1-norm fit: time constants 
mm.l1normBestAmp     = zeros(mm.nspecC,mm.anaTOneFlexN);        % best L1-norm fit: amplitudes
mm.l1normBestFitOpt  = 1e10*ones(mm.nspecC,1);                  % best L1-norm fit: fit optimality
mm.l1normBestFitIter = zeros(mm.nspecC,1);                      % number of optimization steps

% if flag.mmAnaTOneMode           % fixed T1 components
%     mm.t1fit = repmat(mm.anaTOne,[mm.nspecC 1]);        % direct copy
% else                            % flexible T1 components
    mm.t1fit = zeros(mm.nspecC,mm.anaTOneFlexN);        % matrix init
% end
if f_verbose        % f_verbose
    options = optimset('Display','on');
else
    options = optimset('Display','off');
end

%--- data selection ---
if flag.mmAnaFormat         % real
    mm.satRecSpec = real(mm.spec);
else                        % magnitude
    mm.satRecSpec = abs(mm.spec);
end

%--- offset removal: amplitude ---
if 1
    for delayCnt = 1:mm.anaTOneN
        mm.satRecSpec(:,end-(delayCnt-1)) = mm.satRecSpec(:,end-(delayCnt-1)) - mm.satRecSpec(:,1);
    end
end

%--- box car smoothing ---
if mm.boxCar>1
    %--- reload ---
    if ~SP2_MM_DataReco
        return
    end
    
    %--- info printout ---
    fprintf('Box car windowing applied.\n');
        
    for srCnt = 1:mm.satRecN
        %--- apply box car averaging ---
        mmSpecTmp = mm.satRecSpec(:,srCnt);
        for iCnt = 1:size(mm.spec,1)
            mmSpecTmp(iCnt) = mean(mm.satRecSpec(max(iCnt-round(mm.boxCar/2),1): ...
                                                 min(iCnt+round(mm.boxCar/2),size(mm.spec,1)),srCnt));
        end
        mm.satRecSpec(:,srCnt) = mmSpecTmp;
    end
end

%--- L1-norm parameter init ---
nRelT      = mm.anaTOneFlexN;   % number of considered, most relevant time constants
Tmin       = 0.2;               % minimum limit of time constant range
Tmax       = 2;               % maximum limit of time constant range
TstepMin   = 0.1;               % minimum step size for multi-grid analysis
TstepMax   = 1;                 % maximum step size for multi-grid analysis
TstepN     = 10;                % number of multi-grid steps
Tshift     = 0.05;              % global loggingfile shift of T grid
TshiftN    = 3;                 % number of T grid shifts

%--- amplitude fit: parameter init ---
mmAnaTOneN = mm.anaTOneFlexN;   % transfer: flexible to fixed

%--- serial T1 analysis ---
mm.xOff = mm.satRecDelays(1);
for ptCnt = mm.anaMinI:mm.anaMaxI
    %--- init / reset optimization counter for window reduction ---
    optAppl = 1;
    
    %--- info printout ---
    if mod(ptCnt-mm.anaMinI+1,50)==0
        if f_verbose
            fprintf('\n\nANALYSIS %.0f of %.0f ...\n\n\n',ptCnt-mm.anaMinI+1,mm.nFit);
        else
            fprintf('%.0f of %.0f spectral positions completed (%.1f min)\n',...
                    ptCnt-mm.anaMinI+1,mm.nFit,toc/60)
        end
    end

    %--- test data assignment ---
    %     yVec = mm.spec(ptCnt,:);
    %     yVec      = 1 - 5*exp(-mm.satRecDelays/0.010) - 10*exp(-mm.satRecDelays/0.5) - 2*exp(-mm.satRecDelays/1.5);
    %     interpFac = 10;
    %     mm.satRecDelaysFit = mm.satRecDelays(1):(mm.satRecDelays(end)-mm.satRecDelays(1))/(interpFac*(mm.satRecN-1)):mm.satRecDelays(end);
    %--- data extraction ---
    yVec = mm.satRecSpec(ptCnt,:);
    mm.yOff = yVec(1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %--- multiple grid l1-norm estimate of relevant time constants ---
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %--- multi-grid loop ---
    for stepCnt = 1:TstepN
        for shiftCnt = 1:TshiftN
            % find time constants
            T = Tmin:stepCnt*(TstepMax-TstepMin)/(TstepN-1):Tmax + (shiftCnt-1)*Tshift;
            % T = Tmin + (Tmax-Tmin)*rand(20,1)';
            [relT,relAmp,yFit,yRelevant,fitOpt,negFlag] = MultiExpT1Fit_L1Norm(mm.satRecDelays,mm.satRecFine,yVec,T,nRelT);

            % keep if better then previous fits
            if fitOpt<mm.l1normBestFitOpt(ptCnt) && ~negFlag
                mm.l1normBestT(ptCnt,:)     = relT;
                mm.l1normBestAmp(ptCnt,:)   = relAmp;
                mm.l1normBestFitOpt(ptCnt)  = fitOpt;
                mm.l1normBestFitIter(ptCnt) = mm.l1normBestFitIter(ptCnt) + 1;
            end
        end
    end
    
    %--- transfer result ---
    mm.t1spec(ptCnt,:)         = mm.l1normBestAmp(ptCnt,:);    % amplitudes for dominant T1 components
    mm.t1fit(ptCnt,:)          = mm.l1normBestT(ptCnt,:);      % dominant T1 components
    mm.satRecSpecFit(ptCnt,:)  = yVec;                         % original data vector
    mm.satRecSpecFine(ptCnt,:) = yRelevant;                    % best fit (refined temporal grid)      
    
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %--- apply derived T constants to derive amplitudes ---
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %--- optimization loop ---
%     for optCnt = 1:mm.anaOptN
%         %--- fitting procedures ---
%         if yVec(end)>0
%             ub     = 1e7*ones(1,mmAnaTOneN);               % upper bound
%             lb     = zeros(1,mmAnaTOneN);                  % lower bound
%         else
%             ub     = zeros(1,mmAnaTOneN);                  % upper bound
%             lb     = -1e7*ones(1,mmAnaTOneN);              % lower bound
%         end
%         switch mmAnaTOneN
%             case 1
%                 if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                     coeffStart = mm.t1spec(ptCnt-1,:);
%                 else                
%                     coeffStart = [yVec(end)-yVec(1)];  % initial estimate
%                 end
%                 [mm.t1spec(ptCnt,:),mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp01_T1fix',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                 mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp01_T1fix(mm.t1spec(ptCnt,:),mm.satRecDelays);
%                 mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp01_T1fix(mm.t1spec(ptCnt,:),mm.satRecFine);
%             case 2
%                 if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                     coeffStart = mm.t1spec(ptCnt-1,:);
%                 else                
%                     coeffStart = [(yVec(end)-yVec(1))/1.9 ...
%                                   (yVec(end)-yVec(1))/2.1];  % initial estimate
%                 end
%                 [mm.t1spec(ptCnt,:),mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp02_T1fix',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                 mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp02_T1fix(mm.t1spec(ptCnt,:),mm.satRecDelays);
%                 mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp02_T1fix(mm.t1spec(ptCnt,:),mm.satRecFine);
%             case 3
%                 if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                     coeffStart = mm.t1spec(ptCnt-1,:);
%                 else                
%                     coeffStart = [(yVec(end)-yVec(1))/2.9 ...
%                                   (yVec(end)-yVec(1))/3.0 ...
%                                   (yVec(end)-yVec(1))/3.1];     % initial estimate
%                 end
%                 [mm.t1spec(ptCnt,:),mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp03_T1fix',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                 mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp03_T1fix(mm.t1spec(ptCnt,:),mm.satRecDelays);
%                 mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp03_T1fix(mm.t1spec(ptCnt,:),mm.satRecFine);
%             case 4
%                 if flag.mmNeighInit && ptCnt>mm.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
%                     % first optimization step
%                     coeffStart = mm.t1spec(ptCnt-1,:);
%                 else
%                     if optCnt==1
%                         coeffStart = (yVec(end)-yVec(1))/4 * ones(1,4);   % initial estimate
%                     else                % all other optimization steps
%                         coeffStart = mm.t1spec(ptCnt,:) .* ...
%                                     (1+mm.anaOptAmpRg/2*mm.anaOptAmpRed^optAppl*(-1+2*rand(1,mm.satRecN)));
%                     end
%                 end
%                 [mmT1specOpt,mm.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_MM_FunExp04_T1fix',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                 if optCnt==1
%                     mm.anaOptApplInd(ptCnt)    = 1;                 % optimal index
%                     optAppl                    = optAppl + 1;       % applied (improved) optimization steps
%                     mm.t1spec(ptCnt,:)         = mmT1specOpt';
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp04_T1fix(mmT1specOpt,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp04_T1fix(mmT1specOpt,mm.satRecFine);
%                 elseif mm.res2norm(ptCnt,optCnt)<mm.res2norm(ptCnt,optCnt-1)
%                     mm.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
%                     optAppl                    = optAppl + 1;       % applied (improved) optimization steps
%                     mm.t1spec(ptCnt,:)         = mmT1specOpt';
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp04_T1fix(mmT1specOpt,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp04_T1fix(mmT1specOpt,mm.satRecFine);
%                 end
%             case 5
%                 if flag.mmNeighInit && ptCnt>mm.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
%                     % first optimization step
%                     coeffStart = mm.t1spec(ptCnt-1,:);
%                 else
%                     if optCnt==1        % initial estimate
%                         coeffStart = (yVec(end)-yVec(1))/5 * ones(1,5);   
%                     else                % all other optimization steps
%                         coeffStart = mm.t1spec(ptCnt,:) .* ...
%                                     (1+mm.anaOptAmpRg/2*mm.anaOptAmpRed^optAppl*(-1+2*rand(1,5)));
%                     end
%                 end
%                 [mmT1specOpt,mm.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_MM_FunExp05_T1fix',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                 if optCnt==1
%                     mm.anaOptApplInd(ptCnt)    = 1;                 % optimal index
%                     optAppl                    = optAppl + 1;       % applied (improved) optimization steps
%                     mm.t1spec(ptCnt,:)         = mmT1specOpt';
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp05_T1fix(mmT1specOpt,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp05_T1fix(mmT1specOpt,mm.satRecFine);
%                 elseif mm.res2norm(ptCnt,optCnt)<mm.res2norm(ptCnt,optCnt-1)
%                     mm.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
%                     optAppl                    = optAppl + 1;       % applied (improved) optimization steps
%                     mm.t1spec(ptCnt,:)         = mmT1specOpt';
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp05_T1fix(mmT1specOpt,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp05_T1fix(mmT1specOpt,mm.satRecFine);
%                 end
%             otherwise
%                 fprintf('Number of T1 components exceeds implementation!\n');
%                 return
%         end 
%     end
end
fprintf('T1 analysis completed.\n');
    
%--- FID calculation of T1 components ---
if flag.mmAnaTOneMode           % fixed T1 components
    mm.t1fid = complex(zeros(mm.nspecC,mmAnaTOneN+1));         % T1 FID matrix
    for eCnt = 1:mmAnaTOneN
       mm.t1fid(:,eCnt) = ifft(ifftshift(mm.t1spec(:,eCnt),1),[],1);
    end
else
    mm.t1fid = complex(zeros(mm.nspecC,mm.anaTOneFlexN+1));     % T1 FID matrix
    for eCnt = 1:mm.anaTOneFlexN
       mm.t1fid(:,eCnt) = ifft(ifftshift(mm.t1spec(:,eCnt),1),[],1);
    end
end

%--- info printout ---
tTotal = toc;
fprintf('%s done (%.0f s / %.1f min).\n',FCTNAME,tTotal,tTotal/60);

%--- update read flag ---
f_succ = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   L O C A L    F U N C T I O N S                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [relT,relAmp,yFit,yRelevant,fitOpt,negFlag] = MultiExpT1Fit_L1Norm(t,tFineReg,y,T,nRelT)


%--- debuggin flag ---
f_debug = 0;

%--- row/column handling ---
if size(t,1)==1
    t = t';
end
if size(y,1)==1
    y = y';
end

%--- parameter handling ---
tlen     = length(t);
% tFineReg = t(1):(t(end)-t(1))/100:t(end);          % finer, regular time vector

%--- optimization ---
A      = 1-exp(-t*(1./T));
Afun   = @(x) A*x;
Atfun  = @(x) A'*x;
% x0    = zeros(length(T),1);
x0     = A'*y;
ampVec = SP2_l1eq_pd(x0, Afun, Atfun, y, 1e-3);

%--- fitting result ---
yFit = 0;
for Tcnt = 1:length(T)
    yFit = yFit + ampVec(Tcnt)*(1-exp(-tFineReg/T(Tcnt)));
end

%--- result printout ---
if f_debug
    for Tcnt = 1:length(T)
        fprintf('%i: T %.2fsec, amplitude %.5f\n',Tcnt,T(Tcnt),ampVec(Tcnt));
    end
end

%--- sorting of time components ---
[sortAmp,sortInd] = sort(ampVec,'descend');
% fprintf('\nMajor 5 components:\n');
% for Tcnt = 1:5
%     fprintf('%i: T %.2fsec (#%i), amplitude %.5f\n',Tcnt,T(sortInd(Tcnt)),...
%             sortInd(Tcnt),ampVec(sortInd(Tcnt)))
% end

%--- extraction of relevant components ---
ampThresh = 0.1;                                            % amplitude threshold
% nRelevant = length(find(sortAmp>ampThresh*sortAmp(1)));     % relevant time constants
% fprintf('\nDominant time components (>%.0f%% of max.): %i\n',100*ampThresh,nRelevant);
if f_debug
    fprintf('\n%i most relevant time components:\n',nRelT);
    for Tcnt = 1:nRelT
        fprintf('%i: T %.2fsec (#%i), rel. amplitude %.5f\n',Tcnt,T(sortInd(Tcnt)),...
                sortInd(Tcnt),ampVec(sortInd(Tcnt))/ampVec(sortInd(1)))
    end
end

%--- assignment of output vectors ---
relT   = T(sortInd(1:nRelT));
relAmp = ampVec(sortInd(1:nRelT));

%--- relevant fitting result ---
yRelevant = 0;
for Tcnt = 1:nRelT
    yRelevant = yRelevant + ampVec(sortInd(Tcnt))*(1-exp(-tFineReg/T(sortInd(Tcnt))));
end

%--- quality measures ---
fitOpt = sum(abs((yFit-yRelevant)/max(yFit)));      % normalization by max. of data vector * # of data points
if f_debug
    fprintf('Fit optimality ( 1/(fit-relevant) ): %.3f\n',fitOpt);
end

%--- check relevance of negative components ---
ampNegInd = find(ampVec<0);                     % index vector
if isempty(ampNegInd)
    ampNegMax = 0;
else
    ampNegMax = max(abs(ampVec(ampNegInd)));    % max. negative value
end
if ampNegMax < (ampThresh/2)*sortAmp(1)
    if f_debug
        fprintf('Negative amplitudes remain below half the relevance limit.\n');
    end
    negFlag = 0;        % ok
else
    if f_debug
        fprintf('Negative amplitudes exceed half the relevance limit (%.1f>%.1f).\n',...
                ampNegMax,(ampThresh/2)*sortAmp(1))
    end
    negFlag = 1;        % problem likely
end

%--- check for negative amplitudes in return vector ---
if any(relAmp<0)
    negFlag = 1;
end

%--- result visualization ---
if f_debug
    figure
    hold on
    plot(t,y,'*')
    plot(tFineReg,yFit,'r')
    plot(tFineReg,yRelevant,'g')
    hold off
    legend('data','full fit','relevant','Location','SouthEast')
end







