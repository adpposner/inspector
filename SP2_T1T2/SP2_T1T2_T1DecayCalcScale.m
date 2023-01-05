%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [timeVec,scaleVec] = SP2_T1T2_T1DecayCalcScale( f_show )
%%
%%	Relative inversion-recovery signal as a result of T1 decay.
%%  (Simple exp decay)
%%
%%  09-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2


%--- find relative amplitude ---
% analytical:
relAmpl = 1-2*exp(-t1t2.t1decDelay/t1t2.t1decT1);

%--- consistency checks ---
tMax    = 2*t1t2.t1decDelay;
timeVec = 0:tMax/1000:tMax;

%--- relative amplitude calculation ---
scaleVec = 1-2*exp(-timeVec/t1t2.t1decT1);

%--- info printout ---
fprintf('\nT1        = %.5f ms\n',t1t2.t1decT1);
fprintf('Delay     = %.5f ms\n',t1t2.t1decDelay);
fprintf('Amplitude = %.5f a.u. (output)\n\n',relAmpl);

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
    plot(t1t2.t1decDelay*[1 1],[minY maxY],'Color',[0 1 0])
    plot([minX maxX],relAmpl*[1 1],'Color',[0 1 0])
    hold off
end



