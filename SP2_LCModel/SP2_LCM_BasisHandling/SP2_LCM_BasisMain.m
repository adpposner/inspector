%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_LCM_BasisMain
%%
%%  Create window for basisline manipulation.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm pars lcm flag

FCTNAME = 'SP2_LCM_BasisMain';


%--- consistency check ---
if isfield(fm.lcm,'basis')
    if ishandle(fm.lcm.basis.fig)
        figure(fm.lcm.basis.fig)
    else
        fm.lcm.basis.fig = figure;
        set(fm.lcm.basis.fig,'CloseRequestFcn',@SP2_LCM_BasisExitMain);
        set(fm.lcm.basis.fig,'NumberTitle','off','Position',[1 1 600 900],'Color',pars.bgColor,...
                             'MenuBar','none','Resize','off','Name',' SPX Basis Tool');
        axes('Visible','off');
    end
else
    fm.lcm.basis.fig = figure;
    set(fm.lcm.basis.fig,'CloseRequestFcn',@SP2_LCM_BasisExitMain);
    set(fm.lcm.basis.fig,'NumberTitle','off','Position',[1 1 600 900],'Color',pars.bgColor,...
                         'MenuBar','none','Resize','off','Name',' SPX Basis Tool');
    axes('Visible','off');
end

%--- clear handles ---
if ~SP2_LCM_BasisClearWindow
    fprintf('\n--- WARNING ---\nClearing of window figure handles failed.\n\n');
    return
end
    
%--- basis counter ---
if flag.OS==1               % Linux
    fm.lcm.basis.counterLab = text('Position',[-0.115 1.04],'String','#','Color',pars.fgTextColor);
elseif flag.OS==2           % Mac
    fm.lcm.basis.counterLab = text('Position',[-0.115 1.07],'String','#','Color',pars.fgTextColor);
else                        % PC
    fm.lcm.basis.counterLab = text('Position',[-0.115 1.04],'String','#','Color',pars.fgTextColor);
end
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.counter' sprintf('%02i',mCnt) '= text(''Position'',[-0.12 ' ...
              sprintf('%.3f',0.971-(mCnt-1)*0.0584) '],''String'',''' ...
              sprintf('%.02i',mCnt) ''',''Color'',pars.fgTextColor);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.counter' sprintf('%02i',mCnt) '= text(''Position'',[-0.12 ' ...
              sprintf('%.3f',1.035-(mCnt-1)*0.0272) '],''String'',''' ...
              sprintf('%.02i',mCnt) ''',''Color'',pars.fgTextColor);'])
    else                        % PC     
        eval(['fm.lcm.basis.counter' sprintf('%02i',mCnt) '= text(''Position'',[-0.12 ' ...
              sprintf('%.3f',0.971-(mCnt-1)*0.0584) '],''String'',''' ...
              sprintf('%.02i',mCnt) ''',''Color'',pars.fgTextColor);'])
    end
end

%--- metabolite name ---
if flag.OS==1               % Linux
    fm.lcm.basis.nameLab = text('Position',[0.02 1.04],'String','Metabolite','Color',pars.fgTextColor);
elseif flag.OS==2           % Mac
    fm.lcm.basis.nameLab = text('Position',[0.02 1.07],'String','Metabolite','Color',pars.fgTextColor);
else                        % PC
    fm.lcm.basis.nameLab = text('Position',[0.02 1.04],'String','Metabolite','Color',pars.fgTextColor);
end
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.name' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[50 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 120 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisNameUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''Spin system / metabolite name (editable)''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.name' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[50 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 120 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisNameUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''Spin system / metabolite name (editable)''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.name' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[50 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 120 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisNameUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''Spin system / metabolite name (editable)''') ',''FontSize'',pars.fontSize);'])
    end
end

