%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Syn_DoSimMetabBrain
%%
%%  Simulate saturation-recovery data set of all STEAM metabolite spectra.
%%  for both 1) individual moeities and 2) the sum of all moeities. 
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_DoSimMetabBrain';

%--- definition of brain metabolites ---
metabCell  = {{'Acetate',       1.5,    0.100,  0.3}, ...                                   % metabolite cell: name, T1, T2, concentration
              {'Alanine',       1.5,    0.100,  1.0}, ...
              {'Ascorbate',     1.5,    0.100,  1.0}, ...
              {'Aspartate',     1.5,    0.100,  1.0}, ...
              {'Choline',       1.4,    0.100,  0.4}, ...
              {'Creatine',      1.65,   0.100,  5.5}, ...
              {'GABA',          1.5,    0.100,  0.5}, ...
              {'Glucose',       1.35,   0.100,  1.5}, ...
              {'Glutamate',     1.35,   0.100,  7.0}, ...
              {'Glutamine',     1.5,    0.100,  2.0}, ...
              {'Glycine',       1.5,    0.100,  4.5}, ...
              {'GPC',           1.4,    0.100,  0.3}, ...
              {'GSH',           1.5,    0.100,  2.0}, ...
              {'Lactate',       1.5,    0.100,  0.4}, ...
              {'Mac',           1.5,    0.100,  5.0}, ...
              {'MyoInositol',   1.1,    0.100,  6.0}, ...
              {'NAA',           1.6,    0.100,  9.5}, ...
              {'NAAG',          1.6,    0.100,  1.5}, ...
              {'PCr',           1.65,   0.100,  3.0}, ...
              {'PCho',          1.4,    0.100,  0.4}, ...
              {'PE',            1.5,    0.100,  1.5}, ...
              {'ScylloInositol',1.5,    0.100,  0.3}, ...
              {'Taurine',       2.2,    0.100,  2.0}};
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

%--- check directory access ---
if ~SP2_CheckDirAccessR(syn.fidDir)
    return
end

%--- metabolite handling ---
metabN = length(metabCell);             % number of metabolite spin systems (incl. individual moeities)

% %--- check file existence ---
% if ~SP2_CheckFileExistenceR(syn.fidPath)
%     fprintf('\n%s ->\n%s\nMetabolite file has not been found. Program aborted.\n',FCTNAME,syn.fidPath);
% end

%--- load 1st parameter file ---
if strcmp(syn.fidPath(end-3:end),'.par')
    if ~SP2_Syn_LoadParFile([syn.fidDir metabCell{1}{1} '.par'])
        return
    end
    f_format = 1;
elseif strcmp(syn.fidPath(end-3:end),'.mat')
    [fid,nspecC,sf,sw_h,f_done] = SP2_Syn_LoadMatFile([syn.fidDir metabCell{1}{1} '.mat']);
    if ~f_done
        return
    end
    f_format = 2;
elseif strcmp(syn.fidPath(end-3:end),'.raw')
    [fid,f_done] = SP2_Syn_LoadRawFile([syn.fidDir metabCell{1}{1} '.raw']);
    if ~f_done
        return
    end
    f_format = 3;
elseif strcmp(syn.fidPath(end-3:end),'.RAW')
    [fid,f_done] = SP2_Syn_LoadRawFile([syn.fidDir metabCell{1}{1} '.RAW']);
    if ~f_done
        return
    end
    f_format = 4;
else
    fprintf('\n%s ->\nInvalid file format detected. Metabolite file assignment failed.\n',FCTNAME);
    return
end
    
%--- combine all FIDs from the same metabolite and save to file ---
for mCnt = 1:metabN
    %--- check file access ---
    switch f_format
        case 1  % .par
            f_found = SP2_CheckFileExistenceR([syn.fidDir metabCell{mCnt}{1} '.par']);
        case 2  % .mat
            f_found = SP2_CheckFileExistenceR([syn.fidDir metabCell{mCnt}{1} '.mat']);
        case 3  % .raw
            f_found = SP2_CheckFileExistenceR([syn.fidDir metabCell{mCnt}{1} '.raw']);
        case 4  % .RAW
            f_found = SP2_CheckFileExistenceR([syn.fidDir metabCell{mCnt}{1} '.RAW']);
    end
       
    %--- read metabolite and add to brain spectrum ---
    if f_found
        
        %--- load FID from file ---
        fprintf('\n');
        if strcmp(syn.fidPath(end-3:end),'.par')
            [fid,f_done] = SP2_RagLoadFid([syn.fidDir metabCell{mCnt}{1}]);              % original FID
