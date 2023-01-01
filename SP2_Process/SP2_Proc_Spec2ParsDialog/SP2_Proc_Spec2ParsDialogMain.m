%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Proc_Spec2ParsDialogMain(f_nspecC)
%%
%%  Create window for manual entry of spectral parameters defining FID 1.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars proc fm

FCTNAME = 'SP2_Proc_Spec2ParsDialogMain';


%--- consistency check ---
if isfield(fm.proc,'dialog2')              % ROI init open
    if ishandle(fm.proc.dialog2.fig)
        figure(fm.proc.dialog2.fig)
    else
        fm.proc.dialog2.fig = figure;
        set(fm.proc.dialog2.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                                'MenuBar','none','Resize','off','Name',' Spectral Parameters: FID 2');
        axes('Visible','off');
    end
else
    fm.proc.dialog2.fig = figure;
    set(fm.proc.dialog2.fig,'NumberTitle','off','Position',[200 150 350 210],'Color',pars.bgColor,...
                            'MenuBar','none','Resize','off','Name',' Spectral Parameters: FID 2');
    axes('Visible','off');
end

            
%--- parameter assignment ---
fm.proc.dialog2.sfLab     = text('Position',[-0.13, 0.94],'String','Larmor frequency [MHz]');
fm.proc.dialog2.sf        = uicontrol('Style','Edit','Position', [220 160 80 18],'String',num2str(proc.spec2.sf),...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec2ParsSfUpdate');
fm.proc.dialog2.swhLab    = text('Position',[-0.13, 0.66],'String','Acquisition bandwidth [Hz]');
fm.proc.dialog2.swh       = uicontrol('Style','Edit','Position', [220 115 80 18],'String',num2str(proc.spec2.sw_h),...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec2ParsSwhUpdate');
if f_nspecC                                  
    fm.proc.dialog2.nspecCLab = text('Position',[-0.13, 0.38],'String','Complex data points');
    fm.proc.dialog2.nspecC    = uicontrol('Style','Edit','Position', [220 70 80 18],'String',num2str(proc.spec2.nspecC),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Proc_Spec2ParsNspeccUpdate');
end

%--- exit baseline tool ---
fm.proc.dialog2.exit     = uicontrol('Style','Pushbutton','String','Done','FontWeight','bold','Position',[45 20 70 20],...
                                     'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Proc_Spec2ParsDialogExit');

