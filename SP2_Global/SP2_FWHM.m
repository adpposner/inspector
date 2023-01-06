%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg,f_succ] = SP2_FWHM(vector,varargin)
%%
%%  Determination of the full width at half maximum of a vector in points.
%%  A second function argument >1 can be used to assign the dimension
%%  increase for spline interpolation. If such a factor is used the result
%%  is determined from the spline interpolated vector. A third argument can
%%  be used to explicitely switch on/off details of the FWHM calculation
%%  Note that for FWHM determination the spline interpolation only slightly
%%  improves the line width accuracy, because at half hight original vector
%%  and spline interpolation are almost the same. But in addition a more
%%  reliable maximum determination may influence the line width result. If
%%  there is more than one peak with values bigger than half the maximum
%%  value, the FWHM of the maximum peak is determined.
%%
%%  06-2004 / 02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_FWHM';


%--- init success flag ---
f_succ = 0;

%--- init other pars --
f_debug = 1;
fwhmPts     = 0;
minFwhmPts  = 0;
maxFwhmPts  = 0;
maxAmpl     = 0;
maxAmplPts  = 0;
msg         = '';                   % init error messsage

%--- vector handling ---
if ~SP2_Check4Num(vector)
    return
end
vecSize = size(vector);
if length(vecSize)>2
    fprintf('%s -> Only vectors are supported\n\n',FCTNAME);
    return
end
if vecSize(1)==1 && vecSize(2)>1
    % regular case
    vecLen = vecSize(2);
elseif vecSize(1)>1 && vecSize(2)==1
    vector = vector';
    vecLen = vecSize(1);
else
    fprintf('%s -> data format of ''vector'' is not supported\n\n',FCTNAME);
    return
end

%--- additional parameter handling ---
splFac = 1;         % init default
if nargin==2
    splFac  = SP2_Check4NumR( varargin{1} );
elseif nargin==3
    splFac  = SP2_Check4NumR( varargin{1} );
    f_debug = SP2_Check4FlagR( varargin{2} );
elseif nargin~=1
    fprintf('%s -> number of arguments must be zero or one, but is %i\n\n',...
            FCTNAME,nargin)
    return
end

%--- consistency checks ---
if splFac<=1 && mod(splFac,1)~=0
    fprintf('%s -> %.1f makes no sense as spline interpolation factor!\n\n',...
            FCTNAME,splFac)
    return
end


%--------------------------------------------------------------------------------------
%--- D I R E C T   C A L C U L A T I O N ----------------------------------------------
%--------------------------------------------------------------------------------------
[vecMaxVal,vecMaxInd] = max(vector);

%--- consistency check: max location ---
if vecMaxInd==1 || vecMaxInd==vecLen
    fprintf('%s ->\nMaximum value is situated at the beginning/end of the vector\n',FCTNAME);
    fwhmPts    = -1;
    minFwhmPts = 0;
    maxFwhmPts = 0;
    maxAmpl    = vecMaxVal;
    maxAmplPts = vecMaxInd;
    msg        = 'Maximum value is situated at the beginning/end of the vector. Program aborted.';
    return
end

%--- consistency check: 1st and last points < max/2 ---
if vector(1)>vecMaxVal/2
    fprintf('%s ->\nFirst point is larger than max/2. Program aborted\n',FCTNAME);
    fwhmPts    = -1;
    minFwhmPts = 0;
    maxFwhmPts = 0;
    maxAmpl    = vecMaxVal;
    maxAmplPts = vecMaxInd;
    msg        = 'Last point is larger than max/2. Program aborted.';
    return
end
if vector(end)>vecMaxVal/2
    fprintf('%s ->\nLast point is larger than max/2. Program aborted\n',FCTNAME);
    fwhmPts    = -1;
    minFwhmPts = 0;
    maxFwhmPts = 0;
    maxAmpl    = vecMaxVal;
    maxAmplPts = vecMaxInd;
    msg        = 'Last point is larger than max/2. Program aborted.';
    return
end


%--- non-spline calculation ----------------------------------------
limVec = find(vector>vecMaxVal/2);         % indices of points bigger than half of the maximum

%--- check for multiple peaks with at least two times the maximum vector value ---
if ~isempty(find(diff(limVec)~=1))                  % check for non-continous vector indices
    msg = sprintf('FWHM area consists of multiple peaks. Local minimum detected...\n');
    if f_debug
        fprintf(msg);
    end
