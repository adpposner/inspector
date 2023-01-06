%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Proc_JdeEfficiencyMain
%%
%%  Create window for JDE efficiency determination.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag proc fm

FCTNAME = 'SP2_Proc_JdeEfficiencyMain';


%--- consistency check ---
if isfield(fm.proc,'jdeEff')              % ROI init open
    if ishandle(fm.proc.jdeEff.fig)
        figure(fm.proc.jdeEff.fig)
    else
        fm.proc.jdeEff.fig = figure;
        set(fm.proc.jdeEff.fig,'NumberTitle','off','Position',[30 80 400 400],'Color',pars.bgColor,...
                            'MenuBar','none','Resize','off','Name',' JDE Efficiency Tool');
        axes('Visible','off');
    end
else
    fm.proc.jdeEff.fig = figure('IntegerHandle','off');
    set(fm.proc.jdeEff.fig,'NumberTitle','off','Position',[30 80 400 400],'Color',pars.bgColor,...
                        'MenuBar','none','Resize','off','Name',' JDE Efficiency Tool');
    axes('Visible','off');
end

%--- parameter alignments ---
fm.proc.jdeEff.ppmRgLab  = text('Position',[-0.11, 0.99],'String','Spectral range','FontSize',pars.fontSize);
fm.proc.jdeEff.ppmRgMin  = uicontrol('Style','Edit','Position', [160 355 50 18],'String',num2str(proc.jdeEffPpmRg(1)),...
                                     'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_JdeEfficiencyParsUpdate',...
                                     'TooltipString','Minimum limit of spectral range [ppm]');
fm.proc.jdeEff.ppmRgMax  = uicontrol('Style','Edit','Position', [210 355 50 18],'String',num2str(proc.jdeEffPpmRg(2)),...
                                     'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_JdeEfficiencyParsUpdate',...
                                     'TooltipString','Maximum limit of spectral range [ppm]');
fm.proc.jdeEff.offsetLab = text('Position',[-0.11, 0.92],'String','Offset','FontSize',pars.fontSize);
fm.proc.jdeEff.offsetVal = uicontrol('Style','Edit','Position', [160 333 70 18],'String',sprintf('%.1f',proc.jdeEffOffset),...
                                     'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_JdeEfficiencyParsUpdate',...
                                     'TooltipString','Offset value [a.u.]');
fm.proc.jdeEff.assignOff = uicontrol('Style','Pushbutton','String','Assign','Position',[230 333 65 18],'Callback','SP2_Proc_JdeEffOffsetAssign',...
                                     'TooltipString',sprintf('Manual offset assignment'));
fm.proc.jdeEff.analyze   = uicontrol('Style','Pushbutton','String','Analyze','FontWeight','bold','Position',[40 100 70 18],...
                                     'Callback','SP2_Proc_JdeEffAnalysis','TooltipString',sprintf('Manual offset assignment'));
                                             
%--- window update ---
SP2_Proc_JdeEfficiencyWinUpdate


end
