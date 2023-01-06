function [AxisLim, f_succ] = SP2_ModifyAxisValues(varargin)
%
% [MinX, MaxX, MinY, MaxY] = ModifyAxisValues(axis limit vectors)
% very often when different functions are plotted to one figure, one has to determine
% axis values, that are reasonable for both functions. Given the axis values for each
% particular one (e.g. determined by IdealAxisValues.m) the function ModifyAxisValues
% returns a vector of such axis limits reasonable for both.
% Christoph Juchem, 10-2003
%

FCTNAME = 'ModifyAxisValues';

%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
AxisLim = varargin{1};      % init with first vector
if narg>1
    for icnt = 1:narg
        limvec = varargin{icnt};
        vecsize = size(limvec);
        if length(vecsize)~=2
            fprintf('%s -> argument length is %d, but must be 2!',FCTNAME,length(vecsize));
            return
        end
        if vecsize(1)~=1 || vecsize(2)~=4
            fprintf('%s -> arguments must be 1x4 vectors but is %dx%d!',FCTNAME,vecsize(1),vecsize(2));
            return
        end
        if limvec(1) < AxisLim(1,1)
            AxisLim(1,1) = limvec(1);
        end
        if limvec(2) > AxisLim(1,2)
            AxisLim(1,2) = limvec(2);
        end
        if limvec(3) < AxisLim(1,3)
            AxisLim(1,3) = limvec(3);
        end
        if limvec(4) > AxisLim(1,4)
            AxisLim(1,4) = limvec(4);
        end
    end        
else
    fprintf('%s -> the number of arguments must be at least 2!...',FCTNAME);
    return
end

%--- update success flag ---
f_succ = 1;



end