% %--- T1 ---
% if flag.OS==1               % Linux
%     fm.lcm.basis.t1Lab = text('Position',[0.27 1.04],'String','T1','Color',pars.bgTextColor);
% elseif flag.OS==2           % Mac
%     fm.lcm.basis.t1Lab = text('Position',[0.243 1.07],'String','T1','Color',pars.bgTextColor);
% else                        % PC
%     fm.lcm.basis.t1Lab = text('Position',[0.27 1.04],'String','T1','Color',pars.bgTextColor);
% end
% for mCnt = 1:lcm.basis.nLim
%     if flag.OS==1               % Linux
%         eval(['fm.lcm.basis.t1' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT1Update(' sprintf('%i',mCnt) ')'');'])
%     elseif flag.OS==2           % Mac
%         eval(['fm.lcm.basis.t1' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT1Update(' sprintf('%i',mCnt) ')'');'])
%     else                        % PC
%         eval(['fm.lcm.basis.t1' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT1Update(' sprintf('%i',mCnt) ')'');'])
%     end
% end
% 
% %--- T2 ---
% if flag.OS==1               % Linux
%     fm.lcm.basis.t2Lab = text('Position',[0.375 1.04],'String','T2','Color',pars.bgTextColor);
% elseif flag.OS==2           % Mac
%     fm.lcm.basis.t2Lab = text('Position',[0.34 1.07],'String','T2','Color',pars.bgTextColor);
% else                        % PC
%     fm.lcm.basis.t2Lab = text('Position',[0.375 1.04],'String','T2','Color',pars.bgTextColor);
% end
% for mCnt = 1:lcm.basis.nLim
%     if flag.OS==1               % Linux
%         eval(['fm.lcm.basis.t2' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[220 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT2Update(' sprintf('%i',mCnt) ')'');'])
%     elseif flag.OS==2           % Mac
%         eval(['fm.lcm.basis.t2' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[220 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT2Update(' sprintf('%i',mCnt) ')'');'])
%     else                        % PC
%         eval(['fm.lcm.basis.t2' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[220 ' ...
%               sprintf('%.3f',850-(mCnt-1)*20) ' 45 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisT2Update(' sprintf('%i',mCnt) ')'');'])
%     end
% end

%--- comment ---
if flag.OS==1               % Linux
    fm.lcm.basis.comLab = text('Position',[0.33 1.04],'String','Comment','Color',pars.fgTextColor);
elseif flag.OS==2           % Mac
    fm.lcm.basis.comLab = text('Position',[0.30 1.07],'String','Comment','Color',pars.fgTextColor);
else                        % PC
    fm.lcm.basis.comLab = text('Position',[0.33 1.04],'String','Comment','Color',pars.fgTextColor);
end
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.com' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 135 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisCommentUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''User comment (editable)''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.com' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 135 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisCommentUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''User comment (editable)''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.com' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[175 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 135 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisCommentUpdate(' ...
              sprintf('%i',mCnt) ')'',''TooltipString'',' sprintf('''User comment (editable)''') ',''FontSize'',pars.fontSize);'])
    end
end

%--- show ---
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.show' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Show'',' ...
              '''Position'',[325 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisPlotSpecSingle(' num2str(mCnt) ',1);'',''TooltipString'',' ...
              sprintf('''Display selected basis spectrum. Note processing flag and details on main LCM page''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.show' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Show'',' ...
              '''Position'',[325 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisPlotSpecSingle(' num2str(mCnt) ',1);'',''TooltipString'',' ...
              sprintf('''Display selected basis spectrum. Note processing flag and details on main LCM page''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.show' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Show'',' ...
              '''Position'',[325 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisPlotSpecSingle(' num2str(mCnt) ',1);'',''TooltipString'',' ...
              sprintf('''Display selected basis spectrum. Note processing flag and details on main LCM page''') ',''FontSize'',pars.fontSize);'])
    end
end

%--- assign ---
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.assign' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Assign'',' ...
              '''Position'',[375 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisAssign(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Assign current spectrum from LCM main page to this basis field. Note processing flag and details on main page''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.assign' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Assign'',' ...
              '''Position'',[375 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisAssign(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Assign current spectrum from LCM main page to this basis field. Note processing flag and details on main page''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.assign' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Assign'',' ...
              '''Position'',[375 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisAssign(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Assign current spectrum from LCM main page to this basis field. Note processing flag and details on main page''') ',''FontSize'',pars.fontSize);'])
    end
end

%--- delete ---
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.delete' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Delete'',' ...
              '''Position'',[425 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisDelete(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Delete selected spin system from basis set.''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.delete' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Delete'',' ...
              '''Position'',[425 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisDelete(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Delete selected spin system from basis set.''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.delete' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Delete'',' ...
              '''Position'',[425 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisDelete(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Delete selected spin system from basis set.''') ',''FontSize'',pars.fontSize);'])
    end
end

%--- reordering option ---
if flag.OS==1               % Linux
    fm.lcm.basis.reordLab = text('Position',[0.988 1.04],'String','Reorder','Color',pars.fgTextColor);
elseif flag.OS==2           % Mac
    fm.lcm.basis.reordLab = text('Position',[0.878 1.07],'String','Reorder','Color',pars.fgTextColor);
else                        % PC
    fm.lcm.basis.reordLab = text('Position',[0.988 1.04],'String','Reorder','Color',pars.fgTextColor);
end
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.reorder' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[485 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 40 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisReorderUpdate(' ...
              sprintf('%i',mCnt) ')'',''FontSize'',pars.fontSize,''TooltipString'',' ...
              sprintf('''Basis reordering option: Assign new number and push [Move] button.''') ');'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.reorder' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[485 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 40 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisReorderUpdate(' ...
              sprintf('%i',mCnt) ')'',''FontSize'',pars.fontSize,''TooltipString'',' ...
              sprintf('''Basis reordering option: Assign new number and push [Move] button.''') ');'])
    else                        % PC
        eval(['fm.lcm.basis.reorder' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Edit'',''Position'',[485 ' ...
              sprintf('%.3f',850-(mCnt-1)*20) ' 40 20],''BackGroundColor'',pars.bgColor,''Callback'',''SP2_LCM_BasisReorderUpdate(' ...
              sprintf('%i',mCnt) ')'',''FontSize'',pars.fontSize,''TooltipString'',' ...
              sprintf('''Basis reordering option: Assign new number and push [Move] button.''') ');'])
    end
end

%--- move ---
for mCnt = 1:lcm.basis.nLim
    if flag.OS==1               % Linux
        eval(['fm.lcm.basis.move' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Move'',' ...
              '''Position'',[525 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisMove(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Basis reodering option: Assign new number (to the left) and push button.''') ',''FontSize'',pars.fontSize);'])
    elseif flag.OS==2           % Mac
        eval(['fm.lcm.basis.move' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Move'',' ...
              '''Position'',[525 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisMove(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Basis reodering option: Assign new number (to the left) and push button.''') ',''FontSize'',pars.fontSize);'])
    else                        % PC
        eval(['fm.lcm.basis.move' sprintf('%02i',mCnt) '= uicontrol(''Style'',''Pushbutton'',''String'',''Move'',' ...
              '''Position'',[525 ' sprintf('%.0f',850-(mCnt-1)*20) ' 50 20],''FontSize'',' sprintf('%.1f',pars.fontSize) ',''FontName'',''Helvetica'',' ... 
              '''Callback'',''SP2_LCM_BasisMove(' num2str(mCnt) ');'',''TooltipString'',' ...
              sprintf('''Basis reodering option: Assign new number (to the left) and push button.''') ',''FontSize'',pars.fontSize);'])
    end
end

%--- load basis set ---
fm.lcm.basis.load    = uicontrol('Style','Pushbutton','String','Load','FontWeight','bold','Position',[50 25 60 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisLoad;',...
                                 'TooltipString',sprintf('Load basis set from file'));
%--- load basis set ---
fm.lcm.basis.import  = uicontrol('Style','Pushbutton','String','Import','FontWeight','bold','Position',[110 25 60 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisImport;',...
                                 'TooltipString',sprintf('Basis creation for a set of FIDs or direct import of Provencher''s LCModel basis\nNote the processing flag and parameters defined on the main LCM page'));
%--- add metabolite to basis set ---
fm.lcm.basis.add     = uicontrol('Style','Pushbutton','String','Add','FontWeight','bold','Position',[170 25 52 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisAdd;',...
                                 'TooltipString',sprintf('Add empty basis function to basis set'));
%--- reorder basis set ---
fm.lcm.basis.reorder = uicontrol('Style','Pushbutton','String','Reorder','FontWeight','bold','Position',[222 25 73 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisReorder;',...
                                 'TooltipString',sprintf('Reorder basis functions\n1) Choose preferred numeric order in right column\n2) Push [Reorder] button to update basis structure'));
%--- save basis set ---
fm.lcm.basis.save    = uicontrol('Style','Pushbutton','String','Save','FontWeight','bold','Position',[295 25 60 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisSave;',...
                                 'TooltipString',sprintf('Save basis set to file'));
                             
%--- ppm calibration ---
if flag.OS==1               % Linux
    fm.lcm.basis.ppmCalibLab = text('Position',[0.70 -1.44],'String','Calib.','Color',pars.fgTextColor);
elseif flag.OS==2           % Mac
    fm.lcm.basis.ppmCalibLab = text('Position',[0.66 -0.09],'String','Calib.','Color',pars.fgTextColor);
else                        % PC
    fm.lcm.basis.ppmCalibLab = text('Position',[0.70 -1.44],'String','Calib.','Color',pars.fgTextColor);
end
fm.lcm.basis.ppmCalib = uicontrol('Style','Edit','Position',[420 25 60 20],'BackGroundColor',pars.bgColor,...
                                  'String',num2str(lcm.basis.ppmCalib),'Callback','SP2_LCM_BasisPpmCalibUpdate',...
                                  'TooltipString',sprintf('Frequency calibration of LCM basis set [ppm]'));                             
 
%--- exit basis tool ---
fm.lcm.basis.exit    = uicontrol('Style','Pushbutton','String','Exit','FontWeight','bold','Position',[505 25 70 20],...
                                 'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_BasisExitMain',...
                                  'TooltipString',sprintf('Close Basis Tool\n(basis data are preserved)'));   


%--- window update ---
% note that lcm.basis.data = 0 by default and before the data of a basis
% set is assigned (as cell)
if ~isnumeric(lcm.basis.data)
    SP2_LCM_BasisWinUpdate
end
                             

