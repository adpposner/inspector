%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [timeVec,scaleVec] = SP2_T1T2_T1DecayCalcDelay( f_show )
%%
%%	Calculate delay corresponding to given inversion-recovery-based
%%  signal along the recovery curve.
%%  (Simple exp decay)
%%
%%  09-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2


%--- consistency check ---
if t1t2.t1decScale<-1 || t1t2.t1decScale<1
    fprintf('Relative amplitude <-1 or >1 is not possible. Program aborted.\n');
end

%--- delay calculation ---
% analytical:
t1Delay = -t1t2.t1decT1*log((1-t1t2.t1decScale)/2);

%--- consistency checks ---
tMax    = 2*t1Delay;
timeVec = 0:tMax/500:tMax;

%--- relative amplitude calculation ---
scaleVec = 1-2*exp(-timeVec/t1t2.t1decT1);

%--- info printout ---
fprintf('\nT1        = %.5f ms\n',t1t2.t1decT1);
fprintf('Amplitude = %.5f a.u.\n',t1t2.t1decScale);
if t1t2.t1decScale==0
    fprintf('Delay     = %.5f ms = T1*log(2) = T1*0.6931 (output)\n\n',t1Delay);
else
    fprintf('Delay     = %.5f ms (output)\n\n',t1Delay);
end

%--- figure creation ---
if f_show
    t1DecayFh = figure;
    set(t1DecayFh,'NumberTitle','off','Name',' T1 Decay Analysis','Position',[314 114 700 500],'Color',[1 1 1]);
    plot(timeVec,scaleVec);
    xlabel('Delays [ms]')
    ylabel('Amplitude [a.u.]')
    [minX, maxX, minY, maxY] = SP2_IdealAxisValues(timeVec,scaleVec);
    axis([minX maxX minY maxY])
    hold on
    plot(t1Delay*[1 1],[minY maxY],'Color',[0 1 0])
    plot([minX maxX],t1t2.t1decScale*[1 1],'Color',[0 1 0])
    hold off
end




