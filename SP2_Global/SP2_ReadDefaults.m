%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_ReadDefaults( varargin )
%% 
%%  Returns default values for data path and user
%%
%%  01-2007, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars flag data stab mm proc mrsi t1t2 syn marss lcm tools man

FCTNAME = 'SP2_ReadDefaults';


%--- init success flag ---
f_succ = 0;

%--------------------------------------------------------------------------
%---    I N I T     S T R U C T S                                       ---
%--------------------------------------------------------------------------
pars    = {};
data    = {};
stab    = {};
proc    = {};
t1t2    = {};
mrsi    = {};
syn     = {};
marss   = {};
lcm     = {};
tools   = {};
man     = {};

%-----------------------------------------------------------------------------------------------------
%---     P A R A M E T E R    I N I T    B E F O R E    D E F A U L T S     A R E    R E A D       ---
%-----------------------------------------------------------------------------------------------------
%--- (volatile) general parameter assignments ---
pars.spxOpen         = 1;                   % INSPECTOR open
flag.fmWin           = 1;                   % starting/current GUI window 
flag.verbose         = 0;                   % more explicite informational printouts            
pars.nColors         = 256;                 % number of colors
pars.nspecBlock      = 512;                 % maximum memory allocation, e.g. number of 'timeslices' to be processed simultaneously
pars.nbyte           = 8;                   % numeric memory size
flag.colormap        = 0;                   % 0) jet, 1) hsv, 2) hot
flag.debug           = 0;                   % debugging option for very extended printout
% pars.mainDims        = [10 40 600 702];     % main window dimensions: x-pos, y-pos, x-dim, y-dim (fixed)
pars.mainDims        = [10 150 600 702];       % main window dimensions: x-pos, y-pos, x-dim, y-dim (fixed)
pars.figPos          = pars.mainDims;       % flexible window position (written to protocol file)
pars.gyroRatio       = 42.5774789;          % gyromagnetic ratio in MHz/T

%------------------------------------------------------------------------------------------------
%---   P A R A M E T E R    T R A N S F E R     T O     P R O G R A M     V A R I A B L E S   ---
%------------------------------------------------------------------------------------------------
% (temporary) platform identification, 0: windows, 1: linux
% note: this has to be repeated after the full flag structure has been
% loaded from file
if ispc
    flag.OS = 0;
elseif ismac
    flag.OS = 2;
elseif isunix
    flag.OS = 1;
end

SP2_Logger.log("flag.OS = %d\n",flag.OS);

%--- default directory ---
data.defaultDir = SP2_FileHelper.setGetDefaultDir()

SP2_Logger.log("data.defaultDir = %s\n",data.defaultDir);

%--- protocol handling ---
data.protFile     = 'UserProtocol';                 % protocol containing all FMAP parameters
data.protDir      = data.defaultDir;                % protocol directory, a study
data.protPath     = [data.protDir data.protFile];   % protocol path (.mat)
data.protPathMat  = [data.protPath '.mat'];         % protocol path for text export/output (.txt)
data.protPathTxt  = [data.protPath '.txt'];         % protocol path for text export/output (.txt)
data.protDateNum  = now;                            % numeric date 
data.protDateStr  = datestr(data.protDateNum);      % date string


%--- data format: Bruker, Varian ---
flag.dataManu       = 0;        % 0: Bruker, 1: Varian
flag.dataConvdta    = 0;        % digital-to-analog conversion for Bruker data

%--- experiment format ---
% note that the cell choices do not directly correspond to the flag values
flag.dataEditNo   = 1;          % JDE(ON) data selection of combined/shuffled JDE experiment, 1: first, 2: second
flag.dataExpType  = 1;          % data format, 1: single, 2: sat-recovery, 3: JDE, 4: stability, 5: T1/T2, 6: MRSI
data.expTypeDisplCell  = {'Regular MRS','JDE - 1st & last','JDE - 2nd & last','JDE - Array','Sat.-Recovery','Stability (QA)','T1 / T2','MRSI'};
SP2_Data_ExpTypePars2Display;   % assignment of data.expTypeDisplay (number) based on flag.dataEditNo and flag.dataExpType
flag.dataBrukerFormat = 1;      % 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0

%--- data path handling ---
data.spec1.fidDir  = data.defaultDir;
data.spec1.fidName = 'fid';                     % Bruker/Varian
data.spec1.fidFile = [data.spec1.fidDir data.spec1.fidName];
    
if flag.dataManu                % Varian
    %--- method file paths ---
    data.spec1.methFile = [data.spec1.fidDir 'procpar'];
    
    %--- acqp file paths ---
    data.spec1.acqpFile = [data.spec1.fidDir 'text'];
else                            % Bruker
    %--- method file paths ---
    data.spec1.methFile = [data.spec1.fidDir 'method'];
    
    %--- acqp file paths ---
    data.spec1.acqpFile = [data.spec1.fidDir 'acqp'];
end

%--- experiment string ---
data.spec1.seriesStr = '1:5';      % (random) init of experiment series string
data.spec1.seriesVec = 1:5;        % (random) init of experiment series vector
data.spec1.seriesN   = 5;          % (random) number of serial experiments (to be summed up)

