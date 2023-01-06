%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [timeVec,scaleVec] = SP2_T1T2_T2DecayCalcDelay( f_show )
%%
%%	Relative signal as a result of T2 decay.
%%  (Simple exp decay)
%%
%%  08-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2


%--- consistency check ---
if t1t2.t2decScale==0
    fprintf('Relative amplitude zero is not possible. Program aborted.\n');
end

%--- delay calculation ---
% fit:
% t2Delay = SP2_BestApprox(timeVec,scaleVec,t1t2.t2decScale);
% analytical:
t2Delay = -t1t2.t2decT2*log(t1t2.t2decScale);

%--- consistency checks ---
tMax    = 2*t2Delay;
timeVec = 0:tMax/500:tMax;

%--- relative amplitude calculation ---
scaleVec = exp(-timeVec/t1t2.t2decT2);

%--- info printout ---
fprintf('\nT2        = %.5f ms\n',t1t2.t2decT2);
fprintf('Amplitude = %.5f a.u.\n',t1t2.t2decScale);
fprintf('Delay     = %.5f ms (output)\n\n',t2Delay);

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
    plot(t2Delay*[1 1],[minY maxY],'Color',[0 1 0])
    plot([minX maxX],t1t2.t2decScale*[1 1],'Color',[0 1 0])
    hold off
end





end
