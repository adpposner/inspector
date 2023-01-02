%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoT1Analysis
%%
%%  Multi-exponential T1 analysis.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag


FCTNAME = 'SP2_MM_DoT1Analysis';


flag.mmNeighInit = 1;           % init fit with result of neighboring optimization 
f_verbose        = 0;

%--- init read flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mm,'spec')
    if ~SP2_MM_DataReco
        return
    end
end

% %--- consistency checks ---
% if mm.anaTOneN>10 && mm.anaTOneN~=15 && mm.anaTOneN~=20 && ...
%    mm.anaTOneN~=30 && mm.anaTOneN~=40 && mm.anaTOneN~=50
%     fprintf('%s ->\nThe number of T1 components must be 1..10, 15, 20, 30, 40 or 50. Program aborted.\n',FCTNAME);
%     return
% end

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

%--- offset removal ---
if 1
%     mm.satRecDelays = mm.satRecDelays - mm.satRecDelays(1);
    mm.satRecDelays = mm.satRecDelays + 0.030;       % 05/27/2015 data set for R21 (02/2015)    
end
                                                                     
%--- multi-exponential T1 analysis ---
mm.nFit           = mm.anaMaxI-mm.anaMinI+1;                    % number of spectral points (ie. T1 fits)
if flag.mmAnaTOneMode           % fixed T1 components
    mm.t1spec = zeros(mm.nspecC,mm.anaTOneN);                   % T1 spectral matrix
else                            % flexible T1s
    mm.t1spec = zeros(mm.nspecC,2*mm.anaTOneFlexN);               % T1 spectral matrix
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

if flag.mmAnaTOneMode           % fixed T1 components
    mm.t1fit = repmat(mm.anaTOne,[mm.nspecC 1]);        % direct copy
else                            % flexible T1 components
    mm.t1fit = zeros(mm.nspecC,mm.anaTOneFlexN);        % matrix init
end
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

% %--- box car smoothing ---
% if mm.boxCar>1
%     %--- (re)load spectra ---
%     if ~SP2_MM_DataReco
%         return
%     end
%     
%     %--- info printout ---
%     fprintf('Box car windowing applied.\n');
%     
%     for srCnt = 1:mm.satRecN
%         %--- apply box car averaging ---
%         mmSpecTmp = mm.satRecSpec(:,srCnt);
%         for iCnt = 1:size(mm.spec,1)
%             mmSpecTmp(iCnt) = mean(mm.satRecSpec(max(iCnt-round(mm.boxCar/2),1): ...
%                                                  min(iCnt+round(mm.boxCar/2),size(mm.spec,1)),srCnt));
%         end
%         mm.satRecSpec(:,srCnt) = mmSpecTmp;
%     end
% end

%--- cloud handling ---
if mm.boxCar>1
    mm.cloudRgLow  = round((mm.boxCar-1)/2);
    mm.cloudRgHigh = floor((mm.boxCar-1)/2);
else
    mm.cloudRgLow  = 0;
    mm.cloudRgHigh = 0;
end
mm.cloudN = mm.anaOptN * mm.boxCar;     % number of data points per fit

%--- create fitting function ---
fitFctDir  = 'C:\Users\juchem\Matlab\matlab_cj\INSPECTOR_v2\SP2_MM\SP2_MM_FitFunctions\';
if flag.mmAnaTOneMode           % fixed T1 mode
    fitFctName = sprintf('SP2_MM_FunExp%03.0f_T1fix',mm.anaTOneN);
    fitFctPath = [fitFctDir fitFctName];
    if ~SP2_CheckFileExistenceR(fitFctPath)
        if ~SP2_MM_FunExpT1fixCreateFile(fitFctDir,fitFctName,mm.anaTOneN)
            return
        end
        addpath(fitFctDir)
    end
else                            % flexible T1 mode
    fitFctName = sprintf('SP2_MM_FunExp%03.0f_T1flex',mm.anaTOneFlexN);
    fitFctPath = [fitFctDir fitFctName];
    if ~SP2_CheckFileExistenceR(fitFctPath)
        if ~SP2_MM_FunExpT1flexCreateFile(fitFctDir,fitFctName,mm.anaTOneFlexN)
            return
        end
        addpath(fitFctDir)
    end
end

