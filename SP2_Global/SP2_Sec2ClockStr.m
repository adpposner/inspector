function clockStr = SP2_Sec2ClockStr(secTime)

% function clockStr = PHYSx_Sec2ClockStr(secTime)
% time conversion: absolute time [sec] since midnight is converted to a clock string
% Ch. Juchem, 04-2004

FCTNAME = 'SP2_Sec2ClockStr';

if ~SP2_Check4Num(secTime)
    return
end
if secTime<0 || secTime>24*3600
    fprintf('%s -> %f is not a reasonable value to be converted!',FCTNAME,secTime)
    return
end
resSec = mod(secTime,3600);         % residual seconds after cutting away the hours
hVal = (secTime - resSec)/3600;     % hours
sVal = mod(resSec,60);              % seconds
mVal = (resSec - sVal)/60;          % minutes

hStr = sprintf('%.0f',hVal);
if length(hStr)==1
    hStr = [num2str(0) hStr];
end
mStr = sprintf('%.0f',mVal);
if length(mStr)==1
    mStr = [num2str(0) mStr];
end
sStr = sprintf('%.0f',sVal);
if length(sStr)==1
    sStr = [num2str(0) sStr];
end
clockStr = [hStr ':' mStr ':' sStr];



