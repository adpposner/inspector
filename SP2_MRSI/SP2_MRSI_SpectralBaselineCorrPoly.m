%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralBaselineCorrPolySingle(datStruct)
%%
%%  Spectral baseline correction based on polynomial fit.
%%
%%  02-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi


FCTNAME = 'SP2_MRSI_SpectralBaselineCorrPoly';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(datStruct,'specimg')
    fprintf('%s -> No spectral matrix found. Load data first.\n',FCTNAME)
    return
end

%--- extraction of baseline parts to be fitted ---
corrBinVec   = zeros(1,datStruct.nspecCimg);        % init global index vector for ppm ranges to be used
minPpmIndVec = zeros(1,mrsi.basePolyPpmN);           % init minimum ppm index vector
maxPpmIndVec = zeros(1,mrsi.basePolyPpmN);           % init maximum ppm index vector
for winCnt = 1:mrsi.basePolyPpmN
    [minPpmIndVec(winCnt),maxPpmIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(mrsi.basePolyPpmMin(winCnt),mrsi.basePolyPpmMax(winCnt),...
                                 mrsi.ppmCalib,datStruct.sw,datStruct.specimg(:,1,1));
    corrBinVec(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)) = 1;
end
corrIndVec = find(corrBinVec);                                                          % index vector

%--- polynomial fit ---
for xCnt = 1:datStruct.nEncR
    for yCnt = 1:datStruct.nEncP
        realCoeff   = polyfit(corrIndVec,real(datStruct.specimg(corrIndVec,xCnt,yCnt))',mrsi.basePolyOrder);   % polynomial fit of real part
        imagCoeff   = polyfit(corrIndVec,imag(datStruct.specimg(corrIndVec,xCnt,yCnt))',mrsi.basePolyOrder);   % polynomial fit of imaginary part
        specFitTot  = complex(polyval(realCoeff,1:datStruct.nspecCimg)',polyval(imagCoeff,1:datStruct.nspecCimg)');
        datStruct.specimg(:,xCnt,yCnt) = datStruct.specimg(:,xCnt,yCnt) - specFitTot;                   % global baseline correction
    end
end

%--- info print out ---
fprintf('Spectral baseline correction applied (%s).\n',datStruct.name)

%--- update success flag ---
f_succ = 1;
