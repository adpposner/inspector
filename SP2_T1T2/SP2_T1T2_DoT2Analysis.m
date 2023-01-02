%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DoT2Analysis
%%
%%  Multi-exponential T2 analysis.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile t1t2 flag


FCTNAME = 'SP2_T1T2_DoT2Analysis';


%--- init read flag ---
f_succ = 0;

%--- consistency checks ---
if flag.t1t2AnaData<4                   % experimental data (FIDs or spectra)
    %--- check data existence ---
    if ~isfield(t1t2,'spec')
        if ~SP2_T1T2_DataLoadAndReco
            return
        end
    end

    %--- consistency checks ---
    if (flag.t1t2AnaMode && t1t2.anaTConstN>5) || ...
       (~flag.t1t2AnaMode && t1t2.anaTConstFlexN>5)
        fprintf('%s ->\nThe number of time constants must be <6. Program aborted.\n',FCTNAME);
        return
    end
else                                    % directly assigned problem
    if t1t2.anaTimeN~=t1t2.anaAmpN
        fprintf('%s ->\nInconsistent vector lengths detected (time %.0f, amplitude %.0f).\nProgram aborted.\n',...
                FCTNAME,t1t2.anaTimeN,t1t2.anaAmpN)
        return
    end
end

%--- amplitude extraction ---
% if flag.t1t2AnaData==1          % FID
%     if t1t2.anaFidMax>t1t2.anaFidMin
%         amplVec = mean(abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,:)));
%     else
%         amplVec = abs(t1t2.fid(t1t2.anaFidMin,:));
%     end
% elseif flag.t1t2AnaData<4       % spectra
%     amplVec = max(abs(t1t2.spec));
% else
%     amplVec = t1t2.anaAmp;
% end

if flag.t1t2AnaData==1          % FID
    %--- init amplitude vector ---
    t1t2SelectN = t1t2.nr;          % delay selection (so far: take all)
    t1t2Select  = 1:t1t2.nr;
    amplVec     = zeros(1,t1t2.nr); % init amplitude vector
    
    %--- amplitude extraction ---
    if flag.t1t2AnaFormat       % real part of FID
        if t1t2.anaFidMax>t1t2.anaFidMin
            amplVec = mean(real(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,:)));
        else
            amplVec = real(t1t2.fid(t1t2.anaFidMin,:));
        end
    else                        % magnitude FID
        if t1t2.anaFidMax>t1t2.anaFidMin
            amplVec = mean(abs(t1t2.fid(t1t2.anaFidMin:t1t2.anaFidMax,:)));
        else
            amplVec = abs(t1t2.fid(t1t2.anaFidMin,:));
        end
    end
elseif flag.t1t2AnaData<4       % spectra
    %--- init amplitude vector ---
    t1t2SelectN = t1t2.nr;          % delay selection (so far: take all)
    t1t2Select  = 1:t1t2.nr;
    amplVec     = zeros(1,t1t2.nr); % init amplitude vector
    
    %--- concatenation of selected ppm range ---
    for dCnt = 1:t1t2SelectN            % number of selected delays
        %--- t1t2 extraction: spectrum 1 ---
        if flag.t1t2AnaFormat==1        % real part
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(t1t2.ppmWinMin,t1t2.ppmWinMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,real(t1t2.spec(:,dCnt)));
        else                            % magnitude
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_T1T2_ExtractPpmRange(t1t2.ppmWinMin,t1t2.ppmWinMax,t1t2.ppmCalib,...
                                                                           t1t2.sw,abs(t1t2.spec(:,dCnt)));
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
        
        %--- spectrum analysis ---
        if flag.t1t2AnaData==2      % peak height
            amplVec(dCnt) = max(specZoom);
        else                        % peak integral
            amplVec(dCnt) = sum(specZoom);
        end
    end
else
    amplVec = t1t2.anaAmp;
end

%--- delay extraction ---
if flag.t1t2AnaData>3           % direct assignment
    t1t2.delays = t1t2.anaTime;
end

%--- verbose option ---
f_verbose = 0;
if f_verbose        % f_verbose
    options = optimset('Display','on');
else
    options = optimset('Display','off');
end

%--- parameter init ---
fineN           = 100;                % number of fine resolution points
delayExt        = 1.05;               % delay extension of fit (e.g. 1.05 for 5% extension)
t1t2.delaysFine = 0:delayExt*t1t2.delays(end)/(fineN-1):delayExt*t1t2.delays(end);

%--- consistency check ---
% if flag.t1t2AnaFitOffset
%     fprintf('%s ->\nOffsets are not supported yet for T2 fitting, sorry.\n',FCTNAME);
%     return
% end

