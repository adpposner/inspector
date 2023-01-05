%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SerialMetabAnalysis
%% 
%%  Serial (batch) LCModel analysis of simulated brain spectrum including
%%  white noise.
%%
%%  Note 1: The noise power remains unchanged, but it is re-created for 
%%          every LCModel analysis, i.e. it is analysis-specific.
%%  Note 2: All SPX parameter need to be set properly, especially the
%%          brain spectrum synthesis, the LCModel basis file and the
%%          corresponding metabolite selection for LCM
%%  
%%  The purpose of this script is to test and calibrate the CRLB under
%%  ideal conditions for which they should match the SD of a serial
%%  metabolite quantification.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global sim lcm flag fmfig

FCTNAME = 'SP2_LCM_SerialMetabAnalysis';


%--- parameter selection ---
f_lb    = flag.lcmAnaLb;        % show LB fitting result
f_gb    = flag.lcmAnaGb;        % show GB fitting result
f_shift = flag.lcmAnaShift;     % show shift fitting result
f_phc0  = flag.lcmAnaPhc0;      % show PHC0 fitting result

%--- spin system ---
noisePwr  = 0.01224;                  % noise power per sqrt(bandwidth), compare simulation page
% metabCell = {[0.0, 1.0*1e3], ...    % metabolite cell: singlet name, frequency [ppm], T1, T2, concentration
%              [2.0, 2.0*1e3], ...
%              [3.0, 3.0*1e3]};
% metabCell = {[0.0, 1.0*1e1]};

metabCell  = {[0.0, 1.0*1e1], ...        % metabolite cell: singlet name, frequency [ppm], T1, T2, concentration
              [1.0, 1.5*1e1], ...
              [2.0, 2.0*1e1], ...
              [3.0, 2.5*1e1]};

%--- analysis parameters ---
nAna  = 100;         % number of LCModel analyses

%--- file handling ---
calibDir  = 'C:\Users\juchem\analysis\MRS_CRLB\CRLB_Calib\';
calibFile = 'CRLB_CalibAna_Singlet3ppm_LB20Hz_NoisePwr100_26May2016.txt';                                % result summary


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     P R O G R A M     S T A R T                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- confirm selected parameter settings ---
flag.lcmData = 4;       % synthesis
sim.noiseAmp = noisePwr;

%--- create and init result file ---
calibPath = [calibDir calibFile];
rUnit = fopen(calibPath,'w');
fprintf(rUnit, 'CRLB CALIBRATION ANALYSIS\n');
fprintf(rUnit, 'date         = %s\n',datestr(now));
fprintf(rUnit, 'sim.noiseAmp = %.5f\n',sim.noiseAmp);
fclose(rUnit);

%--- init statistics parameters ---
concMat     = zeros(nAna,lcm.fit.appliedN);         % concentration matrix
concCrlbMat = zeros(nAna,lcm.fit.appliedN);         % corresponding CRLB matrix
concSdTrace = zeros(nAna,lcm.fit.appliedN);         % SD development over the course of # of iterations
if f_lb
    lbMat     = zeros(nAna,lcm.fit.appliedN);       % concentration matrix
    lbCrlbMat = zeros(nAna,lcm.fit.appliedN);       % corresponding CRLB matrix
end
if f_shift
    shiftMat     = zeros(nAna,lcm.fit.appliedN);    % concentration matrix
    shiftCrlbMat = zeros(nAna,lcm.fit.appliedN);    % corresponding CRLB matrix
end
if f_phc0
    phc0Mat     = zeros(nAna,1);                    % concentration matrix
    phc0CrlbMat = zeros(nAna,1);                    % corresponding CRLB matrix
end

%--- INSPECTOR current figure ---
% set(0,'CurrentFigure',fmfig)

%--- serial LCModel analysis ---
SP2_LCM_LCModelMain
for nCnt = 1:nAna
    %--- info printout ---
    fprintf('\n\nANALYSIS %03i OF %03i\n\n',nCnt,nAna);

    %--- synthesis of brain MRS including noise ---
