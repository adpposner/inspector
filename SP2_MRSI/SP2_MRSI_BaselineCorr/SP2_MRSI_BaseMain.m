%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_MRSI_BaseMain
%%
%%  Create window for baseline manipulation.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag mrsi fm

FCTNAME = 'SP2_MRSI_BaseMain';


%--- consistency check ---
if isfield(fm.mrsi,'base')              % ROI init open
    if ishandle(fm.mrsi.base.fig)
        figure(fm.mrsi.base.fig)
    else
        fm.mrsi.base.fig = figure;
        set(fm.mrsi.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                             'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
        axes('Visible','off');
    end
else
    fm.mrsi.base.fig = figure;
    set(fm.mrsi.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                        'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
    axes('Visible','off');
end
            

%--- polynomial ---
fm.mrsi.base.polyTitle    = text('Position',[-0.13, 1.03],'String','Polynomial','FontWeight','bold');
% fm.mrsi.base.anaBaseCorr     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
%                                          'Value',flag.mrsiAnaBaseCorr,'Position',[.13 .22 .03 .03],'Callback','SP2_MRSI_AnaBaseCorrUpdate');
fm.mrsi.base.polyOrderL    = text('Position',[-0.13, 0.93],'String','Order');
fm.mrsi.base.polyOrder     = uicontrol('Style','Edit','Position', [60 638 30 18],'String',sprintf('%.0f',mrsi.basePolyOrder),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PolyOrderUpdate');
fm.mrsi.base.polyPpmLabel  = text('Position',[0.11, 0.93],'String','Range');
fm.mrsi.base.polyPpmStr    = uicontrol('Style','Edit','Position', [170 638 300 18],'String',mrsi.basePolyPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_PolyPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for polynomial baseline analysis\n(e.g. 1.2:1.8 7:8.3)'));
fm.mrsi.base.polyCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(1,0);');  % spec 1, do not apply
fm.mrsi.base.polyCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(2,0);');  % spec 2, do not apply
fm.mrsi.base.polyCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 610 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(3,0);');  % export, do not apply
fm.mrsi.base.polyCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(1,1);');  % spec 1, apply correction
fm.mrsi.base.polyCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(2,1);');  % spec 2, apply correction
fm.mrsi.base.polyCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 610 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrPoly(3,1);');  % export, apply correction

%--- interpolation ---
fm.mrsi.base.interpTitle = text('Position',[-0.13, 0.6],'String','Interpolation','FontWeight','bold');
fm.mrsi.base.interpLab     = text('Position',[-0.13, 0.52],'String','Mode');
fm.mrsi.base.interpNearest = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Nearest','Units','Normalized', ...
                                       'Value',flag.mrsiBaseInterpMode==1,'Position',[.11 0.703 .10 .03],'Callback','SP2_MRSI_InterpModeNearest',...
                                       'TooltipString',sprintf('Interpolation mode: Nearest neighbor'));
fm.mrsi.base.interpLinear  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Linear','Units','Normalized', ...
                                       'Value',flag.mrsiBaseInterpMode==2,'Position',[.225 0.703 .10 .03],'Callback','SP2_MRSI_InterpModeLinear',...
                                       'TooltipString',sprintf('Interpolation mode: Linear'));
fm.mrsi.base.interpSpline  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Spline','Units','Normalized', ...
                                       'Value',flag.mrsiBaseInterpMode==3,'Position',[.33 0.703 .10 .03],'Callback','SP2_MRSI_InterpModeSpline',...
                                       'TooltipString',sprintf('Interpolation mode: Piece-wise cubic spline'));
fm.mrsi.base.interpCubic   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Cubic','Units','Normalized', ...
                                       'Value',flag.mrsiBaseInterpMode==4,'Position',[.43 0.703 .10 .03],'Callback','SP2_MRSI_InterpModeCubic',...
                                       'TooltipString',sprintf('Interpolation mode: Shape-preserving piecewise cubic interpolation'));
fm.mrsi.base.interpPpmLabel  = text('Position',[-0.13, 0.42],'String','Range');
fm.mrsi.base.interpPpmStr    = uicontrol('Style','Edit','Position', [65 463 300 18],'String',mrsi.baseInterpPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_InterpPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for baseline interpolation analysis\n(e.g. 1.2:1.8 7:8.3)'));
fm.mrsi.base.interpCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(1,0);');  % spec 1, do not apply
fm.mrsi.base.interpCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(2,0);');  % spec 2, do not apply
fm.mrsi.base.interpCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 435 80 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(3,0);');  % export, do not apply
fm.mrsi.base.interpCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(1,1);');  % spec 1, apply correction
fm.mrsi.base.interpCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(2,1);');  % spec 2, apply correction
fm.mrsi.base.interpCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 435 80 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_BaselineCorrInterp(3,1);');  % export, apply correction

%--- singular value decomposition ---
fm.mrsi.base.svdTitle      = text('Position',[-0.13, 0.0],'String','Hankel Singular Value Decomposition (SVD)','FontWeight','bold');
fm.mrsi.base.svdPeakNLab   = text('Position',[-0.13, -0.10],'String','Peaks');
fm.mrsi.base.svdPeakN      = uicontrol('Style','Edit','Position', [63 285 35 18],'String',num2str(mrsi.baseSvdPeakN),'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_SvdPeakNumberUpdate');
fm.mrsi.base.svdPpmLabel   = text('Position',[0.11, -0.10],'String','Range');
fm.mrsi.base.svdPpmStr     = uicontrol('Style','Edit','Position', [170 285 300 18],'String',mrsi.baseSvdPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_MRSI_SvdPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for HSVD analysis\n(e.g. 4.3:5.3 for water removal)'));
fm.mrsi.base.svdCalcSpec1  = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakAnalysis(1);');  % SVD of spec 1
fm.mrsi.base.svdCalcSpec2  = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakAnalysis(2);');  % SVD of spec 2
fm.mrsi.base.svdCalcExpt   = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakAnalysis(3);');  % SVD of export spectrum
fm.mrsi.base.svdCorrSpec1  = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakRemoval(1);');  % apply peak removal to spec 1
fm.mrsi.base.svdCorrSpec2  = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakRemoval(2);');  % apply peak removal to spec 2
fm.mrsi.base.svdCorrExpt   = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdPeakRemoval(3);');  % apply peak removal to export spectrum
fm.mrsi.base.svdShowSpec   = uicontrol('Style','Pushbutton','String','Show SVD','FontWeight','bold','Position',[20 237 100 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_SvdResultVisualization');  % SVD result visualization

%--- exit baseline tool ---
fm.mrsi.base.exit = uicontrol('Style','Pushbutton','String','Exit','FontWeight','bold','Position',[500 20 70 20],...
                              'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_MRSI_ExitBaseMain');

                                   
%--- window update ---
SP2_MRSI_BaseWinUpdate

