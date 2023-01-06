%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Data_AlignDetailsMain
%%
%%  Create window for setting up the automated phase/frequency alignment
%%  of arrayed acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars flag data fm

FCTNAME = 'SP2_Data_AlignDetailsMain';


%--- consistency check ---
if isfield(fm.data,'alignDet')              % ROI init open
    if ishandle(fm.data.align.fig)
        figure(fm.data.align.fig)
    else
        fm.data.align.fig = figure;
        set(fm.data.align.fig,'CloseRequestFcn',@SP2_Data_AlignDetailsExit);
        set(fm.data.align.fig,'NumberTitle','off','Position',[30 80 600 600],'Color',pars.bgColor,...
                            'MenuBar','none','Resize','off','Name',' Setup for Automated Spectrum Alignment');
        axes('Visible','off');
    end
else
    fm.data.align.fig = figure('IntegerHandle','off');
    set(fm.data.align.fig,'CloseRequestFcn',@SP2_Data_AlignDetailsExit);
    set(fm.data.align.fig,'NumberTitle','off','Position',[30 80 600 600],'Color',pars.bgColor,...
                          'MenuBar','none','Resize','off','Name',' Setup for Automated Spectrum Alignment');
    axes('Visible','off');
end


%--- FREQUENCY ALIGNMENT (1) ---
if flag.OS==1               % Linux
    fm.data.align.frLab         = text('Position',[-0.11, 1.02],'String','1) Frequency Alignment','FontWeight','bold','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frLab         = text('Position',[-0.11, 1.02],'String','1) Frequency Alignment','FontWeight','bold','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frLab         = text('Position',[-0.11, 1.02],'String','1) Frequency Alignment','FontWeight','bold','FontSize',pars.fontSize);
