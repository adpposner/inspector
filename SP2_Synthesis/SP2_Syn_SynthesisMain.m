%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_SynthesisMain
%% 
%%  Main window for the spectral synthesis.
%%  1) combination of existing FIDs, e.g. to generate an 1H brain spectrum
%%  2) synthesis of FIDs (singlets, multiplets,...)
%%  3) potential future extension by proper density matrix computations...
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars syn flag


if ~SP2_ClearWindow
    fprintf('\n--- WARNING ---\nClearing of window figure handles failed.\n\n');
    return
end
flag.fmWin = 8;
figPos = get(fmfig,'Position');
set(fmfig,'Name',' INSPECTOR: Spectral Synthesis Tool','Position',...
    [figPos(1) figPos(2) pars.mainDims(3) pars.mainDims(4)])



%--------------------------------------------------------------------------
%---    S I M U L A T I O N                                             ---
%--------------------------------------------------------------------------
fm.syn.synLab  = text('Position',[-0.15, 1.05],'String','Synthesis','FontWeight','bold');

%--- simulation parameters ---
fm.syn.sfLab       = text('Position',[-0.13, 0.9810],'String','SF','FontSize',pars.fontSize);
fm.syn.sf          = uicontrol('Style','Edit','Position', [55 630 55 18],'String',num2str(syn.sf),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                               'TooltipString',sprintf('Larmor frequency [MHz]'),'FontSize',pars.fontSize);
fm.syn.ppmCalibLab = text('Position',[0.132, 0.9810],'String','Calib','FontSize',pars.fontSize);
fm.syn.ppmCalib    = uicontrol('Style','Edit','Position', [185 630 55 18],'String',num2str(syn.ppmCalib),...
                               'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                               'TooltipString',sprintf('synthesizer frequency calibration [ppm]'),'FontSize',pars.fontSize); 
fm.syn.sw_hLab     = text('Position',[-0.13, 0.9371],'String','BW','FontSize',pars.fontSize);
fm.syn.sw_h        = uicontrol('Style','Edit','Position', [55 605 55 18],'String',num2str(syn.sw_h),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                               'TooltipString',sprintf('Bandwidth [Hz]'),'FontSize',pars.fontSize);
fm.syn.nspecCLab   = text('Position',[0.132, 0.9371],'String','# Pts','FontSize',pars.fontSize);
fm.syn.nspecCBasic = uicontrol('Style','Edit','Position', [185 605 55 18],'String',num2str(syn.nspecCBasic),...
                               'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                               'TooltipString',sprintf('Number of complex points of original synthesis before processing'),'FontSize',pars.fontSize);                
                           
%--- noise characteristics ---                              
fm.syn.noise         = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Add Noise', ...
                                 'Value',flag.synNoise,'Position',[.03 .810 .2 .03],'Callback','SP2_Syn_NoiseUpdate','FontSize',pars.fontSize);
fm.syn.noiseAmp      = uicontrol('Style','Edit','Position', [95 571 70 18],'String',num2str(syn.noiseAmp),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_NoiseAmpUpdate',...
                                 'TooltipString',sprintf('FID noise power per sqrt(bandwidth)\n(The spectral noise is independent of the acquisition bandwidth)'),'FontSize',pars.fontSize);
fm.syn.noiseKeep     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Keep Noise', ...
                                 'Value',flag.synNoiseKeep,'Position',[.31 .810 .2 .03],'Callback','SP2_Syn_NoiseKeepUpdate','FontSize',pars.fontSize);

                                
%--- baseline characteristics ---                              
fm.syn.base          = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Add Base', ...
                                 'Value',flag.synBase,'Position',[.03 .775 .2 .03],'Callback','SP2_Syn_BaseUpdate','Enable','off','FontSize',pars.fontSize);
fm.syn.baseAmp       = uicontrol('Style','Edit','Position', [95 546 70 18],'String',num2str(syn.baseAmp),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_BaseAmpUpdate','Enable','off','FontSize',pars.fontSize);
                             
%--- baseline characteristics ---                              
fm.syn.poly          = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Add Polynomial', ...
                                 'Value',flag.synPoly,'Position',[.03 .740 .25 .03],'Callback','SP2_Syn_PolyUpdate','FontSize',pars.fontSize);
