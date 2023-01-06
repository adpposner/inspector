%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_LCM_SpecParsDialogMain(f_nspecC)
%%
%%  Create window for manual entry of spectral parameters defining FID 1.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars lcm fm

FCTNAME = 'SP2_LCM_SpecParsDialogMain';


%--- consistency check ---
if isfield(fm.lcm,'dialog1')              % ROI init open
    if ishandle(fm.lcm.dialog1.fig)
        figure(fm.lcm.dialog1.fig)
    else
        fm.lcm.dialog1.fig = figure;
        set(fm.lcm.dialog1.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                               'MenuBar','none','Resize','off','Name',' Spectral Parameters');
        axes('Visible','off');
    end
else
    fm.lcm.dialog1.fig = figure;
    set(fm.lcm.dialog1.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                           'MenuBar','none','Resize','off','Name',' Spectral Parameters');
    axes('Visible','off');
end

            
%--- parameter assignment ---
fm.lcm.dialog1.sfLab     = text('Position',[-0.13, 0.94],'String','Larmor frequency [MHz]');
fm.lcm.dialog1.sf        = uicontrol('Style','Edit','Position', [220 160 80 18],'String',num2str(lcm.sf),...
                                     'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_SpecParsSfUpdate');
fm.lcm.dialog1.swhLab    = text('Position',[-0.13, 0.66],'String','Acquisition bandwidth [Hz]');
fm.lcm.dialog1.swh       = uicontrol('Style','Edit','Position', [220 115 80 18],'String',num2str(lcm.sw_h),...
                                     'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_SpecParsSwhUpdate');
if f_nspecC
    fm.lcm.dialog1.nspecCLab = text('Position',[-0.13, 0.38],'String','Complex data points');
    fm.lcm.dialog1.nspecC    = uicontrol('Style','Edit','Position', [220 70 80 18],'String',num2str(lcm.nspecC),...
                                         'BackGroundColor',pars.bgColor,'Callback','SP2_LCM_SpecParsNspeccUpdate');
end

%--- exit baseline tool ---
fm.lcm.dialog1.exit     = uicontrol('Style','Pushbutton','String','Done','FontWeight','bold','Position',[45 20 70 20],...
                                    'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_LCM_SpecParsDialogExit');


end
