%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_ParsUpdate
%% 
%%  Parameter update for quality assessment page.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm t1t2


%--- exponential line braodening ---
t1t2.lb = str2num(get(fm.t1t2.expLbVal,'String'));
if isempty(t1t2.lb)
    t1t2.lb = 0;
end
set(fm.t1t2.expLbVal,'String',num2str(t1t2.lb))

%--- FID apodization ---
t1t2.cut = str2num(get(fm.t1t2.fftCutVal,'String'));
if isempty(t1t2.cut)
    t1t2.cut = 1024;
end
t1t2.cut = max(t1t2.cut,10);
set(fm.t1t2.fftCutVal,'String',num2str(t1t2.cut))

%--- zero filling ---
t1t2.zf = str2num(get(fm.t1t2.fftZfVal,'String'));
if isempty(t1t2.zf)
    t1t2.zf = 16384;
end
t1t2.zf = max(t1t2.zf,1024);
set(fm.t1t2.fftZfVal,'String',num2str(t1t2.zf))

%--- ppm calibration ---
t1t2.ppmCalib = str2num(get(fm.t1t2.ppmCalib,'String'));
if isempty(t1t2.ppmCalib)
    t1t2.ppmCalib = 4.65;
end
set(fm.t1t2.ppmCalib,'String',sprintf('%.3f',t1t2.ppmCalib))

%--- zero order phase offset ---
t1t2.phaseZero = str2num(get(fm.t1t2.phaseZero,'String'));
if isempty(t1t2.phaseZero)
    t1t2.phaseZero = 0;
end
set(fm.t1t2.phaseZero,'String',num2str(t1t2.phaseZero))

%--- delay number ---
t1t2.delayNumber = str2num(get(fm.t1t2.delayNumber,'String'));
if isempty(t1t2.delayNumber)
    t1t2.delayNumber = 1;
end
t1t2.delayNumber = max(t1t2.delayNumber,1);
set(fm.t1t2.delayNumber,'String',num2str(t1t2.delayNumber))

%--- ppm assignment ---
t1t2.ppmAssign = str2num(get(fm.t1t2.ppmAssign,'String'));
if isempty(t1t2.ppmAssign)
    t1t2.ppmAssign = 2.01;
end
set(fm.t1t2.ppmAssign,'String',sprintf('%.3f',t1t2.ppmAssign))

%--- first FID point ---
t1t2.anaFidMin = str2num(get(fm.t1t2.anaFidMin,'String'));
if isempty(t1t2.anaFidMin)
    t1t2.anaFidMin = 1;
end
t1t2.anaFidMin = min(max(round(t1t2.anaFidMin),1),t1t2.anaFidMax);
set(fm.t1t2.anaFidMin,'String',num2str(t1t2.anaFidMin))

%--- last FID point ---
t1t2.anaFidMax = str2num(get(fm.t1t2.anaFidMax,'String'));
if isempty(t1t2.anaFidMax)
    t1t2.anaFidMax = 5;
end
t1t2.anaFidMax = max(round(t1t2.anaFidMax),t1t2.anaFidMin);
set(fm.t1t2.anaFidMax,'String',num2str(t1t2.anaFidMax))

%--- minimum ppm ---
t1t2.ppmWinMin = str2num(get(fm.t1t2.ppmWinMin,'String'));
if isempty(t1t2.ppmWinMin)
    t1t2.ppmWinMin = 0;
end
t1t2.ppmWinMin = min(t1t2.ppmWinMin,t1t2.ppmWinMax-0.01);
set(fm.t1t2.ppmWinMin,'String',num2str(t1t2.ppmWinMin))

%--- maximum ppm ---
t1t2.ppmWinMax = str2num(get(fm.t1t2.ppmWinMax,'String'));
if isempty(t1t2.ppmWinMax)
    t1t2.ppmWinMax = 10;
end
t1t2.ppmWinMax = max(t1t2.ppmWinMax,t1t2.ppmWinMin+0.01);
set(fm.t1t2.ppmWinMax,'String',num2str(t1t2.ppmWinMax))

%--- N sign flip ---
t1t2.anaSignFlipN = str2num(get(fm.t1t2.anaSignFlipN,'String'));
if isempty(t1t2.anaSignFlipN)
    t1t2.anaSignFlipN = 1;
end
t1t2.anaSignFlipN = max(round(t1t2.anaSignFlipN),1);
set(fm.t1t2.anaSignFlipN,'String',num2str(t1t2.anaSignFlipN))

%--- number of flexible T1/T2 components ---
t1t2.anaTConstFlexN = str2num(get(fm.t1t2.anaTConstFlexN,'String'));
if isempty(t1t2.anaTConstFlexN)
    t1t2.anaTConstFlexN = 4;
