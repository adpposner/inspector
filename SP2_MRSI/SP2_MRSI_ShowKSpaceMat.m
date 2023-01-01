%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ShowKSpaceMat
%%
%% Plot MRSI k-space (of 1st FID points).
%%
%% 04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ShowKSpaceMat';

%--- check data existence ---
if ~isfield(mrsi.spec1,'fidksp')
    fprintf('%s -> FID k-space matrix not found. Load data first.\n',FCTNAME)
    return
end

%--- init display matrices ---
matMagn  = zeros(mrsi.spec1.nEncR+1,mrsi.spec1.nEncP+1);
matReal  = zeros(mrsi.spec1.nEncR+1,mrsi.spec1.nEncP+1);
matImag  = zeros(mrsi.spec1.nEncR+1,mrsi.spec1.nEncP+1);

%--- data assignment ---
mat1stPt = squeeze(mrsi.spec1.fidksp(1,:,:));
matMagn(1:mrsi.spec1.nEncR,1:mrsi.spec1.nEncP) = flipud(abs(mat1stPt));
matReal(1:mrsi.spec1.nEncR,1:mrsi.spec1.nEncP) = flipud(real(mat1stPt));
matImag(1:mrsi.spec1.nEncR,1:mrsi.spec1.nEncP) = flipud(imag(mat1stPt));
absMat = abs(mat1stPt);

%--- k-space analysis ---
[RowInd,ColInd] = SP2_MaxMatInd(abs(mat1stPt));

%--- k-space visualization ---
figure
nameStr = ' k-space representation';
set(gcf,'NumberTitle','off','Name',nameStr);

subplot(2,2,1)
set(gcf,'Position',[200 15 560 560]);
pcolor(matMagn)
title('magnitude')
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);
fprintf('k-space maximum at (%i,%i)\n',RowInd,ColInd);

subplot(2,2,2)
set(gcf,'Position',[200 15 560 560]);
surf(matMagn)
title('magnitude')
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);
fprintf('k-space maximum at (%i,%i)\n',RowInd,ColInd);

subplot(2,2,3)
set(gcf,'Position',[180 35 560 560]);
pcolor(matReal)
title('real part')
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);

subplot(2,2,4)
set(gcf,'Position',[160 55 560 560]);
pcolor(matImag)
title('imaginary part')
colormap(gray(256))
set(gca,'XTick',[]);
set(gca,'YTick',[]);




% if mod(mrsi.spec1.nEncR,2)
%     plotRow = absMat(:,(mrsi.spec1.nEncR+1)/2);
% else
%     plotRow = (absMat(:,mrsi.spec1.nEncR/2)+absMat(:,mrsi.spec1.nEncR/2+1))/2;
% end
% if mod(mrsi.spec1.nEncP,2)
%     plotCol = absMat((mrsi.spec1.nEncP+1)/2,:);
% else
%     plotCol = (absMat(mrsi.spec1.nEncP/2,:)+absMat(mrsi.spec1.nEncP/2+1,:))/2;
% end
% 
% CentRowX = [(mrsi.spec1.nEncR+1)/2 (mrsi.spec1.nEncR+1)/2];
% CentColX = [(mrsi.spec1.nEncP+1)/2 (mrsi.spec1.nEncP+1)/2];
% CentRowY = [min(plotRow) max(plotRow)];
% CentColY = [min(plotCol) max(plotCol)];

% h4=figure;
% nameStrLines = 'maximum k-space lines';
% set(h4,'NumberTitle','off','Name',nameStrLines);
% subplot(2,1,1)
% plot(plotRow), grid on;
% title('central row')
% hold on
% plot(CentRowX,CentRowY,'Color','r');
% hold off
% subplot(2,1,2)
% plot(plotCol), grid on;
% title('central column')
% hold on
% plot(CentColX,CentColY,'Color','r');
% hold off

%--- create printout of first acquisition data vector ---
% figure
% subplot(3,1,1)
% plot(real(datRaw))
% title('real part of 1st data vector')
% subplot(3,1,2)
% plot(imag(datRaw))
% title('imaginary part of 1st data vector')
% subplot(3,1,3)
% plot(abs(datRaw))
% title('magnitude of 1st data vector')
