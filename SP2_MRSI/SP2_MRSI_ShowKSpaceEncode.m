%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowKSpaceEncode
%% 
%%  Visualize the applied k-space encoding scheme.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_ShowKSpaceEncode';


%--- display options ---
impline = 3;    % images per line

%--- check data existence ---
if ~isfield(mrsi.spec1,'fidkspOrig')
    fprintf('No data found. Load first.\n');
    return
end

%--- shift indices to positive center ---
encVecR = mrsi.spec1.encTableR + round(mrsi.spec1.mat(1)/2);
encVecP = mrsi.spec1.encTableP + round(mrsi.spec1.mat(2)/2);

%--- convert to matrix scheme ---
encMat = zeros(mrsi.spec1.mat(1),mrsi.spec1.mat(2));
for encCnt = 1:mrsi.spec1.nEnc
    encMat(encVecR(encCnt),encVecP(encCnt)) = encMat(encVecR(encCnt),encVecP(encCnt)) + 1;
end

%--- plot each niveau of the hamming weighting into separate plot ---
mrsiAver = max(max(encMat));                    % maximum number of k-space repetitions
NoResidD = mod(mrsiAver,impline);               % impline = images per line
NoRowsD  = (mrsiAver-NoResidD)/impline+1;
fh = figure;
nameStr = sprintf(' Niveau Representation of k-Space Acquisition Scheme');
set(fh,'NumberTitle','off','Name',nameStr,'Color',[1 1 1]);
for PlotCnt = 1:mrsiAver
    subplot(NoRowsD,impline,PlotCnt)
    pAcqMatrix = zeros(mrsi.spec1.mat(1)+1,mrsi.spec1.mat(2)+1);
    pAcqMatrix(1:mrsi.spec1.mat(1),1:mrsi.spec1.mat(2)) = (encMat>=ones(mrsi.spec1.mat(1))*PlotCnt);
    pcolor(pAcqMatrix)
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    xlabstr = sprintf('NA=%.0f (%.0f)',PlotCnt,length(find(encMat>=PlotCnt)));
    xlabel(xlabstr);
    set(gca,'DataAspectRatioMode','Manual')
end
colormap(gray(2))
% 
% %--- info printout ---
% fprintf('Acquisition time (TR %.1f sec): %.0f sec / %.1f min\n',mrsiTR,encCntP*mrsiTR,encCntP*mrsiTR/60);
% fprintf('%s successfully completed.\n',FCTNAME);
% 

