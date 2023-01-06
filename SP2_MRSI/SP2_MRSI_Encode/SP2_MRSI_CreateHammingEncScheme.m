%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_CreateHammingEncScheme
%% 
%%  Export function (temporal) spectral data.
%%,'mrsiList0','mrsiList1'
%%  xxxR: t1, inner loop
%%  xxxP: t2, outer loop
%%
%%  03-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_CreateHammingEncScheme';


%--- MRSI definition ---
mrsiCircOffset   = 0.00;        % radius offset for Hamming weighting calculation via radius condition
mrsiWeightOffset = 0.00;        % amplitude offset of the CSI weighting function to minimize discretization errors
mrsiMatrix       = 23;           % MRSI matrix size
mrsiAver         = 3;           % number of averages defined as center k-space samples 

%--- file handling ---
tabdir = 'C:\Users\juchem\Matlab\matlab_cj\INSPECTOR_v2\SP2_MRSI\SP2_MRSI_TablibTmp\';

%--- display option ---
f_ppt             = 0;              % creates plot for power point presentations
ppt_xyTickSpace   = 2;              % X/YTick spacing for ppt plots: 2 -> [1 3 5 7 ...], 3 -> [1 4 7 10 ...], starting at 1
ppt_zTickSpace    = 2;              % ZTick spacing, always including maximum value mrsiHammNA
ppt_aFontSize     = 20;             % axis label font size
ppt_aLineWidth    = 2;              % axis line width
ppt_tFontSize     = 20;             % title font size
ppt_pLineWidth    = 2;              % plot line width

f_eps             = 0;              % creates plot for power point presentations
eps_xyTickSpace   = 2;              % X/YTick spacing for ppt plots: 2 -> [1 3 5 7 ...], 3 -> [1 4 7 10 ...], starting at 1
eps_zTickSpace    = 2;              % ZTick spacing, always including maximum value mrsiHammNA
eps_aFontSize     = 15;             % axis label font size
eps_aLineWidth    = 1;              % axis line width
eps_tFontSize     = 20;             % title font size
eps_pLineWidth    = 1;              % plot line width
eps_faceColor     = [1 1 1];        % face color of bar and surface plots

%--- additional options ---
f_niveau          = 1;              % plot each particular niveau of the hamming weighting matrix
impline           = 3;              % images per line, number of niveaus per line in niveau plot (f_niveau)
TR                = 2;              % repetition time assumed for experiment duration calc. [s]

%--- deugging option ---
f_debug           = 0;              % plots all kind of additional information

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   P R O G R A M    S T A R T                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CSI LIST CALCULATION ******************************
% gradient scaling, quadratic k-space matrix 					   
% GradMat contains equidistant values from 0 to 2 and is then shifted to the -1/1 range
% to sample the k-space origin, k-space values are shifted 0.5 the sampling grid if a
% list is used (circular, hamming) and the sampling matrix is even
GradMat0Norm = zeros(mrsiMatrix,mrsiMatrix);
GradMat1Norm = zeros(mrsiMatrix,mrsiMatrix);
if mod(mrsiMatrix,2.0)==0                 % shifted case
    for icnt = 1:mrsiMatrix
        for jcnt = 1:mrsiMatrix 
            GradMat0Norm(icnt,jcnt) = (icnt-1)*2/mrsiMatrix -1;
	        GradMat1Norm(icnt,jcnt) = (jcnt-1)*2/mrsiMatrix -1;
        end
    end
    dkshift = 1/mrsiMatrix;               % shift relative to initial matrix */
else			                            % odd mrsiMatrix
    for icnt = 1:mrsiMatrix 
        for jcnt = 1:mrsiMatrix 
            GradMat0Norm(icnt,jcnt) = 2.0*(icnt-1)/(mrsiMatrix-1) - 1;
	        GradMat1Norm(icnt,jcnt) = 2.0*(jcnt-1)/(mrsiMatrix-1) - 1;
        end
    end
     dkshift = 0;	                        % no weighting function shift
end

