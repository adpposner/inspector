%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloMasterScript
%% 
%%  Template master script to array Monte-Carlo analyses.
%%
%%  04-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_MCarloMasterScript';


%--- target selelction ---
f_mcFit  = 0;                           % data selection, 1: fit from reference LCM analysis, 0: experimental target

%--- general parameters ---
mcSteps  = 2;                           % number of MC simulations (not arrayed)

%--- number of spectral points through ZF ---
specZf   = [2048];                 % vector, spetral zero-filling

%--- noise range ---
noiseRg  = {[10 12]};           % cell, [min max] noise range in [ppm]

%--- noise amplitude ---
noiseFac = [2];                       % vector, noise power relative to original target spectrum 

%--- percentage spread ----             
% note that 'Init' flag is set automatically in this script, potentially
% introduce variable here to make switchable 
% Alternatively, the spread is effectively disabled if a zero value is assigned
% (compare SP2_LCM_AnaDoMonteCarloInVivo.m). This might be a second way.
initSpr  = [20];                  % vector, init with different starting conditions [%]




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M    S T A R T                                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- dimension handling ---
noiseRgN  = length(noiseRg);
specZfN   = length(specZf);
noiseFacN = length(noiseFac);
initSprN  = length(initSpr);

%--- consistency check ---
if any(find(noiseFac<2)) && f_mcFit==1      % experimental spectrum and noise scaling of 1
    fprintf('Experimental data requires some noise amplification for MC simulations. Program aborted.\n');
    return
end

%--- start clock ---
tStart = tic;       % start clock

%--- keep SPX parameter settings for later reset ---
lcmPpmNoiseMin    = lcm.ppmNoiseMin;            % minimum of noise window [ppm]
lcmPpmNoiseMax    = lcm.ppmNoiseMax;            % maximum of noise window [ppm]
flagLcmSpecZf     = flag.lcmSpecZf;             % flag: zero-filling
lcmSpecZf         = lcm.specZf;                 % zero-filling dimension
flagLcmMCarloInit = flag.lcmMCarloInit;         % flag: initialize with spread
lcmMcInitSpread   = lcm.mc.initSpread;          % relative spread [%]
lcmMcNoiseFac     = lcm.mc.noiseFac;            % noise amplification factor in MC simulation
lcmMcN            = lcm.mc.n;                   % number of MC simulations
flagLcmSaveLog    = flag.lcmSaveLog;            % flag: write LCM analysis-specific log files
flagLcmMCarloCont = flag.lcmMCarloCont;         % continue earlier analysis
flagLcmMCarloRef  = flag.lcmMCarloRef;          % perform reference analysis


%--- set SPX parameters for analysis ---
flag.lcmMCarloData = f_mcFit;      % 1: fit, 0: experimental
lcm.mc.n           = mcSteps;      % set number of MC simulations
flag.lcmSpecZf     = 1;            % enable ZF
flag.lcmMCarloInit = 1;            % flag: initialize with spread
flag.lcmSaveLog    = 1;            % save LCM analysis-specific log file
flag.lcmMCarloCont = 0;            % continuation disabled in script mode
flag.lcmMCarloRef  = 1;            % perform reference analysis


%--- perform array of MC analyses ---
totCnt = 0;                 % total analysis counter
for zfCnt = 1:specZfN
    for nrCnt = 1:noiseRgN
        for nfCnt = 1:noiseFacN
            for inCnt = 1:initSprN
                %--- update MC analysis counter ---
                totCnt = totCnt + 1;

                %--- info printout ---
                fprintf('\n\n---  ARRAYED MONTE-CARLO ANALYSIS %03i OF %03i  ---\n',totCnt,specZfN*noiseRgN*noiseFacN*initSprN);
                fprintf('ZF %.0f (%.0f of %.0f)\n',specZf(zfCnt),zfCnt,specZfN);
                fprintf('noise region %s (%.0f of %.0f)\n',SP2_Vec2PrintStr(noiseRg{nrCnt},3),nrCnt,noiseRgN);
                fprintf('noise factor %.0f (%.0f of %.0f)\n',noiseFac(nfCnt),nfCnt,noiseFacN);
                fprintf('init spread %.0f%% (%.0f of %.0f)\n\n',initSpr(inCnt),inCnt,initSprN);

                %--- set parameters ---
                lcm.specZF        = specZf(zfCnt);
                lcm.ppmNoiseMin   = noiseRg{nrCnt}(1);
                lcm.ppmNoiseMax   = noiseRg{nrCnt}(2);
                lcm.mc.noiseFac   = noiseFac(nfCnt);
                lcm.mc.initSpread = initSpr(inCnt);

                %--- create directory string ---
                noiseMinStr = SP2_SubstStrPart(SP2_Vec2PrintStr(noiseRg{nrCnt}(1),3,0),'.','p');
                noiseMaxStr = SP2_SubstStrPart(SP2_Vec2PrintStr(noiseRg{nrCnt}(2),3,0),'.','p');
                mcDirName   = sprintf('%04i_ZF%.0f_NoiseMin%sMax%sPpm_NoiseAmp%.0f_Spread%sPerc',...
                                      totCnt,specZf(zfCnt),noiseMinStr,noiseMaxStr,...
                                      noiseFac(nfCnt),SP2_Vec2PrintStr(initSpr(inCnt),0,0));

                %--- perform MC analysis --- 
                if ~SP2_LCM_AnaDoMonteCarloInVivo(mcDirName)
                    fprintf('%s failed at zfCnt=%.0f, nrCnt=%.0f, nfCnt=%.0f, inCnt=%.0f\n\n',...
                            FCTNAME,zfCnt,nrCnt,nfCnt,inCnt)
                    return
                end
                
                %--- periodically close figures ---
                SP2_LCM_CloseLcmFigures;
            end
        end
    end
end

%--- reset SPX parameters ---
lcm.ppmNoiseMin    = lcmPpmNoiseMin;
lcm.ppmNoiseMax    = lcmPpmNoiseMax;
flag.lcmSpecZf     = flagLcmSpecZf;
lcm.specZf         = lcmSpecZf;
flag.lcmMCarloInit = flagLcmMCarloInit;
lcm.mc.initSpread  = lcmMcInitSpread;
lcm.mc.noiseFac    = lcmMcNoiseFac;
lcm.mc.n           = lcmMcN;
flag.lcmSaveLog    = flagLcmSaveLog;
flag.lcmMCarloCont = flagLcmMCarloCont;        
flag.lcmMCarloRef  = flagLcmMCarloRef;          


%--- info printout ---
fprintf('\n%s completed: %.0f steps, %.1f min / %.1f h\n',FCTNAME,...
        totCnt,toc(tStart)/60,toc(tStart)/60/60)

%--- window update ---
SP2_LCM_LCModelMain



end