%     SP2_Sim_SimulationMain
%     if ~SP2_Sim_DoMetabSimBrain
%         fprintf('%s ->\nSimulation of brain spectrum failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
%     if ~SP2_Sim_DoSimSinglets({[0 100],[0.1 100]})
%         fprintf('%s ->\nSimulation of singlet spectrum failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
    if ~SP2_Sim_DoSimSinglets(metabCell)
        fprintf('%s ->\nSimulation of singlet spectrum failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if ~SP2_Sim_ProcData
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- simulation export handling ---
    sim.expt.fid    = ifft(ifftshift(sim.spec,1),[],1);
    sim.expt.sf     = sim.sf;
    sim.expt.sw_h   = sim.sw_h;
    sim.expt.nspecC = sim.nspecC;
    
    %--- LCModel analysis ---
%     SP2_LCM_LCModelMain
    if ~SP2_LCM_SpecDataAndParsAssign
        fprintf('%s ->\nData import from simulation to LCModel page failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if ~SP2_LCM_ProcLcmData
        fprintf('%s ->\nData processing for LCModel failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if ~SP2_LCM_AnaStartValReset
        fprintf('%s ->\nReset of LCModel starting values failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if ~SP2_LCM_AnaDoAnalysis(0)
        fprintf('%s ->\nLCModel analysis failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if ~SP2_LCM_AnaDoCalcCRLB(0)
        fprintf('%s ->\nCRLB calculation failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- transfer result ---
    concMat(nCnt,:)     = lcm.anaScale(lcm.fit.applied);        % full length vector
    concCrlbMat(nCnt,:) = lcm.fit.crlbAmp;                      % fitted metabs only
    concSdTrace(nCnt,:) = 100*std(concMat(1:nCnt))./mean(concMat(1:nCnt));
    if f_lb
        lbMat(nCnt,:)     = lcm.anaLb(lcm.fit.applied);         % full length vector
        lbCrlbMat(nCnt,:) = lcm.fit.crlbLb;                     % fitted metabs only
    end
    if f_gb
        gbMat(nCnt,:)     = lcm.anaGb(lcm.fit.applied);         % full length vector
        gbCrlbMat(nCnt,:) = lcm.fit.crlbGb;                     % fitted metabs only
    end
    if f_shift
        shiftMat(nCnt,:)     = lcm.anaShift(lcm.fit.applied);   % full length vector
        shiftCrlbMat(nCnt,:) = lcm.fit.crlbShift;               % fitted metabs only
    end
    if f_phc0
        phc0Mat(nCnt)     = lcm.anaPhc0;                        % full length vector
        phc0CrlbMat(nCnt) = lcm.fit.crlbPhc0;                   % fitted metabs only
    end
end

%--- add analysis outcome to result file ---
rUnit = fopen(calibPath,'a');
fprintf(rUnit,'\nLCMODEL OUTCOME\nConcentration:\n');
for nCnt = 1:nAna
    fprintf(rUnit,'%s\n',SP2_Vec2PrintStr(concMat(nCnt,:),4));
end
fprintf(rUnit,'CRLB:\n');
for nCnt = 1:nAna
    fprintf(rUnit,'%s\n',SP2_Vec2PrintStr(concCrlbMat(nCnt,:),4));
end


%--- add analysis statistics to result file ---
fprintf('\nANALYSIS STATISTICS\n');
fprintf('AMPLITUDE\n');
fprintf('Mean:      %s a.u.\n',SP2_Vec2PrintStr(mean(concMat),4));
fprintf('SD:        %s%%\n',SP2_Vec2PrintStr(100*std(concMat)./mean(concMat),4));
fprintf('CRLB Mean: %s%%\n',SP2_Vec2PrintStr(mean(concCrlbMat),4));
fprintf('CRLB SD:   %s%%\n',SP2_Vec2PrintStr(std(concCrlbMat),4));
concRatioCrlbSd = mean(concCrlbMat) ./ (100*std(concMat)./mean(concMat));
fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(concRatioCrlbSd,3),mean(concRatioCrlbSd));
if f_lb 
    fprintf('LB\n');
    fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lbMat),4));
    fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(lbMat),4));
    fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(mean(lbCrlbMat),4));
    fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(std(lbCrlbMat),4));
    lbRatioCrlbSd = mean(lbCrlbMat) ./ std(lbMat);
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(lbRatioCrlbSd,3),mean(lbRatioCrlbSd));
end
if f_gb 
    fprintf('GB\n');
    fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(gbMat),4));
    fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(gbMat),4));
    fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(mean(gbCrlbMat),4));
    fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(std(gbCrlbMat),4));
    gbRatioCrlbSd = mean(gbCrlbMat) ./ std(gbMat);
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(gbRatioCrlbSd,3),mean(gbRatioCrlbSd));
end
if f_shift
    fprintf('SHIFT\n');
    fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(shiftMat),4));
    fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(shiftMat),4));
    fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(mean(shiftCrlbMat),4));
    fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(std(shiftCrlbMat),4));
    shiftRatioCrlbSd = mean(shiftCrlbMat) ./ std(shiftMat);
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(shiftRatioCrlbSd,3),mean(shiftRatioCrlbSd));
end
if f_phc0
    fprintf('PHC0\n');
    fprintf('Mean:      %s deg\n',SP2_Vec2PrintStr(mean(phc0Mat),4));
    fprintf('SD:        %s deg\n',SP2_Vec2PrintStr(std(phc0Mat),4));
    fprintf('CRLB Mean: %s deg\n',SP2_Vec2PrintStr(mean(phc0CrlbMat),4));
    fprintf('CRLB SD:   %s deg\n',SP2_Vec2PrintStr(std(phc0CrlbMat),4));
    phc0RatioCrlbSd = mean(phc0CrlbMat) ./ std(phc0Mat);
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(phc0RatioCrlbSd,3),mean(phc0RatioCrlbSd));
end

