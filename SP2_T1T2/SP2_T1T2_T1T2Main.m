%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_T1T2Main
%% 
%%  T1 / T2 analysis of spectral series.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars flag t1t2


if ~SP2_ClearWindow
    fprintf('\n--- WARNING ---\nClearing of window figure handles failed.\n\n');
    return
end
flag.fmWin = 5;
pars.figPos = get(fmfig,'Position');
set(fmfig,'Name',' INSPECTOR: T1/T2 Analysis','Position',...
    [pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])


%--- pre-processing ---
fm.t1t2.expLbLab  = text('Position',[-0.11, 1.025],'String','Line broadening','FontSize',pars.fontSize);
fm.t1t2.expLbVal  = uicontrol('Style','Edit','Position', [160 655 50 18],'String',num2str(t1t2.lb),...
                              'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                              'TooltipString','Exponential line broadening [Hz]','FontSize',pars.fontSize);
fm.t1t2.fftCutLab  = text('Position',[-0.11, 0.985],'String','Apodization','FontSize',pars.fontSize);
fm.t1t2.fftCutVal  = uicontrol('Style','Edit','Position', [160 632 50 18],'String',num2str(t1t2.cut),...
                               'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                               'TooltipString','Spectral apodization [pts]','FontSize',pars.fontSize);
fm.t1t2.fftZfLab   = text('Position',[-0.11, 0.945],'String','Zero filling','FontSize',pars.fontSize);
fm.t1t2.fftZfVal   = uicontrol('Style','Edit','Position', [160 609 50 18],'String',num2str(t1t2.zf),...
                               'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                               'TooltipString','Spectral zero-filling [pts]','FontSize',pars.fontSize);
fm.t1t2.ppmCalibLab = text('Position',[-0.11, 0.905],'String','ppm reference','FontSize',pars.fontSize);
fm.t1t2.ppmCalib    = uicontrol('Style','Edit','Position', [160 586 50 18],'String',sprintf('%.3f',t1t2.ppmCalib),...
                                'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                'TooltipString','Number of rows in spectra display','FontSize',pars.fontSize);
fm.t1t2.phaseZeroLab = text('Position',[-0.11, 0.865],'String','Zero Phase','FontSize',pars.fontSize);
fm.t1t2.phaseZero    = uicontrol('Style','Edit','Position', [160 563 50 18],'String',num2str(t1t2.phaseZero),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                 'TooltipString','global zero-order phase offset [deg]','FontSize',pars.fontSize);

%--- load data ---
fm.t1t2.dataLoad    = uicontrol('Style','Pushbutton','String','Load & Reco','Position',[260 655 100 18],'Callback','SP2_T1T2_DataLoadAndReco;',...
                                'TooltipString','Load data from ''Data'' page,\nresort delay order (if necessary)\nand reconstruct spectra','FontSize',pars.fontSize);
fm.t1t2.showRawData = uicontrol('Style','Pushbutton','String','Show Raw Data','Position',[260 632 100 18],'Callback','SP2_T1T2_PlotRawData;',...
                                'TooltipString','Show FID/spectra raw data array','FontSize',pars.fontSize);
fm.t1t2.delayNumLab = text('Position',[0.40, 0.905],'String','Delay','FontSize',pars.fontSize);
fm.t1t2.delayNumber = uicontrol('Style','Edit','Position', [310 586 50 18],'String',num2str(t1t2.delayNumber),'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                'TooltipString',sprintf('Frequency [ppm] calibration of center (water) frequency'),'FontSize',pars.fontSize);
fm.t1t2.ppmAssign   = uicontrol('Style','Edit','Position', [370 586 50 18],'String',num2str(t1t2.ppmAssign),'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                'TooltipString',sprintf('Frequency [ppm] value to be assigned to selected peak'),'FontSize',pars.fontSize);
fm.t1t2.ppmAssignToPeak = uicontrol('Style','Pushbutton','String','Assign','Position',[420 586 55 18],...
                                    'FontSize',pars.fontSize,'Callback','SP2_T1T2_PpmAssignToPeak','FontSize',pars.fontSize,...
                                    'TooltipString',sprintf('Assign ppm value (to the left) to\nspectral position in selected spectrum'));
                     
                            
%--- analysis options ---
fm.t1t2.anaDataLab  = text('Position',[-0.11, 0.752],'String','Data','FontSize',pars.fontSize);
fm.t1t2.anaData     = uicontrol('Style','Popup','String',SP2_CellArrayToStrList(t1t2.anaDataCell,'|'),'Value',flag.t1t2AnaData,'FontSize',pars.fontSize,...
                                'Position',[145 510 140 8],'Callback','SP2_T1T2_AnaDataUpdate','TooltipString',sprintf('Data selection for T1/T2 analysis'));
fm.t1t2.anaIntOffCorr = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Offset Corr', ...
                                  'Value',flag.t1t2OffsetCorr,'Position',[.58 .713 .16 .03],'Callback','SP2_T1T2_AnaIntegOffsetCorrUpdate',...
                                  'TooltipString','Spectral offset correction based on 8-10 ppm reference window','FontSize',pars.fontSize);
fm.t1t2.anaOriginLab   = text('Position',[-0.11, 0.700],'String','Origin','FontSize',pars.fontSize);
fm.t1t2.anaFidLab      = text('Position',[0.145, 0.700],'String','FID points','FontSize',pars.fontSize);
fm.t1t2.anaFidMin      = uicontrol('Style','Edit','Position', [215 468 40 18],'String',num2str(t1t2.anaFidMin),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','First FID point to be considered');
fm.t1t2.anaFidMax      = uicontrol('Style','Edit','Position', [255 468 40 18],'String',num2str(t1t2.anaFidMax),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','Last FID point to be considered');
fm.t1t2.ppmWinLab      = text('Position',[0.53, 0.700],'String','ppm window','FontSize',pars.fontSize);
fm.t1t2.ppmWinMin      = uicontrol('Style','Edit','Position', [410 468 50 18],'String',sprintf('%.3f',t1t2.ppmWinMin),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','Minimum parts-per-million (ppm) limit of spectral analysis window');
fm.t1t2.ppmWinMax      = uicontrol('Style','Edit','Position', [460 468 50 18],'String',sprintf('%.3f',t1t2.ppmWinMax),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','Maximum parts-per-million (ppm) limit of spectral analysis window');
fm.t1t2.anaFormatReal  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Real', ...
                                   'Value',flag.t1t2AnaFormat,'Position',[.24 .62 .1 .03],'Callback','SP2_T1T2_AnaFormatRealUpdate',...
                                   'TooltipString','Analysis of real part of FID/spectral data','FontSize',pars.fontSize);
fm.t1t2.anaFormatMagn  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Magnitude', ...
                                   'Value',~flag.t1t2AnaFormat,'Position',[.34 .62 .15 .03],'Callback','SP2_T1T2_AnaFormatMagnUpdate',...
                                   'TooltipString','Analysis of magnitude part of FID/spectral data','FontSize',pars.fontSize);
fm.t1t2.anaSignFlip    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Sign Flip', ...
                                   'Value',flag.t1t2AnaSignFlip,'Position',[.55 .62 .12 .03],'Callback','SP2_T1T2_AnaSignFlipUpdate',...
                                   'TooltipString','Flip amplitude sign of first N time points','FontSize',pars.fontSize);
fm.t1t2.anaSignFlipN   = uicontrol('Style','Edit','Position', [400 437 50 18],'String',num2str(t1t2.anaSignFlipN),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','Number of time points to be sign-flipped','FontSize',pars.fontSize);
fm.t1t2.anaTimeLab     = text('Position',[-0.11, 0.596],'String','Time Vector','FontSize',pars.fontSize);
fm.t1t2.anaTimeStr     = uicontrol('Style','Edit','Position', [147 410 400 18],'String',t1t2.anaTimeStr,...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_AnaTimeStrUpdate','FontSize',pars.fontSize,...
                                   'TooltipString',sprintf('Time vector for directly assigned fitting problem [ms]'));             
fm.t1t2.anaAmpLab      = text('Position',[-0.11, 0.544],'String','Amplitude Vector','FontSize',pars.fontSize);
fm.t1t2.anaAmpStr      = uicontrol('Style','Edit','Position', [147 380 400 18],'String',t1t2.anaAmpStr,...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_AnaAmplitudeStrUpdate','FontSize',pars.fontSize,...
                                   'TooltipString',sprintf('Amplitude vector for directly assigned fitting problem [a.u.]'));             
fm.t1t2.anaAmpCalcT1   = uicontrol('Style','Pushbutton','String','T1','Position',[547 380 22 18],'Callback','SP2_T1T2_AnaAmplCalcT1',...
                                   'TooltipString','Calculate T1 amplitude vector for time delay vector','FontSize',pars.fontSize);             
fm.t1t2.anaAmpCalcT2   = uicontrol('Style','Pushbutton','String','T2','Position',[569 380 22 18],'Callback','SP2_T1T2_AnaAmplCalcT2',...
                                   'TooltipString','Calculate T2 amplitude vector for time delay vector','FontSize',pars.fontSize);
fm.t1t2.anaModeLab     = text('Position',[-0.11, 0.492],'String','TC Mode','FontSize',pars.fontSize);
fm.t1t2.anaModeFix     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Fixed', ...
                                   'Value',flag.t1t2AnaMode,'Position',[.24 .493 .12 .03],'Callback','SP2_T1T2_AnaModeFixedUpdate',...
                                   'TooltipString','Multi-exponential fit with fixed time constants','FontSize',pars.fontSize);
fm.t1t2.anaModeFlex    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Flexible', ...
                                   'Value',~flag.t1t2AnaMode,'Position',[.34 .493 .12 .03],'Callback','SP2_T1T2_AnaModeFlexibleUpdate',...
                                   'TooltipString','Multi-exponential fit with flexible time constants','FontSize',pars.fontSize);
fm.t1t2.anaTConstFlexN = uicontrol('Style','Edit','Position', [270 350 40 18],'String',num2str(t1t2.anaTConstFlexN),...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                   'TooltipString','Number of time constants for flexible fitting');
fm.t1t2.anaModeFlex1Fix   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','One Fix','FontSize',pars.fontSize, ...
                                      'Value',flag.t1t2AnaFlex1Fix,'Position',[.55 .493 .12 .03],'Callback','SP2_T1T2_AnaModeFlex1FixUpdate');
fm.t1t2.anaTConstFlex1Fix = uicontrol('Style','Edit','Position', [400 350 50 18],'String',num2str(t1t2.anaTConstFlex1Fix),...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                      'TooltipString','Single fixed time constant for flexible fitting [ms]');
fm.t1t2.anaTConstLab   = text('Position',[-0.11, 0.440],'String',sprintf('TC Selection (%.0f)',t1t2.anaTConstN),'FontSize',pars.fontSize);
fm.t1t2.anaTConstStr   = uicontrol('Style','Edit','Position', [147 320 400 18],'String',t1t2.anaTConstStr,...
                                   'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_AnaTConstStrUpdate','FontSize',pars.fontSize,...
                                   'TooltipString',sprintf('TC selection for metabolite/T1T2 fitting [ms]'));             
fm.t1t2.anaFitLab      = text('Position',[-0.11, 0.388],'String','Fit Mode','FontSize',pars.fontSize);
fm.t1t2.anaFitOffset   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Offset', ...
                                   'Value',flag.t1t2AnaFitOffset,'Position',[.24 .413 .12 .03],'Callback','SP2_T1T2_AnaFitOffsetUpdate',...
                                   'TooltipString','Include potential offset in T1/T2 analysis','FontSize',pars.fontSize);
                                 
%--- T1 analysis ---
fm.t1t2.doTConstAna      = uicontrol('Style','Pushbutton','String','Do Analysis','Position',[400 290 80 18],'Callback','SP2_T1T2_DoTConstAnalysis;',...
                                     'TooltipString','Perform time constant analysis','FontSize',pars.fontSize);
                       
% %--- analysis/visualization: T1 components (incl. sut1t2ed T1 ranges) ---
% fm.t1t2.tConstDisplLab   = text('Position',[-0.11, 0.27],'String','TC Component','FontSize',pars.fontSize);
% fm.t1t2.tConstFidSingle  = uicontrol('Style','Pushbutton','String','FID','Position',[125 225 60 18],'Callback','SP2_T1T2_T1ShowFidSingle(1);',...
%                                  'TooltipString','Show single TC component');
% fm.t1t2.tConstSpecSingle = uicontrol('Style','Pushbutton','String','Spec','Position',[185 225 60 18],'Callback','SP2_T1T2_T1ShowSpecSingle(1);',...
%                                  'TooltipString','Show single TC component');
% fm.t1t2.tConstSelDecr    = uicontrol('Style','Pushbutton','String','<<','Position',[125 200 30 18],'Callback','SP2_T1T2_T1SelectDecr',...
%                                  'TooltipString','Scroll backward through the TC components');
% fm.t1t2.tConstSelect     = uicontrol('Style','Edit','Position', [155 200 40 18],'String',num2str(t1t2.tConstSelect),...
%                                  'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_TCSelectUpdate',...
%                                  'TooltipString','Selected T1 component to be displayed');
% fm.t1t2.tConstSelIncr    = uicontrol('Style','Pushbutton','String','>>','Position',[195 200 30 18],'Callback','SP2_T1T2_T1SelectIncr',...
%                                  'TooltipString','Scroll upwards through the TC components');
% fm.t1t2.tConstShowSuper  = uicontrol('Style','Pushbutton','String','Superpos','Position',[315 225 75 18],'Callback','SP2_T1T2_T1ShowSpecSuper(1);',...
%                                  'TooltipString','Visualize spectrum superposition');
% fm.t1t2.tConstShowArray  = uicontrol('Style','Pushbutton','String','Array','Position',[390 225 50 18],'Callback','SP2_T1T2_T1ShowSpecArray(1);',...
%                                  'TooltipString','Visualize spectrum array');
% fm.t1t2.tConstShowSum    = uicontrol('Style','Pushbutton','String','Sum','Position',[440 225 50 18],'Callback','SP2_T1T2_T1ShowSpecSum(1);',...
%                                  'TooltipString','Visualize sut1t2ation spectrum');
% fm.t1t2.tConstShowSubtr  = uicontrol('Style','Pushbutton','String','Subract','Position',[490 225 65 18],'Callback','SP2_T1T2_T1ShowSpecSubtract(1);',...
%                                  'TooltipString','Visualize subraction spectrum');
                             
                             
%--- result display ---
fm.t1t2.amplShowLab    = text('Position',[-0.11, 0.105],'String','Amplitude','FontSize',pars.fontSize);
fm.t1t2.amplShowAuto   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.t1t2AmplShow,...
                                 'String','Auto','Position',[.19 .18 .2 .03],'Callback','SP2_T1T2_AmplShowAutoUpdate',...
                                 'TooltipString',sprintf('Automatic determination of amplitude range'),'FontSize',pars.fontSize);
fm.t1t2.amplShowDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',~flag.t1t2AmplShow,...
                                 'String','Direct','Position',[.29 .18 .03 .03],'Callback','SP2_T1T2_AmplShowDirectUpdate',...
                                 'TooltipString',sprintf('Direct assignment of amplitude range'),'FontSize',pars.fontSize);
fm.t1t2.amplShowMin    = uicontrol('Style','Edit','Position', [200 128 50 18],'String',num2str(t1t2.amplShowMin),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                 'TooltipString','Lower amplitude limit','FontSize',pars.fontSize);
fm.t1t2.amplShowMax    = uicontrol('Style','Edit','Position', [250 128 50 18],'String',num2str(t1t2.amplShowMax),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                 'TooltipString','Upper amplitude limit','FontSize',pars.fontSize);
fm.t1t2.ppmShowLab     = text('Position',[0.57, 0.105],'String','Frequency','FontSize',pars.fontSize);
fm.t1t2.ppmShowFull    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Full','FontSize',pars.fontSize, ...
                                 'Value',flag.t1t2PpmShow,'Position',[.695 .18 .12 .03],'Callback','SP2_T1T2_PpmShowFullUpdate');