% determination of residual k-space points for circular sampling */
% radius + mrsiCircOffset (to include more ambient points), radius=1 */
if mod(mrsiMatrix,2.0)==0
    YesNoValue = (1-1/(mrsiMatrix-1)) * (1 + mrsiCircOffset); 
else
	YesNoValue = 1 + mrsiCircOffset;    
end	

% calculate hamming filter function */
for icnt = 1:mrsiMatrix
    hammVec(icnt) = 0.54 - 0.46*cos(2*pi*(icnt-1)/(mrsiMatrix-1));
end
AcqMatrixOrig = zeros(mrsiMatrix,mrsiMatrix);
for icnt = 1:mrsiMatrix
    for jcnt = 1:mrsiMatrix
	    AcqMatrixOrig(icnt,jcnt) = hammVec(icnt)*hammVec(jcnt);	    % like HammingFilterMult.m */ 
        % restrict to circular scheme */   	
        
	    % halfdk is used to shift the pattern, when k-space is shifted for odd dimensional matrices */
	    if sqrt(power(GradMat0Norm(icnt,jcnt)+dkshift,2)+power(GradMat1Norm(icnt,jcnt)+dkshift,2)) > YesNoValue
	        AcqMatrixOrig(icnt,jcnt) = 0;
        end
    end
end

%--- scale to mrsiAver and ensure at least one acquistion per circular k-space area ---
AcqMatrixOrig = mrsiAver * AcqMatrixOrig;

%--- round acquisition matrix ---
AcqMatrixDiscr = AcqMatrixOrig;
AcqMatrixDiscr(find(AcqMatrixOrig>0 & AcqMatrixOrig<0.5)) = 1;      % scale up peripheral subthreshold values
AcqMatrixDiscr = round(AcqMatrixDiscr);                              % discretization


%--- plot Hamming function for particular dimension ---
if f_debug
	fig2 = figure;
    set(fig2,'NumberTitle','off','Name',sprintf('%s: ',FCTNAME))
	subplot(2,1,1)
	plot(hammVec)
	[minX maxX minY maxY] = SP2_IdealAxisValues(hammVec);
	axis([minX maxX 0 maxY])
	titlestr = sprintf('Hamming function (n=%.0f):  y(x) = 0.54 - 0.46*cos(2*pi*x/(n-1))',mrsiMatrix);
	title(titlestr)
	subplot(2,1,2)
	plot(hammVec)
	hold on
        plot(round(hammVec),'r*')
        plot(hammVec,'go')
	hold off
	[minX maxX minY maxY] = SP2_IdealAxisValues(hammVec);
	axis([minX-0.3 maxX+0.3 0 maxY])
	grid on
	title('scaled 1D Hamming function, red/green are rounded/non-rounded values')
	
	% plot k-space weighting function
	fig3 = figure;
	namestr3 = sprintf('%s: hamming weighting, ''NA''=%.0f, COff=%.3f, WOff=%.3f',...
                        FCTNAME,max(max(AcqMatrixDiscr)),mrsiCircOffset,mrsiWeightOffset);
	set(fig3,'Name',namestr3)
	set(fig3,'Color',[1 1 1]);
	colormap([1 1 1])
	subplot(2,2,1)
	bar3(AcqMatrixOrig)
    set(gca,'YLim',[0.6 mrsiMatrix+0.4])
	set(gca,'CameraTarget',[7 7.5 7],'CameraViewAngle',[7.72853])
    title('exakt Hamming function','FontSize',12)
	subplot(2,2,2)
	bar3(AcqMatrixDiscr)
    set(gca,'YLim',[0.6 mrsiMatrix+0.4])
	set(gca,'CameraTarget',[7 7.5 7],'CameraViewAngle',[7.72853])
    title('discrete Hamming function','FontSize',12)
	subplot(2,2,3)
	bar3(AcqMatrixDiscr-AcqMatrixOrig)
    set(gca,'YLim',[0.6 mrsiMatrix+0.4])
	set(gca,'CameraTarget',[7 7.5 7],'CameraViewAngle',[7.72853])
    title('deviation','FontSize',12)
	subplot(2,2,4)
	surf(AcqMatrixDiscr)
    set(gca,'XTick',1:mrsiMatrix,'XTickLabel',1:mrsiMatrix)
	set(gca,'YTick',1:mrsiMatrix,'YTickLabel',1:mrsiMatrix)
	title('discrete Hamming function','FontSize',12)
	if strcmp(machine,'win69')
        set(fig3,'Position',[335 252 1324 865])
	else    % adjusted via win27
        set(fig3,'Position',[360 390 560 544]);
	end
