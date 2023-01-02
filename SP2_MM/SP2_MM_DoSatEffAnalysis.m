%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  SP2_MM_DoSatEffAnalysis
%%
%%  Efficiency analysis of saturation module.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm

FCTNAME = 'SP2_MM_DoSatEffAnalysis';



%--- init read flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(mm,'spec')
    if ~SP2_MM_DataReco
        return
    end
end


mm.satRecDelays = mm.satRecDelays - 0.021;

%--- simple maximum search ---
[mm.effMaxVal,mm.effMaxInd] = max(real(mm.spec));

%--- parameter init ---
fineN         = 500;                                                    % number of fine resolution points
mm.satRecFine = 0:max(mm.satRecDelays)/(fineN-1):max(mm.satRecDelays);  % delay grid for fitting result

% %--- single T1 fit ---
% ub = 1e10*ones(1,3);        % upper bound
% lb = [0 -1e10 0];           % lower bound
% coeffStart = [mm.effMaxVal(end) 0 1];    % initial estimate
% options = optimset('Display','on');
% [mm.effT1,mm.effRes2norm] = lsqcurvefit('SP2_MM_FunExp01_EffAna03',coeffStart,mm.satRecDelays,mm.effMaxVal,lb,ub,options);
% mm.effFit     = SP2_MM_FunExp01_EffAna03(mm.effT1,mm.satRecDelays);
% mm.effFitFine = SP2_MM_FunExp01_EffAna03(mm.effT1,mm.satRecFine);
%--- single T1 fit ---
ub = 1e10*ones(1,3);        % upper bound
lb = [0 -1e10 0];           % lower bound
coeffStart = [mm.effMaxVal(end) 0 1];    % initial estimate
options = optimset('Display','on');
[mm.effT1,mm.effRes2norm] = lsqcurvefit('SP2_MM_FunExp01_EffAna03',coeffStart,mm.satRecDelays,mm.effMaxVal,lb,ub,options);
mm.effFit     = SP2_MM_FunExp01_EffAna03(mm.effT1,mm.satRecDelays);
mm.effFitFine = SP2_MM_FunExp01_EffAna03(mm.effT1,mm.satRecFine);

%--- result analysis: efficiency & offset ---
amplOffset     = mm.effFitFine(1);      % starting point is 0 sec
satDelayOffset = SP2_BestApprox(mm.satRecFine,mm.effFitFine,0);

%--- result visualization ---
fh = figure;
set(fh,'NumberTitle','off','Name',sprintf(' Reference T1 Analysis: coeff %f/%f/%f',mm.effT1(1),mm.effT1(2),mm.effT1(3)))
hold on
plot(mm.satRecDelays,mm.effFit,'r*')
plot(mm.satRecDelays,mm.effMaxVal,'go')
plot(mm.satRecFine,mm.effFitFine)
hold off
xlabel('Saturation Delay [sec]')
ylabel('Amplitude [a.u.]')
% [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(mm.satRecDelays,mm.effFit);
[plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValuesXGap(mm.satRecDelays,mm.effMaxVal);
axis(plotLim)
lh1 = line([plotLim(1) plotLim(2)],[0 0]);
set(lh1,'Color',[0 1 0])
lh2 = line([0 0],[plotLim(3) plotLim(4)]);
set(lh2,'Color',[0 1 0])
lh3 = line([satDelayOffset satDelayOffset],[plotLim(3) plotLim(4)]);
set(lh3,'Color',[1 0 0])

%--- info printout ---
fprintf('T1 analysis: coefficients %.1f/%.4f/%.4f\n',mm.effT1(1),mm.effT1(2),mm.effT1(3));
fprintf('amplitude offset %.1f (%.1f%% of amplitude)\n',amplOffset,100*amplOffset/mm.effT1(1));
fprintf('sat. delay offset %.4f sec\n',satDelayOffset);


