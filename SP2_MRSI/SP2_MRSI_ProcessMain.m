%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ProcessMain
%% 
%%  Main window for processing of multiple MR spectra
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars flag proc


SP2_ClearWindow
flag.fmWin = 4;
figPos = get(fmfig,'Position');
set(fmfig,'Name',' INSPECTOR: Data Processing','Position',...
    [figPos(1) pars.mainDims(2) pars.mainDims(3) pars.mainDims(4)])


%**************************************************************************************************
%    O N E    V S .    T W O    S P E C T R A
%**************************************************************************************************
fm.mrsi.numSpecOne = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','1', ...
                               'Value',flag.mrsiNumSpec==0,'Position',[.10 .96 .08 .03],'Callback','SP2_MRSI_NumSpecOneUpdate');
fm.mrsi.numSpecTwo = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','2', ...
                               'Value',flag.mrsiNumSpec==1,'Position',[.15 .96 .08 .03],'Callback','SP2_MRSI_NumSpecTwoUpdate');

%**************************************************************************************************
%    D A T A     O R I G I N  
%**************************************************************************************************
fm.mrsi.datData = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Data', ...
                            'Value',flag.mrsiData==0,'Position',[.24 .96 .08 .03],'Callback','SP2_MRSI_DataDataUpdate');
fm.mrsi.datProc = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Proc', ...
                            'Value',flag.mrsiData==1,'Position',[.32 .96 .08 .03],'Callback','SP2_MRSI_DataProcUpdate');

%**************************************************************************************************
%    D A T A     F O R M A T  
%**************************************************************************************************
fm.mrsi.datFormatMat = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','.mat', ...
                                 'Value',flag.mrsiDatFormat==1,'Position',[.44 .96 .08 .03],'Callback','SP2_MRSI_DataFormatMatlabUpdate');
fm.mrsi.datFormatTxt = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','.txt', ...
                                 'Value',flag.mrsiDatFormat==0,'Position',[.52 .96 .08 .03],'Callback','SP2_MRSI_DataFormatTextUpdate');

                        
%******************************************************************************
%   L O A D     D A T A     F R O M      F I L E 
%******************************************************************************
%--- data set 1 ---
fm.mrsi.spec1DataLab    = text('Position',[-0.145, 1.025],'String','Spec 1');
if flag.mrsiDatFormat       % matlab format
    fm.mrsi.spec1DataPath   = uicontrol('Style','Edit','Position', [60 655 440 18],'String',mrsi.spec1.dataPathMat,...
                                        'HorizontalAlignment','Left','Callback','SP2_MRSI_Spec1DataPathUpdate');
else                        % text format 
    fm.mrsi.spec1DataPath   = uicontrol('Style','Edit','Position', [60 655 440 18],'String',mrsi.spec1.dataPathTxt,...
                                        'HorizontalAlignment','Left','Callback','SP2_MRSI_Spec1DataPathUpdate');
end
fm.mrsi.spec1DataSelect = uicontrol('Style','Pushbutton','String','Select',...
                                    'Position',[500 655 45 18],'Callback','SP2_MRSI_Spec1DataSelect');
fm.mrsi.spec1DataLoad   = uicontrol('Style','Pushbutton','String','Load','Position',[545 655 45 18],...
                                    'Callback','SP2_MRSI_DataAndParsAssign1;');

%--- data set 2 ---
fm.mrsi.spec2DataLab    = text('Position',[-0.145, 0.990],'String','Spec 2');
if flag.mrsiDatFormat       % matlab format
    fm.mrsi.spec2DataPath   = uicontrol('Style','Edit','Position', [60 635 440 18],'String',mrsi.spec2.dataPathMat,...
                                        'HorizontalAlignment','Left','Callback','SP2_MRSI_Spec2DataPathUpdate');
else                        % text format 
    fm.mrsi.spec2DataPath   = uicontrol('Style','Edit','Position', [60 635 440 18],'String',mrsi.spec2.dataPathTxt,...
                                        'HorizontalAlignment','Left','Callback','SP2_MRSI_Spec2DataPathUpdate');
end
fm.mrsi.spec2DataSelect = uicontrol('Style','Pushbutton','String','Select',...
                                    'Position',[500 635 45 18],'Callback','SP2_MRSI_Spec2DataSelect');
fm.mrsi.spec2DataLoad   = uicontrol('Style','Pushbutton','String','Load','Position',[545 635 45 18],...
                                    'Callback','SP2_MRSI_DataAndParsAssign2;');

%--- export data ---
fm.mrsi.exptDataLab    = text('Position',[-0.145, 0.955],'String','Export');
if flag.mrsiDatFormat       % matlab format
    fm.mrsi.exptDataPath   = uicontrol('Style','Edit','Position', [60 615 440 18],'String',mrsi.expt.dataPathMat,...
                                       'HorizontalAlignment','Left','Callback','SP2_MRSI_ExptDataPathUpdate');
else                        % text format 
    fm.mrsi.exptDataPath   = uicontrol('Style','Edit','Position', [60 615 440 18],'String',mrsi.expt.dataPathTxt,...
                                       'HorizontalAlignment','Left','Callback','SP2_MRSI_ExptDataPathUpdate');
end
fm.mrsi.exptDataSelect = uicontrol('Style','Pushbutton','String','Select',...
                                   'Position',[500 615 45 18],'Callback','SP2_MRSI_ExptDataSelect');
fm.mrsi.exptDataSave   = uicontrol('Style','Pushbutton','String','Save','Position',[545 615 45 18],...
                                   'Callback','SP2_MRSI_ExptDataSave;');

