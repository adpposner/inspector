%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function INSPECTOR( varargin )
%%
%%  One-stop-shop spectroscopy software.
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars flag inspectorroot

%Add all to path
genpath('.');
addpath(genpath('.'));
%--- switch warnings off ---
%warning off;
inspectorroot = fileparts(mfilename('fullpath'));
SP2_Logger.log("%s\n",inspectorroot);




%--- check for open INSPECTOR ---
% if isfield(pars,'spxOpen')
%     SP2_Logger.log('\nOpen INSPECTOR found. Start of second one aborted.\n\n');
%     return
% end

%--- license handling ---
pars.licLimDayStr = '12/01/2023';                       % expiration date of limited-term license, format: mm/dd/yyyy
if datenum(pars.licLimDayStr)-now<0                     % expired
    SP2_Logger.log('\n\nINSPECTOR limited-term license expired.\nObtain updated software/license to proceed.\n\n');
    pause(5)
    return   
elseif datenum(pars.licLimDayStr)-now<30                % 30-day warning
    SP2_Logger.log('\n\nINSPECTOR limited-term license is expiring in less than 30 days.\nObtain updated software/license soon.\n\n');
    pause(5)
end

%addpath('SP2_global','SP2_Data');
%--- read user defaults (last usage) ---
if nargin==0
    if ~SP2_ReadDefaults
        return
    end
elseif nargin==1
    if ~SP2_ReadDefaults(SP2_Check4StrR(varargin{1}))
        return
    end
else
    SP2_Logger.log('%s ->\nWrong number of input arguments. Program aborted.\n',FCTNAME);
    return
end

%--- ensure upper left corner sits in upper left corner of screen ---
set(0,'units','pixels');
screenSizePix = get(0,'screensize');
frameBufferX   = 10;           % frame only
% frameBufferY   = 57;         % frame pluse page buttons (on my PC)
frameBufferY   = 100;          % frame pluse page buttons (on my PC)
pars.figPos(1) = frameBufferX;
pars.figPos(2) = screenSizePix(4) - pars.mainDims(4) - frameBufferY;
if screenSizePix<pars.mainDims(4)+frameBufferY
    SP2_Logger.log('\n--- WARNING ---\nPixel size of INSPECTOR GUI exceeds your screen size.\nSelect the maximal screen resolution.\n\n');
end
% SP2_Logger.log('pars.figPos(1) = %.0f\n',pars.figPos(1));
% SP2_Logger.log('pars.figPos(2) = %.0f\n',pars.figPos(2));

%--- compile for publishing ---
flag.compile4publ = 1;

%%%%%%%%%%%%%%%Create experimental data %%%%%%%%%%%%%%%%%%%%%
expt = ExptData();

%--- main figure creation ---
% if flag.compile4publ
%     fmfig = figure('CloseRequestFcn',@SP2_Exit_ExitFct);
% else
fmfig = figure;
% end
set(fmfig,'NumberTitle','off','Position',0.999*[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)],...
    'Color',pars.bgColor,'MenuBar','none','Resize','off');
axes('Visible','off');

%--- sheet creation ---
datatab = uimenu('Label','Data','Callback',{@SP2_Data_DataMain,expt});
if ~flag.compile4publ
    uimenu('Label','Stability','Callback','SP2_Stab_StabilityMain');
    uimenu('Label','MM','Callback','SP2_MM_MacroMain');
end
uimenu('Label','Processing','Callback','SP2_Proc_ProcessMain');
uimenu('Label','T1/T2','Callback','SP2_T1T2_T1T2Main');
if ~flag.compile4publ
    uimenu('Label','MRSI','Callback','SP2_MRSI_MrsiMain');
end
uimenu('Label','Synthesis','Callback','SP2_Syn_SynthesisMain');
uimenu('Label','MARSS','Callback','SP2_MARSS_MARSSMain');
uimenu('Label','LCM','Callback','SP2_LCM_LCModelMain');
if ~flag.compile4publ
    uimenu('Label','Tools','Callback','SP2_Tools_ToolsMain');
end
uimenu('Label','Manual','Callback','SP2_Man_ManualMain');
uimenu('Label','Exit','Callback','SP2_Exit_ExitMain');

%--- consistency check ---
if flag.compile4publ
    if flag.fmWin==3 || flag.fmWin==5 || flag.fmWin==6
        flag.fmWin = 1;     % reset to Data page
    end
end

%--- init starting sheet ---
switch flag.fmWin
    case 1
        fm.data.fake = uicontrol('Style','RadioButton');    % fake gui init
        SP2_Data_DataMain(datatab,'dummy',expt)
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        %SP2_Data_DataMain
    case 2
        fm.proc.fake = uicontrol('Style','RadioButton');    % fake gui init
        SP2_Stab_StabilityMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_Stab_StabilityMain
    case 3
        fm.mm.fake = uicontrol('Style','RadioButton');      % fake gui init
        SP2_MM_MacroMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_MM_MacroMain
    case 4
        fm.proc.fake = uicontrol('Style','RadioButton');    % fake gui init
        SP2_Proc_ProcessMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_Proc_ProcessMain
    case 5
        fm.t1t2.fake = uicontrol('Style','RadioButton');    % fake gui init
        SP2_T1T2_T1T2Main
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_T1T2_T1T2Main
    case 6
        fm.mrsi.fake = uicontrol('Style','RadioButton');    % fake gui init
        SP2_MRSI_MrsiMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_MRSI_MrsiMain
    case 7
        fm.lcm.fake = uicontrol('Style','RadioButton');     % fake gui init
        SP2_LCM_LCModelMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_LCM_LCModelMain
    case 8
        fm.lcm.fake = uicontrol('Style','RadioButton');     % fake gui init
        SP2_Syn_SynthesisMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_Syn_SynthesisMain
    case 9
        fm.lcm.fake = uicontrol('Style','RadioButton');     % fake gui init
        SP2_Tools_ToolsMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_Tools_ToolsMain   
    case 10
        fm.marss.fake = uicontrol('Style','RadioButton');     % fake gui init
        SP2_MARSS_MARSSMain
        set(fmfig,'Position',[pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])
        SP2_MARSS_MARSSMain   
end

%TODO--- function inclusion for stand-alone application ---
% SP2_CreateFctList4StandAlone
%SP2_FctList4StandAlone

%--- print software info at program start ---
SP2_Logger.log('\n---   INSPECTOR   ---\n');
SP2_Logger.log('Magnetic Resonance Spectroscopy Software\n');
SP2_Logger.log('Version 11-2021\n');
SP2_Logger.log('by Christoph Juchem\n');
SP2_Logger.log('MR SCIENCE Laboratory\n');
SP2_Logger.log('Columbia University\n');
SP2_Logger.log('All Rights Reserved\n\n');




end
