%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [timeVec,scaleVec] = SP2_T1T2_T2DecayCalcScale( f_show )
%%
%%	Relative signal as a result of T2 decay.
%%  (Simple exp decay)
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2


%--- find relative amplitude ---
% fit:
% relAmpl = SP2_BestApprox(scaleVec,timeVec,t1t2.t2decDelay);
% analytical:
relAmpl = exp(-t1t2.t2decDelay/t1t2.t2decT2);

%--- consistency checks ---
tMax    = 2*t1t2.t2decDelay;
timeVec = 0:tMax/1000:tMax;

%--- relative amplitude calculation ---
scaleVec = exp(-timeVec/t1t2.t2decT2);

%--- info printout ---
fprintf('\nT2        = %.5f ms\n',t1t2.t2decT2);
fprintf('Delay     = %.5f ms\n',t1t2.t2decDelay);
fprintf('Amplitude = %.5f a.u. (output)\n\n',relAmpl);

%--- figure creation ---
if f_show
    t2DecayFh = figure;
    set(t2DecayFh,'NumberTitle','off','Name',' T2 Decay Analysis','Position',[314 114 700 500],'Color',[1 1 1]);
    plot(timeVec,scaleVec);
    xlabel('Delays [ms]')
    ylabel('Amplitude [a.u.]')
    [minX, maxX, minY, maxY] = SP2_IdealAxisValues(timeVec,scaleVec);
    axis([minX maxX minY maxY])
    hold on
    plot(t1t2.t2decDelay*[1 1],[minY maxY],'Color',[0 1 0])
    plot([minX maxX],relAmpl*[1 1],'Color',[0 1 0])
    hold off
end




end
