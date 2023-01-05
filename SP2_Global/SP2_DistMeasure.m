%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dist, f_succ] = SP2_DistMeasure
%%
%%  image based distance measurement
%%
%%  03-2004, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_DistMeasure';
global flag exm syn pass ana reg


%--- init success flag ---
f_succ = 0;
dist   = 0;                   % init

%--- get image positions ---
[l2r,d2u]  = ginput(2);      % l2r: from left rightwards, d2u: down upwards

%--- explicite slice assignment ---
if nargin==2
    slice = SP2_Check4IntBigger0R(varargin{1});
else
    if flag.fmWin==1 || flag.fmWin==2 || flag.fmWin==3
        slice    = exm.slice;
        res      = exm.res;
        mat      = exm.mat;
    elseif flag.fmWin==4
        slice    = syn.slice;
        res      = syn.res;
        mat      = syn.mat;
    elseif flag.fmWin==5
        slice    = pass.slice;
        res      = pass.res;
        mat      = pass.mat;
    elseif flag.fmWin==8
        slice    = ana.slice;
        res      = ana.res;
        mat      = ana.mat;
    elseif flag.fmWin==9
        slice    = reg.slice;
        res      = reg.res;
        mat      = reg.mat;
    else
        fprintf('%s -> flag.fmWin=%i not supported',FCTNAME,flag.fmWin);
        return
    end
end

%--- distance calculation ------------------------------
if flag.plotOrient==1               % sagittal
    dist = sqrt((diff(l2r)*res(2))^2 + (diff(d2u)*res(3))^2);
    dimUD = mat(3);      % used for text display shift determination
    dimLR = mat(2);
elseif flag.plotOrient==2           % coronal
    dist = sqrt((diff(l2r)*res(1))^2 + (diff(d2u)*res(3))^2);
    dimUD = mat(3);      % used for text display shift determination
    dimLR = mat(1);
else                                % axial, l2r -> x, d2u -> y
    dist = sqrt((diff(l2r)*res(1))^2 + (diff(d2u)*res(2))^2);
    dimUD = mat(2);      % used for text display shift determination
    dimLR = mat(1);
end
fprintf('%s -> distance measurement (slice %i): %.1f mm\n',FCTNAME,slice,dist);

%--- plot result to image ------------------------------
hold on
    plot(l2r(1),d2u(1),'r+')
    plot(l2r(2),d2u(2),'r+')
    if l2r(2)~=l2r(1) && d2u(2)~=d2u(1)      % diagonal
        plot(l2r(1):(l2r(2)-l2r(1))/500:l2r(2),d2u(1):(d2u(2)-d2u(1))/500:d2u(2),'b')
    elseif l2r(2)~=l2r(1) && d2u(2)==d2u(1)  % horizontal
        plot(l2r(1):(l2r(2)-l2r(1))/500:l2r(2),d2u(1),'b')
    else        % l2r(2)==l2r(1) & d2u(2)~=d2u(1)  % vertical
        plot(l2r(1),d2u(1):(d2u(2)-d2u(1))/500:d2u(2),'b')
    end
hold off
yText = min(d2u);
if yText==d2u(1);
    xText=l2r(1)-round(dimLR/10);
else
    xText=l2r(2)-round(dimLR/10);
end
yText = yText-round(dimUD/30);
distStr = sprintf('%.1f mm',dist);
th = text(xText,yText,distStr);
set(th,'Color','b')

%--- update success flag ---
f_succ = 1;