end
if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    if flag.OS==1               % Linux
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.933],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.987],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.933],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    end
    fm.data.align.frPpm1Str     = uicontrol('Style','Edit','Position', [160 538 100 18],'String',data.frAlignPpm1Str,'BackGroundColor',...
                                            pars.bgColor,'Callback','SP2_Data_AlignFrequPpm1StrUpdate','FontSize',pars.fontSize,...
                                            'TooltipString',sprintf('Frequency range(s) in ppm for frequency alignment of condition 1\n(e.g. 1.2:1.8 7:8.3)'));            
    if flag.OS==1               % Linux
        fm.data.align.frPpm2StrLab  = text('Position',[-0.11, 0.872],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.frPpm2StrLab  = text('Position',[-0.11, 0.943],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.frPpm2StrLab  = text('Position',[-0.11, 0.872],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    end
    fm.data.align.frPpm2Str     = uicontrol('Style','Edit','Position', [160 517 100 18],'String',data.frAlignPpm2Str,'BackGroundColor',...
                                            pars.bgColor,'Callback','SP2_Data_AlignFrequPpm2StrUpdate','FontSize',pars.fontSize,...
                                            'TooltipString',sprintf('Frequency range(s) in ppm for frequency alignment of condition 2\n(e.g. 1.2:1.8 7:8.3)'));            
else
    if flag.OS==1               % Linux
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.872],'String','Frequency window(s)','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.943],'String','Frequency window(s)','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.frPpm1StrLab  = text('Position',[-0.11, 0.872],'String','Frequency window(s)','FontSize',pars.fontSize);
    end
    fm.data.align.frPpm1Str     = uicontrol('Style','Edit','Position', [160 517 100 18],'String',data.frAlignPpm1Str,'FontSize',pars.fontSize,'BackGroundColor',...
                                            pars.bgColor,'Callback','SP2_Data_AlignFrequPpm1StrUpdate',...
                                            'TooltipString',sprintf('Frequency range(s) in ppm for frequency alignment\n(e.g. 1.2:1.8 7:8.3)'));            
end
if flag.OS==1               % Linux
    fm.data.align.frExpLbLab    = text('Position',[-0.11, 0.811],'String','Line Broadening','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frExpLbLab    = text('Position',[-0.11, 0.899],'String','Line Broadening','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frExpLbLab    = text('Position',[-0.11, 0.811],'String','Line Broadening','FontSize',pars.fontSize);
end
fm.data.align.frExpLb       = uicontrol('Style','Edit','Position', [160 496 45 18],'String',num2str(data.frAlignExpLb),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString','Exponential line broadening [Hz]');
if flag.OS==1               % Linux
    fm.data.align.frFftCutLab   = text('Position',[-0.11, 0.750],'String','Apodization','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frFftCutLab   = text('Position',[-0.11, 0.855],'String','Apodization','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frFftCutLab   = text('Position',[-0.11, 0.750],'String','Apodization','FontSize',pars.fontSize);
end
fm.data.align.frFftCut      = uicontrol('Style','Edit','Position', [160 475 45 18],'String',num2str(data.frAlignFftCut),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString','Time-domain apodization [pts]');
if flag.OS==1               % Linux
    fm.data.align.frFftZfLab    = text('Position',[-0.11, 0.689],'String','Resolution','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frFftZfLab    = text('Position',[-0.11, 0.811],'String','Resolution','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frFftZfLab    = text('Position',[-0.11, 0.689],'String','Resolution','FontSize',pars.fontSize);
end
fm.data.align.frFftZf       = uicontrol('Style','Edit','Position', [160 454 45 18],'String',num2str(data.frAlignFftZf),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString','Time-domain zero filling [pts]');
if flag.OS==1               % Linux
    fm.data.align.frFrequRgLab  = text('Position',[-0.11, 0.628],'String','Variation Range','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frFrequRgLab  = text('Position',[-0.11, 0.767],'String','Variation Range','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frFrequRgLab  = text('Position',[-0.11, 0.628],'String','Variation Range','FontSize',pars.fontSize);
end
fm.data.align.frFrequRg     = uicontrol('Style','Edit','Position', [160 433 45 18],'String',num2str(data.frAlignFrequRg),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString','Minimum/maximum shift range [Hz]');
if flag.OS==1               % Linux
    fm.data.align.frFrequResLab = text('Position',[-0.11, 0.567],'String','Resolution','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frFrequResLab = text('Position',[-0.11, 0.723],'String','Resolution','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frFrequResLab = text('Position',[-0.11, 0.567],'String','Resolution','FontSize',pars.fontSize);
end
fm.data.align.frFrequRes    = uicontrol('Style','Edit','Position', [160 412 45 18],'String',num2str(data.frAlignFrequRes),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString','Frequency resolution [Hz]');
if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    if flag.OS==1               % Linux
        fm.data.align.frRef1FidLab   = text('Position',[-0.11, 0.506],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.frRef1FidLab   = text('Position',[-0.11, 0.679],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.frRef1FidLab   = text('Position',[-0.11, 0.506],'String','Reference FID','FontSize',pars.fontSize);
    end
    fm.data.align.frRef1Fid      = uicontrol('Style','Edit','Position', [160 391 45 18],'String',num2str(data.frAlignRefFid(1)),...
                                             'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                             'TooltipString',sprintf('Reference FID for 1st iteration of frequency alignment (Condition 1):\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
    fm.data.align.frRef2Fid      = uicontrol('Style','Edit','Position', [205 391 45 18],'String',num2str(data.frAlignRefFid(2)),...
                                             'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                             'TooltipString',sprintf('Reference FID for 1st iteration of frequency alignment (Condition 2):\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
else                                                    % all other experiment (single condition and reference)
    if flag.OS==1               % Linux
        fm.data.align.frRefFidLab   = text('Position',[-0.11, 0.506],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.frRefFidLab   = text('Position',[-0.11, 0.679],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.frRefFidLab   = text('Position',[-0.11, 0.506],'String','Reference FID','FontSize',pars.fontSize);
    end
    fm.data.align.frRefFid      = uicontrol('Style','Edit','Position', [160 391 45 18],'String',num2str(data.frAlignRefFid(1)),...
                                            'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                            'TooltipString',sprintf('Reference FID for 1st iteration of frequency alignment:\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
end
if flag.OS==1               % Linux
    fm.data.align.frIterFidLab  = text('Position',[-0.11, 0.445],'String','Iterations','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frIterFidLab  = text('Position',[-0.11, 0.635],'String','Iterations','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frIterFidLab  = text('Position',[-0.11, 0.445],'String','Iterations','FontSize',pars.fontSize);
end
fm.data.align.frIter        = uicontrol('Style','Edit','Position', [160 370 45 18],'String',num2str(data.frAlignIter),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString',sprintf('Iterations of frequency alignment [1]\nNote that for >1 the summation result is used as reference'));
if flag.OS==1               % Linux
    fm.data.align.frVerbMaxLab  = text('Position',[-0.11, 0.384],'String','# Verbose','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.frVerbMaxLab  = text('Position',[-0.11, 0.591],'String','# Verbose','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.frVerbMaxLab  = text('Position',[-0.11, 0.384],'String','# Verbose','FontSize',pars.fontSize);
end
fm.data.align.frVerbMax     = uicontrol('Style','Edit','Position', [160 349 45 18],'String',num2str(data.frAlignVerbMax),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignFrequParsUpdate','FontSize',pars.fontSize,...
                                        'TooltipString',sprintf('Number of alignment optimizations per iteration to visualized in verbose mode\n(compare ''Align QA'' flag on main Data page)'));


%--- PHASE ALIGNMENT ---
if flag.OS==1               % Linux
    fm.data.align.phLab        = text('Position',[-0.11, 0.090],'String','2) Phase Alignment','FontWeight','bold','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phLab        = text('Position',[-0.11, 0.363],'String','2) Phase Alignment','FontWeight','bold','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phLab        = text('Position',[-0.11, 0.090],'String','2) Phase Alignment','FontWeight','bold','FontSize',pars.fontSize);
end
if flag.dataExpType==3 || flag.dataExpType==7       % editing experiment, i.e. 2 conditions                                     
    if flag.OS==1               % Linux
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, -0.001],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, 0.334],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, -0.001],'String','Frequ. window(s) 1','FontSize',pars.fontSize);
    end
    fm.data.align.phPpm1Str    = uicontrol('Style','Edit','Position', [160 218 100 18],'String',data.phAlignPpm1Str,'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhasePpm1StrUpdate',...
                                          'TooltipString',sprintf('Frequ. range(s) in ppm for phase alignment of condition 1\n(e.g. 1.2:1.8 7:8.3)'),'FontSize',pars.fontSize);            
    if flag.OS==1               % Linux
        fm.data.align.phPpm2StrLab = text('Position',[-0.11, -0.062],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.phPpm2StrLab = text('Position',[-0.11, 0.290],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.phPpm2StrLab = text('Position',[-0.11, -0.062],'String','Frequ. window(s) 2','FontSize',pars.fontSize);
    end
    fm.data.align.phPpm2Str    = uicontrol('Style','Edit','Position', [160 197 100 18],'String',data.phAlignPpm2Str,'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhasePpm2StrUpdate',...
                                           'TooltipString',sprintf('Frequency range(s) in ppm for phase alignment of condition 2\n(e.g. 1.2:1.8 7:8.3)'),'FontSize',pars.fontSize);            
else
    if flag.OS==1               % Linux
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, -0.062],'String','Frequency window(s)','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, 0.290],'String','Frequency window(s)','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.phPpm1StrLab = text('Position',[-0.11, -0.062],'String','Frequency window(s)','FontSize',pars.fontSize);
    end
    fm.data.align.phPpm1Str    = uicontrol('Style','Edit','Position', [160 197 120 18],'String',data.phAlignPpm1Str,'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhasePpm1StrUpdate',...
                                          'TooltipString',sprintf('Frequency range(s) in ppm for phase alignment\n(e.g. 1.2:1.8 7:8.3)'),'FontSize',pars.fontSize);            
end
if flag.OS==1               % Linux
    fm.data.align.phExpLbLab   = text('Position',[-0.11, -0.123],'String','Line Broadening','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phExpLbLab   = text('Position',[-0.11, 0.246],'String','Line Broadening','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phExpLbLab   = text('Position',[-0.11, -0.123],'String','Line Broadening','FontSize',pars.fontSize);
end
fm.data.align.phExpLb      = uicontrol('Style','Edit','Position', [160 176 45 18],'String',num2str(data.phAlignExpLb),...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                       'TooltipString','Exponential line broadening [Hz]','FontSize',pars.fontSize);
if flag.OS==1               % Linux
    fm.data.align.phFftCutLab  = text('Position',[-0.11, -0.184],'String','Apodization','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phFftCutLab  = text('Position',[-0.11, 0.202],'String','Apodization','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phFftCutLab  = text('Position',[-0.11, -0.184],'String','Apodization','FontSize',pars.fontSize);
end
fm.data.align.phFftCut     = uicontrol('Style','Edit','Position', [160 155 45 18],'String',num2str(data.phAlignFftCut),...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                       'TooltipString','Time-domain apodization [pts]','FontSize',pars.fontSize);
if flag.OS==1               % Linux
    fm.data.align.phFftZfLab   = text('Position',[-0.11, -0.245],'String','Resolution','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phFftZfLab   = text('Position',[-0.11, 0.158],'String','Resolution','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phFftZfLab   = text('Position',[-0.11, -0.245],'String','Resolution','FontSize',pars.fontSize);
end
fm.data.align.phFftZf      = uicontrol('Style','Edit','Position', [160 134 45 18],'String',num2str(data.phAlignFftZf),...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                       'TooltipString','Time-domain zero filling [pts]','FontSize',pars.fontSize);
if flag.OS==1               % Linux
    fm.data.align.phPhStepLab  = text('Position',[-0.11, -0.306],'String','Phase Step','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phPhStepLab  = text('Position',[-0.11, 0.114],'String','Phase Step','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phPhStepLab  = text('Position',[-0.11, -0.306],'String','Phase Step','FontSize',pars.fontSize);
end
fm.data.align.phPhStep     = uicontrol('Style','Edit','Position', [160 113 45 18],'String',num2str(data.phAlignPhStep),...
                                       'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                       'TooltipString','Phase step size, i.e. resolution [deg]','FontSize',pars.fontSize);
if flag.dataExpType==3 || flag.dataExpType==7       % editing experiment, i.e. 2 conditions                                     
    if flag.OS==1               % Linux
        fm.data.align.phRef1FidLab = text('Position',[-0.11, -0.367],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.phRef1FidLab = text('Position',[-0.11, 0.070],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.phRef1FidLab = text('Position',[-0.11, -0.367],'String','Reference FID','FontSize',pars.fontSize);
    end
    fm.data.align.phRef1Fid    = uicontrol('Style','Edit','Position', [160 92 45 18],'String',num2str(data.phAlignRefFid(1)),'FontSize',pars.fontSize,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                           'TooltipString',sprintf('Reference FID for 1st iteration of phase alignment (Condition 1):\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
    fm.data.align.phRef2Fid    = uicontrol('Style','Edit','Position', [205 92 45 18],'String',num2str(data.phAlignRefFid(2)),'FontSize',pars.fontSize,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                           'TooltipString',sprintf('Reference FID for 1st iteration of phase alignment (Condition 2):\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
else                                                % all other experiments (single condition and reference)
    if flag.OS==1               % Linux
        fm.data.align.phRefFidLab  = text('Position',[-0.11, -0.367],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.phRefFidLab  = text('Position',[-0.11, 0.070],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.phRefFidLab  = text('Position',[-0.11, -0.367],'String','Reference FID','FontSize',pars.fontSize);
    end
    fm.data.align.phRefFid     = uicontrol('Style','Edit','Position', [160 92 45 18],'String',num2str(data.phAlignRefFid(1)),'FontSize',pars.fontSize,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                           'TooltipString',sprintf('Reference FID for 1st iteration of phase alignment:\n0: Sum of all traces (for low SNR)\n>0: Selected trace (for high SNR)\n(note that all futher iterations align with the sum)'));                                     
end
if flag.OS==1               % Linux
    fm.data.align.phIterFidLab     = text('Position',[-0.11, -0.428],'String','Iterations','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phIterFidLab     = text('Position',[-0.11, 0.026],'String','Iterations','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phIterFidLab     = text('Position',[-0.11, -0.428],'String','Iterations','FontSize',pars.fontSize);
end
fm.data.align.phIter           = uicontrol('Style','Edit','Position', [160 71 45 18],'String',num2str(data.phAlignIter),'FontSize',pars.fontSize,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                           'TooltipString','Iterations of frequency alignment [1]\nNote that for >1 the summation result is used as reference');
if flag.OS==1               % Linux
    fm.data.align.phVerbMaxLab     = text('Position',[-0.11, -0.489],'String','# Verbose','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.phVerbMaxLab     = text('Position',[-0.11, -0.018],'String','# Verbose','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.phVerbMaxLab     = text('Position',[-0.11, -0.489],'String','# Verbose','FontSize',pars.fontSize);
end
fm.data.align.phVerbMax        = uicontrol('Style','Edit','Position', [160 50 45 18],'String',num2str(data.phAlignVerbMax),'FontSize',pars.fontSize,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignPhaseParsUpdate',...
                                           'TooltipString',sprintf('Number of alignment optimizations per iteration to visualized in verbose mode\n(compare ''Align QA'' flag on main Data page)'));
                                     
                                    
%--- AMPLITUDE ALIGNMENT ---
if flag.OS==1               % Linux
    fm.data.align.amLab       = text('Position',[0.6, 1.02],'String','3) Amplitude Alignment','FontWeight','bold','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amLab       = text('Position',[0.6, 1.02],'String','3) Amplitude Alignment','FontWeight','bold','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amLab       = text('Position',[0.6, 1.02],'String','3) Amplitude Alignment','FontWeight','bold','FontSize',pars.fontSize);
end
if flag.OS==1               % Linux
    fm.data.align.amPpmStrLab = text('Position',[0.6, 0.880],'String','Frequency window(s)','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amPpmStrLab = text('Position',[0.6, 0.943],'String','Frequency window(s)','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amPpmStrLab = text('Position',[0.6, 0.880],'String','Frequency window(s)','FontSize',pars.fontSize);
end
fm.data.align.amPpmStr    = uicontrol('Style','Edit','Position', [465 517 120 18],'String',data.amAlignPpmStr,'FontSize',pars.fontSize,...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplPpmStrUpdate',...
                                      'TooltipString',sprintf('Frequency range(s) in ppm for amplitude alignment\n(e.g. 1.2:1.8 7:8.3)'));            
if flag.OS==1               % Linux
    fm.data.align.amExpLbLab  = text('Position',[0.6, 0.818],'String','Line Broadening','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amExpLbLab  = text('Position',[0.6, 0.899],'String','Line Broadening','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amExpLbLab  = text('Position',[0.6, 0.818],'String','Line Broadening','FontSize',pars.fontSize);
end
fm.data.align.amExpLb     = uicontrol('Style','Edit','Position', [465 496 45 18],'String',num2str(data.amAlignExpLb),'FontSize',pars.fontSize,...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                      'TooltipString','Exponential line broadening [Hz]');
if flag.OS==1               % Linux
    fm.data.align.amFftCutLab = text('Position',[0.6, 0.756],'String','Apodization','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amFftCutLab = text('Position',[0.6, 0.855],'String','Apodization','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amFftCutLab = text('Position',[0.6, 0.756],'String','Apodization','FontSize',pars.fontSize);
end
fm.data.align.amFftCut    = uicontrol('Style','Edit','Position', [465 475 45 18],'String',num2str(data.amAlignFftCut),'FontSize',pars.fontSize,...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                      'TooltipString','Time-domain apodization [pts]');
if flag.OS==1               % Linux
    fm.data.align.amFftZfLab  = text('Position',[0.6, 0.694],'String','Zero-Filling','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amFftZfLab  = text('Position',[0.6, 0.811],'String','Zero-Filling','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amFftZfLab  = text('Position',[0.6, 0.694],'String','Zero-Filling','FontSize',pars.fontSize);
end                               
fm.data.align.amFftZf     = uicontrol('Style','Edit','Position', [465 454 45 18],'String',num2str(data.amAlignFftZf),'FontSize',pars.fontSize,...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                      'TooltipString','Time-domain zero filling [pts]');
if flag.dataExpType==3 || flag.dataExpType==7       % editing experiment, i.e. 2 conditions                                     
    if flag.OS==1               % Linux
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.632],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.767],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.632],'String','Reference FID','FontSize',pars.fontSize);
    end                               
    fm.data.align.amRef1Str = uicontrol('Style','Edit','Position', [465 433 60 18],'String',data.amAlignRef1Str,'FontSize',pars.fontSize,...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplRef1StrUpdate',...
                                        'TooltipString','Reference FIDs for amplitude alignment [1]: Condition 1\n(e.g. 3:2:9 11 17)');                                     
    fm.data.align.amRef2Str = uicontrol('Style','Edit','Position', [525 433 60 18],'String',data.amAlignRef2Str,'FontSize',pars.fontSize,...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplRef2StrUpdate',...
                                        'TooltipString','Reference FIDs for amplitude alignment [1]: Condition 2\n(e.g. 4:2:10 12 18)');                                     
else                            % all other experiments (single condition and reference)
    if flag.OS==1               % Linux
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.632],'String','Reference FID','FontSize',pars.fontSize);
    elseif flag.OS==2           % Mac
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.767],'String','Reference FID','FontSize',pars.fontSize);
    else                        % PC
        fm.data.align.amRef1Lab = text('Position',[0.6, 0.632],'String','Reference FID','FontSize',pars.fontSize);
    end                               
    fm.data.align.amRef1Str = uicontrol('Style','Edit','Position', [465 433 60 18],'String',data.amAlignRef1Str,'FontSize',pars.fontSize,...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplRef1StrUpdate',...
                                        'TooltipString','Reference FIDs for amplitude alignment [1]\n(e.g. 3:10)');                                     
end
if flag.OS==1               % Linux
    fm.data.align.amPolyLab   = text('Position',[0.6, 0.57],'String','Polynomial Order','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amPolyLab   = text('Position',[0.6, 0.723],'String','Polynomial Order','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amPolyLab   = text('Position',[0.6, 0.57],'String','Polynomial Order','FontSize',pars.fontSize);
end                               
fm.data.align.amPolyOrder = uicontrol('Style','Edit','Position', [465 412 45 18],'String',num2str(data.amAlignPolyOrder),'FontSize',pars.fontSize,...
                                      'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                      'TooltipString','Order of polynomical-based amplitude correction');
if flag.OS==1               % Linux
    fm.data.align.amExtraLab    = text('Position',[0.6, 0.508],'String','Extra Window','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.align.amExtraLab    = text('Position',[0.6, 0.679],'String','Extra Window','FontSize',pars.fontSize);
else                        % PC
    fm.data.align.amExtraLab    = text('Position',[0.6, 0.508],'String','Extra Window','FontSize',pars.fontSize);
end                               
fm.data.align.amExtraWin    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.amAlignExtraWin,...
                                        'Position',[.73 .65 .25 .03],'Callback','SP2_Data_AlignAmplExtraWinUpdate',...
                                        'TooltipString',sprintf('Optimization mode:\nMaximization of spectral integral'),'FontSize',pars.fontSize);
fm.data.align.amExtraPpmMin = uicontrol('Style','Edit','Position', [465 391 45 18],'String',num2str(data.amAlignExtraPpm(1)),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                        'TooltipString','Minimum limit [ppm] of extra display window','FontSize',pars.fontSize);
fm.data.align.amExtraPpmMax = uicontrol('Style','Edit','Position', [510 391 45 18],'String',num2str(data.amAlignExtraPpm(2)),...
                                        'BackGroundColor',pars.bgColor,'Callback','SP2_Data_AlignAmplParsUpdate',...
                                        'TooltipString','Maximum limit [ppm] of extra display window','FontSize',pars.fontSize);
                                    
                                    
%--- exit alignment tool ---
fm.data.align.exit = uicontrol('Style','Pushbutton','String','Exit','FontWeight','bold','Position',[480 30 70 20],...
                               'FontSize',pars.fontSize,'FontName','Helvetica','Callback','SP2_Data_AlignDetailsExit');


                                             
%--- window update ---
SP2_Data_AlignDetailsWinUpdate


end
