%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AutoFrequDetPrep(pars)
%% 
%%  Preparation function for SP2_Data_AutoFrequDet.m
%%  (to increase performance by removing redundancies)
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data

FCTNAME = 'SP2_Data_AutoFrequDetPrep';


%--- determination of frequency shift ---
data.opt.frequVec = -data.frAlignFrequRg:data.frAlignFrequRes:data.frAlignFrequRg;       % test frequency shift
data.opt.nFrequ   = length(data.opt.frequVec);                % number of test frequency shifts
intDiff           = zeros(1,data.opt.nFrequ);                 % integral difference measures
phPerPtVec        = data.opt.frequVec*pars.dwell*pars.nspecC*(pi/180)/(2*pi);       % correction phase per point: vector
phPerPtMat        = repmat(phPerPtVec,[pars.nspecC 1]);                    % correction phase per point: matrix
pointMat          = repmat((0:(pars.nspecC-1))',[1 data.opt.nFrequ]);
data.opt.frequShiftMat = exp(-1i*phPerPtMat .* pointMat);      % time domain frequency shift matrix
