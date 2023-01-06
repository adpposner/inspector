%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function SP2_Data_QualityDetailsMain
%%
%%  Create window for quality assessment of data series 1.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars flag data fm

FCTNAME = 'SP2_Data_QualityDetailsMain';


%--- kill existing figure ---
if isfield(fm.data,'qualityDet')
    if ishandle(fm.data.qualityDet.fig)
        delete(fm.data.qualityDet.fig)
    end
end

%--- create figure ---
fm.data.qualityDet.fig = figure('IntegerHandle','off');
set(fm.data.qualityDet.fig,'CloseRequestFcn',@SP2_Data_QualityExitMain);
set(fm.data.qualityDet.fig,'NumberTitle','off','Position',[30 80 400 600],'Color',pars.bgColor,...
                           'MenuBar','none','Resize','off','Name',' Quality Assessment Tool');
axes('Visible','off');

%--- phase alignment ---
if flag.OS==1               % Linux
    fm.data.qualityDet.expLbLab  = text('Position',[-0.11, 1.00],'String','Line broadening','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.expLbLab  = text('Position',[-0.11, 1.025],'String','Line broadening','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.expLbLab  = text('Position',[-0.11, 1.00],'String','Line broadening','FontSize',pars.fontSize);
end
fm.data.qualityDet.expLbVal  = uicontrol('Style','Edit','Position', [160 559 50 18],'String',num2str(data.quality.lb),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Exponential line broadening [Hz]');
if flag.OS==1               % Linux
    fm.data.qualityDet.fftCutLab  = text('Position',[-0.11, 0.91],'String','Apodization','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.fftCutLab  = text('Position',[-0.11, 0.965],'String','Apodization','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.fftCutLab  = text('Position',[-0.11, 0.91],'String','Apodization','FontSize',pars.fontSize);
end
fm.data.qualityDet.fftCutVal  = uicontrol('Style','Edit','Position', [160 528 50 18],'String',num2str(data.quality.cut),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Spectral apodization [pts]');
if flag.OS==1               % Linux
    fm.data.qualityDet.fftZfLab   = text('Position',[-0.11, 0.82],'String','Zero filling','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.fftZfLab   = text('Position',[-0.11, 0.905],'String','Zero filling','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.fftZfLab   = text('Position',[-0.11, 0.82],'String','Zero filling','FontSize',pars.fontSize);
end
fm.data.qualityDet.fftZfVal   = uicontrol('Style','Edit','Position', [160 497 50 18],'String',num2str(data.quality.zf),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Spectral zero-filling [pts]');
if flag.OS==1               % Linux
    fm.data.qualityDet.rowsLab    = text('Position',[-0.11, 0.73],'String','# of rows','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.rowsLab    = text('Position',[-0.11, 0.845],'String','# of rows','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.rowsLab    = text('Position',[-0.11, 0.73],'String','# of rows','FontSize',pars.fontSize);
end
fm.data.qualityDet.rowsVal    = uicontrol('Style','Edit','Position', [160 466 50 18],'String',num2str(data.quality.rows),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Number of rows in spectra display');
if flag.OS==1               % Linux
    fm.data.qualityDet.colsLab    = text('Position',[-0.11, 0.64],'String','# of columns','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.colsLab    = text('Position',[-0.11, 0.785],'String','# of columns','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.colsLab    = text('Position',[-0.11, 0.64],'String','# of columns','FontSize',pars.fontSize);
end
fm.data.qualityDet.colsVal    = uicontrol('Style','Edit','Position', [160 435 50 18],'String',num2str(data.quality.cols),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Number of columns in spectra display');
if flag.OS==1               % Linux
    fm.data.qualityDet.amplLab    = text('Position',[-0.11, 0.55],'String','Amplitude','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.amplLab    = text('Position',[-0.11, 0.711],'String','Amplitude','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.amplLab    = text('Position',[-0.11, 0.55],'String','Amplitude','FontSize',pars.fontSize);
end
fm.data.qualityDet.amplAuto   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.dataQualityAmplMode,...
                                          'String','Auto','Position',[.39 .672 .20 .03],'Callback','SP2_Data_QualityAmplAutoUpdate',...
                                          'TooltipString',sprintf('Automatic determination of amplitude range'));
fm.data.qualityDet.amplDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',~flag.dataQualityAmplMode,...
                                          'String','Direct','Position',[.54 .672 .20 .03],'Callback','SP2_Data_QualityAmplDirectUpdate',...
                                          'TooltipString',sprintf('Direct assignment of amplitude range'));
fm.data.qualityDet.amplMin    = uicontrol('Style','Edit','Position', [275 404 50 18],'String',num2str(data.quality.amplMin),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Lower amplitude limit');
fm.data.qualityDet.amplMax    = uicontrol('Style','Edit','Position', [325 404 50 18],'String',num2str(data.quality.amplMax),...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                          'TooltipString','Upper amplitude limit');
if flag.OS==1               % Linux
    fm.data.qualityDet.frequLab    = text('Position',[-0.11, 0.46],'String','Frequency','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.frequLab    = text('Position',[-0.11, 0.647],'String','Frequency','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.frequLab    = text('Position',[-0.11, 0.46],'String','Frequency','FontSize',pars.fontSize);
end
fm.data.qualityDet.frequglobal = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',flag.dataQualityFrequMode,...
                                           'String','global','Position',[.39 .622 .20 .03],'Callback','SP2_Data_QualityFrequglobalUpdate',...
                                           'TooltipString',sprintf('global frequency range'));
fm.data.qualityDet.frequDirect = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','Value',~flag.dataQualityFrequMode,...
                                           'String','Direct','Position',[.54 .622 .20 .03],'Callback','SP2_Data_QualityFrequDirectUpdate',...
                                           'TooltipString',sprintf('Direct assignment of frequency range'));
fm.data.qualityDet.frequMin    = uicontrol('Style','Edit','Position', [275 375 50 18],'String',num2str(data.quality.frequMin),...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                           'TooltipString','Lower frequency limit [ppm]');
fm.data.qualityDet.frequMax    = uicontrol('Style','Edit','Position', [325 375 50 18],'String',num2str(data.quality.frequMax),...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                           'TooltipString','Upper frequency limit [ppm]');
if flag.OS==1               % Linux
    fm.data.qualityDet.formatLab   = text('Position',[-0.11, 0.37],'String','Format','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.formatLab   = text('Position',[-0.11, 0.593],'String','Format','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.formatLab   = text('Position',[-0.11, 0.37],'String','Format','FontSize',pars.fontSize);
end
fm.data.qualityDet.formatReal  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Real', ...
                                           'Value',flag.dataQualityFormat==1,'Position',[.39 .572 .2 .03],'Callback','SP2_Data_QualityFormatRealUpdate');
fm.data.qualityDet.formatImag  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Imag', ...
                                           'Value',flag.dataQualityFormat==2,'Position',[.53 .572 .2 .03],'Callback','SP2_Data_QualityFormatImagUpdate');
fm.data.qualityDet.formatMagn  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Magn', ...
                                           'Value',flag.dataQualityFormat==3,'Position',[.67 .572 .2 .03],'Callback','SP2_Data_QualityFormatMagnUpdate');
fm.data.qualityDet.formatPhase = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Phase', ...
                                           'Value',flag.dataQualityFormat==4,'Position',[.82 .572 .2 .03],'Callback','SP2_Data_QualityFormatPhaseUpdate');
if flag.OS==1               % Linux
    fm.data.qualityDet.phaseZeroLab = text('Position',[-0.11, 0.28],'String','Zero Phase','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.phaseZeroLab = text('Position',[-0.11, 0.539],'String','Zero Phase','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.phaseZeroLab = text('Position',[-0.11, 0.28],'String','Zero Phase','FontSize',pars.fontSize);
end
fm.data.qualityDet.phaseZero    = uicontrol('Style','Edit','Position', [160 315 50 18],'String',num2str(data.quality.phaseZero),...
                                            'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityParsUpdate',...
                                            'TooltipString','global zero-order phase offset [deg]');
if flag.OS==1               % Linux
    fm.data.qualityDet.cmapLab     = text('Position',[-0.11, 0.19],'String','Color Mode','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.cmapLab     = text('Position',[-0.11, 0.465],'String','Color Mode','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.cmapLab     = text('Position',[-0.11, 0.19],'String','Color Mode','FontSize',pars.fontSize);
end
fm.data.qualityDet.cmapUni     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Blue', ...
                                           'Value',flag.dataQualityCMap==0,'Position',[.39 .472 .2 .03],'Callback','SP2_Data_QualityColormapUniUpdate');
fm.data.qualityDet.cmapJet     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Jet', ...
                                           'Value',flag.dataQualityCMap==1,'Position',[.53 .472 .2 .03],'Callback','SP2_Data_QualityColormapJetUpdate');
fm.data.qualityDet.cmapHsv     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Hsv', ...
                                           'Value',flag.dataQualityCMap==2,'Position',[.67 .472 .2 .03],'Callback','SP2_Data_QualityColormapHsvUpdate');
fm.data.qualityDet.cmapHot     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Hot', ...
                                           'Value',flag.dataQualityCMap==3,'Position',[.82 .472 .2 .03],'Callback','SP2_Data_QualityColormapHotUpdate');
fm.data.qualityDet.cmapglobal  = uicontrol('Style','Pushbutton','String','Match Range','Position',[160 260 85 18],'Callback','SP2_Data_QualityColormapMatch',...
                                           'TooltipString',sprintf('Adjust full color range to full NR range\n(via adjustment of # of rows/columns,\ni.e. scaling from blue (1st) to red (last))'));
fm.data.qualityDet.cmapLegend  = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Legend', ...
                                           'Value',flag.dataQualityLegend,'Position',[.67 .432 .2 .03],'Callback','SP2_Data_QualityColormapLegendUpdate',...
                                           'TooltipString',sprintf('Show overview data legend in superposition and serial window'));

%--- spectra selection ---
if flag.OS==1               % Linux
    fm.data.qualityDet.selectLab  = text('Position',[-0.11, 0.01],'String','Spectra selection','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.selectLab  = text('Position',[-0.11, 0.34],'String','Spectra selection','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.selectLab  = text('Position',[-0.11, 0.01],'String','Spectra selection','FontSize',pars.fontSize);
end
fm.data.qualityDet.selectStr  = uicontrol('Style','Edit','Position', [160 221 200 18],'String',data.quality.selectStr,...
                                          'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualitySelectStrUpdate',...
                                          'TooltipString',sprintf('Spectra selection (applied here)\n1) absolute numbering\n2) Matlab (colon) notation accepted'));             
fm.data.qualityDet.initNonJde = uicontrol('Style','Pushbutton','String','All (non-JDE)','Position',[160 202 90 18],'Callback','SP2_Data_QualitySelectInitNonJde',...
                                          'TooltipString','Initialize NR selection with direct (non-JDE) experiment string');
fm.data.qualityDet.initJde1   = uicontrol('Style','Pushbutton','String','JDE 1','Position',[250 202 55 18],'Callback','SP2_Data_QualitySelectInitJde1',...
                                          'TooltipString','Initialize NR selection with edited (1st) JDE experiments');
fm.data.qualityDet.initJde2   = uicontrol('Style','Pushbutton','String','JDE 2','Position',[305 202 55 18],'Callback','SP2_Data_QualitySelectInitJde2',...
                                          'TooltipString','Initialize NR selection with non-inverted (2nd) JDE experiments');

%--- visualization: superposition ---
fm.data.qualityDet.superposShow   = uicontrol('Style','Pushbutton','String','Superpos','Position',[25 160 65 18],'Callback','SP2_Data_QualitySuperposShow(1);',...
                                              'TooltipString','Visualize spectrum superposition');
fm.data.qualityDet.superposClose  = uicontrol('Style','Pushbutton','String','Close','Position',[90 160 50 18],'Callback','SP2_Data_QualitySuperposClose',...
                                              'TooltipString','Close spectrum superposition');

%--- visualization: array ---                                          
fm.data.qualityDet.arrayShow      = uicontrol('Style','Pushbutton','String','Array','Position',[160 160 50 18],'Callback','SP2_Data_QualityArrayShow(1);',...
                                              'TooltipString','Open spectra display');
fm.data.qualityDet.arrayBackward  = uicontrol('Style','Pushbutton','String','<<','Position',[210 160 35 18],'Callback','SP2_Data_QualityArrayBackward',...
                                              'TooltipString','Scroll backward through sets of spectra');
fm.data.qualityDet.arraySelectNr  = uicontrol('Style','Edit','Position', [245 160 40 18],'String',num2str(data.quality.selectNr),...
                                              'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityArraySelectNrUpdate',...
                                              'TooltipString','First NR to be displayed for arrayed spectral overview');
fm.data.qualityDet.arrayForward   = uicontrol('Style','Pushbutton','String','>>','Position',[285 160 35 18],'Callback','SP2_Data_QualityArrayForward',...
                                              'TooltipString','Scroll forward through sets of spectra');
fm.data.qualityDet.arrayClose     = uicontrol('Style','Pushbutton','String','Close','Position',[320 160 50 18],'Callback','SP2_Data_QualityArrayClose',...
                                              'TooltipString','Close spectra display');
                                          
%--- visualization: series ---
fm.data.qualityDet.seriesShow   = uicontrol('Style','Pushbutton','String','Series','Position',[25 130 65 18],'Callback','SP2_Data_QualitySeriesShow(1);',...
                                            'TooltipString','Visualize spectrum series');
fm.data.qualityDet.seriesClose  = uicontrol('Style','Pushbutton','String','Close','Position',[90 130 50 18],'Callback','SP2_Data_QualitySeriesClose',...
                                            'TooltipString','Close spectrum series');
fm.data.qualityDet.seriesMin    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Min', ...
                                            'Value',flag.dataQualitySeries==1,'Position',[.39 .215 .2 .03],'Callback','SP2_Data_QualitySeriesMinUpdate');
fm.data.qualityDet.seriesMax    = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Max', ...
                                            'Value',flag.dataQualitySeries==2,'Position',[.53 .215 .2 .03],'Callback','SP2_Data_QualitySeriesMaxUpdate');
fm.data.qualityDet.seriesMean   = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Mean', ...
                                            'Value',flag.dataQualitySeries==3,'Position',[.67 .215 .2 .03],'Callback','SP2_Data_QualitySeriesMeanUpdate');
fm.data.qualityDet.seriesMedian = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Median', ...
                                            'Value',flag.dataQualitySeries==4,'Position',[.82 .215 .2 .03],'Callback','SP2_Data_QualitySeriesMedianUpdate');
