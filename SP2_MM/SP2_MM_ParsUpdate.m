%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ParsUpdate
%% 
%%  Parameter update for quality assessment page.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- exponential line braodening ---
mm.lb = str2num(get(fm.mm.expLbVal,'String'));
if isempty(mm.lb)
    mm.lb = 0;
end
set(fm.mm.expLbVal,'String',num2str(mm.lb))

%--- FID apodization ---
mm.cut = str2num(get(fm.mm.fftCutVal,'String'));
if isempty(mm.cut)
    mm.cut = 1024;
end
mm.cut = max(mm.cut,10);
set(fm.mm.fftCutVal,'String',num2str(mm.cut))

%--- zero filling ---
mm.zf = str2num(get(fm.mm.fftZfVal,'String'));
if isempty(mm.zf)
    mm.zf = 16384;
end
mm.zf = max(mm.zf,1024);
set(fm.mm.fftZfVal,'String',num2str(mm.zf))

%--- ppm calibration ---
mm.ppmCalib = str2num(get(fm.mm.ppmCalib,'String'));
if isempty(mm.ppmCalib)
    mm.ppmCalib = 4.65;
end
set(fm.mm.ppmCalib,'String',sprintf('%.3f',mm.ppmCalib))

%--- zero order phase offset ---
mm.phaseZero = str2num(get(fm.mm.phaseZero,'String'));
if isempty(mm.phaseZero)
    mm.phaseZero = 0;
end
set(fm.mm.phaseZero,'String',num2str(mm.phaseZero))

%--- box car window average ---
mm.boxCar = str2num(get(fm.mm.boxCar,'String'));
if isempty(mm.boxCar)
    mm.boxCar = 1;
end
mm.boxCar = min(max(round(mm.boxCar),1),100);
set(fm.mm.boxCar,'String',num2str(mm.boxCar))
if isfield(mm,'sw_h')
    mm.boxCarHz = mm.boxCar * mm.sw_h/mm.zf;      % frequency width of filter
end

%--- data extension factor ---
mm.dataExtFac = str2num(get(fm.mm.dataExtFac,'String'));
if isempty(mm.dataExtFac)
    mm.dataExtFac = 1;
end
mm.dataExtFac = min(max(round(mm.dataExtFac),1),5);
set(fm.mm.dataExtFac,'String',num2str(mm.dataExtFac))

%--- minimum saturation-recovery delay ---
mm.sim.delayMin = str2num(get(fm.mm.simDelayMin,'String'));
if isempty(mm.sim.delayMin)
    mm.sim.delayMin = 0.1;
end
set(fm.mm.simDelayMin,'String',num2str(mm.sim.delayMin))

%--- maximum saturation-recovery delay ---
mm.sim.delayMax = str2num(get(fm.mm.simDelayMax,'String'));
if isempty(mm.sim.delayMax)
    mm.sim.delayMax = 5;
end
set(fm.mm.simDelayMax,'String',num2str(mm.sim.delayMax))

%--- number of saturation-recovery delays ---
mm.sim.delayN = str2num(get(fm.mm.simDelayN,'String'));
if isempty(mm.sim.delayN)
    mm.sim.delayN = 15;
end
mm.sim.delayN = max(round(mm.sim.delayN),5);
set(fm.mm.simDelayN,'String',num2str(mm.sim.delayN))

%--- minimum frequency ---
mm.anaFrequMin = str2num(get(fm.mm.anaFrequMin,'String'));
if isempty(mm.anaFrequMin)
    mm.anaFrequMin = 0;
end
mm.anaFrequMin = min(mm.anaFrequMin,mm.anaFrequMax-0.02);
set(fm.mm.anaFrequMin,'String',num2str(mm.anaFrequMin))

%--- maximum frequency ---
mm.anaFrequMax = str2num(get(fm.mm.anaFrequMax,'String'));
if isempty(mm.anaFrequMax)
    mm.anaFrequMax = 10;
end
mm.anaFrequMax = max(mm.anaFrequMin+0.02,mm.anaFrequMax);
set(fm.mm.anaFrequMax,'String',num2str(mm.anaFrequMax))

%--- number of flexible T1 components ---
mm.anaTOneFlexN = str2num(get(fm.mm.anaTOneFlexN,'String'));
if isempty(mm.anaTOneFlexN)
    mm.anaTOneFlexN = 4;