%--- init 'Data' window parameters (fake inits) ---
data.spec1.vox      = [0 0 0];
% data.spec1.mat     = [0 0 0];
% data.spec1.res     = [0 0 0];
data.spec1.pos      = [0 0 0];
data.spec1.offset   = 0;
data.spec1.te       = 0;
data.spec1.tr       = 0;
data.spec1.na       = 0;
data.spec1.nr       = 0;
data.spec1.sequence = '';
data.spec1.nspecC   = 0;
data.spec1.dim      = 0;
data.spec1.nx       = 0;
data.spec1.ny       = 0;
% data.spec1.slorient      = '';
% data.spec1.rdorient      = '';
data.spec1.gcoil    = '';
data.spec1.seqcon   = 'ccccc';       % fake init
data.spec1.yz       = 0;
data.spec1.xy       = 0;
data.spec1.x2y2     = 0;
data.spec1.x1       = 0;
data.spec1.x3       = 0;
data.spec1.y1       = 0;
data.spec1.xz       = 0;
data.spec1.xz2      = 0;
data.spec1.y3       = 0;
data.spec1.z1c      = 0;
data.spec1.yz2      = 0;
data.spec1.z2c      = 0;
data.spec1.z5       = 0;
data.spec1.z3c      = 0;
data.spec1.z4c      = 0;
data.spec1.zx2y2    = 0;
data.spec1.zxy      = 0;
data.spec1.sw       = 0;
data.spec1.sw_h     = 0;
data.spec1.dwell    = 0;
data.spec1.sf       = 0;
data.spec1.rf1.shape   = '';        % RF 1
data.spec1.rf1.dur     = 0;
data.spec1.rf1.power   = 0;
data.spec1.rf1.offset  = 0;
data.spec1.rf1.method  = '';
data.spec1.rf1.applied = 'n';
data.spec1.rf2.shape   = '';        % RF 2
data.spec1.rf2.dur     = 0;
data.spec1.rf2.power   = 0;
data.spec1.rf2.offset  = 0;
data.spec1.rf2.method  = '';
data.spec1.rf2.applied = 'n';
data.spec1.ws.shape    = '';        % water suppression
data.spec1.ws.dur      = 0;
data.spec1.ws.power    = 0;
data.spec1.ws.offset   = 0;
data.spec1.ws.method   = '';
data.spec1.ws.applied  = 'n';
data.spec1.jde.shape   = '';        % JDE
data.spec1.jde.dur     = 0;
data.spec1.jde.power   = 0;
data.spec1.jde.offset  = 0;
data.spec1.jde.method  = '';
data.spec1.jde.applied = 'n';
data.spec1.gain        = 0;
data.spec1.nRcvrs      = 0;
data.spec2             = data.spec1;
flag.dataAlignAmpl     = 0;            % amplitude correction of individual spectra
flag.dataAlignPhase    = 1;            % phase alignment of individual spectra
flag.dataAlignFrequ    = 1;            % frequency alignment of individual spectra
flag.dataAlignVerbose  = 0;            % detailed output of phase/frequency alignment
flag.dataRcvrAllSelect = 1;            % receiver assignment
data.rcvrMax           = 128;                   % maximum number of receivers
data.rcvr              = ones(1,data.rcvrMax);  % binary vector of receivers used in the reconstruction
data.rcvrInd           = find(data.rcvr);       % receiver indices
data.rcvrN             = length(data.rcvrInd);  % number of receivers
data.rcvrSelectStr     = '1 2 3';      % receiver selection string (note the same as num2str(data.rcvr)
flag.dataRcvrWeight = 1;             % signal-weighted sum of receiver signals                        
flag.dataPhaseCorr  = 1;              % phase correction, 1: Klose method, 0: phase of 1st point of reference
flag.dataKloseMode  = 2;              % Phase of 2: individual phase-cycling-specific steps, 3: selected phase-cycling step
data.phaseCorrNr    = 1;              % Number of water reference (in an arrayed experiment) applied for Klose correction
flag.dataFrequCorr  = 1;              % frequency correction (only makes sense if flag.dataPhaseCorr~=1)
flag.dataAllSelect  = 1;              % data selection/extraction, 1: all, 0: selected NR range
data.select         = [1 2 3];        % FID (NR) selection vector
data.selectN        = length(data.select);   % number of selected FIDs (NR)
data.selectStr      = '1 2 3';        % FID (NR) selection string
data.ppmCalib       = 4.7;            % spectrum calibration, ~4.65 for water
data.ppmAssign      = 2.01;           % spectral peak assignment, e.g. 2.01 for NAA
data.fidCut         = 1024;           % FID apodization (for spectrum display only)
data.fidZf          = 16384;          % spetral zero-filling (for spectrum display only)
data.satRec.minTI   = 0.15;           % minimum TI [sec] spectrum for frequency/phase alignment
flag.dataFrequCorr  = 1;              % frequency correction method, 1: max. single point, 0: interpolated/modeled max. frequency
data.ppmCorrMin     = 1.5;            % minimum ppm value of frequency window for ref. peak of frequency correction
data.ppmCorrMax     = 2.5;            % maximum ppm value of frequency window for ref. peak of frequency correction
data.ds             = 0;              % # of dummy scans (acquired, but not to be used), relevant for acquisition-specific EC correction
data.nPhCycle       = 1;              % # of phase cycle steps
data.ppmTargetMin   = 1.5;            % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
data.ppmTargetMax   = 2.5;            % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
data.ppmNoiseMin    = 9;              % minimum ppm value of frequency window for noise area of SNR analysis
data.ppmNoiseMax    = 10;             % maximum ppm value of frequency window for noise area of SNR analysis
flag.dataKeepFig    = 0;              % keep figure, i.e. create new figure for every plot
flag.dataAna        = 1;              % data selection for visualization/analysis, 1: FID 1, 2: spec 1, 3: FID 2, 4: spec 2
data.scrollRcvr     = 1;              % current receiver number for data scrolling
data.scrollRep      = 1;              % current repetition number for data scrolling
flag.dataAmpl       = 0;              % 0: autoadjust, 1: direct assignment
data.amplMin        = 0;              % minimum display amplitude
data.amplMax        = 1e4;            % maximum display amplitude
flag.dataFormat     = 1;              % visualization format, 1: real, 2: imaginary, 3: magnitude
flag.dataPpmShow    = 0;              % 0: full sweep width, 1: direct assignment
data.ppmShowMin     = 1.0;            % minimum ppm value to be displayed
data.ppmShowMax     = 7.5;            % maximum ppm value to be displayed
data.plotArrMaxElem = 80;             % maximum number of array elements to be plot together
flag.dataIdentScan  = 0;              % identical data file for data set 1 and 2


%--- spectrum alignment window ---
%--- FREQUENCY ---
data.frAlignPpm1Str    = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
data.frAlignPpm1Min    = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
data.frAlignPpm1Max    = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
data.frAlignPpm1N      = 1;           % number of ppm windows for spectrum alignment
data.frAlignPpm2Str    = '1.8:4.1';   % string of ppm window raCouldn't
% Conges for spectrum alignment
data.frAlignPpm2Min    = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
data.frAlignPpm2Max    = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
data.frAlignPpm2N      = 1;           % number of ppm windows for spectrum alignment
data.frAlignExpLb      = 2;           % frequency alignment: exponential line broadening [Hz]
data.frAlignFftCut     = 1024;        % frequency alignment: apodization
data.frAlignFftZf      = 8*1024;      % frequency alignment: zero-filling
data.frAlignFrequRg    = 5;           % frequency alignment: potential frequency variation, +/- frequRg
data.frAlignFrequRes   = 0.1;         % frequency alignment: frequency resolution
data.frAlignRefFid     = [3 4];       % frequency alignment: reference FID (number)
data.frAlignIter       = 2;           % # of iterations, note that >1 iterations use the sum of all spectra
data.frAlignVerbMax    = 10;          % maximum number of verbose displays

%--- PHASE ---
data.phAlignPpm1Str    = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
data.phAlignPpm1Min    = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
data.phAlignPpm1Max    = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
data.phAlignPpm1N      = 1;           % number of ppm windows for spectrum alignment
data.phAlignPpm2Str    = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
data.phAlignPpm2Min    = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
data.phAlignPpm2Max    = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
data.phAlignPpm2N      = 1;           % number of ppm windows for spectrum alignment
data.phAlignExpLb      = 10;          % phase alignment: exponential line broadening [Hz]
data.phAlignFftCut     = 1024;        % frequency alignment: apodization
data.phAlignFftZf      = 8*1024;      % frequency alignment: zero-filling
data.phAlignPhStep     = 2;           % phase alignment: phase step size, i.e. resolution of the optimization
data.phAlignRefFid     = [3 4];       % phase alignment: reference FID (number)
data.phAlignIter       = 2;           % phase alignment: iterations, >1 via sum of all spectra
data.phAlignVerbMax    = 10;          % maximum number of verbose displays

%--- AMPLITUDE ---
data.amAlignPpmStr     = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
data.amAlignPpmMin     = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
data.amAlignPpmMax     = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
data.amAlignPpmN       = 1;           % number of ppm windows for spectrum alignment
data.amAlignExpLb      = 2;           % amplitude alignment: exponential line broadening [Hz]
data.amAlignFftCut     = 1024;        % amplitude alignment: apodization
data.amAlignFftZf      = 8*1024;      % amplitude alignment: zero-filling
data.amAlignRef1Str    = '3';         % amplitude alignment: reference FID (number)
data.amAlignRef1Vec    = 3;           % reference vector amplitude alignment
data.amAlignRef1N      = 1;           % number of reference FIDs considered for amplitude correction
data.amAlignRef2Str    = '4';         % amplitude alignment: reference FID (number)
data.amAlignRef2Vec    = 4;           % reference vector amplitude alignment
data.amAlignRef2N      = 1;           % number of reference FIDs considered for amplitude correction
data.amAlignPolyOrder  = 3;           % order of polynomial amplitude correction
flag.amAlignExtraWin   = 0;           % extra spectral window of user-specified size/position (mostly if single peak is used for alignment)
data.amAlignExtraPpm   = [0 4.3];     % frequency range of extra window

%--- quality assessment window ---
data.quality.lb           = 3;              % exponential line broadening
data.quality.cut          = 1024;           % apodization
data.quality.zf           = 16384;          % zero-filling
data.quality.rows         = 3;              % Number of rows in spectra display
data.quality.cols         = 4;              % Number of columns in spectra display
data.quality.select       = 3:10;           % FID (NR) selection vector
data.quality.selectN      = length(data.quality.select);     % number of selected FIDs (NR)
data.quality.selectStr    = '1 2 3';        % FID (NR) selection string
data.quality.selectNr     = 1;              % first NR to be displayed in arrayed spectral mode
flag.dataQualityAmplMode  = 1;              % amplitude mode, 1: automatic, 0: direct assignment
data.quality.amplMin      = -10000;         % lower (direct) amplitude limit
data.quality.amplMax      = 10000;          % upper (direct) amplitude limit
flag.dataQualityFrequMode = 1;              % frequency mode, 1: automatic, 0: direct assignment
data.quality.frequMin     = 1;              % lower (direct) frequency limit
data.quality.frequMax     = 4.2;            % upper (direct) frequency limit
flag.dataQualityFormat    = 1;              % data format, 1: real, 2: imaginary, 3: magntitude, 4: phase
data.quality.phaseZero    = 0;              % zero-order phase offset
flag.dataQualityCMap      = 0;              % color mode, 0: blue (only), 1: jet, 2: hsv, 3: hot
flag.dataQualityLegend    = 1;              % data (/color) legend
flag.dataQualitySeries    = 2;              % mode selection for series display, 1:min, 2:max, 3:mean, 4:median
data.quality.exclude      = [1 2];          % FID (NR) selection vector to be excluded
data.quality.excludeN     = length(data.quality.exclude);     % number of selected FIDs (NR)
data.quality.excludeStr   = '1 2 3';        % FID (NR) selection string
data.quality.replace      = [1 2];          % FID (NR) selection vector to be used to replace the excluded FIDs
data.quality.replaceN     = length(data.quality.replace);     % number of selected FIDs (NR)
data.quality.replaceStr   = '1 2 3';        % FID (NR) selection string
flag.dataQualityAvgMaxAmp = 1;              % display line at the level of the average maximum amplitude within selected ppm window
flag.dataPhaseLinCorr     = 1;              % linear phase correction of FIDs (= frequency correction), display only

flag.t2Special            = 0;              % T2 water formating


%-----------------
%--- MM window ---
%-----------------
%--- setup / preprocessing ---
mm.lb               = 2;                    % exponential line broadening
mm.cut              = 1024;                 % apodization
mm.zf               = 16384;                % zero-filling
mm.ppmCalib         = 4.65;                 % ppm calibration
mm.phaseZero        = 0;                    % zero-order phase offset 
flag.mmMetabRef     = 1;                    % data type, 1: metabolite spectra, 0: reference (water) spectra
mm.boxCar           = 7;                    % box car average of individual SR spectra
mm.boxCarHz         = 0;                    % box car width [Hz] (calculated once sw_h is known)
mm.dataExtFac       = 2;                    % data extension factor       
flag.mmNeighInit    = 1;                    % init multi-exponential regression analysis with result from neighboring frequency position

%--- FID simulation parameters ---
mm.sim.fidDir       = [data.defaultDir 'juchem\analysis\MRS_MacroMolecule\STEAM_Moieties\']; 
mm.sim.fidName      = 'NAA';                        % metabolite file name
mm.sim.fidPath      = [mm.sim.fidDir mm.sim.fidName];  % metabolite file path
mm.sim.t1           = 1.5;                          % metabolite T1 [s]
mm.sim.t2           = 0.025;                        % metabolite T2 [s]
mm.sim.delayStr     = '0.1:15.1';                   % direct assignment of saturation recovery delay string/vector
mm.sim.delayVec     = str2num(mm.sim.delayStr);     % saturation delay vector for simulation
mm.sim.delayMin     = mm.sim.delayVec(1);           % minimum delay of saturation-recovery series
mm.sim.delayMax     = mm.sim.delayVec(end);         % maximal delay of saturation-recovery series
mm.sim.delayN       = length(mm.sim.delayVec);      % number of delay steps in series
flag.mmSimNoise     = 0;                            % add noise to simulated saturation-recovery experiment

%--- T1 analysis ---
flag.mmAnaWaterMode = 1;                    % water removal, 1: HLSVD, 0: low-pass filter
flag.mmAnaFrequMode = 1;                    % frequency mode, 1: automatic, 0: direct assignment
mm.anaFrequMin      = 1;                    % lower (direct) frequency limit
mm.anaFrequMax      = 4.2;                  % upper (direct) frequency limit
flag.mmAnaFormat    = 1;                    % data format, 1: real, 0: magntitude
flag.mmAnaTOneMode  = 1;                    % T1 components, 1: fixed, 0: flexible
mm.anaTOneFlexN     = 5;                    % number of T1 components for flexible fitting
mm.anaTOneFlexThMin = 0.5;                  % maximum threshold in [s] of short T1 range
mm.anaTOneFlexThMax = 1;                    % minimum threshold in [s] of long T1 range
mm.anaTOne          = [0.1 0.2 0.3 0.8 1.1 1.4 1.7];        % T1 selection vector
mm.anaTOneN         = length(mm.anaTOne);                   % number of T1s to be fitted
mm.anaTOneStr       = SP2_Vec2PrintStr(mm.anaTOne,2,0);     % T1 display string
flag.mmTOneSpline   = 0;                    % spline interpolation of T1 fitting result (sum or subtraction)
mm.anaOptN          = 3;                    % number of processing steps per optimization
mm.anaOptAmpRg      = 0.5;                  % relative amplitude range around first 
mm.anaOptAmpRed     = 0.5;                  % reduction factor of amplitude variation range
mm.mmStructFile     = 'T1_Analysis.mat';        % file name of full T1 analysis
mm.mmStructDir      = [data.defaultDir 'juchem\Analysis\MacroMolecule\Data\'];       % path of full T1 analysis
mm.mmStructPath     = [mm.mmStructDir mm.mmStructFile];     % full path of T1 analysis
mm.tOneSelect       = 1;                    % # of T1 component to be displayed
mm.expPpmSelect     = 1;                    % frequency position [ppm] to be displayed
flag.mmExpPpmLink   = 0;                    % Link ppm value of fit analysis to overall ppm position (for line display)
mm.expPointSelect   = 1;                    % frequency position [points] to be displayed (inconsistent, update with 1st use)

%--- display / data manipulation ---
flag.mmAmplShow     = 1;                    % amplitude mode, 1: automatic, 0: direct assignment
mm.amplShowMin      = -10000;               % lower (direct) amplitude limit
mm.amplShowMax      = 10000;                % upper (direct) amplitude limit
flag.mmPpmShow      = 0;                    % visualization window, 0: full sweep width, 1: direct assignment
flag.mmFormat       = 1;                    % data format, 1: real, 2: imaginary, 3: magntitude, 4: phase
mm.satRecSelect     = 1;                    % # of saturation-recovery experiment to be displayed
mm.satRecCons       = 1:2;                  % # of saturation-recovery time points 'cons'idered for display/summation
mm.satRecConsN      = length(mm.satRecCons); % number of saturation-recovery time points 'cons'idered for display/summation
mm.satRecConsStr    = '1 2';                % saturation-recovery time point # string 
mm.tOneSelect       = 1;                    % selected T1 component for visualization
mm.tOneCons         = 1:2;                  % # of T1 vector entries 'cons'idered for display/summation
mm.tOneConsN        = length(mm.tOneCons);  % number of T1s 'cons'idered for display/summation
mm.tOneConsStr      = '1 2';                % T1 entry # string
flag.mmCMap         = 0;                    % color mode, 0: blue (only), 1: jet, 2: hsv, 3: hot
flag.mmCMapLegend   = 1;                    % 
mm.ppmShowMin       = 1.0;                  % minimum ppm value to be displayed
mm.ppmShowMax       = 7.5;                  % maximum ppm value to be displayed
flag.mmKeepFig      = 0;                    % NOT YET IMPLEMENTED. keep figure(s) and create new ones with parameter changes
flag.mmPpmShowPos   = 0;                    % overlay vertical line at specific spectral position
mm.ppmShowPos       = 2.01;                 % frequecy to be displayed as line is spectrum


%--- MM spectrum alignment window ---
%--- FREQUENCY ---
flag.mmAlignFrequ    = 1;           % frequency alignment of individual spectra
mm.frAlignPpmStr     = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
mm.frAlignPpmMin     = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
mm.frAlignPpmMax     = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
mm.frAlignPpmN       = 1;           % number of ppm windows for spectrum alignment
mm.frAlignExpLb      = 2;           % frequency alignment: exponential line broadening [Hz]
mm.frAlignFftCut     = 1024;        % frequency alignment: apodization
mm.frAlignFftZf      = 8*1024;      % frequency alignment: zero-filling
mm.frAlignFrequRg    = 5;           % frequency alignment: potential frequency variation, +/- frequRg
mm.frAlignFrequRes   = 0.1;         % frequency alignment: frequency resolution
mm.frAlignRefFid     = 3;           % frequency alignment: reference FID (number)
mm.frAlignIter       = 2;           % # of iterations, note that >1 iterations use the sum of all spectra
%--- PHASE ---
flag.mmAlignPhase    = 1;           % phase alignment of individual spectra
flag.mmAlignPhMode   = 1;           % phase alignment mode, 0: maximization of spectrum integral, 1: max. of congruency with reference
mm.phAlignPpmStr     = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
mm.phAlignPpmMin     = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
mm.phAlignPpmMax     = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
mm.phAlignPpmN       = 1;           % number of ppm windows for spectrum alignment
mm.phAlignExpLb      = 10;          % phase alignment: exponential line broadening [Hz]
mm.phAlignFftCut     = 1024;        % frequency alignment: apodization
mm.phAlignFftZf      = 8*1024;      % frequency alignment: zero-filling
mm.phAlignPhStep     = 2;           % phase alignment: phase step size, i.e. resolution of the optimization
mm.phAlignRefFid     = 3;           % phase alignment: reference FID (number)
mm.phAlignIter       = 2;           % phase alignment: iterations, >1 via sum of all spectra
%--- AMPLITUDE ---
flag.mmAlignAmpl     = 1;           % amplitude correction of individual spectra
mm.amAlignPpmStr     = '1.8:4.1';   % string of ppm window ranges for spectrum alignment
mm.amAlignPpmMin     = 1.8;         % minimum ppm window values for spectrum alignment (vector if N>1)
mm.amAlignPpmMax     = 4.1;         % maximum ppm window values for spectrum alignment (vector if N>1)
mm.amAlignPpmN       = 1;           % number of ppm windows for spectrum alignment
mm.amAlignExpLb      = 2;           % amplitude alignment: exponential line broadening [Hz]
mm.amAlignFftCut     = 1024;        % amplitude alignment: apodization
mm.amAlignFftZf      = 8*1024;      % amplitude alignment: zero-filling
mm.amAlignRef1Str    = '3';         % amplitude alignment: reference FID (number)
mm.amAlignRef1Vec    = 3;           % reference vector amplitude alignment
mm.amAlignRef1N      = 1;           % number of reference FIDs considered for amplitude correction
mm.amAlignRef2Str    = '4';         % amplitude alignment: reference FID (number)
mm.amAlignRef2Vec    = 4;           % reference vector amplitude alignment
mm.amAlignRef2N      = 1;           % number of reference FIDs considered for amplitude correction
mm.amAlignPolyOrder  = 3;           % order of polynomial amplitude correction
flag.amAlignExtraWin = 0;           % extra spectral window of user-specified size/position (mostly if single peak is used for alignment)
mm.amAlignExtraPpm   = [0 4.3];     % frequency range of extra window


%------------------------
%--- stability window ---
%------------------------
flag.stabRealMagn    = 0;                % 1: real part, 0: magnitude spectrum
stab.phc0            = 0;                % zero order phase
stab.ppmCalib        = 4.65;             % ppm range to be analyzed
stab.ppmBins         = 21;               % spectral bins
stab.specFirst       = 1;                % first spectrum to be analyzed
stab.specLast        = 1;                % last spectrum to be analyzed
stab.ppmBinSel       = 1;                % selected bin for details analysis/visualization
stab.specSel         = 1;                % selected spectrum for details analysis/visualization
stab.trans           = 1;                % transmit channel number
stab.rcvr            = 1;                % receiver channel number
flag.stabTotAll      = 1;                % show whole spectrum analysis of all spectra
flag.stabTotSel      = 1;                % show whole spectrum analysis of selected spectrum
flag.stabBinAll      = 1;                % show binned spectrum analysis of all spectra
flag.stabBinSel      = 1;                % show binned spectrum analysis of selected spectrum


%-----------------------------------------------
%--- processing window of individual spectra ---
%-----------------------------------------------
flag.procNumSpec       = 0;                % number of spectra to be analyzed, 0: 1 spectrum, 1: 2 spectra
flag.procData          = 1;                % processed data, 1:data, 2:proc, 3:MRSI, 4: synthesis, 5: MARSS, 6: LCM page
proc.procFormat        = 1;                % processing mode: 1 for single spectrum, 2 for 2 spectra

%--- data format ---
flag.procDataFormat    = 1;                % file format, 1: matlab (.mat), 2: text (.txt for RAG software), 3: parameter file (.par) for all moeties of a metabolite, 4: Provencher LCModel (.lcm/.raw), 5: Provencher LCModel result (.coord)
proc.dataFormatCell    = {'Binary format (.mat)','Text format (.txt)','All moeities (.par)','LCModel (.raw)','LCModel (.coord)'};

proc.spec1.dataDir     = data.defaultDir;  % data directory of spectrum 1
proc.spec1.dataFileMat = 'FID1.mat';       % (fake) file name of FID file 1
proc.spec1.dataPathMat = [proc.spec1.dataDir proc.spec1.dataFileMat];  % full path of FID file 1 (.mat)
proc.spec1.dataFileTxt = 'FID1.txt';       % (fake) file name of FID file 1
proc.spec1.dataPathTxt = [proc.spec1.dataDir proc.spec1.dataFileTxt];  % full path of FID file 1 (.mat)
proc.spec1.dataFilePar = 'FID1.par';       % (fake) file name of parameter file 1
proc.spec1.dataPathPar = [proc.spec1.dataDir proc.spec1.dataFilePar];  % full path of parameter file 1 (.par)
proc.spec1.dataFileRaw = 'FID1.raw';       % (fake) file name of parameter file 1
proc.spec1.dataPathRaw = [proc.spec1.dataDir proc.spec1.dataFileRaw];  % full path of parameter file 1 (.par)
proc.spec1.dataFileCoord = 'FID1.coord';       % (fake) file name of parameter file 1
proc.spec1.dataPathCoord = [proc.spec1.dataDir proc.spec1.dataFileCoord];  % full path of parameter file 1 (.par)
proc.spec2.dataDir     = data.defaultDir;  % data directory of FID 1
proc.spec2.dataFileMat = 'FID2.mat';       % (fake) file name of FID file 2
proc.spec2.dataPathMat = [proc.spec2.dataDir proc.spec2.dataFileMat];  % full path of FID file 2 (.mat)
proc.spec2.dataFileTxt = 'FID2.txt';       % (fake) file name of FID file 2
proc.spec2.dataPathTxt = [proc.spec2.dataDir proc.spec2.dataFileTxt];  % full path of FID file 2 (.mat)
proc.spec2.dataFilePar = 'FID2.par';       % (fake) file name of parameter file 2
proc.spec2.dataPathPar = [proc.spec2.dataDir proc.spec2.dataFilePar];  % full path of parameter file 2 (.par)
proc.spec2.dataFileRaw = 'FID2.raw';       % (fake) file name of parameter file 2
proc.spec2.dataPathRaw = [proc.spec2.dataDir proc.spec2.dataFileRaw];  % full path of parameter file 2 (.par)
proc.spec2.dataFileCoord = 'FID2.coord';       % (fake) file name of parameter file 2
proc.spec2.dataPathCoord = [proc.spec2.dataDir proc.spec2.dataFileCoord];  % full path of parameter file 2 (.par)
proc.expt.dataDir      = data.defaultDir;  % data directory of export FID file
proc.expt.dataFileMat  = 'ExportFID.mat';  % (fake) file name of export FID file
proc.expt.dataPathMat  = [proc.expt.dataDir proc.expt.dataFileMat];  % full path of export FID (.mat)
proc.expt.dataFileTxt  = 'ExportFID.txt';  % (fake) file name of export FID file
proc.expt.dataPathTxt  = [proc.expt.dataDir proc.expt.dataFileTxt];  % full path of export FID (.mat)
proc.expt.dataFileRaw  = 'ExportFID.raw';  % (fake) file name of export FID file
proc.expt.dataPathRaw  = [proc.expt.dataDir proc.expt.dataFileRaw];  % full path of export FID (.mat)
flag.procSpec1Cut      = 1;                % FID apodization
proc.spec1.cut         = 1024;              % number of time-domain data points
flag.procSpec2Cut      = 1;                % FID apodization
proc.spec2.cut         = 1024;              % number of time-domain data points
flag.procSyncCut       = 0;
flag.procSpec1Zf       = 1;                % FID zerofilling
proc.spec1.zf          = 8192;             % spectral zerofilling
flag.procSpec2Zf       = 1;                % FID zerofilling
proc.spec2.zf          = 8192;             % spectral zerofilling
flag.procSyncZf        = 0;
flag.procSpec1Lb       = 1;                % exponential line broadening of spectrum 1
flag.procSpec2Lb       = 1;                % exponential line broadening of spectrum 2
proc.spec1.lb          = 3;                % exponential line broadening of spectrum 1 [Hz]
proc.spec2.lb          = 3;                % exponential line broadening of spectrum 2 [Hz]
flag.procSyncLb       = 0;
flag.procSpec1Gb      = 0;                % Gaussian line broadening of spectrum 1
flag.procSpec2Gb      = 0;                % Gaussian line broadening of spectrum 2
proc.spec1.gb         = 3;                % Gaussian line broadening of spectrum 1 [Hz]
proc.spec2.gb         = 3;                % Gaussian line broadening of spectrum 2 [Hz]
flag.procSyncGb       = 0;
flag.procSpec1Phc0    = 1;                % zero order phasing switch for spectrum 1
flag.procSpec2Phc0    = 1;                % zero order phasing switch for spectrum 2
flag.procSpec1Phc1    = 0;                % first order phasing switch for spectrum 1
flag.procSpec2Phc1    = 0;                % first order phasing switch for spectrum 2
proc.spec1.phc0       = 0;                % zero order phase PHC0 of spectrum 1
proc.spec2.phc0       = 0;                % zero order phase PHC0 of spectrum 2
flag.procSyncPhc0     = 0;
proc.spec1.phc1       = 0;                % first order phase correction PHC1 of spectrum 1 (using the Bruker definition)         
proc.spec2.phc1       = 0;                % first order phase correction PHC1 of spectrum 2 (using the Bruker definition)         
flag.procSyncPhc1     = 0;
flag.procSpec1Scale   = 0;                % amplitude scaling switch
flag.procSpec2Scale   = 0;                % amplitude scaling switch
proc.spec1.scale      = 1;                % amplitude scaling spectrum 1
proc.spec2.scale      = 1;                % amplitude scaling spectrum 2
flag.procSyncScale    = 0;
flag.procSpec1Shift   = 0;                % switch for frequency shift of spectrum 1
flag.procSpec2Shift   = 0;                % switch for frequency shift of spectrum 2
proc.spec1.shift      = 0;                % frequency shift of spectrum 1 [Hz]
proc.spec2.shift      = 0;                % frequency shift of spectrum 2 [Hz]
flag.procSyncShift    = 0;
flag.procSpec1Offset  = 0;                % switch for baseline offset of spectrum 1
flag.procSpec2Offset  = 0;                % switch for baseline offset of spectrum 2
proc.spec1.offset     = 0;                % baseline offset of spectrum 1 [a.u.]
proc.spec2.offset     = 0;                % baseline offset of spectrum 2 [a.u.]
flag.procSyncOffset   = 0;
flag.procSpec1Stretch = 0;                % switch for baseline offset of spectrum 1
flag.procSpec2Stretch = 0;                % switch for baseline offset of spectrum 2
proc.spec1.stretch    = 0;                % frequency stretch of spectrum 1 [Hz/ppm]
proc.spec2.stretch    = 0;                % frequency stretch of spectrum 2 [Hz/ppm]
flag.procSyncStretch  = 0;
flag.procPpmShow      = 0;                % visualization window, 0: full sweep width, 1: direct assignment
proc.ppmShowMin       = 1.0;              % minimum ppm value to be displayed
proc.ppmShowMax       = 7.5;              % maximum ppm value to be displayed
flag.procFormat       = 1;                % result spectrum visualization mode, 1: real, 2: imaginary, 3: magnitude
proc.ppmCalib         = 4.67;             % spectrum calibration, center frequency (water)
proc.ppmAssign        = 2.01;             % spectral peak assignment, e.g. 2.01 for NAA
flag.procPpmShowPos   = 0;                % overlay vertical line at specific spectral position
proc.ppmShowPos       = 2.01;             % frequecy to be displayed as line is spectrum
proc.ppmShowPosMirr   = proc.ppmCalib+proc.ppmShowPos;   % mirrored frequency position
flag.procPpmShowPosMirr = 0;             % also show frequency mirror around the synthesize (water) frequency
proc.ppmTargetMin     = 1.5;              % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
proc.ppmTargetMax     = 2.5;              % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
proc.ppmNoiseMin      = 9;                % minimum ppm value of frequency window for noise area of SNR analysis
proc.ppmNoiseMax      = 10;               % maximum ppm value of frequency window for noise area of SNR analysis
flag.procAmpl         = 0;                % 0: autoadjust, 1: direct assignment
proc.amplMin          = 0;                % minimum display amplitude
proc.amplMax          = 1e4;              % maximum display amplitude
flag.procAnaSNR       = 0;                % SNR analysis of FID/spectra
flag.procAnaFWHM      = 0;                % full width at half maximum analysis of spectral peaks
flag.procAnaIntegr    = 0;                % spectral integration
flag.procAnaSign      = 1;                % Perform SNR/FWHM/integration analysis for peak of positive (1) or negative (0) polarity
flag.procAnaAbsOfReal = 0;                % magnitude of real part (only) instead of true magnitude that also considers the imaginary part
flag.procOffset       = 1;                % baseline offset mode, 1: average of ppm range, 0: direct assignment of offset value
proc.ppmOffsetMin     = 0;                % min. frequency of ppm window for determination of baseline offset
proc.ppmOffsetMax     = 1;                % max. frequency of ppm window for determination of baseline offset
proc.offsetVal        = 0;                % baseline offset value
proc.alignAmpWeight   = 1;                % amplitude weighting for spectrum alignment (spec1-spec2)^proc.alignAmpWeight
proc.alignPpmStr      = '1.8:4.1';        % string of ppm window ranges for spectrum alignment
proc.alignPpmMin      = 1.8;              % minimum ppm window values for spectrum alignment (vector if N>1)
proc.alignPpmMax      = 4.1;              % maximum ppm window values for spectrum alignment (vector if N>1)
proc.alignPpmN        = 1;                % number of ppm windows for spectrum alignment
flag.procAlignLb      = 1;                % include LB in spectrum alignment procedure
flag.procAlignGb      = 0;                % include GB in spectrum alignment procedure
flag.procAlignPhc0    = 1;                % include PHC0 in spectrum alignment procedure
flag.procAlignPhc1    = 0;                % include PHC1 in spectrum alignment procedure
flag.procAlignScale   = 1;                % include scaling in spectrum alignment procedure
flag.procAlignShift   = 1;                % include shift in spectrum alignment procedure
proc.alignTolFun      = 1e-15;            % tolerance function
proc.alignMaxIter     = 500;              % maximum number of iterations
flag.procAlignOffset  = 1;                % include offset in spectrum alignment procedure
flag.procAlignPoly    = 0;                % Include polynomial function in spectrum alignment procedure      
proc.alignPolyOrder   = 2;                % Order of polynomial included in spectra alignment
proc.spec1.polycoeff  = zeros(1,11);      % polynomial coefficients 0..10th order
proc.spec2.polycoeff  = zeros(1,11);      % polynomial coefficients 0..10th order
flag.procAlignStretch = 0;                % include stretch in spectrum alignment procedure
flag.procUpdateCalc   = 1;                % 1: automatic update of spectral reconstruction, 0: off (e.g. after baseline correction)                            
flag.procKeepFig      = 0;                % keep figure(s) and create new ones with parameter changes
flag.procFigSelect    = 1;                % figure selection for frequency difference measurement, 1: spec 1, 2: spec 2, 3: super, 4: sum, 5: diff
flag.procApplyPoly1   = 1;                % Apply/ignore the polynomial baseline determined by the spetrum alignment procedure for the processing of spectrum 1
flag.procApplyPoly2   = 0;                % Apply/ignore the polynomial baseline determined by the spetrum alignment procedure for the processing of spectrum 2

%--- JDE efficiency analysis ---
proc.jdeEffPpmRg      = [2.22 2.45];      % frequency range for JDE efficiency analysis 
proc.jdeEffOffset     = 0;                % baseline offset for JDE efficiency analysis
proc.convExtStr       = '_new';               % Potential file extension for above .par-to-.mat data conversion


%--- baseline tool ---
proc.basePolyOrder    = 2;                % polynomial order for base line correction
proc.basePolyPpmStr   = '0:1 7:8';        % string of ppm window ranges for polynomial baseline correction
proc.basePolyPpmMin   = [0 7];            % minimum ppm window values for polynomial baseline correction
proc.basePolyPpmMax   = [1 8];            % maximum ppm window values for polynomial baseline correction
proc.basePolyPpmN     = 2;                % number of ppm windows for polynomial baseline correction
flag.procBaseInterpMode = 1;              % interpolation mode, 1: nearest, 2: linear, 3: spline, 4: cubic
proc.baseInterpPpmStr = '0:1 7:8';        % string of ppm window ranges for interpolation baseline correction
proc.baseInterpPpmMin = [0 7];            % minimum ppm window values for interpolation baseline correction
proc.baseInterpPpmMax = [1 8];            % maximum ppm window values for interpolation baseline correction
proc.baseInterpPpmN   = 2;                % number of ppm windows for interpolation baseline correction
proc.baseSvdPeakN     = 5;                % number of exponentials
proc.baseSvdPpmStr    = '0:1 7:8';        % string of ppm window ranges for SVD-base peak removal
proc.baseSvdPpmMin    = [0 7];            % minimum ppm window values for SVD-base peak removal
proc.baseSvdPpmMax    = [1 8];            % maximum ppm window values for SVD-base peak removal
proc.baseSvdPpmN      = 2;                % number of ppm windows for SVD-base peak removal

%--- proc figure handling ---
% these are session-specific volatile parameters that are NOT written to file
proc.fig.fid1Orig   = [20 20 560 550];
proc.fig.fid1       = [30 30 560 550];
proc.fig.spec1      = [40 40 560 550];
proc.fig.fid2Orig   = [50 50 560 550];
proc.fig.fid2       = [60 60 560 550];
proc.fig.spec2      = [70 70 560 550];
proc.fig.fidSuper   = [80 80 560 550];
proc.fig.fidSum     = [90 90 560 550];
proc.fig.fidDiff    = [100 100 560 550];
proc.fig.specSuper  = [110 110 560 550];
proc.fig.specSum    = [120 120 560 550];
proc.fig.specDiff   = [130 130 560 550];


%--------------------
%--- T1/T2 window ---
%--------------------
t1t2.lb               = 2;                    % exponential line broadening
t1t2.cut              = 1024;                 % apodization
t1t2.zf               = 16384;                % zero-filling
t1t2.ppmCalib         = 4.65;                 % ppm calibration
t1t2.ppmWinMin        = 0;                    % Minimum ppm limit of spectral analysis window
t1t2.ppmWinMax        = 10;                   % Maximum ppm limit of spectral analysis window
t1t2.phaseZero        = 0;                    % zero-order phase offset 
t1t2.delayNumber      = 1;                    % delay number of spectrum to be used for frequency calibration (via peak picking)
t1t2.ppmAssign        = 2.01;                 % calibration frequency used with peak picking
t1t2.anaFrequMin      = 1;                    % lower (direct) frequency limit
t1t2.anaFrequMax      = 4.2;                  % upper (direct) frequency limit
flag.t1t2AnaData      = 4;                    % data type, 1: FID, 0: peaks
t1t2.anaDataCell      = {'Start of FID','Peak height','Peak integral','Direct assignment (T1)','Direct assignment (T2)'};
flag.t1t2OffsetCorr   = 0;                    % offset correction of peak integral (8-10ppm)
t1t2.anaFidMin        = 1;                    % number of first FID point to be considered
t1t2.anaFidMax        = 5;                    % number of last FID point to be considered
flag.t1t2AnaFormat    = 1;                    % data format to be analyzed, 1: real, 0: magnitude
flag.t1t2AnaSignFlip  = 0;                    % flip amplitude sign of first N time points (of magnitude data)
t1t2.anaSignFlipN     = 3;                    % Number of time points to be sign-flipped
t1t2.anaTime          = 0:50:300;             % direct assignment of time vector
t1t2.anaTimeN         = length(t1t2.anaTime); % number of time constants to be fitted
t1t2.anaTimeStr       = SP2_Vec2PrintStr(t1t2.anaTime,0,0);     % time constants display string
t1t2.anaAmp           = [8000 3000 1000 300 150 70 20]; % direct assignment of amplitudes
t1t2.anaAmpN          = length(t1t2.anaAmp); % number of time constants to be fitted
t1t2.anaAmpStr        = SP2_Vec2PrintStr(t1t2.anaAmp,0,0);     % time constants display string
flag.t1t2AnaMode      = 1;                    % time component mode, 1: fixed, 0: flexible
t1t2.anaTConstFlexN   = 5;                    % number of time components for flexible fitting
flag.t1t2AnaFlex1Fix  = 1;                    % flexible fitting with one fixed time constant
t1t2.anaTConstFlex1Fix = 0.07;               % fixed T1 or T2 time constant [s]
t1t2.anaTConst        = [0.1 0.2 0.3 0.8 1.1 1.4 1.7];            % selection vector of time constants
t1t2.anaTConstN       = length(t1t2.anaTConst);                   % number of time constants to be fitted
t1t2.anaTConstStr     = SP2_Vec2PrintStr(t1t2.anaTConst,2,0);     % time constants display string
flag.t1t2AnaFitOffset = 1;                    % include potential offset in T1/T2 analysis
t1t2.tConstSelect     = 1;                    % # of time constants component to be displayed
flag.t1t2AmplShow     = 1;                    % amplitude mode, 1: automatic, 0: direct assignment
t1t2.amplShowMin      = -10000;               % lower (direct) amplitude limit
t1t2.amplShowMax      = 10000;                % upper (direct) amplitude limit
flag.t1t2PpmShow      = 0;                    % visualization window, 0: full sweep width, 1: direct assignment
flag.t1t2Format       = 1;                    % data format, 1: real, 2: imaginary, 3: magntitude, 4: phase
t1t2.ppmShowMin       = 1.0;                  % minimum ppm value to be displayed
t1t2.ppmShowMax       = 7.5;                  % maximum ppm value to be displayed
t1t2.t1decT1          = 1500;                 % T1 [ms];
t1t2.t1decScale       = 0;                    % relative amplitude (input, output is delay)
t1t2.t1decDelay       = 500;                  % time point (input, output is relative amplitude)
t1t2.t2decT2          = 100;                  % T2 [ms];
t1t2.t2decScale       = 0.5;                  % relative amplitude (input, output is delay)
t1t2.t2decDelay       = 200;                  % time point (input, output is relative amplitude)


%-------------------
%--- MARSS window ---
%-------------------
flag.marssSequName      = 1;                % MRS sequence
marss.sequNameCell      = {'STEAM','PRESS','sLASER (Juchem Lab)','Custom'};
flag.marssSequOrigin    = 1;                % sequency origin: customized or MR vendor stock sequence
% marss.sequOriginCell    = {'General Electric','Siemens','Philips','Bruker','Agilent','Hitachi'};
marss.sequOriginCell    = {'General Electric','Siemens','Philips'};
flag.marssSimParsDef    = 3;                % file format, 1: matlab (.mat), 2: text (.txt for RAG software), 3: parameter file (.par) for all moeties of a metabolite, 4: Provencher LCModel (.lcm/.raw), 5: JMRUI (.mrui)marss.outputFormatCell  = {'Binary format (.mat)','Text format (.txt)','JMRUI (.mrui)','LCModel (.raw)'};
marss.simParsDefCell    = {'Data Page','Processing Page','MARSS Page','MRSI Page','LCM Page','Simulation Page'};
flag.marssResultFormat  = 1;                % file format, 1: matlab (.mat), 2: text (.txt for RAG software), 3: parameter file (.par) for all moeties of a metabolite, 4: Provencher LCModel (.lcm/.raw), 5: JMRUI (.mrui)marss.outputFormatCell  = {'Binary format (.mat)','Text format (.txt)','JMRUI (.mrui)','LCModel (.raw)'};
marss.resultFormatCell  = {'Binary format (.mat)','Text format (.txt)','JMRUI (.mrui)','LCModel (.raw)'};
marss.b0                = 7;                % B0 field strength
marss.sf                = 298.1;            % Larmor frequency [MHz]
marss.ppmCalib          = 4.65;             % synthesizer frequency calibration [ppm]
marss.sw_h              = 5000;             % bandwidth [Hz]
marss.sw                = marss.sw_h/marss.sf;  % bandwidth [ppm]
marss.nspecCBasic       = 8192;             % number of complex points before processing
marss.voxDim            = 20;               % voxel dimension [mm], simulation applied to 2*voxDim
marss.simDim            = 128;              % simulation dimension per spatial dimension
marss.te                = 30;               % echo time
marss.te2               = 30;               % echo time 2 (not used yet...)
marss.tm                = 20;               % mixing time, STEAM only
marss.lb                = 1;                % Lorentzian line broadening of simulated spectra
flag.marssSaveIndiv     = 0;                % 1: keep individual spectra in addition to overall basis set, 0: only keep basis
flag.marssSaveLog       = 0;                % write LCM log file equivalent to the command window printout
marss.log               = 0;                % log file handle
flag.marssSaveJpeg      = 0;                % write LCM figure to image (jpeg) format
marss.spinSys.nameCell  = {};               % spin system name cell
marss.spinSys.select    = [];               % init spin system selection in listbox
marss.spinSys.n         = 0;                % init number of spin systems in library
marss.spinSys.libDir   = data.defaultDir;  % directory of spin system library file
marss.spinSys.libName  = 'spinSys.mat';      % name if of spin system library file
marss.spinSys.libPath  = [marss.spinSys.libDir marss.spinSys.libName];  % full path of spin system library file (.mat)
% basis selection
marss.basis.select      = [];               % init metabolite selection from basis listbox
marss.basis.selectN     = length(marss.basis.select);        % init metabolite selection from basis listbox
marss.basis.selectNames = {};               % name cell of basis selection to be simulated
% simulation outcome
marss.basis.n           = 0;                % init number of (actually) simulated metabolites in basis library
marss.basis.nameCell    = {};               % name cell of simulation result
marss.basis.fileDir     = data.defaultDir;  % directory of simulated basis file
marss.basis.fileName    = 'basis.mat';      % name of simulated basis file
marss.basis.filePath    = [marss.basis.fileDir marss.basis.fileName];  % full path of basis file (.mat)
flag.marssProcCut       = 1;                % FID apodization
marss.procCut           = 1024;             % number of time-domain data points
flag.marssProcZf        = 1;                % FID zerofilling
marss.procZf            = 8192;             % spectral zerofilling
flag.marssProcLb        = 1;                % exponential line broadening of spectrum 1
marss.procLb            = 3;                % exponential line broadening of spectrum 1 [Hz]
flag.marssProcGb        = 0;                % Gaussian line broadening of spectrum 1
marss.procGb            = 3;                % Gaussian line broadening of spectrum 1 [Hz]
flag.marssProcPhc0      = 1;                % zero order phasing switch for spectrum 1
marss.procPhc0          = 0;                % zero order phase PHC0 of spectrum 1
flag.marssProcPhc1      = 0;                % first order phasing switch for spectrum 1
marss.procPhc1          = 0;                % first order phase correction PHC1 of spectrum 1 (using the Bruker definition)         
flag.marssProcScale     = 0;                % amplitude scaling switch
marss.procScale         = 1;                % amplitude scaling spectrum 1
flag.marssProcShift     = 0;                % switch for frequency shift of spectrum 1
marss.procShift         = 0;                % frequency shift of spectrum 1 [Hz]
flag.marssProcOffset    = 0;                % switch for baseline offset of spectrum 1
marss.procOffset        = 0;                % baseline offset of spectrum 1 [a.u.]
flag.marssAmplShow      = 1;                % amplitude mode, 1: automatic, 0: direct assignment
marss.amplShowMin       = -10000;           % lower (direct) amplitude limit
marss.amplShowMax       = 10000;            % upper (direct) amplitude limit
flag.marssPpmShow       = 0;                % visualization window, 0: full sweep width, 1: direct assignment
marss.ppmShowMin        = 1.0;              % minimum ppm value to be displayed
marss.ppmShowMax        = 7.5;              % maximum ppm value to be displayed
flag.marssShowSelAll    = 0;                % 1: Superimpose / sum assigned metabolite selection\n0: Superimpose / sum all available metabolites                      
marss.showSel           = [1 2 3];          % MARSS result metabolite selection
marss.showSelN          = length(marss.showSel);   % number of selected metabolites
marss.showSelStr        = '1 2 3';          % metabolite selection string
marss.currShow          = 1;                % current metabolite
marss.lineWidth         = 1;                % linewidth of spectral displays
flag.marssColorMap      = 0;                % color map, 0:uniform, 1:jet, 2:hsv, 3:hot
flag.marssLegend        = 0;                % display selection
flag.marssKeepFig       = 0;                % keep figure(s) and create new ones with parameter changes



%-------------------
%--- MRSI window ---
%-------------------
flag.mrsiNumSpec       = 0;                % number of spectra to be analyzed, 0: 1 spectrum, 1: 2 spectra
flag.mrsiData          = 1;                % processed data, 0: data page, 1: directly from processing page
mrsi.mrsiFormat        = 1;                % processing mode: 1 for single spectrum, 2 for 2 spectra
flag.mrsiDatFormat     = 1;                % file format, 1: matlab (.mat), 0: text (.txt for RAG software)
mrsi.spec1.dataDir     = data.defaultDir;  % data directory of spectrum 1
mrsi.spec1.dataFileMat = 'FID1.mat';       % (fake) file name of FID file 1
mrsi.spec1.dataPathMat = [mrsi.spec1.dataDir mrsi.spec1.dataFileMat];  % full path of FID file 1 (.mat)
mrsi.spec1.dataFileTxt = 'FID1.txt';       % (fake) file name of FID file 1
mrsi.spec1.dataPathTxt = [mrsi.spec1.dataDir mrsi.spec1.dataFileTxt];  % full path of FID file 1 (.mat)
mrsi.spec2.dataDir     = data.defaultDir;  % data directory of FID 1
mrsi.spec2.dataFileMat = 'FID2.mat';       % (fake) file name of FID file 2
mrsi.spec2.dataPathMat = [mrsi.spec2.dataDir mrsi.spec2.dataFileMat];  % full path of FID file 2 (.mat)
mrsi.spec2.dataFileTxt = 'FID2.txt';       % (fake) file name of FID file 2
mrsi.spec2.dataPathTxt = [mrsi.spec2.dataDir mrsi.spec2.dataFileTxt];  % full path of FID file 2 (.mat)
mrsi.ref.dataDir       = data.defaultDir;  % data directory of reference
mrsi.ref.dataFileMat   = 'REF.mat';       % (fake) file name of reference
mrsi.ref.dataPathMat   = [mrsi.ref.dataDir mrsi.ref.dataFileMat];  % full path of reference (.mat)
mrsi.ref.dataFileTxt   = 'REF.txt';       % (fake) file name of FID reference
mrsi.ref.dataPathTxt   = [mrsi.ref.dataDir mrsi.ref.dataFileTxt];  % full path of reference (.mat)
mrsi.expt.dataDir      = data.defaultDir;  % data directory of export FID file
mrsi.expt.dataFileMat  = 'ExportFID.mat';  % (fake) file name of export FID file
mrsi.expt.dataPathMat  = [mrsi.expt.dataDir mrsi.expt.dataFileMat];  % full path of export FID (.mat)
mrsi.expt.dataFileTxt  = 'ExportFID.txt';  % (fake) file name of export FID file
mrsi.expt.dataPathTxt  = [mrsi.expt.dataDir mrsi.expt.dataFileTxt];  % full path of export FID (.mat)
flag.mrsiSpec1Cut      = 1;                % FID apodization
mrsi.spec1.cut         = 1024;             % number of time-domain data points
flag.mrsiSpec2Cut      = 1;                % FID apodization
mrsi.spec2.cut         = 1024;             % number of time-domain data points
flag.mrsiSyncCut       = 0;
flag.mrsiSpec1Zf       = 1;                % FID zerofilling
mrsi.spec1.zf          = 8192;             % spectral zerofilling
flag.mrsiSpec2Zf       = 1;                % FID zerofilling
mrsi.spec2.zf          = 8192;             % spectral zerofilling
flag.mrsiSyncZf        = 0;
flag.mrsiSpec1Lb       = 1;                % exponential line broadening of spectrum 1
flag.mrsiSpec2Lb       = 1;                % exponential line broadening of spectrum 2
mrsi.spec1.lb          = 3;                % exponential line broadening of spectrum 1 [Hz]
mrsi.spec2.lb          = 3;                % exponential line broadening of spectrum 2 [Hz]
flag.mrsiSyncLb      = 0;
flag.mrsiSpec1Gb     = 0;                % Gaussian line broadening of spectrum 1
flag.mrsiSpec2Gb     = 0;                % Gaussian line broadening of spectrum 2
mrsi.spec1.gb        = 3;                % Gaussian line broadening of spectrum 1 [Hz]
mrsi.spec2.gb        = 3;                % Gaussian line broadening of spectrum 2 [Hz]
flag.mrsiSyncGb      = 0;
flag.mrsiSpec1Phc0   = 1;                % zero order phasing switch for spectrum 1
flag.mrsiSpec2Phc0   = 1;                % zero order phasing switch for spectrum 2
flag.mrsiSpec1Phc1   = 0;                % first order phasing switch for spectrum 1
flag.mrsiSpec2Phc1   = 0;                % first order phasing switch for spectrum 2
mrsi.spec1.phc0      = 0;                % zero order phase PHC0 of spectrum 1
mrsi.spec2.phc0      = 0;                % zero order phase PHC0 of spectrum 2
flag.mrsiSyncPhc0    = 0;
mrsi.spec1.phc1      = 0;                % first order phase correction PHC1 of spectrum 1 (using the Bruker definition)         
mrsi.spec2.phc1      = 0;                % first order phase correction PHC1 of spectrum 2 (using the Bruker definition)         
flag.mrsiSyncPhc1    = 0;
flag.mrsiSpec1Scale  = 0;                % amplitude scaling switch
flag.mrsiSpec2Scale  = 0;                % amplitude scaling switch
mrsi.spec1.scale     = 1;                % amplitude scaling spectrum 1
mrsi.spec2.scale     = 1;                % amplitude scaling spectrum 2
flag.mrsiSyncScale   = 0;
flag.mrsiSpec1Shift  = 0;                % switch for frequency shift of spectrum 1
flag.mrsiSpec2Shift  = 0;                % switch for frequency shift of spectrum 2
mrsi.spec1.shift     = 0;                % frequency shift of spectrum 1 [Hz]
mrsi.spec2.shift     = 0;                % frequency shift of spectrum 2 [Hz]
flag.mrsiSyncShift   = 0;
flag.mrsiSpec1Offset = 0;                % switch for baseline offset of spectrum 1
flag.mrsiSpec2Offset = 0;                % switch for baseline offset of spectrum 2
mrsi.spec1.offset    = 0;                % baseline offset of spectrum 1 [a.u.]
mrsi.spec2.offset    = 0;                % baseline offset of spectrum 2 [a.u.]
flag.mrsiSyncOffset  = 0;
flag.mrsiEcc         = 1;                % eddy-current correction
flag.mrsiBaseCorr    = 1;                % baseline correction, 1: polynomial, 2: SVD, 3: ...
flag.mrsiSpatFilt    = 1;                % spatial filter flag
flag.mrsiSpatZF      = 1;                % spatial zero-filling flat
mrsi.spatZF          = 25;               % spatial zero-filling size
mrsi.selectLR        = 5;                % selected single spectrum: left/right
mrsi.selectPA        = 5;                % selected single spectrum: posterior/anterior


%--- MRSI display ---
flag.mrsiPpmShow     = 0;                % visualization window, 0: full sweep width, 1: direct assignment
mrsi.ppmShowMin      = 1.0;              % minimum ppm value to be displayed
mrsi.ppmShowMax      = 7.5;              % maximum ppm value to be displayed
flag.mrsiFormat      = 1;                % result spectrum visualization mode, 1: real, 2: imaginary, 3: magnitude
mrsi.ppmCalib        = 4.67;             % spectrum calibration, center frequency (water)
mrsi.ppmAssign       = 2.01;             % spectral peak assignment, e.g. 2.01 for NAA
flag.mrsiPpmShowPos  = 0;                % overlay vertical line at specific spectral position
mrsi.ppmShowPos      = 2.01;             % frequecy to be displayed as line is spectrum
mrsi.ppmShowPosMirr  = mrsi.ppmCalib+mrsi.ppmShowPos;   % mirrored frequency position
flag.mrsiPpmShowPosMirr = 0;             % also show frequency mirror around the synthesize (water) frequency
mrsi.ppmTargetMin    = 1.5;              % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
mrsi.ppmTargetMax    = 2.5;              % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
mrsi.ppmNoiseMin     = 9;                % minimum ppm value of frequency window for noise area of SNR analysis
mrsi.ppmNoiseMax     = 10;               % maximum ppm value of frequency window for noise area of SNR analysis
flag.mrsiAmpl        = 0;                % 0: autoadjust, 1: direct assignment
mrsi.amplMin         = 0;                % minimum display amplitude
mrsi.amplMax         = 1e4;              % maximum display amplitude
flag.mrsiAnaSNR      = 0;                % SNR analysis of FID/spectra
flag.mrsiAnaFWHM     = 0;                % full width at half maximum analysis of spectral peaks
flag.mrsiAnaIntegr   = 0;                % spectral integration
flag.mrsiOffset      = 1;                % baseline offset mode, 1: average of ppm range, 0: direct assignment of offset value
mrsi.ppmOffsetMin    = 0;                % min. frequency of ppm window for determination of baseline offset
mrsi.ppmOffsetMax    = 1;                % max. frequency of ppm window for determination of baseline offset
mrsi.offsetVal       = 0;                % baseline offset value
flag.mrsiUpdateCalc  = 1;                % 1: automatic update of spectral reconstruction, 0: off (e.g. after baseline correction)                            
flag.mrsiKeepFig     = 0;                % keep figure(s) and create new ones with parameter changes

%--- MRSI baseline tool ---
mrsi.basePolyOrder    = 2;                % polynomial order for base line correction
mrsi.basePolyPpmStr   = '0:1 7:8';        % string of ppm window ranges for polynomial baseline correction
mrsi.basePolyPpmMin   = [0 7];            % minimum ppm window values for polynomial baseline correction
mrsi.basePolyPpmMax   = [1 8];            % maximum ppm window values for polynomial baseline correction
mrsi.basePolyPpmN     = 2;                % number of ppm windows for polynomial baseline correction
flag.mrsiBaseInterpMode = 1;              % interpolation mode, 1: nearest, 2: linear, 3: spline, 4: cubic
mrsi.baseInterpPpmStr = '0:1 7:8';        % string of ppm window ranges for interpolation baseline correction
mrsi.baseInterpPpmMin = [0 7];            % minimum ppm window values for interpolation baseline correction
mrsi.baseInterpPpmMax = [1 8];            % maximum ppm window values for interpolation baseline correction
mrsi.baseInterpPpmN   = 2;                % number of ppm windows for interpolation baseline correction
mrsi.baseSvdPeakN     = 5;                % number of exponentials
mrsi.baseSvdPpmStr    = '0:1 7:8';        % string of ppm window ranges for SVD-base peak removal
mrsi.baseSvdPpmMin    = [0 7];            % minimum ppm window values for SVD-base peak removal
mrsi.baseSvdPpmMax    = [1 8];            % maximum ppm window values for SVD-base peak removal
mrsi.baseSvdPpmN      = 2;                % number of ppm windows for SVD-base peak removal


%--------------------------------------------------
%--- lcmodel window for spectrum quantification ---
%--------------------------------------------------
%--- basic init ---
lcm.sf                  = 123.2;            % (random) default: 3T
lcm.sw_h                = 4000;             % (random) default: 4 kHz

%--- data format ---
flag.lcmData            = 1;                % processed data, 1:data, 2:proc, 3:MRSI, 4: Synthesis, 5: MARSS, 6:directly from LCM page
flag.lcmDataFormat      = 1;                % file format, 1: matlab (.mat), 2: text (.txt for RAG software), 3: parameter file (.par) for all moeties of a metabolite, 4: Provencher LCModel (.lcm/.raw), 5: JMRUI (.mrui)
lcm.dataFormatCell      = {'Binary format (.mat)','Text format (.txt)','All moeities (.par)','LCModel (.raw)','JMRUI (.mrui)'};
lcmDataFormatCell       = lcm.dataFormatCell;       % ensure backward compatibility

lcm.dataDir             = data.defaultDir;  % data directory of spectrum 1
lcm.dataFileMat         = 'FID1.mat';       % (fake) file name of FID file 1
lcm.dataPathMat         = [lcm.dataDir lcm.dataFileMat];  % full path of FID file 1 (.mat)
lcm.dataFileTxt         = 'FID1.txt';       % (fake) file name of FID file 1
lcm.dataPathTxt         = [lcm.dataDir lcm.dataFileTxt];  % full path of FID file 1 (.mat)
lcm.dataFilePar         = 'FID1.par';       % (fake) file name of parameter file 1
lcm.dataPathPar         = [lcm.dataDir lcm.dataFilePar];  % full path of parameter file 1 (.par)
lcm.dataFileRaw         = 'FID1.raw';       % (fake) file name of parameter file 1
lcm.dataPathRaw         = [lcm.dataDir lcm.dataFileRaw];  % full path of parameter file 1 (.par)
lcm.dataFileJmrui       = 'FID1.mrui';       % (fake) file name of parameter file 1
lcm.dataPathJmrui       = [lcm.dataDir lcm.dataFileJmrui];  % full path of parameter file 1 (.par)
lcm.basisDir            = data.defaultDir;  % data directory of LCM basis set
lcm.basisFile           = 'Basis.mat';      % (fake) file name of LCM basis
lcm.basisPath           = [lcm.basisDir lcm.basisFile];  % full path of LCM basis
lcm.expt.dataDir        = data.defaultDir;  % data directory of export FID file
lcm.expt.dataFileMat    = 'ExportFID.mat';  % (fake) file name of export FID file
lcm.expt.dataPathMat    = [lcm.expt.dataDir lcm.expt.dataFileMat];  % full path of export FID (.mat)
lcm.expt.dataFileTxt    = 'ExportFID.txt';  % (fake) file name of export FID file
lcm.expt.dataPathTxt    = [lcm.expt.dataDir lcm.expt.dataFileTxt];  % full path of export FID (.mat)
lcm.expt.dataFileRaw    = 'ExportFID.raw';  % (fake) file name of export FID file
lcm.expt.dataPathRaw    = [lcm.expt.dataDir lcm.expt.dataFileRaw];  % full path of export FID (.mat)
lcm.expt.dataFileJmrui  = 'ExportFID.mrui';  % (fake) file name of export FID file
lcm.expt.dataPathJmrui  = [lcm.expt.dataDir lcm.expt.dataFileJmrui];  % full path of export FID (.mat)
lcm.logPath             = [lcm.expt.dataDir 'SPX_LcmAnalysis.log'];

flag.lcmSpecCut         = 1;                % FID apodization
lcm.specCut             = 1024;             % number of time-domain data points
flag.lcmSpecZf          = 1;                % FID zerofilling
lcm.specZf              = 16384;            % spectral zerofilling
flag.lcmSpecLb          = 1;                % exponential line broadening of spectrum 1
lcm.specLb              = 3;                % exponential line broadening of spectrum 1 [Hz]
flag.lcmSpecGb          = 0;                % Gaussian line broadening of spectrum 1
lcm.specGb              = 3;                % Gaussian line broadening of spectrum 1 [Hz]
flag.lcmUpdProcTarget   = 1;                % selection of processing update with parameter changes: target spectrum to be analyzed
flag.lcmUpdProcBasis    = 1;                % selection of processing update with parameter changes: basis spectra
flag.lcmUpdProcResult   = 1;                % selection of processing update with parameter changes: result spectra
flag.lcmSpecPhc0        = 0;                % zero order phasing switch for spectrum 1
lcm.specPhc0            = 0;                % zero order phase PHC0 of spectrum 1
flag.lcmSpecPhc1        = 0;                % first order phasing switch for spectrum 1
lcm.specPhc1            = 0;                % first order phase correction PHC1 of spectrum 1 (using the Bruker definition)         
flag.lcmSpecScale       = 0;                % amplitude scaling
lcm.specScale           = 1;                % scaling factor
flag.lcmSpecShift       = 0;                % switch for frequency shift of spectrum 1
lcm.specShift           = 0;                % frequency shift of spectrum 1 [Hz]
flag.lcmSpecOffset      = 0;                % spectrum offset
lcm.specOffset          = 1;                % offset
flag.lcmPpmShow         = 0;                % visualization window, 0: full sweep width, 1: direct assignment
lcm.ppmShowMin          = 1.0;              % minimum ppm value to be displayed
lcm.ppmShowMax          = 7.5;              % maximum ppm value to be displayed
flag.lcmFormat          = 1;                % result spectrum visualization mode, 1: real, 2: imaginary, 3: magnitude
lcm.ppmCalib            = 4.65;             % spectrum calibration, center frequency (water)
lcm.ppmAssign           = 2.01;             % spectral peak assignment, e.g. 2.01 for NAA
flag.lcmPpmShowPos      = 0;                % overlay vertical line at specific spectral position
lcm.ppmShowPos          = 2.01;             % frequecy to be displayed as line is spectrum

%--- LCM basis ---
lcm.basis.n             = 0;                % (fake) init: number of metabolite spectra
lcm.basis.ptsMin        = 0;                % (fake) init: minimum FID length
lcm.basis.ptsMax        = 0;                % (fake) init: maximum FID length
lcm.basis.fidLength     = 0;                % (fake) init: vector of individual FID lengths
lcm.basis.data          = 0;                % (fake) init: basis data structure
lcm.basis.sw            = 0;                % (fake) init: sweep width [ppm]
lcm.basis.sw_h          = 0;                % (fake) init: sweep width [Hz]
lcm.basis.sf            = 0;                % (fake) init: Larmor frequency [MHz]
lcm.basis.dwell         = 0;                % (fake) init: dwell time [sec]
lcm.basis.fid           = 0;                % (fake) init: FID of selected metabolite
lcm.basis.spec          = 0;                % (fake) init: spectrum of selected metabolite
lcm.basis.nspecC        = 0;                % (fake) init: number of complex points
lcm.basis.currShow      = 0;                % (fake) init: currently shown metabolite [1]
lcm.basis.nLim          = 40;               % overall maximum number of metabolites per basis set
lcm.basis.ppmCalib      = 0;                % (fake) init: frequency calibration [ppm]
lcm.basis.reorder       = 0;                % (fake) init: metabolite reordering vector

%--- LCM analysis details ---
lcm.fit.n               = 0;                            % (fake) init: number of SELECTED metabolite spectra
lcm.fit.nLim            = 40;                           % overall maximum number of supported basis functions
lcm.fit.shift           = 5;                            % allowed frequency shift
lcm.fit.select          = ones(1,lcm.fit.nLim);         % basis selection vector (binary)
lcm.fit.applied         = find(lcm.fit.select);         % vector of basis functions to be applied
lcm.fit.appliedN        = length(lcm.fit.applied);      % number of applied basis functions
lcm.fit.lbMin           = 5*ones(1,lcm.fit.nLim);       % allowed minimum line width (FWHM), [Hz]
lcm.fit.lbMax           = 20*ones(1,lcm.fit.nLim);      % allowed minimum line width (FWHM), [Hz]
lcm.fit.gbMin           = 0*ones(1,lcm.fit.nLim);       % allowed minimum line width (FWHM), [Hz]
lcm.fit.gbMax           = 10*ones(1,lcm.fit.nLim);      % allowed minimum line width (FWHM), [Hz]
lcm.fit.phc0Var         = 20*ones(1,lcm.fit.nLim);      % allowed PHC0 variation [deg]
lcm.fit.phc1Var         = 20*ones(1,lcm.fit.nLim);      % allowed PHC0 variation [deg]
lcm.fit.shiftMin        = -5*ones(1,lcm.fit.nLim);      % allowed minimum/negative shift limit, [Hz]
lcm.fit.shiftMax        = 5*ones(1,lcm.fit.nLim);       % allowed maximum/positive shift limit, [Hz]
% lcm.fit.frequVar        = 5*ones(1,lcm.fit.nLim);       % allowed frequency variation [Hz], applied to both sides
flag.lcmLinkLb          = 1;                            % link LB of all basis functions, i.e. use 1 global loggingfile value
flag.lcmLinkGb          = 1;                            % link lineshape of all basis functions, i.e. use 1 global loggingfile value
flag.lcmLinkPhc0        = 1;                            % link Phc0 of all basis functions, i.e. use 1 global loggingfile value
flag.lcmLinkPhc1        = 1;                            % link Phc1 of all basis functions, i.e. use 1 global loggingfile value
flag.lcmLinkShift       = 1;                            % link frequency shift of all basis functions, i.e. use 1 global loggingfile value
flag.lcmComb1           = 0;                            % enable metabolite combinations for CRLB analysis
lcm.comb1Str            = '1 2';                        % combination string
lcm.comb1Ind            = [1 2];                        % indices vector
lcm.comb1N              = 2;                            % number of metabolites in combination
flag.lcmComb2           = 0;                            % enable metabolite combinations for CRLB analysis
lcm.comb2Str            = '3 4';                        % combination string
lcm.comb2Ind            = [3 4];                        % indices vector
lcm.comb2N              = 2;                            % number of metabolites in combination
flag.lcmComb3           = 0;                            % enable metabolite combinations for CRLB analysis
lcm.comb3Str            = '5 6';                        % combination string
lcm.comb3Ind            = [5 6];                        % indices vector
lcm.comb3N              = 2;                            % number of metabolites in combination
lcm.combN               = flag.lcmComb1 + flag.lcmComb2 + flag.lcmComb3;            % number of combinations selected
lcm.combInd             = find([flag.lcmComb1 flag.lcmComb2 flag.lcmComb3]);        % index vector of metabolite combinations selected
lcm.fit.lbVarMin        = 2;                            % allowed minimum LB variation around current value
lcm.fit.lbVarMax        = 2;                            % allowed maximum LB variation around current value
lcm.fit.gbVarMin        = 2;                            % allowed minimum GB variation around current value
lcm.fit.gbVarMax        = 2;                            % allowed maximum GB variation around current value
lcm.fit.shiftVarMin     = 2;                            % allowed minimum shift variation around current value
lcm.fit.shiftVarMax     = 2;                            % allowed maximum shift variation around current value
lcm.fit.currShow        = 1;                            % current metabolite
flag.lcmPlotBaseCorr    = 1;                            % consider baseline in the display of LCM results
flag.lcmPlotInclTarget  = 1;                            % include target spectrum in the display of LCM results
flag.lcmPlotInclBase    = 1;                            % include baseline spectrum in the display of LCM results
flag.lcmPlotInclFit     = 1;                            % include total fit sum in single/superposition plot
flag.lcmPlotInclResid   = 1;                            % include fit residual in single/superposition plot
lcm.fit.tolFun          = 1e-8;                         % accuracy threshold
lcm.fit.maxIter         = 200;                          % maximum number of iterations
flag.lcmRealComplex     = 1;                            % Two meanings: 1) data origin: single channel vs. quadrature, 2) 1: real, 0: complex fit 

%--- display limits of error analysis (CRLB & Hessian) ---
lcm.fit.errLimAmpMin   = 0.1;       % [%]
lcm.fit.errLimAmpMax   = 100;       % [%]
lcm.fit.errLimLbMin    = 0.1;       % [Hz]
lcm.fit.errLimLbMax    = 50;        % [Hz]
lcm.fit.errLimGbMin    = 0.1;       % [Hz]
lcm.fit.errLimGbMax    = 50;        % [Hz]
lcm.fit.errLimShiftMin = 0.1;       % [Hz]
lcm.fit.errLimShiftMax = 50;        % [Hz]
lcm.fit.errLimPhc0Min  = 0.1;       % [deg]
lcm.fit.errLimPhc1Min  = 0.1;       % [deg]

%--- result analysis ---
flag.lcmAnaScale        = 1;                                % include scaling (in starting value reset only)
lcm.anaScale            = ones(1,lcm.fit.nLim);             % basis scaling
lcm.anaScaleErr         = ones(1,lcm.fit.nLim);             % basis scaling error
flag.lcmAnaLb           = 1;                                % include LB
lcm.anaLb               = ones(1,lcm.fit.nLim);             % LB vector
lcm.anaLbErr            = ones(1,lcm.fit.nLim);             % LB vector error
flag.lcmAnaGb           = 1;                                % include GB
lcm.anaGb               = ones(1,lcm.fit.nLim);             % GB vector
lcm.anaGbErr            = ones(1,lcm.fit.nLim);             % GB vector error
flag.lcmAnaShift        = 1;                                % include shift
lcm.anaShift            = zeros(1,lcm.fit.nLim);            % shift vector
lcm.anaShiftErr         = zeros(1,lcm.fit.nLim);            % shift vector error
flag.lcmAnaPhc0         = 1;                                % include PHC0
lcm.anaPhc0             = 0;                                % global loggingfile PHC0
lcm.anaPhc0Err          = 0;                                % global loggingfile PHC0 error
flag.lcmAnaPhc1         = 1;                                % include PHC1
lcm.anaPhc1             = 0;                                % global loggingfile PHC1
lcm.anaPhc1Err          = 0;                                % global loggingfile PHC1 error
lcm.anaPpmStr           = '1.8:4.1';                        % string of ppm window ranges for spectrum alignment
lcm.anaPpmMin           = 1.8;                              % minimum ppm window values for spectrum alignment (vector if N>1)
lcm.anaPpmMax           = 4.1;                              % maximum ppm window values for spectrum alignment (vector if N>1)
lcm.anaPpmN             = 1;                                % number of ppm windows for spectrum alignment
% polynomial baseline:
flag.lcmAnaPoly         = 0;                                % Include polynomial function in LCM fit
lcm.anaPolyOrder        = 2;                                % polynomial order for LCM analysis  
lcm.anaPolyCoeff        = zeros(1,11);                      % polynomial coefficients 0..10th order
lcm.anaPolyCoeffErr     = zeros(1,11);                      % polynomial coefficients 0..10th order, error
lcm.anaPolyShift        = 0;                                % shift along the x-axis (ppm-axis) of polynomial
lcm.anaPolyShiftErr     = 0;                                % error of shift along the x-axis (ppm-axis) of polynomial
lcm.anaPolyCoeffImag    = zeros(1,11);                      % polynomial coefficients 0..10th order, imaginary part of complex fit
lcm.anaPolyCoeffImagErr = zeros(1,11);                      % polynomial coefficients 0..10th order, imaginary part of complex fit, error
lcm.anaPolyShiftImag    = 0;                                % shift along the x-axis (ppm-axis) of polynomial
lcm.anaPolyShiftImagErr = 0;                                % error of shift along the x-axis (ppm-axis) of polynomial
% spline baseline:
flag.lcmAnaSpline       = 0;                                % Include b-spline function in LCM fit
lcm.anaSplPtsPerPpm     = 2;                                % (approximate) spline points per ppm
lcm.anaSplOrder         = 2;                                % spline order
lcm.anaSplSmooth        = 0;                                % smoothing
lcm.anaSplBounds        = 5;                                % bounds
% Monte-Carlo simulation
flag.lcmMCarloRunning   = 0;                % 1: MC simulation running, 0: not running, used e.g. to disable automated update functions
lcm.mc.n                = 200;              % number of Monte-Carlo computations
lcm.mc.initSpread       = 10;               % standard deviation [%] of variation for Monte-Carlo initialization
lcm.mc.noiseFac         = 1;                % noise amplification for (arrayed) MC analysis
flag.lcmMCarloData      = 1;                % target selection, 1: synthesized LCM reference analysis, 0: original / experimental spectrum
flag.lcmMCarloRef       = 1;                % 1: Perform reference LCM analysis\n0: Use the current LCM result as reference
flag.lcmMCarloInit      = 0;                % 1: Init LCM fit with result form previous analysis\n0: Reset all parameters for every LCM analysis
flag.lcmMCarloCont      = 0;                % Continue Monte-Carlo analysis and extend by assigned number of computations
lcm.batch.protDir       = lcm.dataDir;      % protocol directory for batch MC simulations
lcm.batch.n             = 100;              % number of Monte-Carlo computations (overrides lcm.mc.n)

%--- data/result display and basic analysis ---
flag.lcmAmpl            = 0;                % 0: autoadjust, 1: direct assignment
lcm.amplMin             = 0;                % minimum display amplitude
lcm.amplMax             = 1e4;              % maximum display amplitude
lcm.ppmTargetMin        = 1.5;              % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
lcm.ppmTargetMax        = 2.5;              % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
lcm.ppmNoiseMin         = 10;               % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
lcm.ppmNoiseMax         = 12;               % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
flag.lcmOffset          = 1;                % baseline offset mode, 1: average of ppm range, 0: direct assignment of offset value
lcm.ppmOffsetMin        = 0;                % min. frequency of ppm window for determination of baseline offset
lcm.ppmOffsetMax        = 1;                % max. frequency of ppm window for determination of baseline offset
lcm.offsetVal           = 0;                % base offset for SNR/FWHM/integral analysis

flag.lcmAnaSNR          = 0;                % SNR analysis of selected spectrum
flag.lcmAnaFWHM         = 0;                % full width at half maximum analysis of spectral peaks
flag.lcmAnaIntegr       = 0;                % spectral integration
flag.lcmAnaSign         = 1;                % implemented, but no functionality/buttons added yet
flag.lcmColorMap        = 0;                % color map, 0:uniform, 1:jet, 2:hsv, 3:hot
flag.lcmLegend          = 0;                % display selection
flag.lcmUpdateCalc      = 1;                % 1: automatic update of spectral reconstruction, 0: off (e.g. after baseline correction)                            
flag.lcmKeepFig         = 0;                % keep figure(s) and create new ones with parameter changes
flag.lcmFigSelect       = 1;                % figure selection for frequency difference measurement, 1: spec 1, 2: spec 2, 3: super, 4: sum, 5: diff
flag.lcmSaveLog         = 0;                % write LCM log file equivalent to the command window printout
lcm.log                 = 0;                % log file handle
flag.lcmSaveJpeg        = 0;                % write LCM figure to image (jpeg) format

%--- baseline ---
flag.lcmBasePoly        = 0;                % Include polynomial function in spectrum alignment lcmedure      
lcm.base.polyOrder      = 2;                % polynomial order for base line correction
lcm.base.polyPpmStr     = '0:1 7:8';        % string of ppm window ranges for polynomial baseline correction
lcm.base.polyPpmMin     = [0 7];            % minimum ppm window values for polynomial baseline correction
lcm.base.polyPpmMax     = [1 8];            % maximum ppm window values for polynomial baseline correction
lcm.base.polyPpmN       = 2;                % number of ppm windows for polynomial baseline correction
% flag.lcmBaseInterpMode  = 1;                % interpolation mode, 1: nearest, 2: linear, 3: spline, 4: cubic
% lcm.baseInterpPpmStr    = '0:1 7:8';        % string of ppm window ranges for interpolation baseline correction
% lcm.baseInterpPpmMin    = [0 7];            % minimum ppm window values for interpolation baseline correction
% lcm.baseInterpPpmMax    = [1 8];            % maximum ppm window values for interpolation baseline correction
% lcm.baseInterpPpmN      = 2;                % number of ppm windows for interpolation baseline correction
% lcm.baseSvdPeakN        = 5;                % number of exponentials
% lcm.baseSvdPpmStr       = '0:1 7:8';        % string of ppm window ranges for SVD-base peak removal
% lcm.baseSvdPpmMin       = [0 7];            % minimum ppm window values for SVD-base peak removal
% lcm.baseSvdPpmMax       = [1 8];            % maximum ppm window values for SVD-base peak removal
% lcm.baseSvdPpmN         = 2;                % number of ppm windows for SVD-base peak removal

%--- display and further analysis ---
flag.lcmShowSelAll  = 0;                      % 1: Superimpose / sum assigned metabolite selection\n0: Superimpose / sum all available metabolites                      
lcm.showSel         = [1 2 3];                % LCM result metabolite selection
lcm.showSelN        = length(lcm.showSel);    % number of selected metabolites
lcm.showSelStr      = '1 2 3';                % metabolite selection string
lcm.lineWidth       = 1.5;                    % linewidth of spectral displays

%--- LCM figure handling ---
% these are session-specific volatile parameters that are NOT written to file
lcm.fig.fhLcmFidOrig            = [60 60 560 550];
lcm.fig.fhLcmFid                = [70 70 560 550];
lcm.fig.fhLcmSpec               = [80 80 560 550];
lcm.fig.fhLcmFitSpecSummary     = [90 90 560 550];
lcm.fig.fhLcmFitSpecSuperpos    = [100 100 560 550];
lcm.fig.fhLcmFitSpecSum         = [110 110 560 550];
lcm.fig.fhLcmFitSpecSingle      = [120 120 560 550];
lcm.fig.fhLcmFitSpecResid       = [130 130 560 550];
lcm.fig.fhBasisSpec             = [140 140 560 550];



%-------------------------
%--- synthesis window ---
%-------------------------
%--- FID simulation parameters ---
syn.fidDir           = [data.defaultDir '']; 
syn.fidNamePar       = 'NAA.par';                 % metabolite parameter file name
syn.fidName          = syn.fidNamePar(1:end-4);   % metabolite file name
syn.fidPath          = [syn.fidDir syn.fidName];  % metabolite file path
syn.fidPathPar       = [syn.fidPath '.par'];      % metabolite parameter file path
syn.t1               = 1.5;                       % metabolite T1 [s]
syn.t2               = 0.025;                     % metabolite T2 [s]
flag.synSource       = 2;                         % signal source, 1: noise, 2: singlets, 3: individual metabolite, 4: brain metabolites

%--- noise characteristics ---
flag.synNoise        = 0;                         % add noise to simulated saturation-recovery experiment
syn.noiseAmp         = 100;                       % noise amplitude [a.u.], to be improved...
flag.synNoiseKeep    = 0;                         % keep noise, i.e. do not recalculate with every use

%--- baseline characteristics ---
flag.synBase         = 0;                         % add baseline from to spectral simulation
syn.baseAmp          = 100;                       % baseline amplitude scaling
flag.synPoly         = 0;                         % add polynomial baseline to spectral simulation
syn.polyCenterPpm    = 3.0;                       % polynomial center position [ppm]
syn.polyAmpVec       = zeros(1,6);                % polynomial amplitude vector (0..5th order).

%--- setup / preprocessing ---
syn.sf              = 298.1;            % Larmor frequency [MHz]
syn.ppmCalib        = 4.65;             % synthesizer frequency calibration [ppm]
syn.sw_h            = 5000;             % bandwidth [Hz]
syn.nspecCBasic     = 16384;            % number of complex points before processing
flag.synProcCut     = 1;                % FID apodization
syn.procCut         = 1024;             % number of time-domain data points
flag.synProcZf      = 1;                % FID zerofilling
syn.procZf          = 8192;             % spectral zerofilling
flag.synProcLb      = 1;                % exponential line broadening of spectrum 1
syn.procLb          = 3;                % exponential line broadening of spectrum 1 [Hz]
flag.synProcGb      = 0;                % Gaussian line broadening of spectrum 1
syn.procGb          = 3;                % Gaussian line broadening of spectrum 1 [Hz]
flag.synProcPhc0    = 1;                % zero order phasing switch for spectrum 1
syn.procPhc0        = 0;                % zero order phase PHC0 of spectrum 1
flag.synProcPhc1    = 0;                % first order phasing switch for spectrum 1
syn.procPhc1        = 0;                % first order phase correction PHC1 of spectrum 1 (using the Bruker definition)         
flag.synProcScale   = 0;                % amplitude scaling switch
syn.procScale       = 1;                % amplitude scaling spectrum 1
flag.synProcShift   = 0;                % switch for frequency shift of spectrum 1
syn.procShift       = 0;                % frequency shift of spectrum 1 [Hz]
flag.synProcOffset  = 0;                % switch for baseline offset of spectrum 1
syn.procOffset      = 0;                % baseline offset of spectrum 1 [a.u.]
flag.synAnaSNR      = 0;                % SNR analysis of FID/spectra
flag.synAnaFWHM     = 0;                % full width at half maximum analysis of spectral peaks
flag.synAnaIntegr   = 0;                % spectral integration
flag.synAnaSign     = 1;                % Perform SNR/FWHM/integration analysis for peak of positive (1) or negative (0) polarity
syn.ppmTargetMin    = 1.5;              % minimum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
syn.ppmTargetMax    = 2.5;              % maximum ppm value of frequency window for target peak of FWHM/integral/SNR analysis
syn.ppmNoiseMin     = 9;                % minimum ppm value of frequency window for noise area of SNR analysis
syn.ppmNoiseMax     = 10;               % maximum ppm value of frequency window for noise area of SNR analysis
flag.synPpmShowPos  = 0;                % overlay vertical line at specific spectral position
syn.ppmShowPos      = 2.01;             % frequecy to be displayed as line is spectrum
syn.ppmShowPosMirr  = syn.ppmCalib+syn.ppmShowPos;   % mirrored frequency position
flag.synPpmShowPosMirr = 0;             % also show frequency mirror around the synthesize (water) frequency
flag.synOffset      = 1;                % baseline offset mode, 1: average of ppm range, 0: direct assignment of offset value
syn.ppmOffsetMin    = 0;                % min. frequency of ppm window for determination of baseline offset
syn.ppmOffsetMax    = 1;                % max. frequency of ppm window for determination of baseline offset
syn.offsetVal       = 0;                % baseline offset value
syn.metabCharStr    = '[0.0 10 10], [1 20 10], [2 25 10], [3 30 10], [4 35 10]';
syn.metabCharCell   = eval(['{' syn.metabCharStr '}']);

%--- display ---
flag.synAmplShow     = 1;               % amplitude mode, 1: automatic, 0: direct assignment
syn.amplShowMin      = -10000;          % lower (direct) amplitude limit
syn.amplShowMax      = 10000;           % upper (direct) amplitude limit
flag.synPpmShow      = 0;               % visualization window, 0: full sweep width, 1: direct assignment
flag.synFormat       = 1;               % data format, 1: real, 2: imaginary, 3: magntitude, 4: phase
flag.synCMap         = 0;               % color mode, 0: blue (only), 1: jet, 2: hsv, 3: hot
flag.synCMapLegend   = 1;               % 
syn.ppmShowMin       = 1.0;             % minimum ppm value to be displayed
syn.ppmShowMax       = 7.5;             % maximum ppm value to be displayed
flag.synPpmShowPos   = 0;               % overlay vertical line at specific spectral position
syn.ppmShowPos       = 2.01;            % frequecy to be displayed as line is spectrum
flag.synUpdateCalc   = 1;                % 1: automatic update of spectral reconstruction, 0: off (e.g. after baseline correction)                            
flag.synKeepFig      = 0;                % keep figure(s) and create new ones with parameter changes
flag.synFigSelect    = 1;                % figure selection for frequency difference measurement, 1: spec 1, 2: spec 2, 3: super, 4: sum, 5: diff

%--- LCM figure handling ---
% these are session-specific volatile parameters that are NOT written to file
syn.fig.fhSynFidOrig    = [60 60 560 550];
syn.fig.fhSynFid        = [70 70 560 550];
syn.fig.fhSynSpec       = [80 80 560 550];


%--- tools page ---
tools.anonFileDir      = data.defaultDir;                   % directory of file to be anonymized
tools.anonFilePath     = [tools.anonFileDir 'procpar'];     % path of file to be anonymized
tools.anonDir          = data.defaultDir;                   % directory to be anonymized

%--- manual page ---
manName   = 'INSPECTOR_Manual.pdf';          % generic file name
man.filePath   = [data.defaultDir manName];


%--- flag handling ---
% Keep all defaults and just replace the ones from loaded protocols. Doing
% so, full backwards compatibility is guaranteed even if certain flags did
% not exist in older versions and, therefore, in older protocols.
flagDef = flag;


%--------------------------------------------------------------------------
%---                U S E R  /  P A T H    H A N D L I N G              ---
%--------------------------------------------------------------------------
%--- search for file with default settings and load/generate it ---
fmStruct = what('INSPECTOR')
if isempty(fmStruct) || ~isfield(fmStruct,'path')
    SP2_Logger.log('%s ->\nCouldn''t find the main program file\nCheck folder name/existence <INSPECTOR_v2> and software version...',FCTNAME);
    return
else
    pars.specPath   = SP2_FileHelper.inspectorPath();
    
    %--- protocol handling ---
    % update of default protocol file path (in any case)
    if flag.OS==1        % Linux
        pars.usrDefFile = [pars.specPath filesep 'SP_DefaultsMac.mat'];
    elseif flag.OS==2            % Mac
        pars.usrDefFile = [pars.specPath filesep 'SP_DefaultsMac.mat'];
    else                            % PC
        pars.usrDefFile = [pars.specPath filesep 'SP_DefaultsWindows.mat'];
    end
    SP2_Logger.log("%s\tpars.usrDefFile=%s",mfilename,pars.usrDefFile);
    % selection of specific/default protocol file
    if nargin==1                % external/specific protocol is loaded
        protFile = varargin{1};
    else                        % default protocol file is loaded
        protFile = pars.usrDefFile;
    end
    
    %--- load protocol and transfer parameters ---
    if exist(protFile,'file')            % load default file: 1) all flags, 2) selected pars parameters
        %--- load protocol ---
        load(protFile)
        
        %--- check if protocol file ---
        if ~exist('data2save') || ~exist('proc2save') || ~exist('mm2save')
            SP2_Logger.log('Assigned file is not an INSPECTOR protocol. Program aborted.\n');
            return
        end        
        
        %--- check if protocol file ---
        if ~isstruct(data2save) || ~isstruct(proc2save) || ~isstruct(mm2save)
            SP2_Logger.log('Assigned file is not an INSPECTOR protocol. Program aborted.\n');
            return
        end        
                
        %--- assure backwards compatibility of phase and frequency window definitions ---
        if isfield(data2save,'phAlignPpmDnMin') && isfield(data2save,'phAlignPpmDnMax') && ...
           isfield(data2save,'phAlignPpmUpMin') && isfield(data2save,'phAlignPpmUpMax')

            if flag.dataAlignPhSpecRg           % 2 windows
                data2save.phAlignPpmStr  = [num2str(data2save.phAlignPpmDnMin) ':' num2str(data2save.phAlignPpmDnMax) ' ' num2str(data2save.phAlignPpmUpMin) ':' num2str(data2save.phAlignPpmUpMax)];
                data2save.phAlignPpmMin  = [data2save.phAlignPpmDnMin data2save.phAlignPpmUpMin];
                data2save.phAlignPpmMax  = [data2save.phAlignPpmDnMax data2save.phAlignPpmUpMax];
                data2save.phAlignPpmN    = 2;
            else                                % 1 window
                data2save.phAlignPpmStr  = [num2str(data2save.phAlignPpmUpMin) ':' num2str(data2save.phAlignPpmUpMax)];
                data2save.phAlignPpmMin  = data2save.phAlignPpmUpMin;
                data2save.phAlignPpmMax  = data2save.phAlignPpmUpMax;
                data2save.phAlignPpmN    = 1;
            end

            SP2_Logger.log('\n--- INFO ---\nBackward compatibility conversion applied\nfor phase alignment parameters.\n');
            SP2_Logger.log('Note: For fully identical phase alignment conditions,\nkeep original FID length (no apodization, no zero-filling)\n');
            % include:
            % data.phAlignFftCut = 1024;        % frequency alignment: apodization
            % data.phAlignFftZf  = 8*1024;      % frequency alignment: zero-filling

            %--- frequency alignment ---
            data2save.frAlignPpmStr  = [num2str(data2save.frAlignPpmMin) ':' num2str(data2save.frAlignPpmMax)];
            data2save.frAlignPpmN    = 1;
            SP2_Logger.log('\n--- INFO ---\nBackward compatibility conversion applied\nfor frequency alignment parameters.\n\n');
        end
                
        %--- assure backwards compatibility of LCM shift variation limits ---
        if exist('lcm2save','var')
            if ~isfield(lcm2save.fit,'shiftMin') && ~isfield(lcm2save.fit,'shiftMax') && isfield(lcm2save.fit,'frequVar')

                lcm2save.fit.shiftMin = -lcm2save.fit.frequVar;       % allowed minimum/negative shift limit, [Hz]
                lcm2save.fit.shiftMax = lcm2save.fit.frequVar;        % allowed maximum/positive shift limit, [Hz]
                lcm2save.fit = rmfield(lcm2save.fit,'frequVar');

                SP2_Logger.log('\n--- INFO ---\nBackward compatibility conversion applied\nto LCM frequency shift range.\n');
            end
        end
        
        % transfer to corresponding flag fields
        % note that all flags are replaced that existed at the time the
        % protocol was generated.
		flagFields = fieldnames(flag);
		for iCnt = 1:length(flagFields)
            if isfield(flagDef,flagFields{iCnt})
               eval(['flagDef.' flagFields{iCnt} ' = flag.' flagFields{iCnt} ';'])
            end
        end
        flag = flagDef;        % replace loaded protocol flag struct with updated defaults
        clear flagDef flagFields
        
        % transfer to corresponding pars fields (if existing)
		if exist('pars2save','var')
            %--- main 'pars' structure ---
            pars2sFields = fieldnames(pars2save);
            for iCnt = 1:length(pars2sFields)
                if isfield(pars,pars2sFields{iCnt})
                    if isstruct(eval(['pars.' pars2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['pars2save.' pars2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['pars.' pars2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['pars.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['pars2save.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['pars.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['pars.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''pars'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['pars.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = pars2save.' pars2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['pars.' pars2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = pars2save.' pars2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['pars.' pars2sFields{iCnt} ' = pars2save.' pars2sFields{iCnt} ';'])
                    end
                end
            end
            clear pars2save pars2sFields
        end
        
        % transfer to corresponding experiment (data) fields (if existing)
		if exist('data2save','var')
            %--- main 'data' structure ---
            data2sFields = fieldnames(data2save);
            for iCnt = 1:length(data2sFields)
                if isfield(data,data2sFields{iCnt})
                    if isstruct(eval(['data.' data2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['data2save.' data2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['data.' data2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['data.' data2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['data2save.' data2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['data.' data2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['data.' data2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''data'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['data.' data2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = data2save.' data2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['data.' data2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = data2save.' data2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['data.' data2sFields{iCnt} ' = data2save.' data2sFields{iCnt} ';'])
                    end
                end
            end
            
            %--- assure backwards compatibility of frequency alignment window ---
            % note that the single window parameters do not exist anymore
            if isfield(data2save,'frAlignPpmN')
                data.frAlignPpm1Str = data2save.frAlignPpmStr;
                data.frAlignPpm1Min = data2save.frAlignPpmMin;
                data.frAlignPpm1Max = data2save.frAlignPpmMax;
                data.frAlignPpm1N   = data2save.frAlignPpmN;
                data.frAlignPpm2Str = data2save.frAlignPpmStr;
                data.frAlignPpm2Min = data2save.frAlignPpmMin;
                data.frAlignPpm2Max = data2save.frAlignPpmMax;
                data.frAlignPpm2N   = data2save.frAlignPpmN;
                SP2_Logger.log('\n--- INFO ---\nBackwards compatibility:\nTwo frequency alignment windows initialized with (old) single-window values.\n');
            end

            %--- assure backwards compatibility of phase alignment window ---
            % note that the single window parameters do not exist anymore
            if isfield(data2save,'phAlignPpmN')
                data.phAlignPpm1Str = data2save.phAlignPpmStr;
                data.phAlignPpm1Min = data2save.phAlignPpmMin;
                data.phAlignPpm1Max = data2save.phAlignPpmMax;
                data.phAlignPpm1N   = data2save.phAlignPpmN;
                data.phAlignPpm2Str = data2save.phAlignPpmStr;
                data.phAlignPpm2Min = data2save.phAlignPpmMin;
                data.phAlignPpm2Max = data2save.phAlignPpmMax;
                data.phAlignPpm2N   = data2save.phAlignPpmN;
                SP2_Logger.log('\n--- INFO ---\nBackwards compatibility:\nTwo phase alignment windows initialized with (old) single-window values.\n');
            end
            clear data2save data2sFields
        end
        
        % transfer to corresponding experiment (MM) fields (if existing)
		if exist('mm2save','var')
            %--- main 'MM' structure ---
            mm2sFields = fieldnames(mm2save);
            for iCnt = 1:length(mm2sFields)
                if isfield(mm,mm2sFields{iCnt})
                    if isstruct(eval(['mm.' mm2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['mm2save.' mm2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['mm.' mm2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['mm.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['mm2save.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['mm.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['mm.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''mm'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['mm.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = mm2save.' mm2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['mm.' mm2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = mm2save.' mm2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['mm.' mm2sFields{iCnt} ' = mm2save.' mm2sFields{iCnt} ';'])
                    end
                end
            end
            %--- assure backward compatibility ---
            if isfield(mm2save,'simDelayMin')
                mm.sim.delayMin = mm2save.simDelayMin;
            end
            if isfield(mm2save,'simDelayMax')
                mm.sim.delayMax = mm2save.simDelayMax;
            end
            if isfield(mm2save,'simDelayN')
                mm.sim.delayN   = mm2save.simDelayN;
            end
            clear mm2save mm2sFields
        end
        
        % transfer to corresponding stability fields (if existing)
        if exist('stab2save','var')
            stab2sFields = fieldnames(stab2save);
            for iCnt = 1:length(stab2sFields)
                if isfield(stab,stab2sFields{iCnt})
                   eval(['stab.' stab2sFields{iCnt} ' = stab2save.' stab2sFields{iCnt} ';'])
                end
            end
            clear stab2save stab2sFields
        end
        
        % transfer to corresponding processing (proc) fields (if existing)
		if exist('proc2save','var')
            %--- main 'proc' structure ---
            proc2sFields = fieldnames(proc2save);
            for iCnt = 1:length(proc2sFields)
                if isfield(proc,proc2sFields{iCnt})
                    if isstruct(eval(['proc.' proc2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['proc2save.' proc2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['proc.' proc2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['proc.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['proc2save.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['proc.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['proc.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''proc'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['proc.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = proc2save.' proc2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['proc.' proc2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = proc2save.' proc2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['proc.' proc2sFields{iCnt} ' = proc2save.' proc2sFields{iCnt} ';'])
                    end
                end
            end
            clear proc2save proc2sFields
        end
         
        % transfer to corresponding T1/T2 (t1t2) fields (if existing)
		if exist('t1t22save','var')
            %--- main 't1t2' structure ---
            t1t22sFields = fieldnames(t1t22save);
            for iCnt = 1:length(t1t22sFields)
                if isfield(t1t2,t1t22sFields{iCnt})
                    if isstruct(eval(['t1t2.' t1t22sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['t1t22save.' t1t22sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['t1t2.' t1t22sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['t1t2.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['t1t22save.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['t1t2.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['t1t2.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''t1t2'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['t1t2.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = t1t22save.' t1t22sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['t1t2.' t1t22sFields{iCnt} '.' sub1Fields{s1Cnt} ' = t1t22save.' t1t22sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['t1t2.' t1t22sFields{iCnt} ' = t1t22save.' t1t22sFields{iCnt} ';'])
                    end
                end
            end
            clear t1t22save t1t22sFields
        end

        % transfer MARSS fields (if existing)
		if exist('marss2save','var')
            %--- main 'marss' structure ---
            marss2sFields = fieldnames(marss2save);
            for iCnt = 1:length(marss2sFields)
                if isfield(marss,marss2sFields{iCnt})
                    if isstruct(eval(['marss.' marss2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['marss2save.' marss2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['marss.' marss2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['marss.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['marss2save.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['marss.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['marss.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''marss'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['marss.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = marss2save.' marss2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['marss.' marss2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = marss2save.' marss2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['marss.' marss2sFields{iCnt} ' = marss2save.' marss2sFields{iCnt} ';'])
                    end
                end
            end
            clear marss2save marss2sFields
        end

        % transfer MRSI fields (if existing)
		if exist('mrsi2save','var')
            %--- main 'mrsi' structure ---
            mrsi2sFields = fieldnames(mrsi2save);
            for iCnt = 1:length(mrsi2sFields)
                if isfield(mrsi,mrsi2sFields{iCnt})
                    if isstruct(eval(['mrsi.' mrsi2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['mrsi2save.' mrsi2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['mrsi.' mrsi2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['mrsi.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['mrsi2save.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['mrsi.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['mrsi.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''mrsi'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['mrsi.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = mrsi2save.' mrsi2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['mrsi.' mrsi2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = mrsi2save.' mrsi2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['mrsi.' mrsi2sFields{iCnt} ' = mrsi2save.' mrsi2sFields{iCnt} ';'])
                    end
                end
            end
            clear mrsi2save mrsi2sFields
        end

        % transfer LCM fields (if existing)
		if exist('lcm2save','var')
            %--- main 'lcm' structure ---
            lcm2sFields = fieldnames(lcm2save);
            for iCnt = 1:length(lcm2sFields)
                if isfield(lcm,lcm2sFields{iCnt})
                    if isstruct(eval(['lcm.' lcm2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['lcm2save.' lcm2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['lcm.' lcm2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['lcm.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['lcm2save.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['lcm.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['lcm.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''lcm'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['lcm.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = lcm2save.' lcm2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['lcm.' lcm2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = lcm2save.' lcm2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['lcm.' lcm2sFields{iCnt} ' = lcm2save.' lcm2sFields{iCnt} ';'])
                    end
                end
            end
            clear lcm2save lcm2sFields
        end

        % transfer simulation fields (if existing)
		if exist('syn2save','var')
            %--- main 'sim' structure ---
            syn2sFields = fieldnames(syn2save);
            for iCnt = 1:length(syn2sFields)
                if isfield(syn,syn2sFields{iCnt})
                    if isstruct(eval(['syn.' syn2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['syn2save.' syn2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['syn.' syn2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['syn.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['syn2save.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['syn.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['syn.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''syn'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['syn.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = syn2save.' syn2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['syn.' syn2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = syn2save.' syn2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['syn.' syn2sFields{iCnt} ' = syn2save.' syn2sFields{iCnt} ';'])
                    end
                end
            end
            clear syn2save syn2sFields
        end

        % transfer tools fields (if existing)
		if exist('tools2save','var')
            %--- main 'tools' structure ---
            tools2sFields = fieldnames(tools2save);
            for iCnt = 1:length(tools2sFields)
                if isfield(tools,tools2sFields{iCnt})
                    if isstruct(eval(['tools.' tools2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['tools2save.' tools2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['tools.' tools2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['tools.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['tools2save.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['tools.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['tools.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''tools'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['tools.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = tools2save.' tools2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['tools.' tools2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = tools2save.' tools2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['tools.' tools2sFields{iCnt} ' = tools2save.' tools2sFields{iCnt} ';'])
                    end
                end
            end
            clear tools2save tools2sFields
        end

        % transfer manual fields (if existing)
		if exist('man2save','var')
            %--- main 'man' structure ---
            man2sFields = fieldnames(man2save);
            for iCnt = 1:length(man2sFields)
                if isfield(man,man2sFields{iCnt})
                    if isstruct(eval(['man.' man2sFields{iCnt}]))
                        %--- sub-structure 1 ---
                        sub1Fields = fieldnames(eval(['man2save.' man2sFields{iCnt}]));
                        for s1Cnt = 1:length(sub1Fields)
                            if isfield(eval(['man.' man2sFields{iCnt}]),sub1Fields{s1Cnt})
                                if isstruct(eval(['man.' man2sFields{iCnt} '.' sub1Fields{s1Cnt}]))
                                    %--- sub-structure 2 ---
                                    sub2Fields = fieldnames(eval(['man2save.' man2sFields{iCnt} '.' sub1Fields{s1Cnt}]));
                                    for s2Cnt = 1:length(sub2Fields)
                                        if isfield(eval(['man.' man2sFields{iCnt} '.' sub1Fields{s1Cnt}]),sub2Fields{s2Cnt})
                                            if isstruct(eval(['man.' man2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt}]))
                                                SP2_Logger.log('%s -> Only 2 sublevels are supported for ''man'' structure.\n',FCTNAME);
                                                return
                                            else                    % single entry field
                                                eval(['man.' man2sFields{iCnt} '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ' = man2save.' man2sFields{iCnt}  '.' sub1Fields{s1Cnt} '.' sub2Fields{s2Cnt} ';'])
                                            end
                                        end
                                    end
                                else                    % single entry field
                                    eval(['man.' man2sFields{iCnt} '.' sub1Fields{s1Cnt} ' = man2save.' man2sFields{iCnt}  '.' sub1Fields{s1Cnt} ';'])
                                end
                            end
                        end
                    else                                                % single entry field
                        eval(['man.' man2sFields{iCnt} ' = man2save.' man2sFields{iCnt} ';'])
                    end
                end
            end
            clear man2save man2sFields
        end
    else
        fprintf(loggingfile,'%s ->\nNo parameter file found. Default settings are used.\n',FCTNAME)        
    end
    clear fmStruct
end


%--------------------------------------------------------------------------
%---     I N I T    F L A G S                                           ---
%--------------------------------------------------------------------------
%--- system init and path updates ---
if ispc
    flag.OS = 0;
elseif ismac
    flag.OS = 2;
else
    flag.OS = 1;
end

%--- manual location ---




%--- string update: OS handling ---

%--- basic init ---
proc.spec1.sf            = 123.2;            % (random) default: 3T
proc.spec1.sw_h          = 4000;             % (random) default: 4 kHz

proc.spec2.sf            = 123.2;            % (random) default: 3T
proc.spec2.sw_h          = 4000;             % (random) default: 4 kHz


%--- buffer change of flag definition ---
if flag.dataKloseMode==0
    flag.dataKloseMode = 1;
end

%--- buffer change of flag definition ---
if flag.procDataFormat==0
    flag.procDataFormat = 1;
end

%--- buffer change of flag definition ---
if flag.procData==0
    flag.procData = 1;
end

%--- update data format ---
SP2_Data_ExpTypePars2Display;   % assignment of data.expTypeDisplay (number) based on flag.dataEditNo and flag.dataExpType

%--- assure backwards compatibility of reference defintion for alignment ---
if length(data.phAlignRefFid)==1
    data.phAlignRefFid = [data.phAlignRefFid data.phAlignRefFid];
end
if length(data.frAlignRefFid)==1
    data.frAlignRefFid = [data.frAlignRefFid data.frAlignRefFid];
end

%--- assure backwards compatibility ---
if data.protDateNum<datenum('03-Oct-2016 21:28:34')
    if flag.dataManu==0         % Bruker
        flag.dataManu = 2;
    end
end

%--- assure backwards compatibility ---
lcm.dataFormatCell = lcmDataFormatCell;             % inclusion of JMRUI format, 12/2016

%--- init general window properties ---
pars.fgColor         = [1 1 1];                     % foreground color (e.g. for text windows)
pars.bgColor         = [0.85 0.85 0.85];            % background color
pars.fgTextColor     = [0 0 0];                     % foreground text color
pars.bgTextColor     = [0.60 0.60 0.60];            % background text color
if flag.OS==1                                       % Linux
    pars.fontSize      = 8;                         % general text font size
    pars.displFontSize = 6.5;                       % display font size (e.g. on 'data' window)
elseif flag.OS==2                                   % Mac
    pars.fontSize      = 10;                        % general text font size
    pars.displFontSize = 10.5;                      % display font size (e.g. on 'data' window)
else                                                % PC
    pars.fontSize      = 8;                         % general text font size
    pars.displFontSize = 8;                         % display font size (e.g. on 'data' window)
end

%--- processing page ---
flag.procProcInit = 0;              % status flag: non-WS analysis done at least once?
flag.mrsiProcInit = 0;              % status flag: non-WS analysis done at least once?

%--- Monte-Carlo simulation ---
flag.lcmMCarloRunning = 0;          % default: not running at startup
flag.lcmMCarloData    = 1;          % default: synthesized LCM analysis

SP2_Logger.log("%s\tdata.defaultDir %s",mfilename,data.defaultDir);

%--- check directory access of all paths ---
if ~isfield(flag,'compile4publ')
    flag.compile4publ = 1;
end 
if ~SP2_CheckDirAccessR(data.defaultDir)
    SP2_Logger.log('The general directory <%s>\nis not accessible. Please update.\n\n',data.defaultDir);
end

SP2_Logger.log("%s\tdata.defaultDir %s",mfilename,data.defaultDir);

if ~SP2_CheckDirAccessR(data.protDir)
    SP2_Logger.log('The protocol directory <%s>\nis not accessible. Please update.\n\n',data.protDir);
end
if ~SP2_CheckDirAccessR(data.spec1.fidDir)
    SP2_Logger.log('The data directory 1 <%s>\nis not accessible. Please update.\n\n',data.spec1.fidDir);
end
if ~SP2_CheckDirAccessR(data.spec2.fidDir)
    SP2_Logger.log('The data directory 2 <%s>\nis not accessible. Please update.\n\n',data.spec2.fidDir);
end
if ~SP2_CheckDirAccessR(mm.sim.fidDir)
    SP2_Logger.log('The simulation directory <%s>\nis not accessible. Please update.\n\n',mm.sim.fidDir);
end
if ~flag.compile4publ
    if ~SP2_CheckDirAccessR(mm.mmStructDir)
        SP2_Logger.log('The directory <%s>\nis not accessible. Please update.\n\n',mm.mmStructDir);
    end
end
if ~SP2_CheckDirAccessR(proc.spec1.dataDir)
    SP2_Logger.log('The processing data directory 1\n<%s>\nis not accessible. Please update.\n\n',proc.spec1.dataDir);
end
if ~SP2_CheckDirAccessR(proc.spec2.dataDir)
    SP2_Logger.log('The processing data directory 2\n<%s>\nis not accessible. Please update.\n\n',proc.spec2.dataDir);
end
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    SP2_Logger.log('The processing export directory\n<%s>\nis not accessible. Please update.\n\n',proc.expt.dataDir);
end
if ~SP2_CheckDirAccessR(marss.spinSys.libDir)
    SP2_Logger.log('The directory containing the spin system library file\n<%s>\nis not accessible. Please update.\n\n',marss.spinSys.libDir);
end
if ~SP2_CheckDirAccessR(marss.basis.fileDir)
    SP2_Logger.log('The directory of simulated basis file\n<%s>\nis not accessible. Please update.\n\n',marss.basis.fileDir);
end
if ~flag.compile4publ
    if ~SP2_CheckDirAccessR(mrsi.spec1.dataDir)
        SP2_Logger.log('The MRSI data directory 1\n<%s>\nis not accessible. Please update.\n\n',mrsi.spec1.dataDir);
    end
    if ~SP2_CheckDirAccessR(mrsi.spec2.dataDir)
        SP2_Logger.log('The MRSI data directory 2\n<%s>\nis not accessible. Please update.\n\n',mrsi.spec2.dataDir);
    end
    if ~SP2_CheckDirAccessR(mrsi.ref.dataDir)
        SP2_Logger.log('The MRSI reference directory\n<%s>\nis not accessible. Please update.\n\n',mrsi.ref.dataDir);
    end
    if ~SP2_CheckDirAccessR(mrsi.expt.dataDir)
        SP2_Logger.log('The MRSI export directory\n<%s>\nis not accessible. Please update.\n\n',mrsi.expt.dataDir);
    end
end
if ~SP2_CheckDirAccessR(lcm.dataDir)
    SP2_Logger.log('The LCM data directory\n<%s>\nis not accessible. Please update.\n\n',lcm.dataDir);
end
if ~SP2_CheckDirAccessR(lcm.basisDir)
    SP2_Logger.log('The LCM basis directory\n<%s>\nis not accessible. Please update.\n\n',lcm.basisDir);
end
if ~SP2_CheckDirAccessR(lcm.batch.protDir)
    SP2_Logger.log('The LCM batch protocol directory\n<%s>\nis not accessible. Please update.\n\n',lcm.batch.protDir);
end
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    SP2_Logger.log('The LCM export directory\n<%s>\nis not accessible. Please update.\n\n',lcm.expt.dataDir);
end
if ~SP2_CheckDirAccessR(syn.fidDir)
    SP2_Logger.log('The simulation directory\n<%s>\nis not accessible. Please update.\n\n',syn.fidDir);
end
if ~flag.compile4publ
    if ~SP2_CheckDirAccessR(tools.anonFileDir)
        SP2_Logger.log('The tools file directory\n<%s>\nis not accessible. Please update.\n\n',tools.anonFileDir);
    end
    if ~SP2_CheckDirAccessR(tools.anonDir)
        SP2_Logger.log('The tools general directory\n<%s>\nis not accessible. Please update.\n\n',tools.anonDir);
    end
end

%--- update success flag ---
f_succ = 1;

end

function manPath = manualFilePath(manPath)
    if flag.OS==1                   % Linux
        if ~SP2_CheckFileExistenceR(manPath,0)             % check default/previous path
            if SP2_CheckFileExistenceR([pars.specPath 'SP2_Manual/INSPECTOR_Manual.pdf'],0)
                manDir  = [pars.specPath 'SP2_Manual/'];   % default directory
                manName = 'INSPECTOR_Manual.pdf';          % generic
                manPath = [manDir manName];
            else
                manDir  = pars.specPath;                   % SPX directory
                manName = 'INSPECTOR_Manual.pdf';          % generic
                manPath = [manDir manName];
            end
        end
    elseif flag.OS==2               % Mac
        if ~SP2_CheckFileExistenceR(manPath,0)             % check default/previous path
            if SP2_CheckFileExistenceR([pars.specPath 'SP2_Manual/INSPECTOR_Manual.pdf'],0)
                manDir  = [pars.specPath 'SP2_Manual/'];   % default directory
                manName = 'INSPECTOR_Manual.pdf';          % generic
                manPath = [manDir manName];
            else
                manDir  = pars.specPath;                   % SPX directory
                manName = 'INSPECTOR_Manual.pdf';          % generic
                manPath = [manDir manName];
            end
        end
    else                            % PC
        if ~SP2_CheckFileExistenceR(manPath,0)             % check default/previous path
            mcrInd = strfind(pars.specPath,'\INSPECTOR_mcr');   % specPath is inside the MCR directory structure
            if any(mcrInd)      % compiled exe
                parsSpecExeDir = pars.specPath(1:mcrInd);
            else                % Matlab code
                parsSpecExeDir = pars.specPath;
            end
            if SP2_CheckFileExistenceR([pars.specPath 'SP2_Manual\INSPECTOR_Manual.pdf'],0)
                manDir  = [pars.specPath 'SP2_Manual\'];   % default directory
            elseif SP2_CheckFileExistenceR([parsSpecExeDir 'INSPECTOR_Manual.pdf'],0)
                manDir  = parsSpecExeDir;                  % SPX directory
            else
                manDir  = pars.specPath;                   % SPX directory
            end
            manName = 'INSPECTOR_Manual.pdf';          % generic
            manPath = [manDir manName];
        end
    end
    if SP2_CheckFileExistenceR(manPath)
        SP2_Logger.log('INSPECTOR manual located:\n%s\n',manPath);
    elseif flag.verbose        
        SP2_Logger.log('WARNING: INSPECTOR manual could NOT be located.\n');
    end

end