end

%--- create acquisition normalized acquisition list ([-1 1] range)--- 
lCnt = 1;       % list counter
maxVal = max(max(AcqMatrixDiscr));
for dimcnt = 1:maxVal
    for icnt = 1:mrsiMatrix
        for jcnt = 1:mrsiMatrix
            if AcqMatrixDiscr(icnt,jcnt) >= maxVal-dimcnt+1
	            mrsiList0Norm(lCnt) = GradMat0Norm(icnt,jcnt);
	            mrsiList1Norm(lCnt) = GradMat1Norm(icnt,jcnt);
	            lCnt = lCnt + 1;
            end
        end
    end
end
mrsiListSize = lCnt-1;

fprintf('mrsiCircOffset = %.3f, mrsiWeightOffset = %.3f\n',mrsiCircOffset,mrsiWeightOffset);
fprintf('mrsiListSize = %.0f, mrsiAver = %.0f\n',mrsiListSize,mrsiAver);
durHamming = mrsiListSize*TR/60;                          % Hamming weighting, experiment duration [min]
durRect    = mrsiMatrix*mrsiMatrix*mrsiAver*TR/60;  % rectangular sampling, experiment duration [min]
ratio      = durHamming/durRect;                         % ratio Hamming duration / rectangular duration [%]                               
fprintf('Acq. time (TR %.1fsec):\nHamming=%.1fmin, rectangular=%.1fmin, ratio=%.3f\n'...
        ,TR,durHamming,durRect,ratio);

%--- plot each niveau of the hamming weighting into separate plot ---
if f_niveau
    NoResidD = mod(mrsiAver,impline);                   % impline = slices per line
    NoRowsD  = (mrsiAver-NoResidD)/impline+1;
    fig4 = figure;
    namestr4 = sprintf(' niveau representation of weigthed acquisition scheme');
    set(fig4,'Name',namestr4)
    set(fig4,'Color',[1 1 1]);
    for PlotCnt = 1:mrsiAver
        subplot(NoRowsD,impline,PlotCnt)
        pAcqMatrix = zeros(mrsiMatrix+1,mrsiMatrix+1);
        pAcqMatrix(1:mrsiMatrix,1:mrsiMatrix) = (AcqMatrixDiscr>=ones(mrsiMatrix)*PlotCnt);
        pcolor(pAcqMatrix)
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);
        xlabstr = sprintf('NA=%.0f (%.0f)',PlotCnt,length(find(AcqMatrixDiscr>=PlotCnt)));
        xlabel(xlabstr);
        set(gca,'DataAspectRatioMode','Manual')
    end
    colormap(gray(2))
end

% return weighting functions (e.g. for comparison via KSPACE_vx.m)
hammingOrig  = AcqMatrixOrig;
hammingDiscr = AcqMatrixDiscr;

