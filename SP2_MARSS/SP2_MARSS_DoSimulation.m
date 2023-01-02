%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function f_succ = SP2_MARSS_DoSimulation
%%
%%  Perform spectral simulation.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile marss flag

FCTNAME = 'SP2_MARSS_DoSimulation';


%--- init success flag ---
f_succ = 0;

%--- assign parameters ---
% actual voxel size is defined by combination of RF and gradient
% simulation size is set below as x, y and z in [mm]. Note that they are
% independent and have to be chosen properly
% B0 [T]
% G: [mT/m], 1) matrix: each row corresponds to an RF pulse, column X, Y, or Z, 2) cell: for shaped wave forms
% Npoints: number of spectral simulation points
% notes: single string, e.g. summary of simulation parameters
% rfOffsets: vector of frequency offsets in [Hz] from TMS with 1 entry per RF pulse
% amplitudeUnit: RF pulse unit in [Gauss], [rad/sec], [Hertz]
% autoMean: automatically take the mean across all spatial dimensions, 1: % collapse all spatial dimensions, 0: save NX x NY x NZ individual spectra from all spatial positions
% delays: extra time, i.e. time between pulses in [sec], to achieve assigned sequence delays, starting at the end of an RF pulse, ending at the beginning of the next pulse
% durations: RF pulse durations in [sec], 3.6 ms for GE's STEAM
% phaseShifts: potential incorportation of phase cycling, e.g. [RF RF RF acq.] for STEAM, potential acq. phase offset in case of excitation offset, not to be used
% rephaseArea: rephase slice selection gradients [s*mT/m], square gradient pulses [duration*amplitude], potentially including crushers
% referencePeak: ppmCalib in [ppm]