%--- T2 analysis ---
if flag.t1t2AnaMode           % fixed T2 components
    %--- exit message ---
    fprintf('\n\nSORRY, THIS MODE IS NOT SUPPORTED YET.\n\n');
    return    
    
    if amplVec(end)>0
        ub     = 1e7*ones(1,t1t2.anaTConstN);               % upper bound
        lb     = zeros(1,t1t2.anaTConstN);                  % lower bound
    else
        ub     = zeros(1,t1t2.anaTConstN);                  % upper bound
        lb     = -1e7*ones(1,t1t2.anaTConstN);              % lower bound
    end
    switch t1t2.anaTConstN
        case 1
            %--- fit setup and execution ---
            coeffStart = [amplVec(end)-amplVec(1)];  % initial estimate
            [coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit('SP2_T1T2_FunExp01_T1fix_offset',coeffStart,t1t2.delays,amplVec,lb,ub,options);
                        
            %--- fit diagnostics ---
            SP2_Loc_FitDiagnostics(exitflag,output)
            
            %--- error analysis ---
            [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);
            
            %--- amplitude assignment ---
            t1t2.amplFit     = SP2_T1T2_FunExp01_T1fix_offset(coeffFit,t1t2.delays);
            t1t2.amplFitFine = SP2_T1T2_FunExp01_T1fix_offset(coeffFit,t1t2.satRecFine);
            
            % TO BE ADDED: INDIVIDUAL COMPONENTS
            
            
            
        case 2
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI         % init with neighbor && not 1st fit
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else                
                coeffStart = [(amplVec(end)-amplVec(1))/1.9 ...
                              (amplVec(end)-amplVec(1))/2.1];  % initial estimate
            end
            [t1t2.t1spec(ptCnt,:),t1t2.res2norm(ptCnt)] = lsqcurvefit('SP2_T1T2_FunExp02_T1fix_offset',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp02_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.delays);
            t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp02_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.satRecFine);
        case 3
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI         % init with neighbor && not 1st fit
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else                
                coeffStart = [(amplVec(end)-amplVec(1))/2.9 ...
                              (amplVec(end)-amplVec(1))/3.0 ...
                              (amplVec(end)-amplVec(1))/3.1];     % initial estimate
            end
            [t1t2.t1spec(ptCnt,:),t1t2.res2norm(ptCnt)] = lsqcurvefit('SP2_T1T2_FunExp03_T1fix_offset',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp03_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.delays);
            t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp03_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.satRecFine);
        case 4
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else
                if optCnt==1
                    coeffStart = (amplVec(end)-amplVec(1))/4 * ones(1,4);   % initial estimate
                else                % all other optimization steps
                    coeffStart = t1t2.t1spec(ptCnt,:) .* ...
                                (1+t1t2.anaOptAmpRg/2*t1t2.anaOptAmpRed^optAppl*(-1+2*rand(1,t1t2.satRecN)));
                end
            end
            [t1t2T1specOpt,t1t2.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_T1T2_FunExp04_T1fix',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            if optCnt==1
                t1t2.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp04_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp04_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            elseif t1t2.res2norm(ptCnt,optCnt)<t1t2.res2norm(ptCnt,optCnt-1)
                t1t2.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp04_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp04_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            end
        case 5
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else
                if optCnt==1        % initial estimate
                    coeffStart = (amplVec(end)-amplVec(1))/5 * ones(1,5);   
                else                % all other optimization steps
                    coeffStart = t1t2.t1spec(ptCnt,:) .* ...
                                (1+t1t2.anaOptAmpRg/2*t1t2.anaOptAmpRed^optAppl*(-1+2*rand(1,5)));
                end
            end
            [t1t2T1specOpt,t1t2.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_T1T2_FunExp05_T1fix',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            if optCnt==1
                t1t2.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp05_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp05_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            elseif t1t2.res2norm(ptCnt,optCnt)<t1t2.res2norm(ptCnt,optCnt-1)
                t1t2.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp05_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp05_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            end
        case 6
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else
                if optCnt==1        % initial estimate
                    coeffStart = (amplVec(end)-amplVec(1))/6 * ones(1,6);   
                else                % all other optimization steps
                    coeffStart = t1t2.t1spec(ptCnt,:) .* ...
                                (1+t1t2.anaOptAmpRg/2*t1t2.anaOptAmpRed^optAppl*(-1+2*rand(1,6)));
                end
            end
            [t1t2T1specOpt,t1t2.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_T1T2_FunExp06_T1fix',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            if optCnt==1
                t1t2.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp06_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp06_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            elseif t1t2.res2norm(ptCnt,optCnt)<t1t2.res2norm(ptCnt,optCnt-1)
                t1t2.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp06_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp06_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            end
        case 7
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else
                if optCnt==1        % initial estimate
                    coeffStart = (amplVec(end)-amplVec(1))/7 * ones(1,7);   
                else                % all other optimization steps
                    coeffStart = t1t2.t1spec(ptCnt,:) .* ...
                                (1+t1t2.anaOptAmpRg/2*t1t2.anaOptAmpRed^optAppl*(-1+2*rand(1,7)));
                end
            end
            [t1t2T1specOpt,t1t2.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_T1T2_FunExp07_T1fix',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            if optCnt==1
                t1t2.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp07_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp07_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            elseif t1t2.res2norm(ptCnt,optCnt)<t1t2.res2norm(ptCnt,optCnt-1)
                t1t2.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp07_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp07_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            end
        case 8
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI         % init with neighbor && not 1st fit
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else                
                coeffStart = [(amplVec(end)-amplVec(1))/7.7 ...
                              (amplVec(end)-amplVec(1))/7.8 ...
                              (amplVec(end)-amplVec(1))/7.9 ...
                              (amplVec(end)-amplVec(1))/8.0 ...
                              (amplVec(end)-amplVec(1))/8.1 ...
                              (amplVec(end)-amplVec(1))/8.2 ...
                              (amplVec(end)-amplVec(1))/8.3 ...
                              (amplVec(end)-amplVec(1))/8.4];     % initial estimate
            end
            [t1t2.t1spec(ptCnt,:),t1t2.res2norm(ptCnt)] = lsqcurvefit('SP2_T1T2_FunExp08_T1fix_offset',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp08_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.delays);
            t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp08_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.satRecFine);
        case 9
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI         % init with neighbor && not 1st fit
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else                
                coeffStart = [(amplVec(end)-amplVec(1))/8.6 ...
                              (amplVec(end)-amplVec(1))/8.7 ...
                              (amplVec(end)-amplVec(1))/8.8 ...
                              (amplVec(end)-amplVec(1))/8.9 ...
                              (amplVec(end)-amplVec(1))/9.0 ...
                              (amplVec(end)-amplVec(1))/9.1 ...
                              (amplVec(end)-amplVec(1))/9.2 ...
                              (amplVec(end)-amplVec(1))/9.3 ...
                              (amplVec(end)-amplVec(1))/9.4];     % initial estimate
            end
            [t1t2.t1spec(ptCnt,:),t1t2.res2norm(ptCnt)] = lsqcurvefit('SP2_T1T2_FunExp09_T1fix_offset',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp09_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.delays);
            t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp09_T1fix_offset(t1t2.t1spec(ptCnt,:),t1t2.satRecFine);
        case 10
            if flag.t1t2NeighInit && ptCnt>t1t2.anaMinI && optCnt==1                 % init with neighbor && not 1st fit
                % first optimization step
                coeffStart = t1t2.t1spec(ptCnt-1,:);
            else
                if optCnt==1        % initial estimate
                    coeffStart = (amplVec(end)-amplVec(1))/10 * ones(1,10);   
                else                % all other optimization steps
                    coeffStart = t1t2.t1spec(ptCnt,:) .* ...
                                (1+t1t2.anaOptAmpRg/2*t1t2.anaOptAmpRed^optAppl*(-1+2*rand(1,10)));
                end
            end
            [t1t2T1specOpt,t1t2.res2norm(ptCnt,optCnt)] = lsqcurvefit('SP2_T1T2_FunExp10_T1fix',coeffStart,t1t2.delays,amplVec,lb,ub,options);
            if optCnt==1
                t1t2.anaOptApplInd(ptCnt)    = 1;                 % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp10_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp10_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            elseif t1t2.res2norm(ptCnt,optCnt)<t1t2.res2norm(ptCnt,optCnt-1)
                t1t2.anaOptAppInd(ptCnt)     = optCnt;            % optimal index
                optAppl                    = optAppl + 1;       % applied (improved) optimization steps
                t1t2.t1spec(ptCnt,:)         = t1t2T1specOpt';
                t1t2.satRecSpecFit(ptCnt,:)  = SP2_T1T2_FunExp10_T1fix(t1t2T1specOpt,t1t2.delays);
                t1t2.satRecSpecFine(ptCnt,:) = SP2_T1T2_FunExp10_T1fix(t1t2T1specOpt,t1t2.satRecFine);
            end
    end 
else                    % flexible/open time components
    %--- T2 fitting limits ---
    t2min = 1;              % overall minimum T2 [ms]
    t2max = 1000;            % overall maximum T2 [ms]
    if flag.t1t2AnaFitOffset            % offset 
        if flag.t1t2AnaFlex1Fix         % flexible with 1st TC fixed

            %--- consistency check ---
            if t1t2.anaTConstFlexN<2
                fprintf('%s ->\nAt least 2 time constants are required for flexible fit\nwith single fixed TC. Program aborted.\n',FCTNAME);
                return
            end

            %--- T2 fitting procedure ---
            coeffStart          = (amplVec(1)-amplVec(end))/t1t2.anaTConstFlexN*ones(1,2*t1t2.anaTConstFlexN);      % starting coefficients, amplitudes
            coeffStart(2:2:end) = flipdim(t2max./(2*(1:t1t2.anaTConstFlexN)),2);                % initial estimate of time constants, small to t2max/2, shortest 1st
            lb          = zeros(1,2*t1t2.anaTConstFlexN);               % lower bound, amplitudes
            lb(2:2:end) = t2min;                                        % lower bound, T2's
            ub          = 1e10*ones(1,2*t1t2.anaTConstFlexN);           % upper bound, amplitude
            ub(2:2:end) = t2max;                                        % upper bound, T2's       
            eval(['[coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(''SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_OneFix_Offset'',coeffStart,t1t2.delays,amplVec,lb,ub,options);'])
            
            %--- fit diagnostics ---
            SP2_Loc_FitDiagnostics(exitflag,output)
            
            %--- error analysis ---
            [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);
            
            %--- amplitude / T2 fit extraction (for display)
            eval(['t1t2.amplFit     = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_OneFix_Offset(coeffFit,t1t2.delays);'])
            eval(['t1t2.amplFitFine = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_OneFix_Offset(coeffFit,t1t2.delaysFine);'])
            t1t2.amplSepFitFine = zeros(length(t1t2.delaysFine),t1t2.anaTConstFlexN+1);       % init array of individual T2 components

            %--- add fixed time constant to fitting result ---
            coeffFit(2*t1t2.anaTConstFlexN+1) = coeffFit(2*t1t2.anaTConstFlexN);        % move offset one position back
            coeffFit(2*t1t2.anaTConstFlexN)   = t1t2.anaTConstFlex1Fix;                 % add fixed time constant
            for tCnt = 1:t1t2.anaTConstFlexN
                t1t2.amplSepFitFine(:,tCnt) = SP2_T1T2_T2FunExp01(coeffFit(2*(tCnt-1)+1:2*tCnt),t1t2.delaysFine);
            end
            t1t2.amplSepFitFine(:,end) = ones(length(t1t2.delaysFine),1)*coeffFit(end);       % offset

            %--- amplitude / T2 extraction ---
            t1t2.fitAmpl        = coeffFit(1:2:length(coeffFit));                   % keep amplitudes, discard T1's
            fitAmplErr          = coeffErr(1:2:length(coeffErr));                   % keep amplitude errors, discard T1 errors
            t1t2.fitAmplPortion = 100*t1t2.fitAmpl/sum(t1t2.fitAmpl(1:end-1));      % amplitude portion [% of total]
            t1t2.fitTConst      = coeffFit(2:2:length(coeffFit));                   % keep T1s, discard amplitudes
            fitTConstErr        = coeffErr(2:2:length(coeffErr));                   % keep T1 errors, discard amplitude errors
            fitOffsetErr        = coeffErr(end);                             % offset error
        else                            % all TC's flexible
            %--- T2 fitting procedure ---
            coeffStart          = [(amplVec(1)-amplVec(end))/t1t2.anaTConstFlexN*ones(1,2*t1t2.anaTConstFlexN) 0];       % starting coefficients, amplitudes
            coeffStart(2:2:end) = flipdim(t2max./(2*(1:t1t2.anaTConstFlexN)),2);                 % initial estimate of time constants, small to t2max/2, shortest 1st
            lb          = [zeros(1,2*t1t2.anaTConstFlexN) -1e10];   % lower bound, amplitudes
            lb(2:2:end) = t2min;                                    % lower bound, T2's
            ub          = 1e10*ones(1,2*t1t2.anaTConstFlexN+1);     % upper bound, amplitude
            ub(2:2:end) = t2max;                                    % upper bound, T2's       
            % working version without info printout:
            % eval(['[coeffFit,res2norm] = lsqcurvefit(''SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_Offset'',coeffStart,t1t2.delays,amplVec,lb,ub,options);'])
            eval(['[coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(''SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_Offset'',coeffStart,t1t2.delays,amplVec,lb,ub,options);'])

            %--- fit diagnostics ---
            SP2_Loc_FitDiagnostics(exitflag,output)
            
            %--- error analysis ---
            [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);
            
            %--- amplitude / T2 fit extraction (for display)
            eval(['t1t2.amplFit     = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_Offset(coeffFit,t1t2.delays);'])
            eval(['t1t2.amplFitFine = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_Offset(coeffFit,t1t2.delaysFine);'])
            t1t2.amplSepFitFine = zeros(length(t1t2.delaysFine),t1t2.anaTConstFlexN+1);       % init array of individual T2 components
            for tCnt = 1:t1t2.anaTConstFlexN
                t1t2.amplSepFitFine(:,tCnt) = SP2_T1T2_T2FunExp01(coeffFit(2*(tCnt-1)+1:2*tCnt),t1t2.delaysFine);
            end
            t1t2.amplSepFitFine(:,end) = ones(length(t1t2.delaysFine),1)*coeffFit(end);       % offset
            
            %--- amplitude / T2 extraction ---
            t1t2.fitAmpl        = coeffFit(1:2:length(coeffFit));                   % keep amplitudes, discard T1's
            fitAmplErr          = coeffErr(1:2:length(coeffErr));                   % keep amplitude errors, discard T1 errors
            t1t2.fitAmplPortion = 100*t1t2.fitAmpl/sum(t1t2.fitAmpl(1:end-1));      % amplitude portion [% of total]
            t1t2.fitTConst      = coeffFit(2:2:length(coeffFit));                   % keep T1s, discard amplitudes
            fitTConstErr        = coeffErr(2:2:length(coeffErr));                   % keep T1 errors, discard amplitude errors
            fitOffsetErr        = coeffErr(end);                             % offset error
        end
    else                                % offset not included in fit
        if flag.t1t2AnaFlex1Fix         % flexible with 1st TC fixed

            %--- consistency check ---
            if t1t2.anaTConstFlexN<2
                fprintf('%s ->\nAt least 2 time constants are required for flexible fit\nwith single fixed TC. Program aborted.\n',FCTNAME);
                return
            end

            %--- T2 fitting procedure ---
            coeffStart          = (amplVec(1)-amplVec(end))/t1t2.anaTConstFlexN*ones(1,2*(t1t2.anaTConstFlexN-1)+1);     % starting coefficients, amplitudes
            coeffStart(2:2:end) = flipdim(t2max./(2*(1:(t1t2.anaTConstFlexN-1))),2);                 % initial estimate of time constants, small to t2max/2, shortest 1st
            lb          = zeros(1,2*(t1t2.anaTConstFlexN-1)+1);         % lower bound, amplitudes
            lb(2:2:end) = t2min;                                        % lower bound, T2's
            ub          = 1e10*ones(1,2*(t1t2.anaTConstFlexN-1)+1);     % upper bound, amplitude
            ub(2:2:end) = t2max;                                        % upper bound, T2's       
            eval(['[coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(''SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '_OneFix'',coeffStart,t1t2.delays,amplVec,lb,ub,options);'])
            
            %--- fit diagnostics ---
            SP2_Loc_FitDiagnostics(exitflag,output)

            %--- error analysis ---
            [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);

            %--- add fixed time constant to fitting result ---
            coeffFit(2*t1t2.anaTConstFlexN) = t1t2.anaTConstFlex1Fix;       % add fixed time constant to fitting result
        
            %--- amplitude / T2 fit extraction (for display)
            eval(['t1t2.amplFit     = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '(coeffFit,t1t2.delays);'])
            eval(['t1t2.amplFitFine = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '(coeffFit,t1t2.delaysFine);'])
            t1t2.amplSepFitFine = zeros(length(t1t2.delaysFine),t1t2.anaTConstFlexN);       % init array of individual T2 components
            for tCnt = 1:t1t2.anaTConstFlexN
                t1t2.amplSepFitFine(:,tCnt) = SP2_T1T2_T2FunExp01(coeffFit(2*(tCnt-1)+1:2*tCnt),t1t2.delaysFine);
            end

            %--- amplitude / T2 extraction ---
            t1t2.fitAmpl        = coeffFit(1:2:length(coeffFit));       % keep amplitudes, discard T1's
            fitAmplErr          = coeffErr(1:2:length(coeffErr));       % keep amplitude errors, discard T1 errors
            t1t2.fitAmplPortion = 100*t1t2.fitAmpl/sum(t1t2.fitAmpl);   % amplitude portion [% of total]
            t1t2.fitTConst      = coeffFit(2:2:length(coeffFit));       % keep T1s, discard amplitudes
            fitTConstErr        = coeffErr(2:2:length(coeffErr));       % keep T1 errors, discard amplitude errors
        else                            % all TC's flexible
            %--- T2 fitting procedure ---
            coeffStart          = (amplVec(1)-amplVec(end))/t1t2.anaTConstFlexN*ones(1,2*t1t2.anaTConstFlexN);       % starting coefficients, amplitudes
            coeffStart(2:2:end) = flipdim(t2max./(2*(1:t1t2.anaTConstFlexN)),2);                 % initial estimate of time constants, small to t2max/2, shortest 1st
            lb          = zeros(1,2*t1t2.anaTConstFlexN);               % lower bound, amplitudes
            lb(2:2:end) = t2min;                                        % lower bound, T2's
            ub          = 1e10*ones(1,2*t1t2.anaTConstFlexN);           % upper bound, amplitude
            ub(2:2:end) = t2max;                                        % upper bound, T2's       
            eval(['[coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = lsqcurvefit(''SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) ''',coeffStart,t1t2.delays,amplVec,lb,ub,options);'])
        
            %--- fit diagnostics ---
            SP2_Loc_FitDiagnostics(exitflag,output)

            %--- error analysis ---
            [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);

            %--- amplitude / T2 fit extraction (for display)
            eval(['t1t2.amplFit     = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '(coeffFit,t1t2.delays);'])
            eval(['t1t2.amplFitFine = SP2_T1T2_T2FunExp0' num2str(t1t2.anaTConstFlexN) '(coeffFit,t1t2.delaysFine);'])
            t1t2.amplSepFitFine = zeros(length(t1t2.delaysFine),t1t2.anaTConstFlexN);       % init array of individual T2 components
            for tCnt = 1:t1t2.anaTConstFlexN
                t1t2.amplSepFitFine(:,tCnt) = SP2_T1T2_T2FunExp01(coeffFit(2*(tCnt-1)+1:2*tCnt),t1t2.delaysFine);
            end

            %--- amplitude / T2 extraction ---
            t1t2.fitAmpl        = coeffFit(1:2:length(coeffFit));       % keep amplitudes, discard T1's
            fitAmplErr          = coeffErr(1:2:length(coeffFit));       % keep amplitude errors, discard T1 errors
            t1t2.fitAmplPortion = 100*t1t2.fitAmpl/sum(t1t2.fitAmpl);   % amplitude portion [% of total]
            t1t2.fitTConst      = coeffFit(2:2:length(coeffFit));       % keep T1s, discard amplitudes
            fitTConstErr        = coeffErr(2:2:length(coeffFit));       % keep T1 errors, discard amplitude errors
        end
    end
end
fprintf('\nT2 analysis completed.\n');
    
%--- info printout ---
if length(amplVec)<10
    fprintf('Time points (%.0f):   %s ms\n',length(amplVec),SP2_Vec2PrintStr(t1t2.delays));
elseif length(amplVec)<100
    fprintf('Time points (%.0f):  %s ms\n',length(amplVec),SP2_Vec2PrintStr(t1t2.delays));
else
    fprintf('Time points (%.0f): %s ms\n',length(amplVec),SP2_Vec2PrintStr(t1t2.delays));
end
fprintf('Amplitudes:        %s a.u.\n',SP2_Vec2PrintStr(amplVec));
fprintf('Fitting res2norm:  %.0f\n',res2norm);
fprintf('T2 time constants: %s ms\n',SP2_Vec2PrintStr(t1t2.fitTConst));
if flag.t1t2AnaFitOffset            % offset 
    fprintf('T2 amplitudes:     %s a.u.\n',SP2_Vec2PrintStr(t1t2.fitAmpl(1:end-1),0));
    fprintf('T2 ampl. ratio:    %s%%\n',SP2_Vec2PrintStr(t1t2.fitAmplPortion(1:end-1)));
    fprintf('Fit offset:        %s a.u.\n',SP2_Vec2PrintStr(t1t2.fitAmpl(end),0));
else
    fprintf('T2 amplitudes:     %s a.u.\n',SP2_Vec2PrintStr(t1t2.fitAmpl,0));
    fprintf('T2 ampl. ratio:    %s%%\n',SP2_Vec2PrintStr(t1t2.fitAmplPortion));
end

%--- figure creation ---
t2AnaFh = figure;
if flag.t1t2AnaData==1                                      % FID
    set(t2AnaFh,'NumberTitle','off','Name',sprintf(' T2 Analysis of FID Amplitudes'),...
        'Position',[314 114 700 500],'Color',[1 1 1]);
elseif flag.t1t2AnaData==2                                  % peak heights
    set(t2AnaFh,'NumberTitle','off','Name',sprintf(' T2 Analysis of Peak Heights'),...
        'Position',[314 114 700 500],'Color',[1 1 1]);
elseif flag.t1t2AnaData==3                                  % peak integral
    set(t2AnaFh,'NumberTitle','off','Name',sprintf(' T2 Analysis of Peak Integrals'),...
        'Position',[314 114 700 500],'Color',[1 1 1]);
elseif flag.t1t2AnaData>3                                   % direct assignment
    set(t2AnaFh,'NumberTitle','off','Name',sprintf(' T2 Analysis of Directly Assigned Vectors'),...
        'Position',[314 114 700 500],'Color',[1 1 1]);
end
hold on
if flag.t1t2AnaFitOffset                                    % fit offset included
    colorMat = colormap(hsv(t1t2.anaTConstFlexN+1));
    for tCnt = 1:t1t2.anaTConstFlexN
        plot(t1t2.delaysFine,t1t2.amplSepFitFine(:,tCnt),'Color',colorMat(tCnt,:));
        if ~flag.t1t2AnaMode && flag.t1t2AnaFlex1Fix && tCnt==t1t2.anaTConstFlexN  
            legendCell{tCnt} = sprintf('T2 %.1f ms (fix), Ampl. %.0f %s %.0f',...
                                       t1t2.fitTConst(tCnt),t1t2.fitAmpl(tCnt),char(177),fitAmplErr(tCnt));
        else    
            legendCell{tCnt} = sprintf('T2 %.1f %s %.1f ms, Ampl. %.0f %s %.0f',...
                                       t1t2.fitTConst(tCnt),char(177),fitTConstErr(tCnt),...
                                       t1t2.fitAmpl(tCnt),char(177),fitAmplErr(tCnt));
        end
    end
    plot(t1t2.delaysFine,t1t2.amplSepFitFine(:,t1t2.anaTConstFlexN+1),'Color',colorMat(t1t2.anaTConstFlexN+1,:));
    plot(t1t2.delays,amplVec,'ro')
    plot(t1t2.delaysFine,t1t2.amplFitFine,'Color',[0 0 0])
    legendCell{t1t2.anaTConstFlexN+1} = sprintf('offset %.0f %s %.0f',...
                                                t1t2.fitAmpl(t1t2.anaTConstFlexN+1),char(177),fitOffsetErr);
    legendCell{t1t2.anaTConstFlexN+2} = 'data points';
    legendCell{t1t2.anaTConstFlexN+3} = 'total fit';

else        % no fit offset
    colorMat = colormap(hsv(t1t2.anaTConstFlexN));
    for tCnt = 1:t1t2.anaTConstFlexN
        plot(t1t2.delaysFine,t1t2.amplSepFitFine(:,tCnt),'Color',colorMat(tCnt,:));
        if ~flag.t1t2AnaMode && flag.t1t2AnaFlex1Fix && tCnt==t1t2.anaTConstFlexN  
            legendCell{tCnt} = sprintf('T2 %.1f ms (fix), Ampl. %.0f %s %.0f',...
                                       t1t2.fitTConst(tCnt),t1t2.fitAmpl(tCnt),char(177),fitAmplErr(tCnt));
        else    
            legendCell{tCnt} = sprintf('T2 %.1f %s %.1f ms, Ampl. %.0f %s %.0f',...
                                       t1t2.fitTConst(tCnt),char(177),fitTConstErr(tCnt),...
                                       t1t2.fitAmpl(tCnt),char(177),fitAmplErr(tCnt));
        end
    end
    plot(t1t2.delays,amplVec,'ro')
    plot(t1t2.delaysFine,t1t2.amplFitFine,'Color',[0 0 0])
    legendCell{t1t2.anaTConstFlexN+1} = 'data points';
    legendCell{t1t2.anaTConstFlexN+2} = 'total fit';
end
legend(legendCell)
hold off
xlabel('Delays [ms]')
ylabel('Amplitude [a.u.]')
% before modification, 12/20/2015
% [minXdata maxXdata minYdata maxYdata] = SP2_IdealAxisValues(t1t2.delays,amplVec);
% [minXfine maxXfine minYfine maxYfine] = SP2_IdealAxisValues(t1t2.delaysFine,t1t2.amplFitFine);
% for tCnt = 1:t1t2.anaTConstFlexN
%     if tCnt==1
%         [minXfake maxXfake minYsep maxYsep] = SP2_IdealAxisValues(t1t2.delaysFine,t1t2.amplSepFitFine(:,tCnt));
%     else
%         [minXfake maxXfake minYtmp maxYtmp] = SP2_IdealAxisValues(t1t2.delaysFine,t1t2.amplSepFitFine(:,tCnt));
%         if minYtmp<minYsep
%             minYsep = minYtmp;
%         end
%         if maxYtmp>maxYsep
%             maxYsep = maxYtmp;
%         end
%     end
% end
% axis([min(minXdata,minXfine) max(maxXdata,maxXfine) min([minYdata minYfine minYsep]) max([maxYdata maxYfine maxYsep])])

% modified, 12/20/2015, temporary until separate amplitude parameters are
% defined for FID/spectral amplitudes and amplitude for T2 fit
[minX maxX minY maxY] = SP2_IdealAxisValuesXGap(t1t2.delays,amplVec);
if flag.t1t2AmplShow
    axis([minX maxX minY maxY])
else
    axis([minX maxX t1t2.amplShowMin t1t2.amplShowMax])
end

%--- error display (for software development ---
if flag.verbose
    fprintf('coeffErr = %s\n',SP2_Vec2PrintStr(coeffErr'));
end

%--- update read flag ---
f_succ = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L    F U N C T I O N S                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------
%--- fit diagnostics ---
%-----------------------
function SP2_Loc_FitDiagnostics(exitflag,output)

    %--- fit quality assessment ---
    fprintf('\nFit diagnostics:\n');
    switch exitflag
        case 1
            fprintf('lsqcurvefit converged to a solution.\n');
        case 2 
            fprintf('Change in X too small.\n');
        case 3  
            fprintf('Change in RESNORM too small.\n');
        case 4  
            fprintf('Computed search direction too small.\n');
        case 0
            fprintf('Too many function evaluations or iterations.\n');
        case -1  
            fprintf('Stopped by output/plot function.');
        case -2  
            fprintf('Bounds are inconsistent.');
    end

    %--- info printout ---
    fprintf('firstorderopt: %.4f\n',output.firstorderopt);
    fprintf('iterations:    %.0f\n',output.iterations);
    fprintf('funcCount:     %.0f\n',output.funcCount);
    fprintf('cgiterations:  %.0f\n',output.iterations);
    fprintf('algorithm:     %s\n\n',output.algorithm);

    
%----------------------       
%--- error analysis ---
%----------------------
function [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian);
    
    % ERROR 1: STANDARD DEVIATION OF THE OBSERVATIONS AROUND THE REGRESSION CURVE
    % by Peter Perkins, The MathWorks, Inc. 
    % I think you probably mean the standard deviation of the observations around
    % the regression curve (or surface), is that right? The usual estimate is
    % norm(residuals)/sqrt(n-p), where n is the number of observations, and p is the
    % number of estimated parameters. The squared norm of the residuals is the
    % second output from LSQCURVEFIT, so take the square root of that.
    sdErr = sqrt(res2norm);
    fprintf('SD around fit: %.2f = norm(residuals)/sqrt(#observations - #fitpars)\n',sdErr);

    % ERROR 2: STANDARD ERRORS OF INDIVIDUAL FITTING PARAMETERS
    % http://comp.soft-sys.matlab.narkive.com/Jq6b64k7/errors-of-parameters-deduced-using-lsqcurvefit
    % Post by john
    % I have just used lsqcurvefit to obtain 4 parameters to my equation, i
    % was wondering if anyone could help on how to find the errors for the
    % individual parameters.
    % Hi John -
    % 
    % I assume you mean "standard errors". The most common thing to do is to
    % approximate the Hessian using the Jacobian, and use the inverse of that
    % as an approximation to the covariance matrix:
    % 
    % [Q,R] = qr(J,0);
    % mse = sum(abs(r).^2)/(size(J,1)-size(J,2));
    % Rinv = inv(R);
    % Sigma = Rinv*Rinv'*mse;
    % se = sqrt(diag(Sigma));
    % 
    % where r is the residual vector and J is the Jacobian, both outputs of
    % LSQCURVEFIT. The usual assumptions about independent errors and large
    % sample size and so forth apply.
    % 
    % If you have the Statistics Toolbox, you can also get confidence
    % intervals using NLPARCI, and prediction/confidence intervals for the
    % fitted curve using NLPREDCI.
    % 
    % Hope this helps.
    % 
    % - Peter Perkins
    % The MathWorks, Inc.
    [Q,R]    = qr(jacobian,0);
    mse      = sum(abs(residual).^2)/(size(jacobian,1)-size(jacobian,2));
    Rinv     = inv(R);
    Sigma    = Rinv*Rinv'*mse;
    coeffErr = full(sqrt(diag(Sigma)));