%--- create black&yellow figures for export to power point ---
if f_ppt
    % the tick values for x and y start at 1. The following ones depend on the desired spacing 'xyTickSp'
    ppt_xyTickVec = ppt_xyTickSpace*[1:floor((mrsiMatrix+(ppt_xyTickSpace-1))/ppt_xyTickSpace)]-(ppt_xyTickSpace-1);    % x&y tick and tick label vector
    % the tick values for z always include the maximum value mrsiAver. The others depend on the spacing 'zTickSp'
    ppt_zTickVec = ppt_zTickSpace*[1:floor((mrsiAver+ppt_zTickSpace)/ppt_zTickSpace)]-(ppt_zTickSpace-mod(mrsiAver,ppt_zTickSpace));
    figure
    set(gcf,'Position',[352 78 1255 979],'Color',[0 0 0],'NumberTitle','off')
    set(gcf,'Name',' exact Hamming function (histogram)')
    ph1 = bar3(hammingOrig);
    set(findobj(gcf,'Color',[1 1 1]),'Color',[0 0 0])
    set(gca,'XLim',[0 mrsiMatrix+1],'YLim',[0 mrsiMatrix+1],'ZLim',[0 mrsiAver])
    set(gca,'XColor',[1 1 0],'YColor',[1 1 0],'ZColor',[1 1 0])
    set(gca,'FontSize',ppt_aFontSize,'LineWidth',[ppt_aLineWidth])
    set(gca,'XTick',ppt_xyTickVec,'XTickLabel',ppt_xyTickVec,'YTick',ppt_xyTickVec,'YTickLabel',ppt_xyTickVec)
    set(gca,'ZTick',ppt_zTickVec,'ZTickLabel',ppt_zTickVec)
    set(ph1,'FaceColor',[0.3 0.3 0],'EdgeColor',[1 1 0],'LineWidth',[ppt_pLineWidth])
    title('exact Hamming function','FontSize',ppt_tFontSize,'Color',[1 1 0])
    figure
    set(gcf,'Position',[357 83 1250 974],'Color',[0 0 0],'NumberTitle','off')
    set(gcf,'Name',' discrete Hamming function (histogram)')
    ph1 = bar3(hammingDiscr);
    set(findobj(gcf,'Color',[1 1 1]),'Color',[0 0 0])
    set(gca,'XLim',[0 mrsiMatrix+1],'YLim',[0 mrsiMatrix+1],'ZLim',[0 mrsiAver])
    set(gca,'XColor',[1 1 0],'YColor',[1 1 0],'ZColor',[1 1 0])
    set(gca,'FontSize',ppt_aFontSize,'LineWidth',[ppt_aLineWidth])
    set(gca,'XTick',ppt_xyTickVec,'XTickLabel',ppt_xyTickVec,'YTick',ppt_xyTickVec,'YTickLabel',ppt_xyTickVec)
    set(gca,'ZTick',ppt_zTickVec,'ZTickLabel',ppt_zTickVec)
    set(ph1,'FaceColor',[0.3 0.3 0],'EdgeColor',[1 1 0],'LineWidth',[ppt_pLineWidth])
    title('discrete Hamming function','FontSize',ppt_tFontSize,'Color',[1 1 0])
    figure
    set(gcf,'Position',[362 87 1245 969],'Color',[0 0 0],'NumberTitle','off')
    set(gcf,'Name',' exact Hamming function (surface)')
    ph1 = surf(hammingOrig);
    set(findobj(gcf,'Color',[1 1 1]),'Color',[0 0 0])
    set(gca,'XLim',[1 mrsiMatrix],'YLim',[1 mrsiMatrix],'ZLim',[0 mrsiAver])
    set(gca,'XColor',[1 1 0],'YColor',[1 1 0],'ZColor',[1 1 0])
    set(gca,'FontSize',ppt_aFontSize,'LineWidth',[ppt_aLineWidth])
    set(gca,'XTick',ppt_xyTickVec,'XTickLabel',ppt_xyTickVec,'YTick',ppt_xyTickVec,'YTickLabel',ppt_xyTickVec)
    set(gca,'ZTick',ppt_zTickVec,'ZTickLabel',ppt_zTickVec)
    set(ph1,'FaceColor',[0.9 0.9 0],'FaceAlpha',[0.5],'EdgeColor',[1 1 0],'LineWidth',[ppt_pLineWidth])
    title('exact Hamming function','FontSize',ppt_tFontSize,'Color',[1 1 0])
    figure
    set(gcf,'Position',[367 93 1240 964],'Color',[0 0 0],'NumberTitle','off')
    set(gcf,'Name',' discrete Hamming function (surface)')
    ph1 = surf(hammingDiscr);
    set(findobj(gcf,'Color',[1 1 1]),'Color',[0 0 0])
    set(gca,'XLim',[1 mrsiMatrix],'YLim',[1 mrsiMatrix],'ZLim',[0 mrsiAver])
    set(gca,'XColor',[1 1 0],'YColor',[1 1 0],'ZColor',[1 1 0])
    set(gca,'FontSize',ppt_aFontSize,'LineWidth',[ppt_aLineWidth])
    set(gca,'XTick',ppt_xyTickVec,'XTickLabel',ppt_xyTickVec,'YTick',ppt_xyTickVec,'YTickLabel',ppt_xyTickVec)
    set(gca,'ZTick',ppt_zTickVec,'ZTickLabel',ppt_zTickVec)
    set(ph1,'FaceColor',[0.8 0.8 0],'FaceAlpha',[0.5],'EdgeColor',[1 1 0],'LineWidth',[ppt_pLineWidth])
    title('discrete Hamming function','FontSize',ppt_tFontSize,'Color',[1 1 0])