%--- directory handling for predefined sequence definition files ---
% marss.sequDefFileDir = SP2_PathWinLin([pars.specPath 'SP2_MARSS\SP2_MARSS_SequDefinitions\']);
% if ~SP2_CheckDirAccessR(marss.sequDefFileDir)
%     return
% end

%--- consistency checks: basis output directory ---
if ~SP2_CheckDirAccessR(marss.basis.fileDir)
    return
end

%--- check write permissions ---
if ~SP2_CheckDirWritePermR(marss.basis.fileDir)
    fprintf('%s ->\nDesignated basis directory does not have write permissions.\nPlease choose a different one.\n',FCTNAME);
    return
end

%--- check for overwrite, confirm by dialog ---
if SP2_CheckFileExistenceR(marss.basis.filePath)
    choice = questdlg('Would you like to overwrite basis set at hand','MARSS Dialog', ...
        'Yes','No','No');
    
    %--- user input ---
    if strcmp(choice,'No')
        %--- info output ---
        fprintf('\nBasis simulation aborted.\n');
        return
    end
end

%--- info printout ---
fprintf('\nAutomated basis simulation started...\n');
fprintf('MARSS software: Landheer et al., NMR Biomed, 2019, e4129\n');

%--- update vendor-specific sequence selection ---
if ~SP2_MARSS_SimCaseUpdate
    return
end

%--- load basic MRS sequence definition ---
switch flag.marssSimCase
    case 1      % GE, STEAM
        marss.sequDefFileName = 'SP2_MARSS_STEAMGETE20msTM10ms.m';
        marss.sequNotes       = 'GE STEAM template: SP2_MARSS_STEAMGETE20msTM10ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock General Electric STEAM sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock General Electric STEAM sequence template loaded from file\n');
        end
    case 2      % Siemens, STEAM
        marss.sequDefFileName = 'SP2_MARSS_STEAMSiemensTE20msTM10ms.m';
        marss.sequNotes       = 'Siemens STEAM template: SP2_MARSS_STEAMGETE20msTM10ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock Siemens STEAM sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock Siemens STEAM sequence template loaded from file\n');
        end
    case 3      % Philips, STEAM
        marss.sequDefFileName = 'SP2_MARSS_STEAMPhilipsTE20msTM16ms.m';
        marss.sequNotes       = 'Philips STEAM template: SP2_MARSS_STEAMGETE20msTM16ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock Philips STEAM sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock Philips STEAM sequence template loaded from file\n');
        end
    case 4      % GE, PRESS
        marss.sequDefFileName = 'SP2_MARSS_PRESSGETE30ms.m';
        marss.sequNotes       = 'GE PRESS template: SP2_MARSS_PRESSGETE30ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock General Electric PRESS sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock General Electric PRESS sequence template loaded from file\n');
        end
    case 5      % Siemens, PRESS
        marss.sequDefFileName = 'SP2_MARSS_PRESSSiemensTE30ms.m';
        marss.sequNotes       = 'Siemens PRESS template: SP2_MARSS_PRESSSiemensTE30ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock Siemens PRESS sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock Siemens PRESS sequence template loaded from file\n');
        end
    case 6      % Philips, PRESS
        marss.sequDefFileName = 'SP2_MARSS_PRESSPhilipsTE30ms.m';
        marss.sequNotes       = 'Philips PRESS template: SP2_MARSS_PRESSPhilipsTE30ms.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Stock Philips PRESS sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Stock Philips PRESS sequence template loaded from file\n');
        end
    case 7      % GE, sLASER
        marss.sequDefFileName = 'SP2_MARSS_SLASERGE.m';
        marss.sequNotes       = 'GE sLASER template: SP2_MARSS_SLASERGE.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('General Electric semi-LASER sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('General Electric semi-LASER sequence template loaded from file\n');
        end
    case 8      % Siemens, sLASER
        marss.sequDefFileName = 'SP2_MARSS_SLASERSiemens.m';
        marss.sequNotes       = 'Siemens sLASER template: SP2_MARSS_SLASERSiemens.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Siemens semi-LASER sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Siemens semi-LASER sequence template loaded from file\n');
        end
        fprintf('C2P: http://juchem.bme.columbia.edu/mega-slaser-single-voxel-mrs-sequence\n');
    case 9      % Philips, sLASER, NOT SUPPORTED
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('\n%s ->\nPhilips sLASER sequences are not supported yet. Program aborted.\n\n',FCTNAME);
        return
        
        marss.sequDefFileName = 'SP2_MARSS_SLASERPhilips.m';
        marss.sequNotes       = 'Philips sLASER template: SP2_MARSS_SLASERPhilips.m';
        % marss.sequDefFilePath = [marss.sequDefFileDir marss.sequDefFileName];
        if flag.verbose
            fprintf('Philips semi-LASER sequence template loaded from file %s\n',marss.sequDefFileName);
        else
            fprintf('Philips semi-LASER sequence template loaded from file\n');
        end
    case 10      % user-sequence (incl. sLASER, MEGA-sLASER, etc)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('\n\n%s ->\nUser MRS sequences are not supported yet. Program aborted.\n\n',FCTNAME);
        return
        
        %--- check existence of input file ---
        if ~SP2_CheckFileExistenceR(marss.sim.defFileAssignPath)
            fprintf('%s ->\nAssigned simulation input file not found. Program aborted.\n',FCTNAME,marss.basis.simInputPath);
            return
        end
        
        %--- assign sequence definition file ---
        marss.sequDefFilePath = marss.sim.defFileAssignPath;
        
        %--- notes ---
        marss.sequNotes = 'Custom sequence';
        
    otherwise
        fprintf('%s ->\nUnknown sequence selection. Program aborted.\n',FCTNAME);
end

%--- info printout ---
fprintf('Experiment-specific sequence parameters applied\n');

% load(marss.sequDefFilePath) commented out by Karl Landheer and below 2
% lines added
pulseStruct = SP2_MARSS_ReadFileM(marss.sequDefFileName,1);

