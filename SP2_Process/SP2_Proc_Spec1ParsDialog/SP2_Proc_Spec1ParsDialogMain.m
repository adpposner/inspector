%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Proc_Spec1ParsDialogMain(f_nspecC)
%%
%%  Create window for manual entry of spectral parameters defining FID 1.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars proc fm

FCTNAME = 'SP2_Proc_Spec1ParsDialogMain';


%--- consistency check ---
if isfield(fm.proc,'dialog1')              % ROI init open
    if ishandle(fm.proc.dialog1.fig)
        figure(fm.proc.dialog1.fig)
    else
        fm.proc.dialog1.fig = figure;
        set(fm.proc.dialog1.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                                'MenuBar','none','Resize','off','Name',' Spectral Parameters: FID 1');
        axes('Visible','off');
    end
else
    fm.proc.dialog1.fig = figure;
    set(fm.proc.dialog1.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                            'MenuBar','none','Resize','off','Name',' Spectral Parameters: FID 1');
    axes('Visible','off');
end

            
%--- parameter assignment ---
fm.proc.dialog1.sfLab     = text('Position',[-0.13, 0.94],'String','Larmor frequency [MHz]');
fm.proc.dialog1.sf        = uicontrol('Style','Edit','Position', [220 160 80 18],'String',num2str(proc.spec1.sf),...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec1ParsSfUpdate');
fm.proc.dialog1.swhLab    = text('Position',[-0.13, 0.66],'String','Acquisition bandwidth [Hz]');
fm.proc.dialog1.swh       = uicontrol('Style','Edit','Position', [220 115 80 18],'String',num2str(proc.spec1.sw_h),...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec1ParsSwhUpdate');
if f_nspecC
    fm.proc.dialog1.nspecCLab = text('Position',[-0.13, 0.38],'String','Complex data points');
    fm.proc.dialog1.nspecC    = uicontrol('Style','Edit','Position', [220 70 80 18],'String',num2str(proc.spec1.nspecC),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec1ParsNspeccUpdate');
end

%--- exit baseline tool ---
fm.proc.dialog1.exit     = uicontrol('Style','Pushbutton','String','Done','FontWeight','bold','Position',[45 20 70 20],...
                                     'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_Spec1ParsDialogExit');

