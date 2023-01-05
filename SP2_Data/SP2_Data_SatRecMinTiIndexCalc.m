%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_SatRecMinTiIndexCalc( f_verbose )
%% 
%%  Index handling for minimum TI frequency and phase alignment.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

%--- init success flag ---
f_succ = 0;

%--- update flag displays ---
data.satRec.delays      = cell2mat(data.spec1.inv.ti);
data.satRec.delaysN     = length(data.satRec.delays);
data.satRec.invalidInd  = find(data.satRec.delays<data.satRec.minTI);           % TIs that are too short
data.satRec.invalidN    = length(data.satRec.invalidInd);                       % number of TIs that are too short
data.satRec.validInd    = find(data.satRec.delays>=data.satRec.minTI);          % indices of valid TIs
if isempty(data.satRec.validInd)
    fprintf('%s ->\nAll TIs remain below minimum TI threshold (%.3 sec). Program aborted.\n',FCTNAME,data.satRec.minTI);
end
data.satRec.validMinTI  = min(data.satRec.delays(data.satRec.validInd));        % minimum valid TI above min threshold
data.satRec.validMinInd = find(data.satRec.delays==data.satRec.validMinTI);     % index within overall TI vector
data.satRec.indexMinTI  = 1:data.satRec.delaysN;                                % set up index vector for minimal TI handling
data.satRec.indexMinTI(data.satRec.invalidInd) = data.satRec.validMinInd*ones(1,data.satRec.invalidN);   % replace indices with TI<TImin with index of 1st TI>TImin

%--- info printout ---
if f_verbose
    fprintf('Index handling for minimum TI frequency/phase alignment:\n');
    data.satRec
    fprintf('delays    = %s sec\n',SP2_Vec2PrintStr(data.satRec.delays,3));
    fprintf('acq. time = %.0f sec (%.1f min) per scan\n\n',data.spec1.durSec,data.spec1.durMin);
else
    if isempty(data.satRec.invalidInd)
        fprintf('No TI<TImin found. All corrections use their own TI data as reference\n');
    else
        fprintf('Minimum TI %.3f sec (index %.0f) applied as reference to scans %s\n',...
                data.satRec.minTI,data.satRec.indexMinTI,SP2_Vec2PrintStr(data.satRec.invalidInd,0))
    end
end

%--- update success flag ---
f_succ = 1;