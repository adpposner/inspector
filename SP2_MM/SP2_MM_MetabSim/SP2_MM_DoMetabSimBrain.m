%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoMetabSimBrain
%%
%%  Simulate saturation-recovery data set of all STEAM metabolite spectra.
%%  for both 1) individual moeities and 2) the sum of all moeities. 
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_DoMetabSimBrain';

parDir     = 'C:\Users\juchem\Analysis\LCModel\MetaboliteLibraryBrainInVivo_NMRWizard\';    % parameter directory
resultDir  = 'C:\Users\juchem\analysis\MRS_MacroMolecule\STEAM_Combined\';                  % result directory, 1 FID per metabolite
metabCell  = {{'Acetate',       1.5,    0.025,  0.3}, ...                                   % metabolite cell: name, T1, T2, concentration
              {'Alanine',       1.5,    0.025,  1.0}, ...
              {'Ascorbate',     1.5,    0.025,  1.0}, ...
              {'Aspartate',     1.5,    0.025,  1.0}, ...
              {'Choline',       1.4,    0.025,  0.4}, ...
              {'Creatine',      1.65,   0.025,  6.0}, ...
              {'GABA',          1.5,    0.025,  1.0}, ...
              {'Glucose',       1.35,   0.025,  1.5}, ...
              {'Glutamate',     1.35,   0.025,  8.0}, ...
              {'Glutamine',     1.5,    0.025,  3.0}, ...
              {'Glycine',       1.5,    0.025,  4.5}, ...
              {'GPC',           1.4,    0.025,  0.3}, ...
              {'GSH',           1.5,    0.025,  2.3}, ...
              {'Lactate',       1.5,    0.025,  0.6}, ...
              {'MyoInositol',   1.1,    0.025,  6.5}, ...
              {'NAA',           1.6,    0.025,  11.0}, ...
              {'NAAG',          1.6,    0.025,  1.5}, ...
              {'PCr',           1.65,   0.025,  3.0}, ...
              {'PCho',          1.4,    0.025,  0.4}, ...
              {'PE',            1.5,    0.025,  1.5}, ...
              {'ScylloInositol',1.5,    0.025,  0.3}, ...
              {'Taurine',       2.2,    0.025,  2.0}};
%               {'MM1',           0.50,   0.025,  1.0}, ...
%               {'MM2',           0.45,   0.030,  1.0}, ...
%               {'MM3',           0.45,   0.030,  1.0}, ...
%               {'MM4',           0.35,   0.020,  1.0}};
% metabCell  = {'NAAG_Glutamate'};

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- parameter assignment ---
mm.sim.fidDir  = resultDir;

%--- assign simulation delays ---
mm.satRecDelays = mm.sim.delayVec;     
mm.satRecN      = mm.sim.delayN;

%--- metabolite handling ---
metabN = length(metabCell);             % number of metabolite spin systems (incl. individual moeities)

%--- consistency checks ---
if ~SP2_CheckDirAccessR(resultDir)
    return
end
    
%--- load 1st parameter file ---
if ~SP2_MM_LoadParFile([resultDir metabCell{1}{1} '.par'])
    return
end

%--- info printout ---
fprintf('\n%s started:\n',FCTNAME);

%--- combine all FIDs from the same metabolite and save to file ---
tVec     = (0:(mm.nspecC-1))'*mm.dwell;                 % time vector of FID
fidMetab = complex(zeros(mm.nspecC,mm.satRecN));        % init sat-rec. data array of single metabolite
fidBrain = complex(zeros(mm.nspecC,mm.satRecN));        % init brain sat-rec. data array
for mCnt = 1:metabN
    %--- load FID from file ---
    mm.sim.fid  = SP2_RagLoadFid([resultDir metabCell{mCnt}{1}]);
    mm.sim.t1   = metabCell{mCnt}{2};
    mm.sim.t2   = metabCell{mCnt}{3};
    mm.sim.conc = metabCell{mCnt}{4};
    
    %--- create metabolite-specific sat-rec. data ---
    for srCnt = 1:mm.satRecN        % individual saturation-recovery experiments
        fidMetab(:,srCnt) = mm.sim.conc*mm.sim.fid .* ...                                 % base FID
                            exp(-tVec/mm.sim.t2) * ...                        % T2
                            (1-exp(-mm.satRecDelays(srCnt)/mm.sim.t1));       % T1
    end
    
    %--- add to brain FID ---
    fidBrain = fidBrain + fidMetab;
    
    %--- info printout ---
    fprintf('%s added (T1 %.3f s, T2 %.3f s, %.2f mMol/l)\n',metabCell{mCnt}{1},...
            metabCell{mCnt}{2},metabCell{mCnt}{3},metabCell{mCnt}{4})
end
mm.fid = fidBrain;

%--- noise handling ---
if flag.mmSimNoise
    for srCnt = 1:mm.satRecN                % individual saturation-recovery experiments
        fidBrain(:,srCnt) = fidBrain(:,srCnt) + randn(1,mm.nspecC)'/5.*exp((1i*randn(1,mm.nspecC))).';   % noise
    end
end

%--- spectrum reconstruction ---
mm.spec = complex(zeros(mm.nspecC,mm.satRecN));
for srCnt = 1:mm.satRecN
    %--- basic reco (no apod/ZF) ---
    % mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt),mm.zf));

    %--- full processing options ---
    if mm.nspecC<mm.cut        % no apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.nspecC-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt).*lbWeight,mm.zf));
    else                                    % apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.cut-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(1:mm.cut,srCnt).*lbWeight,mm.zf));
        if srCnt==1
            fprintf('%s ->\nApodization of FID to %.0f points applied.\n',...
                    FCTNAME,mm.cut)
        end
    end
    mm.spec(:,srCnt) = mm.spec(:,srCnt) .* exp(1i*mm.phaseZero*pi/180)';
end

%--- info printout ---
fprintf('%s completed.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;





end
