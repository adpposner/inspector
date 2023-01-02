%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [maxVal,maxInd,f_succ] = SP2_SplineMaxDeterm(datVec,varargin)
%%
%%  function maxPt = SP2_SplineMaxDeterm(datVec,varargin)
%%  calculates maximum value of spline interpolated peak and corresponding index. A 
%%  second function argument can be used to assign a spline interpolation factor
%%  different from the default of two. With a third optional argument, a plotting
%%  option of the fitting result is enabled (value: 1)
%%  08-2004, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME    = 'SP2_SplineMaxDeterm';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
maxVal  = 0;          % init
maxInd  = 0;          % maxInd
splFac  = 2;          % default for spline interpolation factor
f_debug = 0;          % default for plotting option

%--- format handling of datVec ---
vecSize = size(datVec);
if length(vecSize)>2
    fprintf('%s ->\nFunction argument is not a vector\n',FCTNAME);
    return
end
if vecSize(1)>1 && vecSize(2)==1
    datVec = datVec';
elseif vecSize(1)~=1 && vecSize(2)~=1
    fprintf('%s ->\nData format of ''vector'' is not supported, size=(%i/%i)\n'...
                  ,FCTNAME,vecSize(1),vecSize(2))
    return
end

%--- additional parameter handling ---
if nargin==2
    splFac = SP2_Check4NumR(varargin{1});
elseif nargin==3
    splFac  = SP2_Check4NumR(varargin{1});
    f_debug = SP2_Check4NumR(varargin{2});
    if f_debug~=0 && f_debug~=1
        fprintf('%s ->\nf_debug must be 0 or 1...',FCTNAME);
        return
    end
elseif nargin~=1
    fprintf('%s ->\nNumber of function arguments must be 0 or 1...',FCTNAME);
    return
end

vecLen = length(datVec);
xx = 1:(vecLen-1)/(vecLen*splFac-1):vecLen;     % x-axis scaling is not changed
yy = spline(1:vecLen,datVec,xx);
[maxVal,maxIndYY] = max(yy);
maxInd = xx(maxIndYY);

if maxInd==1 || maxInd==length(xx)
    fprintf('%s -> the maximum was detected at one of the edges...\n',FCTNAME);
    f_stop  = 1;
    f_debug = 1;
else
    f_stop = 0;     % successful maximum search
end

if f_debug
    fh = figure;
    nameStr = sprintf('%s: spline interpolation result',FCTNAME);
    set(fh,'NumberTitle','off','Name',nameStr)
    plot(datVec)
    hold on
        plot(datVec,'r+')
        plot(xx,yy,'g+')
    hold off
    if f_stop
        fprintf('-> program execution stopped!');
        return
    end
end

%--- update success flag ---
f_succ = 1;