%             [syn.fidOrig,f_done] = SP2_RagLoadFid(syn.fidPath(end-3:end),'.par');              % original FID
            if ~f_done
                return
            end
        elseif strcmp(syn.fidPath(end-3:end),'.mat')
            [fid,nspecC,sf,sw_h,f_done] = SP2_Syn_LoadMatFile([syn.fidDir metabCell{mCnt}{1} '.mat']);
            if ~f_done
                return
            end
        elseif strcmp(syn.fidPath(end-3:end),'.raw')
            [fid,f_done] = SP2_Syn_LoadRawFile([syn.fidDir metabCell{mCnt}{1} '.raw']);
            if ~f_done
                return
            end
        elseif strcmp(syn.fidPath(end-3:end),'.RAW')
            [fid,f_done] = SP2_Syn_LoadRawFile([syn.fidDir metabCell{mCnt}{1} '.RAW']);
            if ~f_done
                return
            end
        else
            fprintf('\n%s ->\nInvalid file format detected. Metabolite file assignment failed.\n',FCTNAME);
            return
        end

        syn.brain.fid   = fid;                      % FID assignment
        syn.brain.t1    = metabCell{mCnt}{2};
        syn.brain.t2    = metabCell{mCnt}{3};
        syn.brain.conc  = metabCell{mCnt}{4};
        syn.brain.metab = metabCell{mCnt};

        if mCnt==1
            if syn.nspecCBasic<=length(syn.brain.fid)
                tVec        = (0:(syn.nspecCBasic-1))'*syn.dwell;                   % time vector of FID
                syn.fidOrig = complex(zeros(syn.nspecCBasic,1));                    % init resultant brain FID
            else
                fprintf('Number of basic simulation points is larger than available metabolite FID length (%.0f pts).\nProgram aborted.\n',...
                        length(syn.brain.fid))
                return
            end
        end    

        %--- convert to resultant FID that includes all aspects ---
    %     syn.brain.fid(:,srCnt) = syn.brain.conc*syn.brain.fid .* ...        % concentration * base FID
    %                              exp(-tVec/syn.brain.t2) * ...              % * T2 effect
    %                              (1-exp(-tVec/syn.brain.t1));               % * T1 effect
    %    syn.brain.fid(1:syn.nspecCBasic,1) = syn.brain.conc*syn.brain.fid(1:syn.nspecCBasic,1) .* ...        % concentration * base FID
    %                                         exp(-tVec/syn.brain.t2);                   % * T2 effect
        syn.brain.fid(1:syn.nspecCBasic,1) = syn.brain.conc*syn.brain.fid(1:syn.nspecCBasic,1);                   % * T2 effect

        %--- add to brain FID ---
        syn.fidOrig = syn.fidOrig + syn.brain.fid(1:syn.nspecCBasic,1);

        %--- info printout ---
        fprintf('%s added (T1 %.3f s, T2 %.3f s, %.2f mMol/l)\n',metabCell{mCnt}{1},...
                metabCell{mCnt}{2},metabCell{mCnt}{3},metabCell{mCnt}{4})

    else
        fprintf('\nMetabolite <%s> not found.\n\n',metabCell{mCnt}{1});
    end
end
syn.fid        = syn.fidOrig;
syn.nspecC     = syn.nspecCBasic;
syn.nspecCOrig = syn.nspecC;

%--- noise handling ---
if flag.synNoise
    % syn.fidOrig = syn.fidOrig + syn.noiseAmp * randn(1,syn.nspecC)'.*exp((1i*randn(1,syn.nspecC)'));   % noise
    %--- create noise ---
    if ~isfield(syn,'noiseNspecC')
        syn.noiseNspecC = 1;                % fake assignment
    end
    if ~flag.synNoiseKeep || ~isfield(syn,'noise') || syn.nspecC~=syn.noiseNspecC       
        syn.noise = (syn.noiseAmp*sqrt(syn.sw_h)) * randn(1,syn.nspecC)' + ...
                    1i*(syn.noiseAmp*sqrt(syn.sw_h)) * randn(1,syn.nspecC)';
        syn.noiseNspecC = syn.nspecC;
    end
    
    %--- add noise to FID ---
    syn.fid = syn.fid + syn.noise;
%     fprintf('Gaussian (white) noise added\n');
end

%--- spectral processing ---
if ~SP2_Syn_ProcData
    return
end

%--- polynomial baseline ----
if flag.synPoly
    %--- x-axis with [ppm]-based scale ---
    % note that this convention makes it independent of the number of spectral points per ppm, i.e. nspecC
    fprintf('Points per ppm: %.0f\n',(syn.nspecC-1)/syn.sw)               % points per ppm
    synPpmVec = (-syn.sw/2:syn.sw/(syn.nspecC-1):syn.sw/2)' + (syn.ppmCalib-syn.polyCenterPpm);
    syn.spec = syn.spec + ...
               syn.polyAmpVec(6) * synPpmVec.^5 + ...
               syn.polyAmpVec(5) * synPpmVec.^4 + ...
               syn.polyAmpVec(4) * synPpmVec.^3 + ...
               syn.polyAmpVec(3) * synPpmVec.^2 + ...
               syn.polyAmpVec(2) * synPpmVec + ...
               syn.polyAmpVec(1);
end

%--- FID creation ---
syn.fid = ifft(ifftshift(syn.spec,1),[],1);

%--- signal source ---
flag.synSource = 4;

%--- figure update ---
if ~SP2_Syn_FigureUpdate
    fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- info printout ---
fprintf('Brain-like metabolite spectrum synthesized\n');

%--- info string ---
if flag.verbose
    fprintf('larmor frequency: %.1f MHz\n',syn.sf);
    fprintf('sweep width:      %.1f Hz\n',syn.sw_h);
    fprintf('complex points:   %.0f\n',syn.nspecC);
    fprintf('ppm calibration:  %.3f ppm (global)\n\n',syn.ppmCalib);
end
    
%--- update success flag ---
f_succ = 1;