fm.t1t2.ppmShowDirect  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','FontSize',pars.fontSize, ...
                                 'Value',~flag.t1t2PpmShow,'Position',[.775 .18 .03 .03],'Callback','SP2_T1T2_PpmShowDirectUpdate');
fm.t1t2.ppmShowMin     = uicontrol('Style','Edit','Position', [495 128 40 18],'String',sprintf('%.2f',t1t2.ppmShowMin),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate','FontSize',pars.fontSize,...
                                 'TooltipString','Lower amplitude limit');
fm.t1t2.ppmShowMax     = uicontrol('Style','Edit','Position', [535 128 40 18],'String',sprintf('%.2f',t1t2.ppmShowMax),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_T1T2_ParsUpdate',...
                                 'TooltipString','Upper amplitude limit','FontSize',pars.fontSize);
fm.t1t2.formatLab   = text('Position',[-0.11, 0.055],'String','Format','FontSize',pars.fontSize);
fm.t1t2.formatReal  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Real','FontSize',pars.fontSize, ...
                                'Value',flag.t1t2Format,'Position',[.19 .138 .2 .03],'Callback','SP2_T1T2_FormatRealUpdate');
fm.t1t2.formatMagn  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Magn','FontSize',pars.fontSize, ...
                                'Value',~flag.t1t2Format,'Position',[.29 .138 .2 .03],'Callback','SP2_T1T2_FormatMagnUpdate');