end

minIndIn  = min(limVec);            % minimal index with value >vecMaxVal/2
minIndOut = minIndIn-1;             % 1st point outside on the minimum index side
maxIndIn  = max(limVec);            % maximal index with value >vecMaxVal/2
maxIndOut = maxIndIn+1;             % 1st point outside on the maximum index side

%--- slope m and x (exact index) determination ----------------
% m=(y2-y1)/(x2-x1)
mMin = vector(minIndIn)-vector(minIndOut);          % point resolution of x -> x2-x1=1
mMax = vector(maxIndOut)-vector(maxIndIn);          % point resolution of x -> x2-x1=1
% y = m*(x-x1) + y1 -> x = (y-y1)/m + x1
minInd = (vecMaxVal/2-vector(minIndOut))/mMin + minIndOut; 
maxInd = (vecMaxVal/2-vector(maxIndIn))/mMax + maxIndIn;
fwhm   = maxInd-minInd;


%--------------------------------------------------------------------------------------
%--- S P L I N E   C A L C U L A T I O N
%----------------------------------------------
%--------------------------------------------------------------------------------------
if splFac>1
    vecLen = length(vector);
    xx = 1:(vecLen-1)/(vecLen*splFac-1):vecLen;
    yy = spline(1:vecLen,vector,xx);
    [yyMaxVal,yyMaxInd] = max(yy);
    spLimYY = find(yy>yyMaxVal/2);      % indices of points bigger than half of the maximum
	spLimMaxInd = find(spLimYY==yyMaxInd);       % find maxInd in limVec (values bigger half of max)
	
	% it may happen that other peaks also have values bigger than half of the maximum peak
	% therefore starting from the maximum peak maximum position continuity is checked down/upwards
	spMinIndIn = yyMaxInd;                     % index of minimal index with value >vecMaxVal/2
	ptCnt  = 0;
	while spLimMaxInd-(ptCnt+1)>0             % till first point of limVec, -> positiv index
	if spLimYY(spLimMaxInd-ptCnt)-spLimYY(spLimMaxInd-(ptCnt+1))==1
        ptCnt  = ptCnt + 1;
        spMinIndIn = yyMaxInd-ptCnt;
	end
	
	end
	spMinIndOut = spMinIndIn-1;
	spMaxIndIn = yyMaxInd;                     % index of minimal index with value >vecMaxVal/2
	ptCnt    = 0;
	while spLimMaxInd+ptCnt<length(spLimYY)             % till first point of limVec, -> positiv index
	if spLimYY(spLimMaxInd+ptCnt+1)-spLimYY(spLimMaxInd+ptCnt)==1
        ptCnt    = ptCnt + 1;
        spMaxIndIn = yyMaxInd+ptCnt;
	end
	
	end
	spMaxIndOut = spMaxIndIn+1;
    
    %--- slope m and x (exact index) determination ----------------
    % m=(y2-y1)/(x2-x1)
    mMinSp = yy(spMinIndIn)-yy(spMinIndOut);          % point resolution of x -> x2-x1=1
    mMaxSp = yy(spMaxIndOut)-yy(spMaxIndIn);          % point resolution of x -> x2-x1=1
    % y = m*(x-x1) + y1 -> x = (y-y1)/m + x1
    spMinInd = (yyMaxVal/2-yy(spMinIndOut))/mMinSp + spMinIndOut;
    spMaxInd = (yyMaxVal/2-yy(spMaxIndIn))/mMaxSp + spMaxIndIn;
    fwhmDirect = fwhm;      % FWHM determination without spline interpolation
    fwhm   = (spMaxInd-spMinInd)/splFac;
end

%--- result assignment ---
if splFac==1        % no interpolation
    minFwhmPts = minInd; 
    maxFwhmPts = maxInd;
    maxAmpl    = vecMaxVal;
    maxAmplPts = vecMaxInd;
else                % spline interpolation applied
    minFwhmPts = minInd; 
    maxFwhmPts = maxInd;
    maxAmpl    = yyMaxVal;
    maxAmplPts = (yyMaxInd+1)/splFac;
end
fwhmPts = fwhm;

if f_debug
    if splFac>1
        fprintf('%s -> FWHM = %.2f pts (direct calc: %.2f pts)\n',FCTNAME,fwhm,fwhmDirect);
    else
        fprintf('%s -> FWHM = %.2f pts\n',FCTNAME,fwhm);
    end
