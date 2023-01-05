%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_QualityReplaceApply
%%
%%  Exclude assigned spectra by replacing them with other, undistorted ones.
%%  Note that this substitution is applied to both the original Rx-specific
%%  data and the Rx-combinations displayed here.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_QualityReplaceApply';


%--- init success flag ---
f_done = 0;

%--- separate processing stream based on data dimension ---
if ~isfield(data.spec1,'fidArrRxComb')
    if ~SP2_Data_QualityCalcFidArrRxComb
        return
    end
end
if ~isfield(data.spec1,'fidArrSerial')
    if ~SP2_Data_QualityCalcFidArrSerial
        return
    end
end

%--- consistency checks ---
if data.quality.excludeN~=data.quality.replaceN
    fprintf('%s ->\nInconsistent number of exclusion/replacement FIDs detected (%.0f~=%.0f).\n',...
            FCTNAME,data.quality.excludeN,data.quality.replaceN)
    return
end

%--- FID replacement ---
% note that FID exchange is also possible
dataSpec1FidArr       = data.spec1.fidArr;
dataSpec1FidArrRxComb = data.spec1.fidArrRxComb;
dataSpec1FidArrSerial = data.spec1.fidArrSerial;
for repCnt = 1:data.quality.replaceN
    seriesCntExcl = ceil(data.quality.exclude(repCnt)/data.spec1.nr);
    nrCntExcl     = mod(data.quality.exclude(repCnt)-1,data.spec1.nr)+1;
    seriesCntRepl = ceil(data.quality.replace(repCnt)/data.spec1.nr);
    nrCntRepl     = mod(data.quality.replace(repCnt)-1,data.spec1.nr)+1;
%     data.spec1.fidArr(seriesCntRepl,:,:,nrCntRepl)     = dataSpec1FidArr(seriesCntExcl,:,:,nrCntExcl);
    data.spec1.fidArrRxComb(seriesCntRepl,:,nrCntRepl) = dataSpec1FidArrRxComb(seriesCntRepl,:,nrCntRepl);
    data.spec1.fidArrSerial(:,data.quality.exclude(repCnt)) = dataSpec1FidArrSerial(:,data.quality.replace(repCnt));
end

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);

%--- info printout ---
fprintf('Replacement of FID(s) <%s> with <%s> completed.\n',data.quality.excludeStr,data.quality.replaceStr);


%--- update success flag ---
f_done = 1;
