%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralBaselineCorrPolySingle(datStruct)
%%
%%  Spectral baseline correction of single spectrum based on polynomial fit.
%%
%%  02-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi


FCTNAME = 'SP2_MRSI_SpectralBaselineCorrPolySingle';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(datStruct,'spec')
    fprintf('%s -> No single spectrum found. Load data first.\n',FCTNAME)
    return
end

%--- extraction of baseline parts to be fitted ---
corrBinVec   = zeros(1,datStruct.nspecCimg);        % init global index vector for ppm ranges to be used
minPpmIndVec = zeros(1,mrsi.basePolyPpmN);           % init minimum ppm index vector
maxPpmIndVec = zeros(1,mrsi.basePolyPpmN);           % init maximum ppm index vector
for winCnt = 1:mrsi.basePolyPpmN
    [minPpmIndVec(winCnt),maxPpmIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(mrsi.basePolyPpmMin(winCnt),mrsi.basePolyPpmMax(winCnt),...
                                 mrsi.ppmCalib,datStruct.sw,datStruct.spec);
    corrBinVec(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)) = 1;
end
corrIndVec = find(corrBinVec);                                                          % index vector

%--- polynomial fit ---
realCoeff   = polyfit(corrIndVec,real(datStruct.spec(corrIndVec))',mrsi.basePolyOrder);   % polynomial fit of real part
imagCoeff   = polyfit(corrIndVec,imag(datStruct.spec(corrIndVec))',mrsi.basePolyOrder);   % polynomial fit of imaginary part
specFitTot  = complex(polyval(realCoeff,1:datStruct.nspecCimg)',polyval(imagCoeff,1:datStruct.nspecCimg)');
datStruct.spec = datStruct.spec - specFitTot;                   % global baseline correction

%--- info print out ---
fprintf('Spectral baseline correction applied (%s).\n',datStruct.name)

%--- update success flag ---
f_succ = 1;