end
    
%--- plot results --------------------------------------------   
if f_debug
    currFh   = get(0,'CurrentFigure');
    figh1    = figure;
    namestr1 = sprintf(' %s determination',FCTNAME);
    set(figh1,'NumberTitle','off','Name',namestr1,'Position',[125 217 941 615])
    subplot(1,2,1)
    plot(vector)
    [minX maxX minY maxY] = SP2_IdealAxisValues(vector);
    axis([minX maxX minY maxY])
    title(sprintf('original vector, FWHM=%.2fpts',fwhm))
    hold on
        plot(minInd:1/1000:minInd,minY:(maxY-minY)/1000:maxY,'g')
        plot(maxInd:1/1000:maxInd,minY:(maxY-minY)/1000:maxY,'g')
        plot(minX:(maxX-minX)/1000:maxX,vecMaxVal/2:1/1000:vecMaxVal/2,'g')
        plot(minX:(maxX-minX)/1000:maxX,0:1/1000:0,'g')
    hold off
    xlabel('frequency [pts]')
    ylabel('amplitude [a.u.]')
    subplot(1,2,2)
    if splFac>1
        vecInterp = interp1(1:length(vector),vector,1:1/splFac:length(yy));
        % linear interpolation of vector to yy resolution the appearence
        % of 'vector' is not change by the linear neighbouring point interpolation
        
        %--- number of spline pts outside the 1st vector point < max/2
        Gap = splFac+1;    % = number of blue pts outside the 1st red point small half the maximum
        
        %--- determine plot limits for zoomed plot via the original data vector
        % to be shure that the original data vector isn't reduced/cut
        spPlotMin = minIndOut*splFac -(splFac-1) -Gap; 
        spPlotMax = maxIndOut*splFac -(splFac-1) +Gap;
        nZoom     = spPlotMax-spPlotMin+1;      % number of data points to be plotted (zoom)
              
        
        plotVecX = ((1:nZoom)+(spPlotMin-1)+(splFac-1))./splFac;
        plot(xx(spPlotMin:spPlotMax+Gap),yy(spPlotMin:spPlotMax+Gap),'r')           % peak including 1st points outside FWHM
        [minX maxX minY maxY] = SP2_IdealAxisValues(plotVecX,vecInterp(spPlotMin:spPlotMax));
        hold on
            plot(xx(spPlotMin:spPlotMax+Gap),yy(spPlotMin:spPlotMax+Gap),'+')
            plot(plotVecX,vecInterp(spPlotMin:spPlotMax))
            diffVal = nZoom-splFac - mod(nZoom-splFac,splFac); % different point scales need not to be multiplets from the other
            xAltern = spPlotMin + (0:splFac:diffVal) + Gap;    % alternate, only original vector points are plotted
            plot(minIndOut:minIndOut+length(xAltern)-1,vecInterp(1,xAltern),'r+')
            plotValMin = (spMinInd-1) * (length(vector)-1)/(length(xx)-1) + 1;
            plotValMax = (spMaxInd-1) * (length(vector)-1)/(length(xx)-1) + 1;
            plot([plotValMin plotValMin],[minY maxY],'g')
            plot([plotValMax plotValMax],[minY maxY],'g')
            plot([minX maxX],[yyMaxVal/2 yyMaxVal/2],'g')
        hold off
        axis([minX maxX minY maxY])
        title('vector & spline interp.')
        xlabel('[pts]')
    else
        plotVecX = [minIndOut:maxIndOut];
        plot(plotVecX,vector(minIndOut:maxIndOut))           % peak including 1st points outside FWHM
        [minX maxX minY maxY] = SP2_IdealAxisValues(plotVecX,vector(minIndOut:maxIndOut));
        axis([minX maxX minY maxY])
        hold on
            plot(plotVecX,vector(minIndOut:maxIndOut),'r+')
            plot([minInd minInd],[minY maxY],'g')
            plot([maxInd maxInd],[minY maxY],'g')
            plot([minX maxX],[vecMaxVal/2 vecMaxVal/2],'g')
        hold off
        title('zoom on peak')
        xlabel('[pts]')
    end
    set(0,'CurrentFigure',currFh)
end
    
%--- update success flag ---
f_succ = 1;


end