%--- show SD development ---
figure
plot(concSdTrace)
xlabel('# iterations')
ylabel('SD as f(# iter) in [%]')

%--- add analysis statistics to result file ---
fprintf(rUnit,'\nANALYSIS STATISTICS\n');
fprintf(rUnit,'Conc. Mean:\n%s [a.u.]\n\n',SP2_Vec2PrintStr(mean(concMat),4));
fprintf(rUnit,'Conc. SD:\n%s%%\n\n',SP2_Vec2PrintStr(100*std(concMat)./mean(concMat),4));
fprintf(rUnit,'CRLB Mean:\n%s\n\n',SP2_Vec2PrintStr(mean(concCrlbMat),4));
if f_lb
    fprintf(rUnit,'LB Mean:\n%s Hz\n\n',SP2_Vec2PrintStr(mean(lbMat),4));
    fprintf(rUnit,'LB. SD:\n%s Hz\n\n',SP2_Vec2PrintStr(std(lbMat),4));
    fprintf(rUnit,'LB CRLB Mean:\n%s%%\n\n',SP2_Vec2PrintStr(mean(lbCrlbMat),4));
end

%--- convergence analysis ---
sdDevel = zeros(nAna,lcm.fit.appliedN);        % SD development in [%] of mean over all cases
for nCnt = 2:nAna
    sdDevel(nCnt,:) = 100*std(concMat(1:nCnt,:))./mean(concMat);
end
for mCnt = 1:lcm.fit.appliedN
    fprintf(rUnit,'%s SD [%%] as function of sample size:\n%s\n\n',lcm.anaMetabs{mCnt},SP2_Vec2PrintStr(sdDevel(:,mCnt)',4));
end
fclose(rUnit);

%--- display convergence analysis ---
% figure
% plot(1:lcm.fit.appliedN,sdDevel(:,mCnt))

%--- info printout ---
fprintf('\n%s finished.\n\n',FCTNAME);

