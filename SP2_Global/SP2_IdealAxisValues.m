%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [MinX, MaxX, MinY, MaxY] = SP2_IdealAxisValues(varargin)
%%
%%  [MinX, MaxX, MinY, MaxY] = SP2_IdealAxisValues(dataSet)
%%  determination of ideal plotting limits (axis) to entirely plot a data set
%%  (fid, spectrum, ...), but preventing additional gaps without data points
%%  in the plot.
%%  A single vector may be given as argument, or alternatively two vectors, 
%%  assigning the x- and y-axis respectively: SP2_IdealAxisValues(x-vector,y-vector)
%%  An optional third argument can be used to assign the gap size in relative units
%%  e.g. OffsetFac=0.1 -> 10% of the max/min difference are added to the plot range
%%
%%  Christoph Juchem, 03-2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_IdealAxisValues';


OffsetFac = 0.1;      % constant to determine the gap between the function and the window limit

narg = nargin;
if narg==1
    dataSetY = SP2_Check4NumR(varargin{1});
    if ~isreal(dataSetY)
        fprintf('%s -> vector to be plotted is complex\n\n',FCTNAME)
        return
    end
    datSize = size(dataSetY);
    MinX = 1;
    MaxX = max(datSize);
elseif narg==2
    dataSetX = SP2_Check4NumR(varargin{1});
    dataSetY = SP2_Check4NumR(varargin{2});
    if ~isreal(dataSetX) || ~isreal(dataSetY)
        fprintf('%s -> at least one of the vectors to be plotted is complex\n\n',FCTNAME)
        return
    end
    MinX = min(dataSetX);
    MaxX = max(dataSetX);
elseif narg==3
    dataSetX  = SP2_Check4NumR(varargin{1});
    dataSetY  = SP2_Check4NumR(varargin{2});
    OffsetFac = SP2_Check4NumR(varargin{3});
    if ~isreal(dataSetX) || ~isreal(dataSetY)
        fprintf('%s -> at least one of the vectors to be plotted is complex\n\n',FCTNAME)
        return
    end
    MinX = min(dataSetX);
    MaxX = max(dataSetX);
elseif narg~=3
    fprintf('%s -> the number of arguments must be one or two!...\n\n',FCTNAME)
    return
end

%--- take full exact x-range, but enhanced y-range -------------------
if isempty(find(dataSetY~=0))
    MinYVal = -1;
    MaxYVal = 1;
else
    MinYVal = min(dataSetY);
    MaxYVal = max(dataSetY);
end
MinY = MinYVal - abs(MaxYVal-MinYVal)*OffsetFac;
MaxY = MaxYVal + abs(MaxYVal-MinYVal)*OffsetFac;

%--- check for identical values of MinY and MaxY which would lead to an error message from the plotting function ---
if MinY==MaxY
    if MinY<0
        MinY = (1+OffsetFac) * MinY;
        MaxY = (1-OffsetFac) * MaxY;
    elseif MinY==0
        MinY = -0.5;
        MaxY = 0.5;
    else            % MinY>0
        MinY = (1-OffsetFac) * MinY;
        MaxY = (1+OffsetFac) * MaxY;
    end
end