end

%--- create figures for eps export ---
if f_eps
    % the tick values for x and y start at 1. The following ones depend on the desired spacing 'xyTickSp'
    eps_xyTickVec = eps_xyTickSpace*[1:floor((mrsiMatrix+(eps_xyTickSpace-1))/eps_xyTickSpace)]-(eps_xyTickSpace-1);    % x&y tick and tick label vector
    % the tick values for z always include the maximum value mrsiAver. The others depend on the spacing 'zTickSp'
    eps_zTickVec = eps_zTickSpace*[1:floor((mrsiAver+eps_zTickSpace)/eps_zTickSpace)]-(eps_zTickSpace-mod(mrsiAver,eps_zTickSpace));
    figure
    set(gcf,'Position',[154 52 1239 896],'NumberTitle','off','Color',[1 1 1])
    set(gcf,'Name',' exact Hamming function (histogram)')
    ph1 = bar3(hammingOrig);
    set(gca,'XLim',[0.5 mrsiMatrix+0.5],'YLim',[0.5 mrsiMatrix+0.5],'ZLim',[0 mrsiAver])
    set(gca,'FontSize',eps_aFontSize,'LineWidth',[eps_aLineWidth])
    set(gca,'XTick',eps_xyTickVec,'XTickLabel',eps_xyTickVec,'YTick',eps_xyTickVec,'YTickLabel',eps_xyTickVec)
    set(gca,'ZTick',eps_zTickVec,'ZTickLabel',eps_zTickVec)
    set(ph1,'FaceColor',eps_faceColor,'LineWidth',[eps_pLineWidth])
    title('exact Hamming function','FontSize',eps_tFontSize)
    figure
    set(gcf,'Position',[154 52 1239 896],'NumberTitle','off','Color',[1 1 1])
    set(gcf,'Name',' discrete Hamming function (histogram)')
    ph1 = bar3(hammingDiscr);
    set(gca,'XLim',[0.5 mrsiMatrix+0.5],'YLim',[0.5 mrsiMatrix+0.5],'ZLim',[0 mrsiAver])
    set(gca,'FontSize',eps_aFontSize,'LineWidth',[eps_aLineWidth])
    set(gca,'XTick',eps_xyTickVec,'XTickLabel',eps_xyTickVec,'YTick',eps_xyTickVec,'YTickLabel',eps_xyTickVec)
    set(gca,'ZTick',eps_zTickVec,'ZTickLabel',eps_zTickVec)
    set(ph1,'FaceColor',eps_faceColor,'LineWidth',[eps_pLineWidth])
    title('discrete Hamming function','FontSize',eps_tFontSize)
    figure
    set(gcf,'Position',[154 52 1239 896],'NumberTitle','off','Color',[1 1 1])
    set(gcf,'Name',' exact Hamming function (surface)')
    ph1 = surf(hammingOrig);
    set(gca,'XLim',[1 mrsiMatrix],'YLim',[1 mrsiMatrix],'ZLim',[0 mrsiAver])
    set(gca,'FontSize',eps_aFontSize,'LineWidth',[eps_aLineWidth])
    set(gca,'XTick',eps_xyTickVec,'XTickLabel',eps_xyTickVec,'YTick',eps_xyTickVec,'YTickLabel',eps_xyTickVec)
    set(gca,'ZTick',eps_zTickVec,'ZTickLabel',eps_zTickVec)
    set(ph1,'FaceColor',eps_faceColor,'FaceAlpha',[0.5],'LineWidth',[eps_pLineWidth])
    title('exact Hamming function','FontSize',eps_tFontSize)
    figure
    set(gcf,'Position',[154 52 1239 896],'NumberTitle','off','Color',[1 1 1])
    set(gcf,'Name',' discrete Hamming function (surface)')
    ph1 = surf(hammingDiscr);
    set(gca,'XLim',[1 mrsiMatrix],'YLim',[1 mrsiMatrix],'ZLim',[0 mrsiAver])
    set(gca,'FontSize',eps_aFontSize,'LineWidth',[eps_aLineWidth])
    set(gca,'XTick',eps_xyTickVec,'XTickLabel',eps_xyTickVec,'YTick',eps_xyTickVec,'YTickLabel',eps_xyTickVec)
    set(gca,'ZTick',eps_zTickVec,'ZTickLabel',eps_zTickVec)
    set(ph1,'FaceColor',eps_faceColor,'FaceAlpha',[0.5],'LineWidth',[eps_pLineWidth])
    title('discrete Hamming function','FontSize',eps_tFontSize)    
    figure
    set(gcf,'Position',[154 52 1239 896],'NumberTitle','off','Color',[1 1 1])
    set(gcf,'Name',' discrete Hamming function (surface)')
    ph1 = bar3(AcqMatrixDiscr-AcqMatrixOrig);
    set(gca,'XLim',[0.6 mrsiMatrix+0.4],'YLim',[0.6 mrsiMatrix+0.4])
    set(gca,'FontSize',eps_aFontSize,'LineWidth',[eps_aLineWidth])
    set(gca,'XTick',eps_xyTickVec,'XTickLabel',eps_xyTickVec,'YTick',eps_xyTickVec,'YTickLabel',eps_xyTickVec)
    set(ph1,'FaceColor',eps_faceColor,'LineWidth',[eps_pLineWidth])
    title('deviation map','FontSize',eps_tFontSize)
