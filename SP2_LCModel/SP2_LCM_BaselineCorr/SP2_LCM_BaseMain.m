%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_LCM_BaseMain
%%
%%  Create window for baseline manipulation.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag lcm fm

FCTNAME = 'SP2_LCM_BaseMain';


%--- consistency check ---
if isfield(fm.lcm,'base')              % ROI init open
    if ishandle(fm.lcm.base.fig)
        figure(fm.lcm.base.fig)
    else
        fm.lcm.base.fig = figure;
        set(fm.lcm.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                             'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
        axes('Visible','off');
    end
else
    fm.lcm.base.fig = figure;
    set(fm.lcm.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                        'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
    axes('Visible','off');
end
            

%--- polynomial ---
fm.lcm.base.polyTitle    = text('Position',[-0.13, 1.03],'String','Polynomial','FontWeight','bold');
% fm.lcm.base.anaBaseCorr     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
%                                          'Value',flag.lcmAnaBaseCorr,'Position',[.13 .22 .03 .03],'Callback','SP2_LCM_AnaBaseCorrUpdate');
fm.lcm.base.polyOrderL    = text('Position',[-0.13, 0.93],'String','Order');
fm.lcm.base.polyOrder     = uicontrol('Style','Edit','Position', [60 638 30 18],'String',sprintf('%.0f',lcm.basePolyOrder),'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_PolyOrderUpdate');
fm.lcm.base.polyPpmLabel  = text('Position',[0.11, 0.93],'String','Range');
fm.lcm.base.polyPpmStr    = uicontrol('Style','Edit','Position', [170 638 300 18],'String',lcm.basePolyPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_PolyPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for polynomial baseline analysis\n(e.g. 1.2:1.8 7:8.3)'));
fm.lcm.base.polyCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(1,0);');  % spec 1, do not apply
fm.lcm.base.polyCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(2,0);');  % spec 2, do not apply
fm.lcm.base.polyCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 610 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(3,0);');  % export, do not apply
fm.lcm.base.polyCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(1,1);');  % spec 1, apply correction
fm.lcm.base.polyCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 610 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(2,1);');  % spec 2, apply correction
fm.lcm.base.polyCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 610 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrPoly(3,1);');  % export, apply correction

%--- interpolation ---
fm.lcm.base.interpTitle = text('Position',[-0.13, 0.6],'String','Interpolation','FontWeight','bold');
fm.lcm.base.interpLab     = text('Position',[-0.13, 0.52],'String','Mode');
fm.lcm.base.interpNearest = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Nearest','Units','Normalized', ...
                                       'Value',flag.lcmBaseInterpMode==1,'Position',[.11 0.703 .10 .03],'Callback','SP2_LCM_InterpModeNearest',...
                                       'TooltipString',sprintf('Interpolation mode: Nearest neighbor'));
fm.lcm.base.interpLinear  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Linear','Units','Normalized', ...
                                       'Value',flag.lcmBaseInterpMode==2,'Position',[.225 0.703 .10 .03],'Callback','SP2_LCM_InterpModeLinear',...
                                       'TooltipString',sprintf('Interpolation mode: Linear'));
fm.lcm.base.interpSpline  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Spline','Units','Normalized', ...
                                       'Value',flag.lcmBaseInterpMode==3,'Position',[.33 0.703 .10 .03],'Callback','SP2_LCM_InterpModeSpline',...
                                       'TooltipString',sprintf('Interpolation mode: Piece-wise cubic spline'));
fm.lcm.base.interpCubic   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Cubic','Units','Normalized', ...
                                       'Value',flag.lcmBaseInterpMode==4,'Position',[.43 0.703 .10 .03],'Callback','SP2_LCM_InterpModeCubic',...
                                       'TooltipString',sprintf('Interpolation mode: Shape-preserving piecewise cubic interpolation'));
fm.lcm.base.interpPpmLabel  = text('Position',[-0.13, 0.42],'String','Range');
fm.lcm.base.interpPpmStr    = uicontrol('Style','Edit','Position', [65 463 300 18],'String',lcm.baseInterpPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_InterpPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for baseline interpolation analysis\n(e.g. 1.2:1.8 7:8.3)'));
fm.lcm.base.interpCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(1,0);');  % spec 1, do not apply
fm.lcm.base.interpCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(2,0);');  % spec 2, do not apply
fm.lcm.base.interpCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 435 80 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(3,0);');  % export, do not apply
fm.lcm.base.interpCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(1,1);');  % spec 1, apply correction
fm.lcm.base.interpCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 435 60 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(2,1);');  % spec 2, apply correction
fm.lcm.base.interpCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 435 80 20],...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BaselineCorrInterp(3,1);');  % export, apply correction

%--- singular value decomposition ---
fm.lcm.base.svdTitle      = text('Position',[-0.13, 0.0],'String','Hankel Singular Value Decomposition (SVD)','FontWeight','bold');
fm.lcm.base.svdPeakNLab   = text('Position',[-0.13, -0.10],'String','Peaks');
fm.lcm.base.svdPeakN      = uicontrol('Style','Edit','Position', [63 285 35 18],'String',num2str(lcm.baseSvdPeakN),'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_SvdPeakNumberUpdate');
fm.lcm.base.svdPpmLabel   = text('Position',[0.11, -0.10],'String','Range');
fm.lcm.base.svdPpmStr     = uicontrol('Style','Edit','Position', [170 285 300 18],'String',lcm.baseSvdPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_SvdPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for HSVD analysis\n(e.g. 4.3:5.3 for water removal)'));
fm.lcm.base.svdCalcSpec1  = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakAnalysis(1);',...
                                       'TooltipString',sprintf('Calculation of SVD for spectrum 1\n(the correction is not applied)'));       % SVD of spec 1
fm.lcm.base.svdCalcSpec2  = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakAnalysis(2);',...
                                       'TooltipString',sprintf('Calculation of SVD for spectrum 2\n(the correction is not applied)'));       % SVD of spec 2
fm.lcm.base.svdCalcExpt   = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakAnalysis(3);',...
                                       'TooltipString',sprintf('Calculation of SVD for current export spectrum\n(the correction is not applied)'));  % SVD of export spectrum
fm.lcm.base.svdCorrSpec1  = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakRemoval(1);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to spectrum 1'));                                     % apply peak removal to spec 1
fm.lcm.base.svdCorrSpec2  = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakRemoval(2);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to spectrum 2'));                                     % apply peak removal to spec 2
fm.lcm.base.svdCorrExpt   = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdPeakRemoval(3);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to current export spectrum'));                        % apply peak removal to export spectrum
fm.lcm.base.svdShowSpec   = uicontrol('Style','Pushbutton','String','Show SVD','FontWeight','bold','Position',[20 237 100 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SvdResultVisualization');  % SVD result visualization

%--- exit baseline tool ---
fm.lcm.base.exit = uicontrol('Style','Pushbutton','String','Exit','FontWeight','bold','Position',[500 20 70 20],...
                              'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_ExitBaseMain');

                                   
%--- window update ---
SP2_LCM_BaseWinUpdate


end