fm.data.qualityDet.seriesSD     = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','SD', ...
                                            'Value',flag.dataQualitySeries==5,'Position',[.39 .17 .2 .03],'Callback','SP2_Data_QualitySeriesStdDevUpdate');
fm.data.qualityDet.seriesIntegr = uicontrol('Style','RadioButton','BackGroundColor',pars.bgColor,'Units','Normalized','String','Integral', ...
                                            'Value',flag.dataQualitySeries==6,'Position',[.53 .17 .2 .03],'Callback','SP2_Data_QualitySeriesIntegralUpdate');
                                        
                                        
%--- data exclusion/replacement ---
if flag.OS==1               % Linux
    fm.data.qualityDet.excludeLab  = text('Position',[-0.11, -0.46],'String','Exclusion','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.excludeLab  = text('Position',[-0.11, 0.009],'String','Exclusion','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.excludeLab  = text('Position',[-0.11, -0.46],'String','Exclusion','FontSize',pars.fontSize);
end
fm.data.qualityDet.excludeStr  = uicontrol('Style','Edit','Position', [130 60 130 18],'String',data.quality.excludeStr,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityExcludeStrUpdate',...
                                           'TooltipString',sprintf('Selection of spectra to be excluded\n1) absolute numbering\n2) Matlab (colon) notation accepted'));
if flag.OS==1               % Linux
    fm.data.qualityDet.replaceLab  = text('Position',[-0.11, -0.52],'String','Replacement','FontSize',pars.fontSize);
elseif flag.OS==2           % Mac
    fm.data.qualityDet.replaceLab  = text('Position',[-0.11, -0.045],'String','Replacement','FontSize',pars.fontSize);
else                        % PC
    fm.data.qualityDet.replaceLab  = text('Position',[-0.11, -0.52],'String','Replacement','FontSize',pars.fontSize);
end
fm.data.qualityDet.replaceStr  = uicontrol('Style','Edit','Position', [130 40 130 18],'String',data.quality.replaceStr,...
                                           'BackGroundColor',pars.bgColor,'Callback','SP2_Data_QualityReplaceStrUpdate',...
                                           'TooltipString',sprintf('Selection of spectra applied to replace the excluded ones\n(note that number has to match the number excluded spectra)'));
fm.data.qualityDet.doReplace   = uicontrol('Style','Pushbutton','String','Replace','Position',[260 40 55 18],'Callback','SP2_Data_QualityReplaceApply;',...
                                           'TooltipString','Replace excluded spectra');

%--- close window ---
fm.data.qualityDet.closeWindow  = uicontrol('Style','Pushbutton','String','Exit','Position',[320 10 55 18],'Callback','SP2_Data_QualityExitMain',...
                                            'TooltipString','Close quality assessment window');
                                             
%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- close (old) superposition figure ---
SP2_Data_QualitySuperposClose

%--- close (old) series figure ---
SP2_Data_QualitySeriesClose

%--- close (old) array figure ---
SP2_Data_QualityArrayClose


end
