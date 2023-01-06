%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Proc_BaseMain
%%
%%  Create window for baseline manipulation.
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag proc fm

FCTNAME = 'SP2_Proc_BaseMain';


%--- consistency check ---
if isfield(fm.proc,'base')              % ROI init open
    if ishandle(fm.proc.base.fig)
        figure(fm.proc.base.fig)
    else
        fm.proc.base.fig = figure;
        set(fm.proc.base.fig,'CloseRequestFcn',@SP2_Proc_ExitBaseMain);
        set(fm.proc.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                             'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
        axes('Visible','off');
    end
else
    fm.proc.base.fig = figure;
    set(fm.proc.base.fig,'CloseRequestFcn',@SP2_Proc_ExitBaseMain);
    set(fm.proc.base.fig,'NumberTitle','off','Position',pars.mainDims,'Color',pars.bgColor,...
                        'MenuBar','none','Resize','off','Name',' INSPECTOR: Baseline Tool');
    axes('Visible','off');
end
            

%--- polynomial ---
if flag.OS==1               % Linux
    fm.proc.base.polyTitle    = text('Position',[-0.13, 1.03],'String','Polynomial','FontWeight','bold','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.polyTitle    = text('Position',[-0.13, 1.045],'String','Polynomial','FontWeight','bold','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.polyTitle    = text('Position',[-0.13, 1.03],'String','Polynomial','FontWeight','bold','FontSize',pars.fontSize);
end
% fm.proc.base.anaBaseCorr     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized', ...
%                                          'Value',flag.procAnaBaseCorr,'Position',[.13 .22 .03 .03],'Callback','SP2_Proc_AnaBaseCorrUpdate');
if flag.OS==1               % Linux
    fm.proc.base.polyOrderL    = text('Position',[-0.13, 0.93],'String','Order','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.polyOrderL    = text('Position',[-0.13, 0.996],'String','Order','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.polyOrderL    = text('Position',[-0.13, 0.93],'String','Order','FontSize',pars.fontSize);
end
fm.proc.base.polyOrder     = uicontrol('Style','Edit','Position', [60 638 30 18],'String',sprintf('%.0f',proc.basePolyOrder),'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_PolyOrderUpdate');
if flag.OS==1               % Linux
    fm.proc.base.polyPpmLabel  = text('Position',[0.11, 0.93],'String','Range','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.polyPpmLabel  = text('Position',[0.11, 0.996],'String','Range','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.polyPpmLabel  = text('Position',[0.11, 0.93],'String','Range','FontSize',pars.fontSize);
end
fm.proc.base.polyPpmStr    = uicontrol('Style','Edit','Position', [170 638 300 18],'String',proc.basePolyPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_PolyPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for polynomial baseline analysis\n(e.g. 1.2:1.8 7:8.3)'));
fm.proc.base.polyCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 610 60 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(1,0);');  % spec 1, do not apply
fm.proc.base.polyCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 610 60 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(2,0);');  % spec 2, do not apply
fm.proc.base.polyCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 610 80 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(3,0);');  % export, do not apply
fm.proc.base.polyCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 610 60 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(1,1);');  % spec 1, apply correction
fm.proc.base.polyCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 610 60 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(2,1);');  % spec 2, apply correction
fm.proc.base.polyCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 610 80 20],'FontSize',pars.fontSize,...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrPoly(3,1);');  % export, apply correction

%--- interpolation ---
if flag.OS==1               % Linux
    fm.proc.base.interpTitle = text('Position',[-0.13, 0.6],'String','Interpolation','FontWeight','bold');
    fm.proc.base.interpLab     = text('Position',[-0.13, 0.52],'String','Mode');
    fm.proc.base.interpNearest = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Nearest','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==1,'Position',[.11 0.703 .10 .03],'Callback','SP2_Proc_InterpModeNearest',...
                                           'TooltipString',sprintf('Interpolation mode: Nearest neighbor'),'FontSize',pars.fontSize);
    fm.proc.base.interpLinear  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Linear','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==2,'Position',[.225 0.703 .10 .03],'Callback','SP2_Proc_InterpModeLinear',...
                                           'TooltipString',sprintf('Interpolation mode: Linear'),'FontSize',pars.fontSize);
    fm.proc.base.interpSpline  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Spline','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==3,'Position',[.33 0.703 .10 .03],'Callback','SP2_Proc_InterpModeSpline',...
                                           'TooltipString',sprintf('Interpolation mode: Piece-wise cubic spline'),'FontSize',pars.fontSize);
    fm.proc.base.interpCubic   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Cubic','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==4,'Position',[.43 0.703 .10 .03],'Callback','SP2_Proc_InterpModeCubic',...
                                           'TooltipString',sprintf('Interpolation mode: Shape-preserving piecewise cubic interpolation'),'FontSize',pars.fontSize);
    fm.proc.base.interpPpmLabel  = text('Position',[-0.13, 0.42],'String','Range','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.interpTitle = text('Position',[-0.13, 0.795],'String','Interpolation','FontWeight','bold');
    fm.proc.base.interpLab     = text('Position',[-0.13, 0.748],'String','Mode');
    fm.proc.base.interpNearest = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Nearest','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==1,'Position',[.11 0.703 .10 .03],'Callback','SP2_Proc_InterpModeNearest',...
                                           'TooltipString',sprintf('Interpolation mode: Nearest neighbor'),'FontSize',pars.fontSize);
    fm.proc.base.interpLinear  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Linear','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==2,'Position',[.225 0.703 .10 .03],'Callback','SP2_Proc_InterpModeLinear',...
                                           'TooltipString',sprintf('Interpolation mode: Linear'),'FontSize',pars.fontSize);
    fm.proc.base.interpSpline  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Spline','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==3,'Position',[.33 0.703 .10 .03],'Callback','SP2_Proc_InterpModeSpline',...
                                           'TooltipString',sprintf('Interpolation mode: Piece-wise cubic spline'),'FontSize',pars.fontSize);
    fm.proc.base.interpCubic   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Cubic','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==4,'Position',[.43 0.703 .10 .03],'Callback','SP2_Proc_InterpModeCubic',...
                                           'TooltipString',sprintf('Interpolation mode: Shape-preserving piecewise cubic interpolation'),'FontSize',pars.fontSize);
    fm.proc.base.interpPpmLabel  = text('Position',[-0.13, 0.69],'String','Range','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.interpTitle = text('Position',[-0.13, 0.6],'String','Interpolation','FontWeight','bold');
    fm.proc.base.interpLab     = text('Position',[-0.13, 0.52],'String','Mode');
    fm.proc.base.interpNearest = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Nearest','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==1,'Position',[.11 0.703 .10 .03],'Callback','SP2_Proc_InterpModeNearest',...
                                           'TooltipString',sprintf('Interpolation mode: Nearest neighbor'),'FontSize',pars.fontSize);
    fm.proc.base.interpLinear  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Linear','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==2,'Position',[.225 0.703 .10 .03],'Callback','SP2_Proc_InterpModeLinear',...
                                           'TooltipString',sprintf('Interpolation mode: Linear'),'FontSize',pars.fontSize);
    fm.proc.base.interpSpline  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Spline','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==3,'Position',[.33 0.703 .10 .03],'Callback','SP2_Proc_InterpModeSpline',...
                                           'TooltipString',sprintf('Interpolation mode: Piece-wise cubic spline'),'FontSize',pars.fontSize);
    fm.proc.base.interpCubic   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'String','Cubic','Units','Normalized', ...
                                           'Value',flag.procBaseInterpMode==4,'Position',[.43 0.703 .10 .03],'Callback','SP2_Proc_InterpModeCubic',...
                                           'TooltipString',sprintf('Interpolation mode: Shape-preserving piecewise cubic interpolation'),'FontSize',pars.fontSize);
    fm.proc.base.interpPpmLabel  = text('Position',[-0.13, 0.42],'String','Range','FontSize',pars.fontSize);