end


%%%%%%%%%%%%  S A V E    W E I G H T I N G    T O    F I L E   %%%%%%%%%%%%
%--- file creation ---
fileHammR = sprintf('%sHamming%02.0fx%02.0fNA%.0fN%.0f_R.txt',tabdir,mrsiMatrix,mrsiMatrix,mrsiAver,mrsiListSize);
fileHammP = sprintf('%sHamming%02.0fx%02.0fNA%.0fN%.0f_P.txt',tabdir,mrsiMatrix,mrsiMatrix,mrsiAver,mrsiListSize);
[unitHammR,msg] = fopen(fileHammR,'w');
if unitHammR==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end
[unitHammP,msg] = fopen(fileHammP,'w');
if unitHammP==-1
    fprintf('%s ->\nOpening data file failed.\nMessage: %s\nProgram aborted.\n',...
            FCTNAME,msg)
    return
end

%--- varian table format ---
mrsiList0VnmrJ = mrsiList0Norm*(mrsiMatrix-1)/2;
mrsiList1VnmrJ = mrsiList1Norm*(mrsiMatrix-1)/2;

%--- table creation ---
fprintf(unitHammR,'t1 =\n');
fprintf(unitHammP,'t2 =\n');
for lCnt = 1:mrsiListSize
    fprintf(unitHammR,'%.0f\n',mrsiList0VnmrJ(lCnt));
    fprintf(unitHammP,'%.0f\n',mrsiList1VnmrJ(lCnt));
end
fclose(unitHammR);
fclose(unitHammP);

%--- save exact and acquisition weighting to .mat file ---
fileHammMat = sprintf('%sHamming%02.0fx%02.0fNA%.0fN%.0f.mat',tabdir,mrsiMatrix,mrsiMatrix,mrsiAver,mrsiListSize);

save(fileHammMat,'AcqMatrixDiscr','AcqMatrixOrig','GradMat0Norm','GradMat1Norm','mrsiAver',...
     'mrsiCircOffset','mrsiList0Norm','mrsiList1Norm','mrsiList0VnmrJ','mrsiList1VnmrJ',...
     'mrsiListSize','mrsiMatrix','mrsiWeightOffset')

 %--- info printout ---
fprintf('%s successfully completed.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

end
