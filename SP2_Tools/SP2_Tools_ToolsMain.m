%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Tools_ToolsMain
%% 
%%  Main window for MRS-related auxiliary tools.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm fmfig pars tools flag


if ~SP2_ClearWindow
    fprintf('\n--- WARNING ---\nClearing of window figure handles failed.\n\n');
    return
end
flag.fmWin = 9;
pars.figPos = get(fmfig,'Position');
set(fmfig,'Name',' INSPECTOR: Auxiliary Tools','Position',...
    [pars.figPos(1) pars.figPos(2) pars.mainDims(3) pars.mainDims(4)])



%**********************************************************************************
%***    A N O N Y M I Z A T I O N    T O O L                                    ***
%**********************************************************************************
fm.tools.anonHeading    = text('Position',[-0.14, 1.05],'String','Data Anonymization','FontSize',pars.fontSize,'FontWeight','bold');
fm.tools.anonFileLab    = text('Position',[-0.14, 1.006],'String','File','FontSize',pars.fontSize);
fm.tools.anonFilePath   = uicontrol('Style','Edit','Position', [75 645 500 18],'String',tools.anonFilePath, ...
                                    'HorizontalAlignment','Left','Callback','SP2_Tools_AnonFilePathUpdate;','FontSize',pars.fontSize,...
                                    'TooltipString',sprintf('Path of parameter file to be anonymized (i.e. identifiers removed)'),'FontSize',pars.fontSize);
fm.tools.anonFileSelect = uicontrol('Style','Pushbutton','String','Select','Position',[75 625 50 18],'Callback','SP2_Tools_AnonFileSelect',...
                                    'TooltipString',sprintf('Select parameter file to be anonymized (i.e. identifiers removed)'),'FontSize',pars.fontSize);
fm.tools.anonFileApply  = uicontrol('Style','Pushbutton','String','Apply','Position',[125 625 50 18],'Callback','SP2_Tools_AnonFileApply',...
                                    'TooltipString',sprintf('Apply anonymization to selected scan / file'),'FontSize',pars.fontSize);
fm.tools.anonDirLab     = text('Position',[-0.14, 0.92],'String','Directory','FontSize',pars.fontSize);
fm.tools.anonDirPath    = uicontrol('Style','Edit','Position', [75 595 500 18],'String',tools.anonDir, ...
                                    'HorizontalAlignment','Left','Callback','SP2_Tools_AnonFilePathUpdate;','FontSize',pars.fontSize,...
                                    'TooltipString',sprintf('Path of study directory to be anonymized (i.e. identifiers removed)'),'FontSize',pars.fontSize);
fm.tools.anonDirSelect  = uicontrol('Style','Pushbutton','String','Select','Position',[75 575 50 18],'Callback','SP2_Tools_AnonDirSelect',...
                                    'TooltipString',sprintf('Select study directory to be anonymized (i.e. identifiers removed'),'FontSize',pars.fontSize);
fm.tools.anonDirApply   = uicontrol('Style','Pushbutton','String','Apply','Position',[125 575 50 18],'Callback','SP2_Tools_AnonDirApply;',...
                                    'TooltipString',sprintf('Apply anonymization to entire directory'),'FontSize',pars.fontSize);

                                
%--- window update ---                           
SP2_Tools_ToolsWinUpdate