end
t1t2.anaTConstFlexN = max(round(t1t2.anaTConstFlexN),1);
set(fm.t1t2.anaTConstFlexN,'String',num2str(t1t2.anaTConstFlexN))

%--- single fixed T1/T2 time constant ---
t1t2.anaTConstFlex1Fix = str2num(get(fm.t1t2.anaTConstFlex1Fix,'String'));
if isempty(t1t2.anaTConstFlex1Fix)
    t1t2.anaTConstFlex1Fix = 0.1;
end
t1t2.anaTConstFlex1Fix = max(t1t2.anaTConstFlex1Fix,0.001);
set(fm.t1t2.anaTConstFlex1Fix,'String',num2str(t1t2.anaTConstFlex1Fix))

%--- minimum amplitude ---
t1t2.amplShowMin = str2num(get(fm.t1t2.amplShowMin,'String'));
if isempty(t1t2.amplShowMin)
    t1t2.amplShowMin = -10000;
end
t1t2.amplShowMin = min(t1t2.amplShowMin,t1t2.amplShowMax);
set(fm.t1t2.amplShowMin,'String',num2str(t1t2.amplShowMin))

%--- maximum amplitude ---
t1t2.amplShowMax = str2num(get(fm.t1t2.amplShowMax,'String'));
if isempty(t1t2.amplShowMax)
    t1t2.amplShowMax = 10000;
end
t1t2.amplShowMax = max(t1t2.amplShowMin,t1t2.amplShowMax);
set(fm.t1t2.amplShowMax,'String',num2str(t1t2.amplShowMax))

%--- minimum amplitude ---
t1t2.ppmShowMin = str2num(get(fm.t1t2.ppmShowMin,'String'));
if isempty(t1t2.ppmShowMin)
    t1t2.ppmShowMin = 0;
end
t1t2.ppmShowMin = min(t1t2.ppmShowMin,t1t2.ppmShowMax);
set(fm.t1t2.ppmShowMin,'String',sprintf('%.2f',t1t2.ppmShowMin))

%--- maximum amplitude ---
t1t2.ppmShowMax = str2num(get(fm.t1t2.ppmShowMax,'String'));
if isempty(t1t2.ppmShowMax)
    t1t2.ppmShowMax = 5;
end
t1t2.ppmShowMax = max(t1t2.ppmShowMin,t1t2.ppmShowMax);
set(fm.t1t2.ppmShowMax,'String',sprintf('%.2f',t1t2.ppmShowMax))

%--- T1 decay: time constant ---
t1t2.t1decT1 = str2num(get(fm.t1t2.t1DecT1,'String'));
if isempty(t1t2.t1decT1)
    t1t2.t1decT1 = 1000;
end
t1t2.t1decT1 = max(t1t2.t1decT1,1);
set(fm.t1t2.t1DecT1,'String',num2str(t1t2.t1decT1))

%--- T1 decay: delay ---
t1t2.t1decDelay = str2num(get(fm.t1t2.t1DecDelay,'String'));
if isempty(t1t2.t1decDelay)
    t1t2.t1decDelay = 500;
end
t1t2.t1decDelay = min(max(t1t2.t1decDelay,1),1e5);
set(fm.t1t2.t1DecDelay,'String',num2str(t1t2.t1decDelay))

%--- T1 decay: scale ---
t1t2.t1decScale = str2num(get(fm.t1t2.t1DecScale,'String'));
if isempty(t1t2.t1decScale)
    t1t2.t1decScale = 0.0;
end
t1t2.t1decScale = max(min(t1t2.t1decScale,1),-1);
set(fm.t1t2.t1DecScale,'String',num2str(t1t2.t1decScale))

%--- T2 decay: time constant ---
t1t2.t2decT2 = str2num(get(fm.t1t2.t2DecT2,'String'));
if isempty(t1t2.t2decT2)
    t1t2.t2decT2 = 100;
end
t1t2.t2decT2 = max(t1t2.t2decT2,1);
set(fm.t1t2.t2DecT2,'String',num2str(t1t2.t2decT2))

%--- T2 decay: delay ---
t1t2.t2decDelay = str2num(get(fm.t1t2.t2DecDelay,'String'));
if isempty(t1t2.t2decDelay)
    t1t2.t2decDelay = 100;
end
t1t2.t2decDelay = min(max(t1t2.t2decDelay,1),1e5);
set(fm.t1t2.t2DecDelay,'String',num2str(t1t2.t2decDelay))

%--- T2 decay: scale ---
t1t2.t2decScale = str2num(get(fm.t1t2.t2DecScale,'String'));
if isempty(t1t2.t2decScale)
    t1t2.t2decScale = 0.5;
end
t1t2.t2decScale = max(min(t1t2.t2decScale,1),1e-5);
set(fm.t1t2.t2DecScale,'String',num2str(t1t2.t2decScale))


%--- window update ---
SP2_T1T2_T1T2WinUpdate