end
mm.anaTOneFlexN = max(round(mm.anaTOneFlexN),1);
set(fm.mm.anaTOneFlexN,'String',num2str(mm.anaTOneFlexN))

%--- maximum of short T1 components ---
mm.anaTOneFlexThMin = str2num(get(fm.mm.anaTOneFlexThMin,'String'));
if isempty(mm.anaTOneFlexThMin)
    mm.anaTOneFlexThMin = 0.5;
end
set(fm.mm.anaTOneFlexThMin,'String',num2str(mm.anaTOneFlexThMin))

%--- minimum of long T1 components ---
mm.anaTOneFlexThMax = str2num(get(fm.mm.anaTOneFlexThMax,'String'));
if isempty(mm.anaTOneFlexThMax)
    mm.anaTOneFlexThMax = 2;
end
set(fm.mm.anaTOneFlexThMax,'String',num2str(mm.anaTOneFlexThMax))

%--- number of optimization steps ---
mm.anaOptN = str2num(get(fm.mm.anaOptN,'String'));
if isempty(mm.anaOptN)
    mm.anaOptN = 1;
end
mm.anaOptN = max(round(mm.anaOptN),1);
set(fm.mm.anaOptN,'String',num2str(mm.anaOptN))

%--- initial amplitude range ---
mm.anaOptAmpRg = str2num(get(fm.mm.anaOptAmpRg,'String'));
if isempty(mm.anaOptAmpRg)
    mm.anaOptAmpRg = 0.5;
end
mm.anaOptAmpRg = min(max(mm.anaOptAmpRg,0.001),1);
set(fm.mm.anaOptAmpRg,'String',num2str(mm.anaOptAmpRg))

%--- initial amplitude reduction ---
mm.anaOptAmpRed = str2num(get(fm.mm.anaOptAmpRed,'String'));
if isempty(mm.anaOptAmpRed)
    mm.anaOptAmpRed = 0.5;
end
mm.anaOptAmpRed = min(max(mm.anaOptAmpRed,0.001),1);
set(fm.mm.anaOptAmpRed,'String',num2str(mm.anaOptAmpRed))

%--- minimum amplitude ---
mm.amplShowMin = str2num(get(fm.mm.amplShowMin,'String'));
if isempty(mm.amplShowMin)
    mm.amplShowMin = -10000;
end
mm.amplShowMin = min(mm.amplShowMin,mm.amplShowMax);
set(fm.mm.amplShowMin,'String',num2str(mm.amplShowMin))

%--- maximum amplitude ---
mm.amplShowMax = str2num(get(fm.mm.amplShowMax,'String'));
if isempty(mm.amplShowMax)
    mm.amplShowMax = 10000;
end
mm.amplShowMax = max(mm.amplShowMin,mm.amplShowMax);
set(fm.mm.amplShowMax,'String',num2str(mm.amplShowMax))

%--- minimum amplitude ---
mm.ppmShowMin = str2num(get(fm.mm.ppmShowMin,'String'));
if isempty(mm.ppmShowMin)
    mm.ppmShowMin = 0;
end
mm.ppmShowMin = min(mm.ppmShowMin,mm.ppmShowMax(1));
set(fm.mm.ppmShowMin,'String',sprintf('%.2f',mm.ppmShowMin))

%--- maximum amplitude ---
mm.ppmShowMax = str2num(get(fm.mm.ppmShowMax,'String'));
if isempty(mm.ppmShowMax)
    mm.ppmShowMax = 5;
end
mm.ppmShowMax = max(mm.ppmShowMin(1),mm.ppmShowMax);
set(fm.mm.ppmShowMax,'String',sprintf('%.2f',mm.ppmShowMax))

% %--- check data existence ---
% if ~isfield(mm,'spec')
%     if ~SP2_MM_DataLoad
%         return
%     end
% end

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_SatRecShowSpecSubtract(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);
SP2_MM_T1ShowSpecSubtract(0);
SP2_MM_T1ShowSpec2D(0);
% SP2_MM_2DShowSum(0);
% SP2_MM_2DShowSubtract(0);
% SP2_MM_2DShowAndDefine(0);

%--- figure update ---
SP2_MM_ExpFitAnalysis(0);

%--- window update ---
SP2_MM_MacroWinUpdate

end