%--- T1 decay analysis ---                            
fm.t1t2.t1DecT1Lab     = text('Position',[0.0, -0.055],'String','T1','FontSize',pars.fontSize);
fm.t1t2.t1DecT1        = uicontrol('Style','Edit','Position', [103 37 50 18],'String',num2str(t1t2.t1decT1),'BackGroundColor',pars.bgColor,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','T1 time constant [ms]','FontSize',pars.fontSize);
fm.t1t2.t1DecDelayLab  = text('Position',[0.25, -0.055],'String','Delay','FontSize',pars.fontSize);
fm.t1t2.t1DecDelay     = uicontrol('Style','Edit','Position', [235 37 50 18],'String',num2str(t1t2.t1decDelay),'BackGroundColor',pars.bgColor,'FontSize',pars.fontSize,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','Delay [ms] for which the relative amplitude will be determined');
fm.t1t2.t1DecCalcScale = uicontrol('Style','Pushbutton','String','Calc T1 Scale','Position',[290 37 80 18],'Callback','SP2_T1T2_T1DecayCalcScale(1);',...
                                   'TooltipString','Calculation of the relative amplitude at the assigned delay','FontSize',pars.fontSize);
fm.t1t2.t1DecScaleLab  = text('Position',[0.68, -0.055],'String','Rel. Ampl.','FontSize',pars.fontSize);
fm.t1t2.t1DecScale     = uicontrol('Style','Edit','Position', [460 37 40 18],'String',num2str(t1t2.t1decScale),'BackGroundColor',pars.bgColor,'FontSize',pars.fontSize,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','Relative amplitude [1] for which the corresponding delay will be determined');
fm.t1t2.t1DecCalcDelay = uicontrol('Style','Pushbutton','String','Calc T1 Delay','Position',[505 37 80 18],'Callback','SP2_T1T2_T1DecayCalcDelay(1);',...
                                   'TooltipString','Calculation of delay at which the assigned relative amplitude is reached','FontSize',pars.fontSize);
                            
%--- T2 decay analysis ---                            
fm.t1t2.t2DecT2Lab     = text('Position',[0.0, -0.1],'String','T2','FontSize',pars.fontSize);
fm.t1t2.t2DecT2        = uicontrol('Style','Edit','Position', [103 12 50 18],'String',num2str(t1t2.t2decT2),'BackGroundColor',pars.bgColor,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','T2 time constant [ms]','FontSize',pars.fontSize);
fm.t1t2.t2DecDelayLab  = text('Position',[0.25, -0.1],'String','Delay','FontSize',pars.fontSize);
fm.t1t2.t2DecDelay     = uicontrol('Style','Edit','Position', [235 12 50 18],'String',num2str(t1t2.t2decDelay),'BackGroundColor',pars.bgColor,'FontSize',pars.fontSize,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','Delay [ms] for which the relative amplitude will be determined');
fm.t1t2.t2DecCalcScale = uicontrol('Style','Pushbutton','String','Calc T2 Scale','Position',[290 12 80 18],'Callback','SP2_T1T2_T2DecayCalcScale(1);',...
                                   'TooltipString','Calculation of the relative amplitude at the assigned delay','FontSize',pars.fontSize);
fm.t1t2.t2DecScaleLab  = text('Position',[0.68, -0.1],'String','Rel. Ampl.','FontSize',pars.fontSize);
fm.t1t2.t2DecScale     = uicontrol('Style','Edit','Position', [460 12 40 18],'String',num2str(t1t2.t2decScale),'BackGroundColor',pars.bgColor,'FontSize',pars.fontSize,...
                                   'Callback','SP2_T1T2_ParsUpdate','TooltipString','Relative amplitude [1] for which the corresponding delay will be determined');
fm.t1t2.t2DecCalcDelay = uicontrol('Style','Pushbutton','String','Calc T2 Delay','Position',[505 12 80 18],'Callback','SP2_T1T2_T2DecayCalcDelay(1);',...
                                   'TooltipString','Calculation of delay at which the assigned relative amplitude is reached','FontSize',pars.fontSize);
                            
                            
%--- window update ---                           
SP2_T1T2_T1T2WinUpdate

end