%--- offset removal: amplitude ---
if 0
    for delayCnt = 1:mm.satRecN
        mm.satRecSpec(:,end-(delayCnt-1)) = mm.satRecSpec(:,end-(delayCnt-1)) - mm.satRecSpec(:,1);
    end
end

%--- serial T1 analysis ---
mm.xOff = mm.satRecDelays(1);
for ptCnt = mm.anaMinI:mm.anaMaxI
    %--- init / reset optimization counter for window reduction ---
    optAppl = 1;
    
    %--- info printout ---
    if mod(ptCnt-mm.anaMinI+1,100)==0
        if f_verbose
            fprintf('\n\nANALYSIS %.0f of %.0f ...\n\n\n',ptCnt-mm.anaMinI+1,mm.nFit);
        else
            portion = (ptCnt-mm.anaMinI+1)/mm.nFit;
            fprintf('%.0f of %.0f frequencies completed (%.1f%%, %.1f min left)\n',...
                    ptCnt-mm.anaMinI+1,mm.nFit,100*portion,(toc/portion)*(1-portion)/60)
%             fprintf('ptCnt %.0f: portion %.3f, toc %.1f sec\n',ptCnt,portion,toc);
        end
    end


    
% %--- info printout ---
% tTotal = toc;
% fprintf('%s done (%.0f s / %.1f min).\n',FCTNAME,tTotal,tTotal/60
    
    
    %--- test data assignment ---
%     yVec = mm.spec(ptCnt,:);
%     yVec      = 1 - 5*exp(-mm.satRecDelays/0.010) - 10*exp(-mm.satRecDelays/0.5) - 2*exp(-mm.satRecDelays/1.5);
%     interpFac = 10;
%     mm.satRecDelaysFit = mm.satRecDelays(1):(mm.satRecDelays(end)-mm.satRecDelays(1))/(interpFac*(mm.satRecN-1)):mm.satRecDelays(end);
    
    %--- data selection ---
    if mm.boxCar==1     % single frequency position
        xVec = mm.satRecDelays;
        yVec = mm.satRecSpec(ptCnt,:);
        mm.yOff = yVec(1);
    else
        xVec = [];      % delay vector
        yVec = [];      % amplitude vector
        for cCnt = 1:mm.boxCar
            ptInd = ptCnt-mm.cloudRgLow+(cCnt-1);       % confine to min/max index range
            if ptInd>=mm.anaMinI && ptInd<=mm.anaMaxI
                xVec  = [xVec mm.satRecDelays];
                yVec  = [yVec mm.satRecSpec(ptInd,:)];
            end
        end
        mm.yOff = yVec(1);      % better: 1) original frequency position or 2) mean over all points
    end    
    
    %--- optimization loop ---
    for optCnt = 1:mm.anaOptN
        %--- fitting procedures ---
        if flag.mmAnaTOneMode           % fixed T1 components
            %--- init limits ---
            if ptCnt==mm.anaMinI && optCnt==1
                if yVec(end)>0
                    ub = 1e7*ones(1,mm.anaTOneN);               % upper bound
                    lb = zeros(1,mm.anaTOneN);                  % lower bound
                else
                    ub = zeros(1,mm.anaTOneN);                  % upper bound
                    lb = -1e7*ones(1,mm.anaTOneN);              % lower bound
                end
            end
            
            %--- init starting conditions ---
            if flag.mmNeighInit && ptCnt>mm.anaMinI && optCnt==1                 % init with neighbor && 1st fit iteration
                % first optimization step
                coeffStart = mm.t1spec(ptCnt-1,:);
            else
                if optCnt==1
                    coeffStart = (yVec(end)-yVec(1))/mm.anaTOneN * ones(1,mm.anaTOneN);   % initial estimate
                else                % all other optimization steps
                    coeffStart = mm.t1spec(ptCnt,:) .* ...
                                (1+mm.anaOptAmpRg/2*mm.anaOptAmpRed^optAppl*(-1+2*rand(1,mm.anaTOneN)));
                end
            end
            
            %--- T1 analysis ---
            [mmT1specOpt,mm.res2norm(ptCnt,optCnt)] = lsqcurvefit(fitFctName,coeffStart,xVec,yVec,lb,ub,options);
            if optCnt==1
                mm.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                mm.t1spec(ptCnt,:)         = mmT1specOpt';
                eval(['mm.satRecSpecFit(ptCnt,:)  = ' fitFctName '(mmT1specOpt,mm.satRecDelays);'])
                eval(['mm.satRecSpecFine(ptCnt,:) = ' fitFctName '(mmT1specOpt,mm.satRecFine);'])
            elseif mm.res2norm(ptCnt,optCnt)<mm.res2norm(ptCnt,optCnt-1)
                mm.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                mm.t1spec(ptCnt,:)         = mmT1specOpt';
                eval(['mm.satRecSpecFit(ptCnt,:)  = ' fitFctName '(mmT1specOpt,mm.satRecDelays);'])
                eval(['mm.satRecSpecFine(ptCnt,:) = ' fitFctName '(mmT1specOpt,mm.satRecFine);'])
            end
        else                    % flexible/open T1 components
            %--- init limits ---
            t1min = 0.001;      % overall minimum T1
            t1max = 10;         % overall maximum T1
            if yVec(end)>0
                ub                                 = 1e7*ones(1,2*mm.anaTOneFlexN);   % upper bound
                ub(2:2:2*round(mm.anaTOneFlexN/2)) = mm.anaTOneFlexThMin;
                lb                                 = zeros(1,2*mm.anaTOneFlexN);      % lower bound
                lb(2*round(mm.anaTOneFlexN/2)+2:2:2*mm.anaTOneFlexN) = mm.anaTOneFlexThMax;
            else
                ub     = zeros(1,mm.anaTOneFlexN);                  % upper bound
                lb     = -1e7*ones(1,mm.anaTOneFlexN);              % lower bound
            end
            
            %--- init starting conditions ---
            if flag.mmNeighInit && ptCnt>mm.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = mm.t1spec(ptCnt-1,:);
            else
                if optCnt==1
                    coeffStart = (yVec(end)-yVec(1))/mm.anaTOneFlexN * ones(1,2*mm.anaTOneFlexN);
                    coeffStart(2:2:2*round(mm.anaTOneFlexN/2)) = mm.anaTOneFlexThMin/2;       % initial estimate
                    coeffStart(2*round(mm.anaTOneFlexN/2)+2:2:2*mm.anaTOneFlexN) = 2* mm.anaTOneFlexThMax;       % initial estimate
                else                % all other optimization steps
                    coeffStart = mm.t1spec(ptCnt,:) .* ...
                                (1+mm.anaOptAmpRg/2*mm.anaOptAmpRed^optAppl*(-1+2*rand(1,2*mm.anaTOneFlexN)));
                end
            end
            
            %--- T1 analysis ---
            [mmT1specOpt,mm.res2norm(ptCnt,optCnt)] = lsqcurvefit(fitFctName,coeffStart,xVec,yVec,lb,ub,options);
            if optCnt==1
                mm.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                mm.t1spec(ptCnt,:)         = mmT1specOpt';
                eval(['mm.satRecSpecFit(ptCnt,:)  = ' fitFctName '(mmT1specOpt,mm.satRecDelays);'])
                eval(['mm.satRecSpecFine(ptCnt,:) = ' fitFctName '(mmT1specOpt,mm.satRecFine);'])
            elseif mm.res2norm(ptCnt,optCnt)<mm.res2norm(ptCnt,optCnt-1)
                mm.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                mm.t1spec(ptCnt,:)         = mmT1specOpt';
                eval(['mm.satRecSpecFit(ptCnt,:)  = ' fitFctName '(mmT1specOpt,mm.satRecDelays);'])
                eval(['mm.satRecSpecFine(ptCnt,:) = ' fitFctName '(mmT1specOpt,mm.satRecFine);'])
            end
            
