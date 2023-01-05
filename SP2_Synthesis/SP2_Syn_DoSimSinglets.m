%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Syn_DoSimSinglets( varargin )
%%
%%  Simulate a set of singlets
%%  1) between 0..4.5 ppm (default)
%%  2) at user-assigned frequency positions.
%%     Example: SP2_Syn_DoSimSinglets({[0 100],[1 100]}) for 2 singlets at 0 and 1 ppm
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_DoSimSinglets';

%--- metabolite definition ---
% metabCharCell  = {[0.0, 1e2], ...          % metabolite cell: singlet name, frequency [ppm], T1, T2, concentration
%               [1.0, 1e2], ...
%               [2.0, 1e2], ...
%               [3.0, 1e2], ...
%               [4.0, 1e2]};

metabCharCell  = {[0.0 1.0*1e1 20], ...        % metabolite cell: singlet name, frequency [ppm], T1, T2, concentration
                  [1.0 1.5*1e1 20], ...
                  [2.0 2.0*1e1 20], ...
                  [3.0 2.5*1e1 20]};

% metabCharCell  = {[0.0, 10]};

%--- parameter settings ---
% syn.nspecCOrig = syn.nspecC;
syn.sw         = syn.sw_h/syn.sf;
syn.dwell      = 1/syn.sw_h;

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- argument handling ---
if nargin==1
    if iscell( varargin{1} )                    % direct assignment
        metabCharCell = varargin{1};
    else                                        % window assignment
        metabCharCell = syn.metabCharCell;
    end
elseif nargin~=0
    fprintf('%s ->\nSorry, only 0 or 1 input arguments are supported!',FCTNAME);
    return
end

%--- metabolite handling ---
metabN = length(metabCharCell);             % number of metabolite spin systems (incl. individual moeities)

%--- info printout ---
% fprintf('\n%s started:\n',FCTNAME);

%--- combine all FIDs from the same metabolite and save to file ---
synN    = length(metabCharCell);                                            % # of peaks
synFreq = zeros(1,synN);                                                % peak frequencies [Hz]
for sCnt = 1:synN
    synFreq(sCnt) = syn.sf*(metabCharCell{sCnt}(1) - syn.ppmCalib);         % offset frequency [Hz]
end

%--- noise-free FID creation ---
syn.fidOrig = complex(zeros(syn.nspecCBasic,1));                             % init resultant brain FID
tVec        = (0:(syn.nspecCBasic-1))' * syn.dwell;
for sCnt = 1:synN         % multiple signals of single spectrum
    lbWeight    = exp(-metabCharCell{sCnt}(3)*syn.dwell*(0:syn.nspecCBasic-1)*pi)';
    syn.fidOrig = syn.fidOrig + metabCharCell{sCnt}(2) * exp(2*pi*1i*synFreq(sCnt)*tVec) .* lbWeight;
end

%--- offset correction ---
syn.fidOrig(1) = syn.fidOrig(1)/2;

%--- data assignment ---
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
flag.synSource = 2;

%--- figure update ---
if ~SP2_Syn_FigureUpdate
    fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
fprintf('Singlet spectrum created\n');

%--- update success flag ---
f_succ = 1;