end
fm.proc.base.interpPpmStr    = uicontrol('Style','Edit','Position', [65 463 300 18],'String',proc.baseInterpPpmStr,'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_InterpPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for baseline interpolation analysis\n(e.g. 1.2:1.8 7:8.3)'),'FontSize',pars.fontSize);
fm.proc.base.interpCalcSpec1 = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 435 60 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(1,0);');  % spec 1, do not apply
fm.proc.base.interpCalcSpec2 = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 435 60 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(2,0);');  % spec 2, do not apply
fm.proc.base.interpCalcExpt  = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 435 80 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(3,0);');  % export, do not apply
fm.proc.base.interpCorrSpec1 = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 435 60 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(1,1);');  % spec 1, apply correction
fm.proc.base.interpCorrSpec2 = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 435 60 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(2,1);');  % spec 2, apply correction
fm.proc.base.interpCorrExpt  = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 435 80 20],'FontSize',pars.fontSize,...
                                         'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_BaselineCorrInterp(3,1);');  % export, apply correction

%--- singular value decomposition ---
if flag.OS==1               % Linux
    fm.proc.base.svdTitle      = text('Position',[-0.13, 0.0],'String','Hankel Singular Value Decomposition (SVD)','FontWeight','bold','FontSize',pars.fontSize);
    fm.proc.base.svdPeakNLab   = text('Position',[-0.13, -0.10],'String','Peaks','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.svdTitle      = text('Position',[-0.13, 0.43],'String','Hankel Singular Value Decomposition (SVD)','FontWeight','bold','FontSize',pars.fontSize);
    fm.proc.base.svdPeakNLab   = text('Position',[-0.13, 0.38],'String','Peaks','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.svdTitle      = text('Position',[-0.13, 0.0],'String','Hankel Singular Value Decomposition (SVD)','FontWeight','bold','FontSize',pars.fontSize);
    fm.proc.base.svdPeakNLab   = text('Position',[-0.13, -0.10],'String','Peaks','FontSize',pars.fontSize);
end
fm.proc.base.svdPeakN      = uicontrol('Style','Edit','Position', [63 285 35 18],'String',num2str(proc.baseSvdPeakN),'FontSize',pars.fontSize,...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_SvdPeakNumberUpdate');
if flag.OS==1               % Linux
    fm.proc.base.svdPpmLabel   = text('Position',[0.11, -0.10],'String','Range','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.proc.base.svdPpmLabel   = text('Position',[0.11, 0.38],'String','Range','FontSize',pars.fontSize);
else                        % PC
    fm.proc.base.svdPpmLabel   = text('Position',[0.11, -0.10],'String','Range','FontSize',pars.fontSize);
end
fm.proc.base.svdPpmStr     = uicontrol('Style','Edit','Position', [170 285 300 18],'String',proc.baseSvdPpmStr,'FontSize',pars.fontSize,...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_SvdPpmStrUpdate',...
                                       'TooltipString',sprintf('Frequency range(s) in ppm for HSVD analysis\n(e.g. 4.3:5.3 for water removal)'));
fm.proc.base.svdCalcSpec1  = uicontrol('Style','Pushbutton','String','Calc 1','FontWeight','bold','Position',[20 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakAnalysis(1);',...
                                       'TooltipString',sprintf('Calculation of SVD for spectrum 1\n(the correction is not applied)'));       % SVD of spec 1
fm.proc.base.svdCalcSpec2  = uicontrol('Style','Pushbutton','String','Calc 2','FontWeight','bold','Position',[80 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakAnalysis(2);',...
                                       'TooltipString',sprintf('Calculation of SVD for spectrum 2\n(the correction is not applied)'));       % SVD of spec 2
fm.proc.base.svdCalcExpt   = uicontrol('Style','Pushbutton','String','Calc Export','FontWeight','bold','Position',[140 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakAnalysis(3);',...
                                       'TooltipString',sprintf('Calculation of SVD for current export spectrum\n(the correction is not applied)'));  % SVD of export spectrum
fm.proc.base.svdCorrSpec1  = uicontrol('Style','Pushbutton','String','Corr 1','FontWeight','bold','Position',[250 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakRemoval(1);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to spectrum 1'));                                     % apply peak removal to spec 1
fm.proc.base.svdCorrSpec2  = uicontrol('Style','Pushbutton','String','Corr 2','FontWeight','bold','Position',[310 257 60 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakRemoval(2);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to spectrum 2'));                                     % apply peak removal to spec 2
fm.proc.base.svdCorrExpt   = uicontrol('Style','Pushbutton','String','Corr Export','FontWeight','bold','Position',[370 257 80 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdPeakRemoval(3);',...
                                       'TooltipString',sprintf('Apply SVD peak removal to current export spectrum'));                        % apply peak removal to export spectrum
fm.proc.base.svdShowSpec   = uicontrol('Style','Pushbutton','String','Show SVD','FontWeight','bold','Position',[20 237 100 20],...
                                       'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_SvdResultVisualization');  % SVD result visualization

%--- exit baseline tool ---
fm.proc.base.exit = uicontrol('Style','Pushbutton','String','Exit','FontWeight','bold','Position',[500 20 70 20],...
                              'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_ExitBaseMain');

                                   
%--- window update ---
SP2_Proc_BaseWinUpdate


end