% spectrum 1: FID apodization
fm.mrsi.specCutLab    = text('Position',[-0.13, 0.8930],'String','Cut');
fm.mrsi.spec1CutFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                  'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Cut==1,...
                                  'Position',[.12 .822 .03 .03],'Callback','SP2_MRSI_Spec1CutFlagUpdate',...
                                  'TooltipString',sprintf('Apodization of FID data vector [pts]'));
fm.mrsi.spec1CutDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutDec3');
fm.mrsi.spec1CutDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutDec2');
fm.mrsi.spec1CutDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutDec1');
fm.mrsi.spec1CutVal   = uicontrol('Style','Edit','Position', [161 580 55 18],'String',sprintf('%.0f',mrsi.spec1.cut),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1CutUpdate');
fm.mrsi.spec1CutInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutInc1');
fm.mrsi.spec1CutInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutInc2');
fm.mrsi.spec1CutInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1CutInc3');
fm.mrsi.spec1CutReset = uicontrol('Style','Pushbutton','String','R','Position',[285 580 22 18],'Callback','SP2_MRSI_Spec1CutReset');

% spectrum 2: FID apodization
fm.mrsi.spec2CutFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                  'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Cut==1,...
                                  'Position',[.55 .822 .03 .03],'Callback','SP2_MRSI_Spec2CutFlagUpdate',...
                                  'TooltipString',sprintf('Apodization of FID data vector [pts]'));
fm.mrsi.spec2CutDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutDec3');
fm.mrsi.spec2CutDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutDec2');
fm.mrsi.spec2CutDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutDec1');
fm.mrsi.spec2CutVal   = uicontrol('Style','Edit','Position', [419 580 55 18],'String',sprintf('%.0f',mrsi.spec2.cut),...
                                  'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2CutUpdate');
fm.mrsi.spec2CutInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutInc1');
fm.mrsi.spec2CutInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutInc2');
fm.mrsi.spec2CutInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 580 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2CutInc3');              
fm.mrsi.spec2CutReset = uicontrol('Style','Pushbutton','String','R','Position',[543  580 22 18],'Callback','SP2_MRSI_Spec2CutReset');              
fm.mrsi.syncCut       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                  'Normalized','Value',flag.mrsiSyncCut,'Position',[.96 .822 .03 .03],...
                                  'Callback','SP2_MRSI_SyncCutFlagUpdate','TooltipString',...
                                  sprintf('Apply modifications to both FID 1 and FID 2'));
                          
% spectrum 1: FID zero-filling
fm.mrsi.specZfLab    = text('Position',[-0.13, 0.8491],'String','ZF');
fm.mrsi.spec1ZfFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Zf==1,...
                                 'Position',[.12 .7864 .03 .03],'Callback','SP2_MRSI_Spec1ZfFlagUpdate',...
                                 'TooltipString',sprintf('Time domain zero-filling [pts]'));
fm.mrsi.spec1ZfDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfDec3');
fm.mrsi.spec1ZfDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfDec2');
fm.mrsi.spec1ZfDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfDec1');
fm.mrsi.spec1ZfVal   = uicontrol('Style','Edit','Position', [161 555 55 18],'String',sprintf('%.0f',mrsi.spec1.zf),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1ZfUpdate');
fm.mrsi.spec1ZfInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfInc1');
fm.mrsi.spec1ZfInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfInc2');
fm.mrsi.spec1ZfInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ZfInc3');
fm.mrsi.spec1ZfReset = uicontrol('Style','Pushbutton','String','R','Position',[285 555 22 18],'Callback','SP2_MRSI_Spec1ZfReset');
                            
% spectrum 2: FID zero-filling
fm.mrsi.spec2ZfFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Zf==1,...
                                 'Position',[.55 .7864 .03 .03],'Callback','SP2_MRSI_Spec2ZfFlagUpdate',...
                                 'TooltipString',sprintf('Time domain zero-filling [pts]'));
fm.mrsi.spec2ZfDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfDec3');
fm.mrsi.spec2ZfDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfDec2');
fm.mrsi.spec2ZfDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfDec1');
fm.mrsi.spec2ZfVal   = uicontrol('Style','Edit','Position', [419 555 55 18],'String',sprintf('%.0f',mrsi.spec2.zf),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2ZfUpdate');
fm.mrsi.spec2ZfInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfInc1');
fm.mrsi.spec2ZfInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfInc2');
fm.mrsi.spec2ZfInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 555 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ZfInc3');
fm.mrsi.spec2ZfReset = uicontrol('Style','Pushbutton','String','R','Position',[543  555 22 18],'Callback','SP2_MRSI_Spec2ZfReset');
fm.mrsi.syncZf       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncZf,'Position',[.96 .7864 .03 .03],...
                                 'Callback','SP2_MRSI_SyncZfFlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));
                            
% spectrum 1: exponential line broadening
fm.mrsi.specLbLab    = text('Position',[-0.13, 0.8053],'String','LB');
fm.mrsi.spec1LbFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Lb==1,...
                                 'Position',[.12 .7508 .03 .03],'Callback','SP2_MRSI_Spec1LbFlagUpdate',...
                                 'TooltipString',sprintf('Exponential line broadening [Hz]\n(compare Gaussian broadening, GB)'));