%             switch mm.anaTOneFlexN
%                 case 1
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [yVec(end)-yVec(1) mm.anaTOneFlexThMin/2];  % initial estimate
%                     end
%                     ub         = 1e7*ones(1,2);        % upper bound
%                     ub(2)      = mm.anaTOneFlexThMin;
%                     lb         = zeros(1,2);            % lower bound
%                     lb(2)      = t1min;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp01_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp01_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp01_offset(coeffFit,mm.satRecFine);
%                 case 2
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/1.9 mm.anaTOneFlexThMin/2 ...
%                                       (yVec(end)-yVec(1))/2.1 1.5*mm.anaTOneFlexThMax];  % initial estimate
%                     end
%                     ub         = 1e7*ones(1,4);         % upper bound
%                     ub(2)      = mm.anaTOneFlexThMin;
%                     ub(4)      = t1max;
%                     lb         = zeros(1,4);             % lower bound
%                     lb(2)      = t1min;                 
%                     lb(4)      = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp02_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp02_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp02_offset(coeffFit,mm.satRecFine);
%                 case 3
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/2.9 mm.anaTOneFlexThMin/3 ...
%                                       (yVec(end)-yVec(1))/3.0 2*mm.anaTOneFlexThMin/3 ...
%                                       (yVec(end)-yVec(1))/3.1 1.5*mm.anaTOneFlexThMax];  % initial estimate
%                     end
%                     ub         = 1e7*ones(1,6);         % upper bound
%                     ub(2:2:4)  = mm.anaTOneFlexThMin;
%                     ub(6)      = t1max;
%                     lb         = zeros(1,6);            % lower bound
%                     lb(2:2:4)  = t1min;
%                     lb(6)      = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp03_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp03_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp03_offset(coeffFit,mm.satRecFine);
%                 case 4
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/3.9 mm.anaTOneFlexThMin/3 ...
%                                       (yVec(end)-yVec(1))/4.0 2*mm.anaTOneFlexThMin/3 ...
%                                       (yVec(end)-yVec(1))/4.1 1.5*mm.anaTOneFlexThMax ...
%                                       (yVec(end)-yVec(1))/4.2 3*mm.anaTOneFlexThMax];       % initial estimate
%                     end
%                     ub         = 1e7*ones(1,8);        % upper bound
%                     ub(2:2:4)  = mm.anaTOneFlexThMin;
%                     ub(6:2:8)  = t1max;
%                     lb         = zeros(1,8);            % lower bound
%                     lb(2:2:4)  = t1min;
%                     lb(6:2:8)  = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp04_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp04_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp04_offset(coeffFit,mm.satRecFine);
%                 case 5
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/4.8 mm.anaTOneFlexThMin/4 ...
%                                       (yVec(end)-yVec(1))/4.9 mm.anaTOneFlexThMin/2 ...
%                                       (yVec(end)-yVec(1))/5.0 3*mm.anaTOneFlexThMin/4 ...
%                                       (yVec(end)-yVec(1))/5.1 1.5*mm.anaTOneFlexThMax ...
%                                       (yVec(end)-yVec(1))/5.2 3*mm.anaTOneFlexThMax];  % initial estimate
%                     end
%                     ub         = 1e7*ones(1,10);        % upper bound
%                     ub(2:2:6)  = mm.anaTOneFlexThMin;
%                     lb         = zeros(1,10);           % lower bound
%                     lb(8:2:10) = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp05_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp05_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp05_offset(coeffFit,mm.satRecFine);
%                 case 6
%                     coeffStart = [(yVec(end)-yVec(1))/5.8 mm.anaTOneFlexThMin/4 ...
%                                   (yVec(end)-yVec(1))/5.9 mm.anaTOneFlexThMin/2 ...
%                                   (yVec(end)-yVec(1))/6.0 3*mm.anaTOneFlexThMin/4 ...
%                                   (yVec(end)-yVec(1))/6.1 1.5*mm.anaTOneFlexThMax ...
%                                   (yVec(end)-yVec(1))/6.2 2*mm.anaTOneFlexThMax ...
%                                   (yVec(end)-yVec(1))/6.3 3*mm.anaTOneFlexThMax];  % initial estimate
%                     ub         = 1e7*ones(1,12);       % upper bound
%                     ub(2:2:6)  = mm.anaTOneFlexThMin;
%                     lb         = zeros(1,12);           % lower bound
%                     lb(8:2:12) = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp06_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp06_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp06_offset(coeffFit,mm.satRecFine);
%                 case 7
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/6.7 mm.anaTOneFlexThMin/5 ...
%                                       (yVec(end)-yVec(1))/6.8 2*mm.anaTOneFlexThMin/5 ...
%                                       (yVec(end)-yVec(1))/6.9 3*mm.anaTOneFlexThMin/5 ...
%                                       (yVec(end)-yVec(1))/7.0 4*mm.anaTOneFlexThMin/5 ...
%                                       (yVec(end)-yVec(1))/7.1 1.5*mm.anaTOneFlexThMax ...
%                                       (yVec(end)-yVec(1))/7.2 2*mm.anaTOneFlexThMax ...
%                                       (yVec(end)-yVec(1))/7.3 3*mm.anaTOneFlexThMax];  % initial estimate
%                     end
%                     ub          = 1e7*ones(1,14);       % upper bound
%                     ub(2:2:8)   = mm.anaTOneFlexThMin;
%                     lb          = zeros(1,14);           % lower bound
%                     lb(10:2:14) = mm.anaTOneFlexThMax;
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp07_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp07_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp07_offset(coeffFit,mm.satRecFine);
%                 case 8
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/7.7 9.7 ...
%                                       (yVec(end)-yVec(1))/7.8 9.8 ...
%                                       (yVec(end)-yVec(1))/7.9 9.9 ...
%                                       (yVec(end)-yVec(1))/8.0 10 ...
%                                       (yVec(end)-yVec(1))/8.1 10.1 ...
%                                       (yVec(end)-yVec(1))/8.2 10.2 ...
%                                       (yVec(end)-yVec(1))/8.3 10.3 ...
%                                       (yVec(end)-yVec(1))/8.4 10.4];  % initial estimate
%                     end
%                     ub = 1e7*ones(1,17);       % upper bound
%                     lb = zeros(1,17);           % lower bound
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp08_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp08_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp08_offset(coeffFit,mm.satRecFine);
%                 case 9
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/8.6 9.6 ...
%                                       (yVec(end)-yVec(1))/8.7 9.7 ...
%                                       (yVec(end)-yVec(1))/8.8 9.8 ...
%                                       (yVec(end)-yVec(1))/8.9 9.9 ...
%                                       (yVec(end)-yVec(1))/9.0 10 ...
%                                       (yVec(end)-yVec(1))/9.1 10.1 ...
%                                       (yVec(end)-yVec(1))/9.2 10.2 ...
%                                       (yVec(end)-yVec(1))/9.3 10.3 ...
%                                       (yVec(end)-yVec(1))/9.4 10.4];  % initial estimate
%                     end
%                     ub = 1e7*ones(1,19);       % upper bound
%                     lb = zeros(1,19);           % lower bound
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp09_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp09_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp09_offset(coeffFit,mm.satRecFine);
%                 case 10
%                     if flag.mmNeighInit && ptCnt>mm.anaMinI         % init with neighbor && not 1st fit
%                         coeffStart = mm.t1spec(ptCnt-1,:);
%                     else                
%                         coeffStart = [(yVec(end)-yVec(1))/9.5 9.5 ...
%                                       (yVec(end)-yVec(1))/9.6 9.6 ...
%                                       (yVec(end)-yVec(1))/9.7 9.7 ...
%                                       (yVec(end)-yVec(1))/9.8 9.8 ...
%                                       (yVec(end)-yVec(1))/9.9 9.9 ...
%                                       (yVec(end)-yVec(1))/10.0 10.0 ...
%                                       (yVec(end)-yVec(1))/10.1 10.1 ...
%                                       (yVec(end)-yVec(1))/10.2 10.2 ...
%                                       (yVec(end)-yVec(1))/10.3 10.3 ...
%                                       (yVec(end)-yVec(1))/10.4 10.4];  % initial estimate
%                     end
%                     ub = 1e7*ones(1,21);       % upper bound
%                     lb = zeros(1,21);           % lower bound
%                     [coeffFit,mm.res2norm(ptCnt)] = lsqcurvefit('SP2_MM_FunExp10_offset',coeffStart,mm.satRecDelays,yVec,lb,ub,options);
%                     mm.satRecSpecFit(ptCnt,:)  = SP2_MM_FunExp10_offset(coeffFit,mm.satRecDelays);
%                     mm.satRecSpecFine(ptCnt,:) = SP2_MM_FunExp10_offset(coeffFit,mm.satRecFine);
%             end
%             mm.t1spec(ptCnt,:) = coeffFit(1:2:end);       % keep amplitudes, discard T1's
%             mm.t1fit(ptCnt,:)  = coeffFit(2:2:end);       % keep T1s, discard amplitudes
        end
    end
end
fprintf('T1 analysis completed.\n');
    
%--- FID calculation of T1 components ---
if flag.mmAnaTOneMode           % fixed T1 components
    mm.t1fid = complex(zeros(mm.nspecC,mm.anaTOneN+1));         % T1 FID matrix
    for eCnt = 1:mm.anaTOneN
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