%--- udpate selected parameters based on user choices ---
B0               = marss.b0;            % [T]
% G                = xxx;
Npoints          = marss.nspecCBasic;
% amplitudeUnit    = xxx;
autoMean         = 1;
bandwidth        = marss.sw_h;
% coherencePathway = xxx;
% delays           = xxx;
% durations        = xxx;
metabolites      = marss.basis.selectNames;
notes            = marss.sequNotes;
outputDirectory  = marss.basis.fileDir;
% phaseShifts      = xxx;
% rephaseAreas     = xxx;
% rfOffsets        = xxx;
% rfPulses         = xxx;
x                = linspace(-marss.voxDim,marss.voxDim,marss.simDim);     % covering twice the voxel extension
y                = linspace(-marss.voxDim,marss.voxDim,marss.simDim);     % covering twice the voxel extension
z                = linspace(-marss.voxDim,marss.voxDim,marss.simDim);     % covering twice the voxel extension
referencePeak    = marss.ppmCalib;
LB               = marss.lb;

%--- check basis directory access for 1) temporary input file, 2) basis files ---
if SP2_CheckDirAccessR(marss.basis.fileDir)
    MARSSInputTmpPath = [marss.basis.fileDir 'MARSS_BasisSimDefinition.mat'];       % tmp file to basis directory
else
    fprintf('%s ->\nBasis directory not accessible:\n%s\nProgram aborted.\n',FCTNAME,marss.basis.fileDir);
    return
end

switch flag.marssSimCase
    case 1      % GE, STEAM
        flagSequence = 1;
        flagOrigin = 1;
    case 2      % Siemens, STEAM
        flagSequence = 1;
        flagOrigin = 2;
    case 3      % Philips, STEAM
        flagSequence = 1;
        flagOrigin = 3;
    case 4      % GE, PRESS
        flagSequence = 2;
        flagOrigin = 1;
    case 5      % Siemens, PRESS
        flagSequence = 2;
        flagOrigin = 2;
    case 6      % Philips, PRESS
        flagSequence = 2;
        flagOrigin = 3;
    case 7      % GE, sLASER
        flagSequence = 3;
        flagOrigin = 1;
    case 8      % Siemens, sLASER
        flagSequence = 3;
        flagOrigin = 2;
%     case 9      % Philips, sLASER
%         flagSequence = 3;
%         flagOrigin = 3;
%     case 10      % customized
%         flagSequence = xxx;
%         flagOrigin = xxx;
end

% adjust delays by Karl Landheer
[pulseStruct.delays] = SP2_MARSS_AdjustDelays(pulseStruct.delays,marss.te,marss.tm,flagSequence,flagOrigin); 

%--- temporary file defining the entire simulation (merger of default & GUI selection) ---
% save(MARSSInputTmpPath,...
% 'B0','G','Npoints','amplitudeUnit','autoMean','bandwidth','coherencePathway',...
% 'delays','durations','metabolites','notes','outputDirectory',...
% 'phaseShifts','rephaseAreas','rfOffsets','rfPulses','x','y','z')

% pulse struct built by Karl Landheer
pulseStruct.B0 = B0; pulseStruct.Npoints = Npoints; pulseStruct.autoMean = autoMean; pulseStruct.bandwidth = bandwidth; pulseStruct.metabolites = metabolites;
pulseStruct.outputDirectory = outputDirectory; pulseStruct.x = x; pulseStruct.y = y; pulseStruct.z = z; pulseStruct.LB = LB; pulseStruct.referencePeak = referencePeak;

% fprintf('%s -> Full experiment definition written to temporary file.\n',FCTNAME);

%--- run basis simulation ---
if ~SP2_MARSS_RunMARSS(pulseStruct);
    return
end

%--- remove temporary MARSS input file ---
% delete(MARSSInputTmpPath)

%--- create INSPECTOR basis set ---
if ~SP2_MARSS_BasisSave
    return
end

%--- update display ---
SP2_MARSS_MARSSWinUpdate

%--- update success flag ---
f_succ = 1;