fm.syn.polyCenterLab = text('Position',[0.195, 0.789],'String','Center','FontSize',pars.fontSize);
fm.syn.polyCenter    = uicontrol('Style','Edit','Position', [215 520 55 18],'String',num2str(syn.polyCenterPpm),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyCenterPpmUpdate',...
                                 'TooltipString',sprintf('Center position of polynomial baseline [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp0Lab   = text('Position',[-0.12, 0.754],'String','0','FontSize',pars.fontSize);
fm.syn.polyAmp0      = uicontrol('Style','Edit','Position', [40 500 55 18],'String',num2str(syn.polyAmpVec(1)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('Zero-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp1Lab   = text('Position',[0.07, 0.754],'String','1','FontSize',pars.fontSize);
fm.syn.polyAmp1      = uicontrol('Style','Edit','Position', [127.5 500 55 18],'String',num2str(syn.polyAmpVec(2)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('First-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp2Lab   = text('Position',[0.26, 0.754],'String','2','FontSize',pars.fontSize);
fm.syn.polyAmp2      = uicontrol('Style','Edit','Position', [215 500 55 18],'String',num2str(syn.polyAmpVec(3)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('Second-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp3Lab   = text('Position',[-0.12, 0.719],'String','3','FontSize',pars.fontSize);
fm.syn.polyAmp3      = uicontrol('Style','Edit','Position', [40 480 55 18],'String',num2str(syn.polyAmpVec(4)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('Third-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp4Lab   = text('Position',[0.07, 0.719],'String','4','FontSize',pars.fontSize);
fm.syn.polyAmp4      = uicontrol('Style','Edit','Position', [127.5 480 55 18],'String',num2str(syn.polyAmpVec(5)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('Fourth-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
fm.syn.polyAmp5Lab   = text('Position',[0.26, 0.719],'String','5','FontSize',pars.fontSize);
fm.syn.polyAmp5      = uicontrol('Style','Edit','Position', [215 480 55 18],'String',num2str(syn.polyAmpVec(6)),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PolyAmpUpdate',...
                                 'TooltipString',sprintf('Fifth-order polynomial amplitude per [ppm]'),'FontSize',pars.fontSize);
                                              
%--- spectral synthesis from existing basis functions ---
fm.syn.loadProc    = uicontrol('Style','Pushbutton','String','Load Proc','Position',[20 420 125 18],'Callback','SP2_Syn_DoLoadProc;',...
                               'TooltipString',sprintf('Load spectrum from Processing page'),'FontSize',pars.fontSize);
fm.syn.loadLCM     = uicontrol('Style','Pushbutton','String','Load LCM','Position',[145 420 125 18],'Callback','SP2_Syn_DoLoadLCM;',...
                               'TooltipString',sprintf('Load spectrum from LCM page'),'FontSize',pars.fontSize);
fm.syn.synNoise    = uicontrol('Style','Pushbutton','String','Simulate Noise','Position',[20 400 125 18],'Callback','SP2_Syn_DoSimNoise;',...
                               'TooltipString',sprintf('Simulate noise spectrum'),'FontSize',pars.fontSize);
fm.syn.synSinglets = uicontrol('Style','Pushbutton','String','Simulate Singlets','Position',[145 400 125 18],'Callback','SP2_Syn_DoSimSinglets(1);',...
                               'TooltipString',sprintf('Simulate spectrum of grid of singlets\nas defined in the ''Singlets'' field below'),'FontSize',pars.fontSize);
fm.syn.synMetab    = uicontrol('Style','Pushbutton','String','Load Metab','Position',[20 380 125 18],'Callback','SP2_Syn_DoSimMetabSingle;',...
                               'TooltipString',sprintf('Simulate spectrum of selected metabolite'),'FontSize',pars.fontSize);
fm.syn.synBrain    = uicontrol('Style','Pushbutton','String','Synthesize Brain','Position',[145 380 125 18],'Callback','SP2_Syn_DoSimMetabBrain;',...
                               'TooltipString',sprintf('Simulate 1H metabolite spectrum of the human brain'),'FontSize',pars.fontSize);
fm.syn.metabCharLab   = text('Position',[-0.13, 0.507],'String','Singlets','FontSize',pars.fontSize);
fm.syn.metabCharEntry = uicontrol('Style','Edit','Position', [80 360 500 18],'String',syn.metabCharStr,'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_MetabCharStrUpdate','FontSize',pars.fontSize,...
                                  'TooltipString',sprintf('Assignment of grid of singlets as comma-separated list of vectors:\n1) frequency [ppm]\n2) amplitude [a.u.]\n3) linewidth [Hz]\ne.g. [0.0 10 10], [1 20 10], [2 25 10], [3 30 10], [4 35 10]'));
fm.syn.metabLibLab = text('Position',[-0.13, 0.473],'String','Metabolite','FontSize',pars.fontSize);
fm.syn.fidPath     = uicontrol('Style','Edit','Position', [80 340 450 18],'String',syn.fidPath, ...
                               'HorizontalAlignment','Left','Callback','SP2_Syn_MetabFidPathUpdate',...
                               'TooltipString','File path of single FID for simulation','FontSize',pars.fontSize);
fm.syn.fidSelect   = uicontrol('Style','Pushbutton','String','Select','Position',[530 340 50 18],'Callback','SP2_Syn_MetabFidSelect;',...
                               'TooltipString','Select single FID file for simulation','FontSize',pars.fontSize);    

                             
%--- display of simulated FID ---
fm.syn.plotFidOrig = uicontrol('Style','Pushbutton','String','FID Orig','Position',[20 290 70 20],...
                               'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Syn_ProcAndPlotFidOrig;',...
                               'TooltipString',sprintf('Show original FID before data manipulation'));
% note that data are not reprocessed
fm.syn.plotFid     = uicontrol('Style','Pushbutton','String','FID','Position',[90 290 70 20],...
                               'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Syn_PlotFid(1);',...
                               'TooltipString',sprintf('Show FID including data manipulation'));
% note that data are not reprocessed
fm.syn.plotSpec    = uicontrol('Style','Pushbutton','String','Spec','Position',[160 290 70 20],...
                               'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Syn_PlotSpec(1);',...
                               'TooltipString',sprintf('Show spectrum'));                             
                             
                             
                           
%--------------------------------------------------------------------------
%---    P R O C E S S I N G                                             ---
%--------------------------------------------------------------------------
% fm.syn.procLab  = text('Position',[0.5, 1.05],'String','Processing','FontWeight','bold');

%--- spectral processing ---
% apodization
fm.syn.procCutLab    = text('Position',[0.5, 0.9810],'String','Cut','FontSize',pars.fontSize);
fm.syn.procCutFlag   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcCut,...
                                 'Position',[.59 .8930 .03 .03],'Callback','SP2_Syn_ProcCutFlagUpdate',...
                                 'TooltipString',sprintf('Apodization of FID data vector [pts]'));
fm.syn.procCutDec3   = uicontrol('Style','Pushbutton','String','<<<','Position',[376 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutDec3','FontSize',pars.fontSize);
fm.syn.procCutDec2   = uicontrol('Style','Pushbutton','String','<<','Position',[398 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutDec2','FontSize',pars.fontSize);
fm.syn.procCutDec1   = uicontrol('Style','Pushbutton','String','<','Position',[420 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutDec1','FontSize',pars.fontSize);
fm.syn.procCutVal    = uicontrol('Style','Edit','Position', [442 630 55 18],'String',sprintf('%.0f',syn.procCut),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcCutUpdate','FontSize',pars.fontSize);
fm.syn.procCutInc1   = uicontrol('Style','Pushbutton','String','>','Position',[497 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutInc1','FontSize',pars.fontSize);
fm.syn.procCutInc2   = uicontrol('Style','Pushbutton','String','>>','Position',[519 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutInc2','FontSize',pars.fontSize);
fm.syn.procCutInc3   = uicontrol('Style','Pushbutton','String','>>>','Position',[543 630 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcCutInc3','FontSize',pars.fontSize);
fm.syn.procCutReset  = uicontrol('Style','Pushbutton','String','R','Position',[568 630 22 18],'Callback','SP2_Syn_ProcCutReset','FontSize',pars.fontSize);
            
% zero-filling
fm.syn.procZfLab     = text('Position',[0.5, 0.9371],'String','ZF','FontSize',pars.fontSize);
fm.syn.procZfFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcZf,...
                                 'Position',[.59 .8574 .03 .03],'Callback','SP2_Syn_ProcZfFlagUpdate',...
                                 'TooltipString',sprintf('Time domain zero-filling [pts]'));
fm.syn.procZfDec3    = uicontrol('Style','Pushbutton','String','<<<','Position',[376 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfDec3','FontSize',pars.fontSize);
fm.syn.procZfDec2    = uicontrol('Style','Pushbutton','String','<<','Position',[398 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfDec2','FontSize',pars.fontSize);
fm.syn.procZfDec1    = uicontrol('Style','Pushbutton','String','<','Position',[420 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfDec1','FontSize',pars.fontSize);
fm.syn.procZfVal     = uicontrol('Style','Edit','Position', [442 605 55 18],'String',sprintf('%.0f',syn.procZf),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcZfUpdate','FontSize',pars.fontSize);
fm.syn.procZfInc1    = uicontrol('Style','Pushbutton','String','>','Position',[497 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfInc1','FontSize',pars.fontSize);
fm.syn.procZfInc2    = uicontrol('Style','Pushbutton','String','>>','Position',[519 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfInc2','FontSize',pars.fontSize);
fm.syn.procZfInc3    = uicontrol('Style','Pushbutton','String','>>>','Position',[543 605 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcZfInc3','FontSize',pars.fontSize);
fm.syn.procZfReset   = uicontrol('Style','Pushbutton','String','R','Position',[568 605 22 18],'Callback','SP2_Syn_ProcZfReset','FontSize',pars.fontSize);
                            
% exponential line broadening
fm.syn.procLbLab     = text('Position',[0.5, 0.8932],'String','LB','FontSize',pars.fontSize);
fm.syn.procLbFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcLb,...
                                 'Position',[.59 .8218 .03 .03],'Callback','SP2_Syn_ProcLbFlagUpdate',...
                                 'TooltipString',sprintf('Exponential line broadening [Hz]\n(compare Gaussian broadening, GB)'));
fm.syn.procLbDec3    = uicontrol('Style','Pushbutton','String','<<<','Position',[376 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbDec3','FontSize',pars.fontSize);
fm.syn.procLbDec2    = uicontrol('Style','Pushbutton','String','<<','Position',[398 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbDec2','FontSize',pars.fontSize);
fm.syn.procLbDec1    = uicontrol('Style','Pushbutton','String','<','Position',[420 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbDec1','FontSize',pars.fontSize);
fm.syn.procLbVal     = uicontrol('Style','Edit','Position', [442 580 55 18],'String',sprintf('%.2f',syn.procLb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcLbUpdate','FontSize',pars.fontSize);
fm.syn.procLbInc1    = uicontrol('Style','Pushbutton','String','>','Position',[497 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbInc1','FontSize',pars.fontSize);
fm.syn.procLbInc2    = uicontrol('Style','Pushbutton','String','>>','Position',[519 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbInc2','FontSize',pars.fontSize);
fm.syn.procLbInc3    = uicontrol('Style','Pushbutton','String','>>>','Position',[543 580 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcLbInc3','FontSize',pars.fontSize);
fm.syn.procLbReset   = uicontrol('Style','Pushbutton','String','R','Position',[568 580 22 18],'Callback','SP2_Syn_ProcLbReset','FontSize',pars.fontSize);

% Gaussian line broadening
fm.syn.procGbLab     = text('Position',[0.5, 0.8493],'String','GB','FontSize',pars.fontSize);
fm.syn.procGbFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcGb,...
                                 'Position',[.59 .7862 .03 .03],'Callback','SP2_Syn_ProcGbFlagUpdate',...
                                 'TooltipString',sprintf('Gaussian line broadening [Hz^2]\n(compare exponential broadening, LB)'));
fm.syn.procGbDec3    = uicontrol('Style','Pushbutton','String','<<<','Position',[376 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbDec3','FontSize',pars.fontSize);
fm.syn.procGbDec2    = uicontrol('Style','Pushbutton','String','<<','Position',[398 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbDec2','FontSize',pars.fontSize);
fm.syn.procGbDec1    = uicontrol('Style','Pushbutton','String','<','Position',[420 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbDec1','FontSize',pars.fontSize);
fm.syn.procGbVal     = uicontrol('Style','Edit','Position', [442 555 55 18],'String',sprintf('%.2f',syn.procGb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcGbUpdate','FontSize',pars.fontSize);
fm.syn.procGbInc1    = uicontrol('Style','Pushbutton','String','>','Position',[497 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbInc1','FontSize',pars.fontSize);
fm.syn.procGbInc2    = uicontrol('Style','Pushbutton','String','>>','Position',[519 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbInc2','FontSize',pars.fontSize);
fm.syn.procGbInc3    = uicontrol('Style','Pushbutton','String','>>>','Position',[543 555 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcGbInc3','FontSize',pars.fontSize);
fm.syn.procGbReset   = uicontrol('Style','Pushbutton','String','R','Position',[568 555 22 18],'Callback','SP2_Syn_ProcGbReset','FontSize',pars.fontSize);

% phase correction: zero order          
fm.syn.procPhc0Lab   = text('Position',[0.5, 0.8054],'String','PHC0','FontSize',pars.fontSize);
fm.syn.procPhc0Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcPhc0,...
                                 'Position',[.59 .7506 .03 .03],'Callback','SP2_Syn_ProcPhc0FlagUpdate',...
                                 'TooltipString',sprintf('Zero order phase correction [deg]'));
fm.syn.procPhc0Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[376 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Dec3','FontSize',pars.fontSize);
fm.syn.procPhc0Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[398 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Dec2','FontSize',pars.fontSize);
fm.syn.procPhc0Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[420 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Dec1','FontSize',pars.fontSize);
fm.syn.procPhc0Val   = uicontrol('Style','Edit','Position', [442 530 55 18],'String',sprintf('%.1f',syn.procPhc0),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcPhc0Update','FontSize',pars.fontSize);
fm.syn.procPhc0Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[497 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Inc1','FontSize',pars.fontSize);
fm.syn.procPhc0Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[519 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Inc2','FontSize',pars.fontSize);
fm.syn.procPhc0Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[543 530 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc0Inc3','FontSize',pars.fontSize);
fm.syn.procPhc0Reset = uicontrol('Style','Pushbutton','String','R','Position',[568 530 22 18],'Callback','SP2_Syn_ProcPhc0Reset','FontSize',pars.fontSize);

% phase correction: first order          
fm.syn.procPhc1Lab   = text('Position',[0.5, 0.7615],'String','PHC1','FontSize',pars.fontSize);
fm.syn.procPhc1Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcPhc1,...
                                 'Position',[.59 .7150 .03 .03],'Callback','SP2_Syn_ProcPhc1FlagUpdate',...
                                 'TooltipString',sprintf('First order phase correction [deg]'));
fm.syn.procPhc1Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[376 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Dec3','FontSize',pars.fontSize);
fm.syn.procPhc1Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[398 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Dec2','FontSize',pars.fontSize);
fm.syn.procPhc1Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[420 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Dec1','FontSize',pars.fontSize);
fm.syn.procPhc1Val   = uicontrol('Style','Edit','Position', [442 505 55 18],'String',sprintf('%.1f',syn.procPhc1),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcPhc1Update','FontSize',pars.fontSize);
fm.syn.procPhc1Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[497 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Inc1','FontSize',pars.fontSize);
fm.syn.procPhc1Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[519 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Inc2','FontSize',pars.fontSize);
fm.syn.procPhc1Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[543 505 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcPhc1Inc3','FontSize',pars.fontSize);
fm.syn.procPhc1Reset = uicontrol('Style','Pushbutton','String','R','Position',[568 505 22 18],'Callback','SP2_Syn_ProcPhc1Reset','FontSize',pars.fontSize);

% amplitude scaling
fm.syn.procScaleLab   = text('Position',[0.5, 0.7176],'String','Scale','FontSize',pars.fontSize);
fm.syn.procScaleFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                  'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcScale,...
                                  'Position',[.59 .6794 .03 .03],'Callback','SP2_Syn_ProcScaleFlagUpdate',...
                                  'TooltipString',sprintf('Amplitude scaling [1]'));
fm.syn.procScaleDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[376 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleDec3','FontSize',pars.fontSize);
fm.syn.procScaleDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[398 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleDec2','FontSize',pars.fontSize);
fm.syn.procScaleDec1  = uicontrol('Style','Pushbutton','String','<','Position',[420 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleDec1','FontSize',pars.fontSize);
fm.syn.procScaleVal   = uicontrol('Style','Edit','Position', [442 480 55 18],'String',sprintf('%.3f',syn.procScale),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcScaleUpdate','FontSize',pars.fontSize);
fm.syn.procScaleInc1  = uicontrol('Style','Pushbutton','String','>','Position',[497 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleInc1','FontSize',pars.fontSize);
fm.syn.procScaleInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[519 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleInc2','FontSize',pars.fontSize);
fm.syn.procScaleInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[543 480 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcScaleInc3','FontSize',pars.fontSize);
fm.syn.procScaleReset = uicontrol('Style','Pushbutton','String','R','Position',[568 480 22 18],'Callback','SP2_Syn_ProcScaleReset','FontSize',pars.fontSize);

% frequency shift          
fm.syn.procShiftLab   = text('Position',[0.5, 0.6737],'String','Shift','FontSize',pars.fontSize);
fm.syn.procShiftFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                  'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcShift,...
                                  'Position',[.59 .6438 .03 .03],'Callback','SP2_Syn_ProcShiftFlagUpdate',...
                                  'TooltipString',sprintf('Spectral shift [Hz]'));
fm.syn.procShiftDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[376 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftDec3','FontSize',pars.fontSize);
fm.syn.procShiftDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[398 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftDec2','FontSize',pars.fontSize);
fm.syn.procShiftDec1  = uicontrol('Style','Pushbutton','String','<','Position',[420 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftDec1','FontSize',pars.fontSize);
fm.syn.procShiftVal   = uicontrol('Style','Edit','Position', [442 455 55 18],'String',sprintf('%.3f',syn.procShift),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcShiftUpdate','FontSize',pars.fontSize);
fm.syn.procShiftInc1  = uicontrol('Style','Pushbutton','String','>','Position',[497 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftInc1','FontSize',pars.fontSize);
fm.syn.procShiftInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[519 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftInc2','FontSize',pars.fontSize);
fm.syn.procShiftInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[543 455 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcShiftInc3','FontSize',pars.fontSize);
fm.syn.procShiftReset = uicontrol('Style','Pushbutton','String','R','Position',[568 455 22 18],'Callback','SP2_Syn_ProcShiftReset','FontSize',pars.fontSize);

% baseline offset          
fm.syn.procOffsetLab   = text('Position',[0.5, 0.6298],'String','Offset','FontSize',pars.fontSize);
fm.syn.procOffsetFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                   'FontSize',pars.fontSize,'Units','Normalized','Value',flag.synProcOffset,...
                                   'Position',[.59 .6082 .03 .03],'Callback','SP2_Syn_ProcOffsetFlagUpdate',...
                                   'TooltipString',sprintf('Baseline offset [a.u.]'));
fm.syn.procOffsetDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[376 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetDec3','FontSize',pars.fontSize);
fm.syn.procOffsetDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[398 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetDec2','FontSize',pars.fontSize);
fm.syn.procOffsetDec1  = uicontrol('Style','Pushbutton','String','<','Position',[420 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetDec1','FontSize',pars.fontSize);
fm.syn.procOffsetVal   = uicontrol('Style','Edit','Position', [442 430 55 18],'String',num2str(syn.procOffset),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ProcOffsetUpdate','FontSize',pars.fontSize);
fm.syn.procOffsetInc1  = uicontrol('Style','Pushbutton','String','>','Position',[497 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetInc1','FontSize',pars.fontSize);
fm.syn.procOffsetInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[519 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetInc2','FontSize',pars.fontSize);
fm.syn.procOffsetInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[543 430 22 18],'FontWeight','bold','Callback','SP2_Syn_ProcOffsetInc3','FontSize',pars.fontSize);
fm.syn.procOffsetReset = uicontrol('Style','Pushbutton','String','R','Position',[568 430 22 18],'Callback','SP2_Syn_ProcOffsetReset','FontSize',pars.fontSize);


%--------------------------------------------------------------------------
%---    D I S P L A Y  /  A N A L Y S I S                               ---
%--------------------------------------------------------------------------
%--- FWHM / integral area definition ---
fm.syn.ppmTargetLab     = text('Position',[-0.13, 0.30],'String','Target','FontSize',pars.fontSize);
fm.syn.ppmTargetMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[75 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmTargetMinDecr','FontSize',pars.fontSize);
fm.syn.ppmTargetMin     = uicontrol('Style','Edit','Position', [93 242 45 18],'String',sprintf('%.2f',syn.ppmTargetMin),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PpmTargetWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmTargetMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[138 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmTargetMinIncr','FontSize',pars.fontSize);
fm.syn.ppmTargetMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[161 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmTargetMaxDecr','FontSize',pars.fontSize);
fm.syn.ppmTargetMax     = uicontrol('Style','Edit','Position', [179 242 45 18],'String',sprintf('%.2f',syn.ppmTargetMax),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PpmTargetWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmTargetMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[224 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmTargetMaxIncr','FontSize',pars.fontSize);

%--- noise area definition ---
fm.syn.ppmNoiseLab     = text('Position',[-0.13, 0.25],'String','Noise','FontSize',pars.fontSize);
fm.syn.ppmNoiseMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[75 213 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmNoiseMinDecr','FontSize',pars.fontSize);
fm.syn.ppmNoiseMin     = uicontrol('Style','Edit','Position', [93 213 45 18],'String',sprintf('%.2f',syn.ppmNoiseMin),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PpmNoiseWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmNoiseMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[138 213 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmNoiseMinIncr','FontSize',pars.fontSize);
fm.syn.ppmNoiseMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[161 213 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmNoiseMaxDecr','FontSize',pars.fontSize);
fm.syn.ppmNoiseMax     = uicontrol('Style','Edit','Position', [179 213 45 18],'String',sprintf('%.2f',syn.ppmNoiseMax),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_PpmNoiseWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmNoiseMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[224 213 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmNoiseMaxIncr','FontSize',pars.fontSize);

%--- offset area definition ---
fm.syn.offsetLab        = text('Position',[0.44, 0.30],'String','Offset','FontSize',pars.fontSize);
fm.syn.offsetPpmFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Range', ...
                                    'Value',flag.synOffset,'Position',[.540 .34 .10 .03],'Callback','SP2_Syn_OffsetPpmWinFlagUpdate','FontSize',pars.fontSize);
fm.syn.ppmOffsetMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[381 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmOffsetMinDecr','FontSize',pars.fontSize);
fm.syn.ppmOffsetMin     = uicontrol('Style','Edit','Position', [399 242 40 18],'String',sprintf('%.2f',syn.ppmOffsetMin),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_OffsetPpmWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmOffsetMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[439 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmOffsetMinIncr','FontSize',pars.fontSize);
fm.syn.ppmOffsetMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[462 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmOffsetMaxDecr','FontSize',pars.fontSize);
fm.syn.ppmOffsetMax     = uicontrol('Style','Edit','Position', [480 242 40 18],'String',sprintf('%.2f',syn.ppmOffsetMax),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_OffsetPpmWinUpdate','FontSize',pars.fontSize);
fm.syn.ppmOffsetMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[520 242 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmOffsetMaxIncr','FontSize',pars.fontSize);
fm.syn.offsetValFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Value', ...
                                    'Value',~flag.synOffset,'Position',[.540 .30 .10 .03],'Callback','SP2_Syn_OffsetValueFlagUpdate','FontSize',pars.fontSize);

%--- spectral offset definition ---                                
fm.syn.offsetDec3       = uicontrol('Style','Pushbutton','String','<<<','Position',[381 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetDec3','FontSize',pars.fontSize);
fm.syn.offsetDec2       = uicontrol('Style','Pushbutton','String','<<','Position',[403 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetDec2','FontSize',pars.fontSize);
fm.syn.offsetDec1       = uicontrol('Style','Pushbutton','String','<','Position',[425 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetDec1','FontSize',pars.fontSize);
fm.syn.offsetVal        = uicontrol('Style','Edit','Position', [447 213 70 18],'String',sprintf('%.1f',syn.offsetVal),'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_OffsetValueUpdate','FontSize',pars.fontSize);
fm.syn.offsetInc1       = uicontrol('Style','Pushbutton','String','>','Position',[517 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetInc1','FontSize',pars.fontSize);
fm.syn.offsetInc2       = uicontrol('Style','Pushbutton','String','>>','Position',[539 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetInc2','FontSize',pars.fontSize);
fm.syn.offsetInc3       = uicontrol('Style','Pushbutton','String','>>>','Position',[561 213 22 18],'FontWeight','bold','Callback','SP2_Syn_OffsetInc3','FontSize',pars.fontSize);
fm.syn.offsetReset      = uicontrol('Style','Pushbutton','String','Zero','Position',[381 193 60 18],...
                                    'FontSize',pars.fontSize,'Callback','SP2_Syn_OffsetZero','TooltipString',sprintf('Reset of amplitude offset\nfor SNR, FWHM & Integral calcuations'));
fm.syn.offsetAssign     = uicontrol('Style','Pushbutton','String','Assign','Position',[441 193 60 18],'FontSize',pars.fontSize,'Callback','SP2_Syn_OffsetAssign',...
                                    'TooltipString',sprintf('Manual assignment of amplitude offset\nfor SNR, FWHM & Integral calcuations'));

                                                             
%--- analysis options ---
fm.syn.anaLab       = text('Position',[-0.13, 0.20],'String','Analysis','FontSize',pars.fontSize);
fm.syn.anaSNR       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','SNR', ...
                                'Value',flag.synAnaSNR,'Position',[.13 .26 .15 .03],'Callback','SP2_Syn_AnaSnrUpdate',...
                                'TooltipString',sprintf('Signal-to-noise analysis of selected spectrum'),'FontSize',pars.fontSize);
fm.syn.anaFWHM      = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','FWHM', ...
                                'Value',flag.synAnaFWHM,'Position',[.23 .26 .15 .03],'Callback','SP2_Syn_AnaFwhmUpdate',...
                                'TooltipString',sprintf('Full width at half maximum (FWHM) analysis of selected spectrum'),'FontSize',pars.fontSize);
fm.syn.anaIntegr    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Integral', ...
                                'Value',flag.synAnaIntegr,'Position',[.33 .26 .15 .03],'Callback','SP2_Syn_AnaIntegralUpdate',...
                                'TooltipString',sprintf('Spectral integration of selected spectrum'),'FontSize',pars.fontSize);
fm.syn.anaSignPos   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','(+)', ...
                                'Value',flag.synAnaSign,'Position',[.13 .23 .15 .03],'Callback','SP2_Syn_AnaSignPositiveUpdate',...
                                'TooltipString',sprintf('Perform SNR/FWHM/integration analysis for peak of positive polarity'),'FontSize',pars.fontSize);
fm.syn.anaSignNeg   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','(-)', ...
                                'Value',~flag.synAnaSign,'Position',[.20 .23 .15 .03],'Callback','SP2_Syn_AnaSignNegativeUpdate',...
                                'TooltipString',sprintf('Perform SNR/FWHM/integration analysis for peak of negative polarity'),'FontSize',pars.fontSize);
fm.syn.anaFrequDiff = uicontrol('Style','Pushbutton','String','Delta','Position',[262 186 40 18],'FontSize',pars.fontSize,...
                                'FontName','Helvetica','Callback','SP2_Syn_AnaFrequDifference',...
                                'TooltipString',sprintf('Measurement of frequency difference between two spectral positions'),'FontSize',pars.fontSize);

         
%--- freeze/keep figure ---
fm.syn.updateCalc = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Update', ...
                              'Value',flag.synUpdateCalc,'Position',[.19 .162 .12 .03],'Callback','SP2_Syn_UpdateCalcUpdate',...
                              'TooltipString',sprintf('Automated processing if needed and update every time a parameter is changed'),'FontSize',pars.fontSize);
fm.syn.keepFigure = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Keep', ...
                              'Value',flag.synKeepFig,'Position',[.32 .162 .10 .03],'Callback','SP2_Syn_KeepFigureUpdate',...
                              'TooltipString',sprintf('1: figures are kept, ie. parameter changes are plotted to new figures\n0: Parameter changes are updated in the same figure'),'FontSize',pars.fontSize);
fm.syn.verbose    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.verbose,...
                              'String','Verbose','Position',[0.45 0.162 .17 .03],'Callback','SP2_Syn_VerboseFlagUpdate','FontSize',pars.fontSize);

                            
%--- result display ---
fm.syn.amplShowLab    = text('Position',[-0.11, 0.030],'String','Amplitude','FontSize',pars.fontSize);
fm.syn.amplShowAuto   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',~flag.synAmplShow,...
                                  'String','Auto','Position',[.19 .12 .2 .03],'Callback','SP2_Syn_AmplShowAutoUpdate',...
                                  'TooltipString',sprintf('Automatic determination of amplitude range'),'FontSize',pars.fontSize);
fm.syn.amplShowDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.synAmplShow,...
                                  'String','Direct','Position',[.29 .12 .03 .03],'Callback','SP2_Syn_AmplShowDirectUpdate',...
                                  'TooltipString',sprintf('Direct assignment of amplitude range'),'FontSize',pars.fontSize);
fm.syn.amplShowMin    = uicontrol('Style','Edit','Position', [200 88 50 18],'String',num2str(syn.amplShowMin),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                                  'TooltipString','Lower amplitude limit','FontSize',pars.fontSize);
fm.syn.amplShowMax    = uicontrol('Style','Edit','Position', [250 88 50 18],'String',num2str(syn.amplShowMax),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                                  'TooltipString','Upper amplitude limit','FontSize',pars.fontSize);
fm.syn.ppmShowLab     = text('Position',[0.54, 0.030],'String','Frequ.','FontSize',pars.fontSize);
fm.syn.ppmShowFull    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Full', ...
                                  'Value',flag.synPpmShow,'Position',[.615 .12 .12 .03],'Callback','SP2_Syn_PpmShowFullUpdate','FontSize',pars.fontSize);
fm.syn.ppmShowDirect  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
                                  'Value',~flag.synPpmShow,'Position',[.694 .12 .03 .03],'Callback','SP2_Syn_PpmShowDirectUpdate','FontSize',pars.fontSize);
fm.syn.ppmShowMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[436 88 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmShowMinDecr','FontSize',pars.fontSize);
fm.syn.ppmShowMin     = uicontrol('Style','Edit','Position', [454 88 40 18],'String',sprintf('%.2f',syn.ppmShowMin),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                                  'TooltipString','Lower amplitude limit','FontSize',pars.fontSize);
fm.syn.ppmShowMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[494 88 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmShowMinIncr','FontSize',pars.fontSize);
fm.syn.ppmShowMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[517 88 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmShowMaxDecr','FontSize',pars.fontSize);
fm.syn.ppmShowMax     = uicontrol('Style','Edit','Position', [535 88 40 18],'String',sprintf('%.2f',syn.ppmShowMax),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_Syn_ParsUpdate',...
                                  'TooltipString','Upper amplitude limit','FontSize',pars.fontSize);
fm.syn.ppmShowMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[575 88 18 18],'FontWeight','bold','Callback','SP2_Syn_PpmShowMaxIncr','FontSize',pars.fontSize);
                              
fm.syn.formatLab   = text('Position',[-0.11, -0.022],'String','Format','FontSize',pars.fontSize);
fm.syn.formatReal  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Real', ...
                               'Value',flag.synFormat==1,'Position',[.19 .078 .2 .03],'Callback','SP2_Syn_FormatRealUpdate','FontSize',pars.fontSize);
fm.syn.formatImag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Imag', ...
                               'Value',flag.synFormat==2,'Position',[.28 .078 .2 .03],'Callback','SP2_Syn_FormatImagUpdate','FontSize',pars.fontSize);
fm.syn.formatMagn  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Magn', ...
                               'Value',flag.synFormat==3,'Position',[.37 .078 .2 .03],'Callback','SP2_Syn_FormatMagnUpdate','FontSize',pars.fontSize);
fm.syn.formatPhase = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Phase', ...
                               'Value',flag.synFormat==4,'Position',[.46 .078 .2 .03],'Callback','SP2_Syn_FormatPhaseUpdate','FontSize',pars.fontSize);
fm.syn.cmapLab     = text('Position',[-0.11, -0.074],'String','Color Mode','FontSize',pars.fontSize);
fm.syn.cmapUni     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Blue', ...
                               'Value',flag.synCMap==0,'Position',[.19 .036 .1 .03],'Callback','SP2_Syn_ColormapUniUpdate','FontSize',pars.fontSize);
fm.syn.cmapJet     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Jet', ...
                               'Value',flag.synCMap==1,'Position',[.28 .036 .1 .03],'Callback','SP2_Syn_ColormapJetUpdate','FontSize',pars.fontSize);
fm.syn.cmapHsv     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Hsv', ...
                               'Value',flag.synCMap==2,'Position',[.37 .036 .1 .03],'Callback','SP2_Syn_ColormapHsvUpdate','FontSize',pars.fontSize);
fm.syn.cmapHot     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Hot', ...
                               'Value',flag.synCMap==3,'Position',[.46 .036 .1 .03],'Callback','SP2_Syn_ColormapHotUpdate','FontSize',pars.fontSize);
fm.syn.ppmShowPosLab    = text('Position',[0.6, -0.074],'String','Position','FontSize',pars.fontSize);
fm.syn.ppmShowPos       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.synPpmShowPos,...
                                    'Position',[0.69 0.036 .03 .03],'Callback','SP2_Syn_PpmShowPosFlagUpdate',...
                                    'TooltipString',sprintf('Display frequency position in 2D plot'),'FontSize',pars.fontSize);
fm.syn.ppmShowPosVal    = uicontrol('Style','Edit','Position',[440 28 50 18],'String',num2str(syn.ppmShowPos),'BackGroundColor',pars.bgColor,...
                                    'Callback','SP2_Syn_PpmShowPosValUpdate','TooltipString',sprintf('Frequency [ppm] position to be displayed'),'FontSize',pars.fontSize);
fm.syn.ppmShowPosAssign = uicontrol('Style','Pushbutton','String','Assign','Position',[490 28 55 18],...
                                    'FontSize',pars.fontSize,'Callback','SP2_Syn_PpmShowPosAssign',...
                                    'TooltipString',sprintf('Manual assignment of frequency position [ppm]'),'FontSize',pars.fontSize);        
  
%--- window update ---                           
SP2_Syn_SynthesisWinUpdate

end