fm.mrsi.spec1LbDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbDec3');
fm.mrsi.spec1LbDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbDec2');
fm.mrsi.spec1LbDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbDec1');
fm.mrsi.spec1LbVal   = uicontrol('Style','Edit','Position', [161 530 55 18],'String',sprintf('%.2f',mrsi.spec1.lb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1LbUpdate');
fm.mrsi.spec1LbInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbInc1');
fm.mrsi.spec1LbInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbInc2');
fm.mrsi.spec1LbInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1LbInc3');
fm.mrsi.spec1LbReset = uicontrol('Style','Pushbutton','String','R','Position',[285 530 22 18],'Callback','SP2_MRSI_Spec1LbReset');

% spectrum 2: exponential line broadening
fm.mrsi.spec2LbFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Lb==1,...
                                 'Position',[.55 .7508 .03 .03],'Callback','SP2_MRSI_Spec2LbFlagUpdate',...
                                 'TooltipString',sprintf('Exponential line broadening [Hz]\n(compare Gaussian broadening, GB)'));
fm.mrsi.spec2LbDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbDec3');
fm.mrsi.spec2LbDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbDec2');
fm.mrsi.spec2LbDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbDec1');
fm.mrsi.spec2LbVal   = uicontrol('Style','Edit','Position', [419 530 55 18],'String',sprintf('%.2f',mrsi.spec2.lb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2LbUpdate');
fm.mrsi.spec2LbInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbInc1');
fm.mrsi.spec2LbInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbInc2');
fm.mrsi.spec2LbInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 530 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2LbInc3');
fm.mrsi.spec2LbReset = uicontrol('Style','Pushbutton','String','R','Position',[543  530 22 18],'Callback','SP2_MRSI_Spec2LbReset');
fm.mrsi.syncLb       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncLb,'Position',[.96 .7508 .03 .03],...
                                 'Callback','SP2_MRSI_SyncLbFlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));
                         
% spectrum 1: Gaussian line broadening
fm.mrsi.specGbLab    = text('Position',[-0.13, 0.7614],'String','GB');
fm.mrsi.spec1GbFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Gb==1,...
                                 'Position',[.12 .7151 .03 .03],'Callback','SP2_MRSI_Spec1GbFlagUpdate',...
                                 'TooltipString',sprintf('Gaussian line broadening [Hz^2]\n(compare exponential broadening, LB)'));
fm.mrsi.spec1GbDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbDec3');
fm.mrsi.spec1GbDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbDec2');
fm.mrsi.spec1GbDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbDec1');
fm.mrsi.spec1GbVal   = uicontrol('Style','Edit','Position', [161 505 55 18],'String',sprintf('%.2f',mrsi.spec1.gb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1GbUpdate');
fm.mrsi.spec1GbInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbInc1');
fm.mrsi.spec1GbInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbInc2');
fm.mrsi.spec1GbInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1GbInc3');
fm.mrsi.spec1GbReset = uicontrol('Style','Pushbutton','String','R','Position',[285 505 22 18],'Callback','SP2_MRSI_Spec1GbReset');

% spectrum 2: Gaussian line broadening
fm.mrsi.spec2GbFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                 'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Gb==1,...
                                 'Position',[.55 .7151 .03 .03],'Callback','SP2_MRSI_Spec2GbFlagUpdate',...
                                 'TooltipString',sprintf('Gaussian line broadening [Hz^2]\n(compare exponential broadening, LB)'));
fm.mrsi.spec2GbDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbDec3');
fm.mrsi.spec2GbDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbDec2');
fm.mrsi.spec2GbDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbDec1');
fm.mrsi.spec2GbVal   = uicontrol('Style','Edit','Position', [419 505 55 18],'String',sprintf('%.2f',mrsi.spec2.gb),...
                                 'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2GbUpdate');
fm.mrsi.spec2GbInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbInc1');
fm.mrsi.spec2GbInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbInc2');
fm.mrsi.spec2GbInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 505 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2GbInc3');
fm.mrsi.spec2GbReset = uicontrol('Style','Pushbutton','String','R','Position',[543  505 22 18],'Callback','SP2_MRSI_Spec2GbReset');
fm.mrsi.syncGb       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncGb,'Position',[.96 .7151 .03 .03],...
                                 'Callback','SP2_MRSI_SyncGbFlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));
                         
% phase correction: spectrum 1, zero order          
fm.mrsi.specPhc0Lab    = text('Position',[-0.13, 0.7175],'String','PHC0');
fm.mrsi.spec1Phc0Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                   'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Phc0==1,...
                                   'Position',[.12 .6795 .03 .03],'Callback','SP2_MRSI_Spec1Phc0FlagUpdate',...
                                   'TooltipString',sprintf('Zero order phase correction [deg]'));
fm.mrsi.spec1Phc0Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Dec3');
fm.mrsi.spec1Phc0Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Dec2');
fm.mrsi.spec1Phc0Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Dec1');
fm.mrsi.spec1Phc0Val   = uicontrol('Style','Edit','Position', [161 480 55 18],'String',sprintf('%.1f',mrsi.spec1.phc0),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1Phc0Update');
fm.mrsi.spec1Phc0Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Inc1');
fm.mrsi.spec1Phc0Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Inc2');
fm.mrsi.spec1Phc0Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc0Inc3');
fm.mrsi.spec1Phc0Reset = uicontrol('Style','Pushbutton','String','R','Position',[285 480 22 18],'Callback','SP2_MRSI_Spec1Phc0Reset');

% phase correction: spectrum 2, zero order          
fm.mrsi.spec2Phc0Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                   'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Phc0==1,...
                                   'Position',[.55 .6795 .03 .03],'Callback','SP2_MRSI_Spec2Phc0FlagUpdate',...
                                   'TooltipString',sprintf('Zero order phase correction [deg]'));
fm.mrsi.spec2Phc0Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Dec3');
fm.mrsi.spec2Phc0Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Dec2');
fm.mrsi.spec2Phc0Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Dec1');
fm.mrsi.spec2Phc0Val   = uicontrol('Style','Edit','Position', [419 480 55 18],'String',sprintf('%.1f',mrsi.spec2.phc0),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2Phc0Update');
fm.mrsi.spec2Phc0Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Inc1');
fm.mrsi.spec2Phc0Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Inc2');
fm.mrsi.spec2Phc0Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 480 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc0Inc3');
fm.mrsi.spec2Phc0Reset = uicontrol('Style','Pushbutton','String','R','Position',[543  480 22 18],'Callback','SP2_MRSI_Spec2Phc0Reset');
fm.mrsi.syncPhc0       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncPhc0,'Position',[.96 .6795 .03 .03],...
                                 'Callback','SP2_MRSI_SyncPhc0FlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));

% phase correction: spectrum 1, first order          
fm.mrsi.specPhc1Lab    = text('Position',[-0.13, 0.6736],'String','PHC1');
fm.mrsi.spec1Phc1Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                   'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Phc1==1,...
                                   'Position',[.12 .6439 .03 .03],'Callback','SP2_MRSI_Spec1Phc1FlagUpdate',...
                                   'TooltipString',sprintf('First order phase correction [deg]'));
fm.mrsi.spec1Phc1Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Dec3');
fm.mrsi.spec1Phc1Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Dec2');
fm.mrsi.spec1Phc1Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Dec1');
fm.mrsi.spec1Phc1Val   = uicontrol('Style','Edit','Position', [161 455 55 18],'String',sprintf('%.1f',mrsi.spec1.phc1),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1Phc1Update');
fm.mrsi.spec1Phc1Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Inc1');
fm.mrsi.spec1Phc1Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Inc2');
fm.mrsi.spec1Phc1Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1Phc1Inc3');
fm.mrsi.spec1Phc1Reset = uicontrol('Style','Pushbutton','String','R','Position',[285 455 22 18],'Callback','SP2_MRSI_Spec1Phc1Reset');

% phase correction: spectrum 2, first order          
fm.mrsi.spec2Phc1Flag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                   'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Phc1==1,...
                                   'Position',[.55 .6439 .03 .03],'Callback','SP2_MRSI_Spec2Phc1FlagUpdate',...
                                   'TooltipString',sprintf('First order phase correction [deg]'));
fm.mrsi.spec2Phc1Dec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Dec3');
fm.mrsi.spec2Phc1Dec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Dec2');
fm.mrsi.spec2Phc1Dec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Dec1');
fm.mrsi.spec2Phc1Val   = uicontrol('Style','Edit','Position', [419 455 55 18],'String',sprintf('%.1f',mrsi.spec2.phc1),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2Phc1Update');
fm.mrsi.spec2Phc1Inc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Inc1');
fm.mrsi.spec2Phc1Inc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Inc2');
fm.mrsi.spec2Phc1Inc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 455 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2Phc1Inc3');
fm.mrsi.spec2Phc1Reset = uicontrol('Style','Pushbutton','String','R','Position',[543  455 22 18],'Callback','SP2_MRSI_Spec2Phc1Reset');
fm.mrsi.syncPhc1       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncPhc1,'Position',[.96 .6439 .03 .03],...
                                 'Callback','SP2_MRSI_SyncPhc1FlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));

% amplitude scaling: spectrum 1
fm.mrsi.specScaleLab    = text('Position',[-0.13, 0.6298],'String','Scale');
fm.mrsi.spec1ScaleFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                    'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Scale==1,...
                                    'Position',[.12 .6082 .03 .03],'Callback','SP2_MRSI_Spec1ScaleFlagUpdate',...
                                    'TooltipString',sprintf('Amplitude scaling [1]'));
fm.mrsi.spec1ScaleDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleDec3');
fm.mrsi.spec1ScaleDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleDec2');
fm.mrsi.spec1ScaleDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleDec1');
fm.mrsi.spec1ScaleVal   = uicontrol('Style','Edit','Position', [161 430 55 18],'String',sprintf('%.3f',mrsi.spec1.scale),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1ScaleUpdate');
fm.mrsi.spec1ScaleInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleInc1');
fm.mrsi.spec1ScaleInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleInc2');
fm.mrsi.spec1ScaleInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ScaleInc3');
fm.mrsi.spec1ScaleReset = uicontrol('Style','Pushbutton','String','R','Position',[285 430 22 18],'Callback','SP2_MRSI_Spec1ScaleReset');

% amplitude scaling: spectrum 2
fm.mrsi.spec2ScaleFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                    'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Scale==1,...
                                    'Position',[.55 .6082 .03 .03],'Callback','SP2_MRSI_Spec2ScaleFlagUpdate',...
                                    'TooltipString',sprintf('Amplitude scaling [1]'));
fm.mrsi.spec2ScaleDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleDec3');
fm.mrsi.spec2ScaleDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleDec2');
fm.mrsi.spec2ScaleDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleDec1');
fm.mrsi.spec2ScaleVal   = uicontrol('Style','Edit','Position', [419 430 55 18],'String',sprintf('%.3f',mrsi.spec2.scale),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2ScaleUpdate');
fm.mrsi.spec2ScaleInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleInc1');
fm.mrsi.spec2ScaleInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleInc2');
fm.mrsi.spec2ScaleInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 430 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ScaleInc3');
fm.mrsi.spec2ScaleReset = uicontrol('Style','Pushbutton','String','R','Position',[543  430 22 18],'Callback','SP2_MRSI_Spec2ScaleReset');
fm.mrsi.syncScale       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncScale,'Position',[.96 .6082 .03 .03],...
                                 'Callback','SP2_MRSI_SyncScaleFlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));

% frequency shift: spectrum 1          
fm.mrsi.specShiftLab    = text('Position',[-0.13, 0.5859],'String','Shift');
fm.mrsi.spec1ShiftFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                    'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Shift==1,...
                                    'Position',[.12 .5726 .03 .03],'Callback','SP2_MRSI_Spec1ShiftFlagUpdate',...
                                    'TooltipString',sprintf('Spectral shift [Hz]'));
fm.mrsi.spec1ShiftDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftDec3');
fm.mrsi.spec1ShiftDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftDec2');
fm.mrsi.spec1ShiftDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftDec1');
fm.mrsi.spec1ShiftVal   = uicontrol('Style','Edit','Position', [161 405 55 18],'String',sprintf('%.3f',mrsi.spec1.shift),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1ShiftUpdate');
fm.mrsi.spec1ShiftInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftInc1');
fm.mrsi.spec1ShiftInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftInc2');
fm.mrsi.spec1ShiftInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1ShiftInc3');
fm.mrsi.spec1ShiftReset = uicontrol('Style','Pushbutton','String','R','Position',[285 405 22 18],'Callback','SP2_MRSI_Spec1ShiftReset');

% frequency shift: spectrum 2
fm.mrsi.spec2ShiftFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                    'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Shift==1,...
                                    'Position',[.55 .5726 .03 .03],'Callback','SP2_MRSI_Spec2ShiftFlagUpdate',...
                                    'TooltipString',sprintf('Spectral shift [Hz]'));
fm.mrsi.spec2ShiftDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftDec3');
fm.mrsi.spec2ShiftDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftDec2');
fm.mrsi.spec2ShiftDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftDec1');
fm.mrsi.spec2ShiftVal   = uicontrol('Style','Edit','Position', [419 405 55 18],'String',sprintf('%.3f',mrsi.spec2.shift),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2ShiftUpdate');
fm.mrsi.spec2ShiftInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftInc1');
fm.mrsi.spec2ShiftInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftInc2');
fm.mrsi.spec2ShiftInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 405 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2ShiftInc3');
fm.mrsi.spec2ShiftReset = uicontrol('Style','Pushbutton','String','R','Position',[543  405 22 18],'Callback','SP2_MRSI_Spec2ShiftReset');
fm.mrsi.syncShift       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                 'Normalized','Value',flag.mrsiSyncShift,'Position',[.96 .5726 .03 .03],...
                                 'Callback','SP2_MRSI_SyncShiftFlagUpdate','TooltipString',...
                                 sprintf('Apply modifications to both FID 1 and FID 2'));

% baseline offset: spectrum 1          
fm.mrsi.specOffsetLab    = text('Position',[-0.13, 0.5420],'String','Offset');
fm.mrsi.spec1OffsetFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                     'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec1Offset==1,...
                                     'Position',[.12 .537 .03 .03],'Callback','SP2_MRSI_Spec1OffsetFlagUpdate',...
                                     'TooltipString',sprintf('Baseline offset [a.u.]'));
fm.mrsi.spec1OffsetDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[95 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetDec3');
fm.mrsi.spec1OffsetDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[117 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetDec2');
fm.mrsi.spec1OffsetDec1  = uicontrol('Style','Pushbutton','String','<','Position',[139 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetDec1');
fm.mrsi.spec1OffsetVal   = uicontrol('Style','Edit','Position', [161 380 55 18],'String',sprintf('%.0f',mrsi.spec1.offset),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec1OffsetUpdate');
fm.mrsi.spec1OffsetInc1  = uicontrol('Style','Pushbutton','String','>','Position',[216 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetInc1');
fm.mrsi.spec1OffsetInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[238 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetInc2');
fm.mrsi.spec1OffsetInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[260 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec1OffsetInc3');
fm.mrsi.spec1OffsetReset = uicontrol('Style','Pushbutton','String','R','Position',[285 380 22 18],'Callback','SP2_MRSI_Spec1OffsetReset');

% baseline offset: spectrum 2
fm.mrsi.spec2OffsetFlag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,...
                                     'FontSize',10,'Units','Normalized','Value',flag.mrsiSpec2Offset==1,...
                                     'Position',[.55 .537 .03 .03],'Callback','SP2_MRSI_Spec2OffsetFlagUpdate',...
                                     'TooltipString',sprintf('Baseline offset [a.u.]'));
fm.mrsi.spec2OffsetDec3  = uicontrol('Style','Pushbutton','String','<<<','Position',[353 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetDec3');
fm.mrsi.spec2OffsetDec2  = uicontrol('Style','Pushbutton','String','<<','Position',[375 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetDec2');
fm.mrsi.spec2OffsetDec1  = uicontrol('Style','Pushbutton','String','<','Position',[397 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetDec1');
fm.mrsi.spec2OffsetVal   = uicontrol('Style','Edit','Position', [419 380 55 18],'String',sprintf('%.0f',mrsi.spec2.offset),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_Spec2OffsetUpdate');
fm.mrsi.spec2OffsetInc1  = uicontrol('Style','Pushbutton','String','>','Position',[474 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetInc1');
fm.mrsi.spec2OffsetInc2  = uicontrol('Style','Pushbutton','String','>>','Position',[496 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetInc2');
fm.mrsi.spec2OffsetInc3  = uicontrol('Style','Pushbutton','String','>>>','Position',[518 380 22 18],'FontWeight','bold','Callback','SP2_MRSI_Spec2OffsetInc3');
fm.mrsi.spec2OffsetReset = uicontrol('Style','Pushbutton','String','R','Position',[543  380 22 18],'Callback','SP2_MRSI_Spec2OffsetReset');
fm.mrsi.syncOffset       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'FontSize',10,'Units',...
                                     'Normalized','Value',flag.mrsiSyncOffset,'Position',[.96 .537 .03 .03],...
                                     'Callback','SP2_MRSI_SyncOffsetFlagUpdate','TooltipString',...
                                     sprintf('Apply modifications to both FID 1 and FID 2'));

% separation line
fm.mrsi.line2 = text('Position',[-0.12, 0.5],'String','______________________________________________________________________');

% spectrum visualization: data format
fm.mrsi.formatLab   = text('Position',[-0.13, 0.45],'String','Format');
fm.mrsi.formatReal  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Real', ...
                                'Value',flag.mrsiFormat==1,'Position',[.13 .46 .15 .03],'Callback','SP2_MRSI_FormatRealUpdate');
fm.mrsi.formatImag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Imag', ...
                                'Value',flag.mrsiFormat==2,'Position',[.22 .46 .15 .03],'Callback','SP2_MRSI_FormatImagUpdate');
fm.mrsi.formatMagn  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Magn', ...
                                'Value',flag.mrsiFormat==3,'Position',[.305 .46 .15 .03],'Callback','SP2_MRSI_FormatMagnUpdate');
fm.mrsi.formatPhase = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Phase', ...
                                'Value',flag.mrsiFormat==4,'Position',[.40 .46 .15 .03],'Callback','SP2_MRSI_FormatPhaseUpdate');

% spectrum visualization: ppm calibration
fm.mrsi.ppmCalibLab = text('Position',[0.55, 0.450],'String','Calibration');
fm.mrsi.ppmCalib    = uicontrol('Style','Edit','Position', [405 327 50 18],'String',num2str(mrsi.ppmCalib),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmCalibUpdate',...
                                'TooltipString',sprintf('Frequency [ppm] calibration of center (water) frequency'));
fm.mrsi.ppmAssign   = uicontrol('Style','Edit','Position', [470 327 45 18],'String',num2str(mrsi.ppmAssign),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmAssignUpdate',...
                                'TooltipString',sprintf('Frequency [ppm] value to be assigned to selected peak'));
fm.mrsi.ppmAssignToPeak = uicontrol('Style','Pushbutton','String','Assign','Position',[515 327 55 18],...
                                    'FontSize',pars.fontSize,'Callback','SP2_MRSI_PpmAssignToPeak',...
                                    'TooltipString',sprintf('Assigns ppm value (to the left) to the peak\nthat is selected in spectrum 1'));
                       
% spectrum visualization: ppm position display
fm.mrsi.ppmShowPosLab    = text('Position',[0.55, 0.40],'String','Position');
fm.mrsi.ppmShowPos       = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.mrsiPpmShowPos,...
                                     'Position',[0.64 0.42 .03 .03],'Callback','SP2_MRSI_PpmShowPosFlagUpdate');
fm.mrsi.ppmShowPosVal    = uicontrol('Style','Edit','Position',[405 298 50 18],'String',num2str(mrsi.ppmShowPos),'BackGroundColor',pars.bgColor,...
                                     'Callback','SP2_MRSI_PpmShowPosValUpdate','TooltipString',sprintf('Frequency [ppm] position to be displayed'));
fm.mrsi.ppmShowPosAssign = uicontrol('Style','Pushbutton','String','Assign','Position',[455 298 55 18],...
                                     'FontSize',pars.fontSize,'Callback','SP2_MRSI_PpmShowPosAssign',...
                                     'TooltipString',sprintf('Manual assignment of frequency position [ppm]'));
fm.mrsi.ppmShowPosMirr   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.mrsiPpmShowPosMirr,...
                                     'String','Mirror','Position',[0.87 0.42 .10 .03],'Callback','SP2_MRSI_PpmShowPosMirrorUpdate',...
                                     'TooltipString',sprintf('Display also the frequency mirrored\naround the synthesizer (/water) position'));

% spectrum visualization: ppm window
fm.mrsi.ppmShowLab    = text('Position',[-0.13, 0.40],'String','Frequ.');
fm.mrsi.ppmShowFull   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Full', ...
                                  'Value',flag.mrsiPpmShow==0,'Position',[.13 .42 .15 .03],'Callback','SP2_MRSI_PpmShowFullUpdate');
fm.mrsi.ppmShowDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
                                  'Value',flag.mrsiPpmShow==1,'Position',[.21 .42 .15 .03],'Callback','SP2_MRSI_PpmShowDirectUpdate');
fm.mrsi.ppmShowMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[145 298 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmShowMinDecr');
fm.mrsi.ppmShowMin     = uicontrol('Style','Edit','Position', [163 298 40 18],'String',sprintf('%.2f',mrsi.ppmShowMin),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmShowWinUpdate');
fm.mrsi.ppmShowMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[203 298 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmShowMinIncr');
fm.mrsi.ppmShowMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[226 298 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmShowMaxDecr');
fm.mrsi.ppmShowMax     = uicontrol('Style','Edit','Position', [244 298 40 18],'String',sprintf('%.2f',mrsi.ppmShowMax),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmShowWinUpdate');
fm.mrsi.ppmShowMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[284 298 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmShowMaxIncr');

% spectrum visualization: amplitude window
fm.mrsi.amplLab    = text('Position',[-0.13, 0.35],'String','Ampl.');
fm.mrsi.amplAuto   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Auto', ...
                               'Value',flag.mrsiAmpl==0,'Position',[.13 .38 .15 .03],'Callback','SP2_MRSI_AmplAutoUpdate');
fm.mrsi.amplDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
                               'Value',flag.mrsiAmpl==1,'Position',[.21 .38 .15 .03],'Callback','SP2_MRSI_AmplDirectUpdate');
fm.mrsi.amplMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[145 270 18 18],'FontWeight','bold','Callback','SP2_MRSI_AmplWinMinDecr');
fm.mrsi.amplMin     = uicontrol('Style','Edit','Position', [163 270 50 18],'String',sprintf('%.0f',mrsi.amplMin),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_AmplWinUpdate');
fm.mrsi.amplMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[213 270 18 18],'FontWeight','bold','Callback','SP2_MRSI_AmplWinMinIncr');
fm.mrsi.amplMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[236 270 18 18],'FontWeight','bold','Callback','SP2_MRSI_AmplWinMaxDecr');
fm.mrsi.amplMax     = uicontrol('Style','Edit','Position', [254 270 50 18],'String',sprintf('%.0f',mrsi.amplMax),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_AmplWinUpdate');
fm.mrsi.amplMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[304 270 18 18],'FontWeight','bold','Callback','SP2_MRSI_AmplWinMaxIncr');

%--- FWHM / integral area definition ---
fm.mrsi.ppmTargetLab     = text('Position',[-0.13, 0.30],'String','Target');
fm.mrsi.ppmTargetMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[75 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmTargetMinDecr');
fm.mrsi.ppmTargetMin     = uicontrol('Style','Edit','Position', [93 242 45 18],'String',sprintf('%.2f',mrsi.ppmTargetMin),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmTargetWinUpdate');
fm.mrsi.ppmTargetMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[138 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmTargetMinIncr');
fm.mrsi.ppmTargetMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[161 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmTargetMaxDecr');
fm.mrsi.ppmTargetMax     = uicontrol('Style','Edit','Position', [179 242 45 18],'String',sprintf('%.2f',mrsi.ppmTargetMax),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmTargetWinUpdate');
fm.mrsi.ppmTargetMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[224 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmTargetMaxIncr');

%--- noise area definition ---
fm.mrsi.ppmNoiseLab     = text('Position',[-0.13, 0.25],'String','Noise');
fm.mrsi.ppmNoiseMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[75 213 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmNoiseMinDecr');
fm.mrsi.ppmNoiseMin     = uicontrol('Style','Edit','Position', [93 213 45 18],'String',sprintf('%.2f',mrsi.ppmNoiseMin),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmNoiseWinUpdate');
fm.mrsi.ppmNoiseMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[138 213 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmNoiseMinIncr');
fm.mrsi.ppmNoiseMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[161 213 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmNoiseMaxDecr');
fm.mrsi.ppmNoiseMax     = uicontrol('Style','Edit','Position', [179 213 45 18],'String',sprintf('%.2f',mrsi.ppmNoiseMax),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PpmNoiseWinUpdate');
fm.mrsi.ppmNoiseMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[224 213 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmNoiseMaxIncr');

%--- noise area definition ---
fm.mrsi.offsetLab  = text('Position',[0.44, 0.30],'String','Offset');

fm.mrsi.offsetPpmFlag = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Range', ...
                                  'Value',flag.mrsiOffset,'Position',[.540 .34 .10 .03],'Callback','SP2_MRSI_OffsetPpmWinFlagUpdate');
fm.mrsi.ppmOffsetMinDecr = uicontrol('Style','Pushbutton','String','-','Position',[381 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmOffsetMinDecr');
fm.mrsi.ppmOffsetMin     = uicontrol('Style','Edit','Position', [399 242 40 18],'String',sprintf('%.2f',mrsi.ppmOffsetMin),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_OffsetPpmWinUpdate');
fm.mrsi.ppmOffsetMinIncr = uicontrol('Style','Pushbutton','String','+','Position',[439 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmOffsetMinIncr');
fm.mrsi.ppmOffsetMaxDecr = uicontrol('Style','Pushbutton','String','-','Position',[462 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmOffsetMaxDecr');
fm.mrsi.ppmOffsetMax     = uicontrol('Style','Edit','Position', [480 242 40 18],'String',sprintf('%.2f',mrsi.ppmOffsetMax),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_OffsetPpmWinUpdate');
fm.mrsi.ppmOffsetMaxIncr = uicontrol('Style','Pushbutton','String','+','Position',[520 242 18 18],'FontWeight','bold','Callback','SP2_MRSI_PpmOffsetMaxIncr');
fm.mrsi.offsetValFlag    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Value', ...
                                     'Value',~flag.mrsiOffset,'Position',[.540 .30 .10 .03],'Callback','SP2_MRSI_OffsetValueFlagUpdate');
fm.mrsi.offsetDec3    = uicontrol('Style','Pushbutton','String','<<<','Position',[381 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetDec3');
fm.mrsi.offsetDec2    = uicontrol('Style','Pushbutton','String','<<','Position',[403 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetDec2');
fm.mrsi.offsetDec1    = uicontrol('Style','Pushbutton','String','<','Position',[425 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetDec1');
fm.mrsi.offsetVal     = uicontrol('Style','Edit','Position', [447 213 70 18],'String',sprintf('%.1f',mrsi.offsetVal),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_OffsetValueUpdate');
fm.mrsi.offsetInc1    = uicontrol('Style','Pushbutton','String','>','Position',[517 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetInc1');
fm.mrsi.offsetInc2    = uicontrol('Style','Pushbutton','String','>>','Position',[539 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetInc2');
fm.mrsi.offsetInc3    = uicontrol('Style','Pushbutton','String','>>>','Position',[561 213 22 18],'FontWeight','bold','Callback','SP2_MRSI_OffsetInc3');
fm.mrsi.offsetReset   = uicontrol('Style','Pushbutton','String','Zero','Position',[381 193 60 18],...
                                  'FontSize',pars.fontSize,'Callback','SP2_MRSI_OffsetZero','TooltipString',sprintf('Reset of amplitude offset\nfor SNR, FWHM & Integral calcuations'));
fm.mrsi.offsetAssign  = uicontrol('Style','Pushbutton','String','Assign','Position',[441 193 60 18],'FontSize',pars.fontSize,'Callback','SP2_MRSI_OffsetAssign',...
                                  'TooltipString',sprintf('Manual assignment of amplitude offset\nfor SNR, FWHM & Integral calcuations'));
                              
%--- analysis options ---
fm.mrsi.anaLab    = text('Position',[-0.13, 0.20],'String','Analysis');
fm.mrsi.anaSNR    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','SNR', ...
                              'Value',flag.mrsiAnaSNR,'Position',[.13 .26 .15 .03],'Callback','SP2_MRSI_AnaSnrUpdate');
fm.mrsi.anaFWHM   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','FWHM', ...
                              'Value',flag.mrsiAnaFWHM,'Position',[.23 .26 .15 .03],'Callback','SP2_MRSI_AnaFwhmUpdate');
fm.mrsi.anaIntegr = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Integral', ...
                              'Value',flag.mrsiAnaIntegr,'Position',[.33 .26 .15 .03],'Callback','SP2_MRSI_AnaIntegralUpdate');
                          
%--- polynomial baseline correction ---
fm.mrsi.baseCorr  = uicontrol('Style','Pushbutton','String','Baseline Handling','FontWeight','bold','Position',[10 130 140 20],...
                              'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaseMain',...
                              'TooltipString',sprintf('Open window for baseline handling'));

%--- spectral processing ---
fm.mrsi.plotFid1Orig = uicontrol('Style','Pushbutton','String','FID 1 Orig','FontWeight','bold','Position',[10 80 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFid1Orig');
fm.mrsi.plotFid2Orig = uicontrol('Style','Pushbutton','String','FID 2 Orig','FontWeight','bold','Position',[95 80 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFid2Orig');
fm.mrsi.plotFid1     = uicontrol('Style','Pushbutton','String','FID 1','FontWeight','bold','Position',[10 60 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFid1');
fm.mrsi.plotFid2     = uicontrol('Style','Pushbutton','String','FID 2','FontWeight','bold','Position',[95 60 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFid2');
fm.mrsi.procData1    = uicontrol('Style','Pushbutton','String','Proc 1','FontWeight','bold','Position',[10 40 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcData1(1);');
fm.mrsi.procData2    = uicontrol('Style','Pushbutton','String','Proc 2','FontWeight','bold','Position',[95 40 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcData2(1);');
fm.mrsi.plotSpec1    = uicontrol('Style','Pushbutton','String','Spec 1','FontWeight','bold','Position',[10 20 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotSpec1');
fm.mrsi.plotSpec2    = uicontrol('Style','Pushbutton','String','Spec 2','FontWeight','bold','Position',[95 20 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotSpec2');

%--- FID combinations ---                             
fm.mrsi.fidSuperpos  = uicontrol('Style','Pushbutton','String','FID Super','FontWeight','bold','Position',[180 60 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFidSuperpos');
fm.mrsi.fidSum       = uicontrol('Style','Pushbutton','String','FID Sum','FontWeight','bold','Position',[180 40 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFidSum');
fm.mrsi.fidDiff      = uicontrol('Style','Pushbutton','String','FID Diff','FontWeight','bold','Position',[180 20 80 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotFidDiff');

%--- spectrum combinations ---
fm.mrsi.specSuperpos = uicontrol('Style','Pushbutton','String','Spec Super','FontWeight','bold','Position',[265 60 90 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotSpecSuperpos');
fm.mrsi.specSum      = uicontrol('Style','Pushbutton','String','Spec Sum','FontWeight','bold','Position',[265 40 90 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotSpecSum');
fm.mrsi.specDiff     = uicontrol('Style','Pushbutton','String','Spec Diff','FontWeight','bold','Position',[265 20 90 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ProcAndPlotSpecDiff');

%--- freeze/keep figure ---
fm.mrsi.updateCalc   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Update', ...
                                 'Value',flag.mrsiUpdateCalc,'Position',[.62 .085 .12 .03],'Callback','SP2_MRSI_UpdateCalcUpdate',...
                                 'TooltipString',sprintf('Automated processing if needed and update every time a parameter is changed'));
fm.mrsi.keepFigure   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Keep', ...
                                 'Value',flag.mrsiKeepFig,'Position',[.62 .055 .10 .03],'Callback','SP2_MRSI_KeepFigureUpdate',...
                                 'TooltipString',sprintf('1: figures are kept, ie. parameter changes are plotted to new figures\n0: Parameter changes are updated in the same figure'));
fm.mrsi.verbose      = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.verbose,...
                                 'String','Verbose','Position',[0.62 0.025 .17 .03],'Callback','SP2_MRSI_VerboseFlagUpdate');

%--- additional analysis options ---
fm.mrsi.jdeEffWin    = uicontrol('Style','Pushbutton','String','JDE Efficiency','Position',[500 60 85 20],'Callback','SP2_MRSI_JdeEfficiencyMain',...
                                 'TooltipString',sprintf('JDE efficiency determination'));
fm.mrsi.special      = uicontrol('Style','Pushbutton','String','SPECIAL','Position',[500 40 85 20],'Callback','SP2_MRSI_Special',...
                                 'TooltipString',sprintf('SPECIAL'));

                             
%--- window update ---
SP2_MRSI_MrsiWinUpdate

end
