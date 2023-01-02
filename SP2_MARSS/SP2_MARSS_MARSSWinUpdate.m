%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_MARSSWinUpdate
%% 
%%  'MARSS' window update
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag pars marss

FCTNAME = 'SP2_MARSS_MARSSWinUpdate';


%--- update pull down vendor selection ---
if flag.marssSequName==4        % custom sequence
    set(fm.marss.sequOriginLab,'Color',pars.bgTextColor)
    set(fm.marss.sequOrigin,'Enable','off')
else
    set(fm.marss.sequOriginLab,'Color',pars.fgTextColor)
    set(fm.marss.sequOrigin,'Enable','on')
end

%--- user simulation parameters ---
if flag.marssSimParsDef==3              % MARSS page
    set(fm.marss.simParsDefAdopt,'Enable','off')
    set(fm.marss.simParsLab,'Color',pars.fgTextColor)
    set(fm.marss.b0Lab,'Color',pars.fgTextColor)
    set(fm.marss.b0,'Enable','on')
    set(fm.marss.sfLab,'Color',pars.fgTextColor)
    set(fm.marss.sf,'Enable','on')
    set(fm.marss.sw_hLab,'Color',pars.fgTextColor)
    set(fm.marss.sw_h,'Enable','on')
    set(fm.marss.swLab,'Color',pars.fgTextColor)
    set(fm.marss.sw,'Enable','on')
    set(fm.marss.nspecCLab,'Color',pars.fgTextColor)
    set(fm.marss.nspecCBasic,'Enable','on')
    set(fm.marss.ppmCalibLab,'Color',pars.fgTextColor)
    set(fm.marss.ppmCalib,'Enable','on')
    set(fm.marss.voxDimLab,'Color',pars.fgTextColor)
    set(fm.marss.voxDim,'Enable','on')
    set(fm.marss.teLab,'Color',pars.fgTextColor)
    set(fm.marss.te,'Enable','on')
else                                    % all other INSPECTOR pages
    set(fm.marss.simParsDefAdopt,'Enable','on')
    set(fm.marss.simParsLab,'Color',pars.bgTextColor)
    set(fm.marss.b0Lab,'Color',pars.bgTextColor)
    set(fm.marss.b0,'Enable','off')
    set(fm.marss.sfLab,'Color',pars.bgTextColor)
    set(fm.marss.sf,'Enable','off')
    set(fm.marss.sw_hLab,'Color',pars.bgTextColor)
    set(fm.marss.sw_h,'Enable','off')
    set(fm.marss.swLab,'Color',pars.bgTextColor)
    set(fm.marss.sw,'Enable','off')
    set(fm.marss.nspecCLab,'Color',pars.bgTextColor)
    set(fm.marss.nspecCBasic,'Enable','off')
    set(fm.marss.ppmCalibLab,'Color',pars.bgTextColor)
    set(fm.marss.ppmCalib,'Enable','off')
    set(fm.marss.voxDimLab,'Color',pars.bgTextColor)
    set(fm.marss.voxDim,'Enable','off')
    set(fm.marss.teLab,'Color',pars.bgTextColor)
    set(fm.marss.te,'Enable','off')
end

%--- value update ---
set(fm.marss.b0,'String',sprintf('%.3f',marss.b0))
set(fm.marss.sf,'String',sprintf('%.2f',marss.sf))
set(fm.marss.sw_h,'String',sprintf('%.1f',marss.sw_h))
set(fm.marss.sw,'String',sprintf('%.3f',marss.sw))
set(fm.marss.nspecCBasic,'String',num2str(marss.nspecCBasic))
set(fm.marss.ppmCalib,'String',num2str(marss.ppmCalib))
set(fm.marss.voxDim,'String',num2str(marss.voxDim))
set(fm.marss.simDim,'String',num2str(marss.simDim))
set(fm.marss.lb,'String',num2str(marss.lb))
set(fm.marss.te,'String',num2str(marss.te))

%--- TM ---
if isfield(fm.marss,'tmLab')                % TM label
    if ishandle(fm.marss.tmLab)
        delete(fm.marss.tmLab)              % delete label
        fm.marss = rmfield(fm.marss,'tmLab');
    end
end
if isfield(fm.marss,'tm')                   % TM
    if ishandle(fm.marss.tm)
        delete(fm.marss.tm)                 % delete TM entry
        fm.marss = rmfield(fm.marss,'tm');
    end
end
if flag.marssSequName==1                    % STEAM
    fm.marss.tmLab = text('Position',[0.845, 0.5766],'String','TM','FontSize',pars.fontSize);                           
    fm.marss.tm    = uicontrol('Style','Edit','Position', [525 399 50 18],'String',num2str(marss.tm),...
                               'BackGroundColor',pars.bgColor,'Callback','SP2_MARSS_SimParsUpdate',...
                               'TooltipString',sprintf('Simulation detail: Mixing time [ms]'),'FontSize',pars.fontSize); 
end
    
%--- cut-off (apodization) ---
if flag.marssProcCut==1
    set(fm.marss.procCutDec3,'Enable','on')
    set(fm.marss.procCutDec2,'Enable','on')
    set(fm.marss.procCutDec1,'Enable','on')
    set(fm.marss.procCutVal,'Enable','on')
    set(fm.marss.procCutInc1,'Enable','on')
    set(fm.marss.procCutInc2,'Enable','on')
    set(fm.marss.procCutInc3,'Enable','on')
    set(fm.marss.procCutReset,'Enable','on')
else
    set(fm.marss.procCutDec3,'Enable','off')
    set(fm.marss.procCutDec2,'Enable','off')
    set(fm.marss.procCutDec1,'Enable','off')
    set(fm.marss.procCutVal,'Enable','off')
    set(fm.marss.procCutInc1,'Enable','off')
    set(fm.marss.procCutInc2,'Enable','off')
    set(fm.marss.procCutInc3,'Enable','off')
    set(fm.marss.procCutReset,'Enable','off')
end

%--- ZF ---
if flag.marssProcZf==1
    set(fm.marss.procZfDec3,'Enable','on')
    set(fm.marss.procZfDec2,'Enable','on')
    set(fm.marss.procZfDec1,'Enable','on')
    set(fm.marss.procZfVal,'Enable','on')
    set(fm.marss.procZfInc1,'Enable','on')
    set(fm.marss.procZfInc2,'Enable','on')
    set(fm.marss.procZfInc3,'Enable','on')
    set(fm.marss.procZfReset,'Enable','on')
else
    set(fm.marss.procZfDec3,'Enable','off')
    set(fm.marss.procZfDec2,'Enable','off')
    set(fm.marss.procZfDec1,'Enable','off')
    set(fm.marss.procZfVal,'Enable','off')
    set(fm.marss.procZfInc1,'Enable','off')
    set(fm.marss.procZfInc2,'Enable','off')
    set(fm.marss.procZfInc3,'Enable','off')
    set(fm.marss.procZfReset,'Enable','off')
end

%--- exponential line broadening ---
if flag.marssProcLb==1
    set(fm.marss.procLbDec3,'Enable','on')
    set(fm.marss.procLbDec2,'Enable','on')
    set(fm.marss.procLbDec1,'Enable','on')
    set(fm.marss.procLbVal,'Enable','on')
    set(fm.marss.procLbInc1,'Enable','on')
    set(fm.marss.procLbInc2,'Enable','on')
    set(fm.marss.procLbInc3,'Enable','on')
    set(fm.marss.procLbReset,'Enable','on')
else
    set(fm.marss.procLbDec3,'Enable','off')
    set(fm.marss.procLbDec2,'Enable','off')
    set(fm.marss.procLbDec1,'Enable','off')
    set(fm.marss.procLbVal,'Enable','off')
    set(fm.marss.procLbInc1,'Enable','off')
    set(fm.marss.procLbInc2,'Enable','off')
    set(fm.marss.procLbInc3,'Enable','off')
    set(fm.marss.procLbReset,'Enable','off')
end

%--- Gaussian line broadening ---
if flag.marssProcGb==1
    set(fm.marss.procGbDec3,'Enable','on')
    set(fm.marss.procGbDec2,'Enable','on')
    set(fm.marss.procGbDec1,'Enable','on')
    set(fm.marss.procGbVal,'Enable','on')
    set(fm.marss.procGbInc1,'Enable','on')
    set(fm.marss.procGbInc2,'Enable','on')
    set(fm.marss.procGbInc3,'Enable','on')
    set(fm.marss.procGbReset,'Enable','on')
else
    set(fm.marss.procGbDec3,'Enable','off')
    set(fm.marss.procGbDec2,'Enable','off')
    set(fm.marss.procGbDec1,'Enable','off')
    set(fm.marss.procGbVal,'Enable','off')
    set(fm.marss.procGbInc1,'Enable','off')
    set(fm.marss.procGbInc2,'Enable','off')
    set(fm.marss.procGbInc3,'Enable','off')
    set(fm.marss.procGbReset,'Enable','off')
end

%--- zero order phase correction ---
if flag.marssProcPhc0
    set(fm.marss.procPhc0Dec3,'Enable','on')
    set(fm.marss.procPhc0Dec2,'Enable','on')
    set(fm.marss.procPhc0Dec1,'Enable','on')
    set(fm.marss.procPhc0Val,'Enable','on')
    set(fm.marss.procPhc0Inc1,'Enable','on')
    set(fm.marss.procPhc0Inc2,'Enable','on')
    set(fm.marss.procPhc0Inc3,'Enable','on')
    set(fm.marss.procPhc0Reset,'Enable','on')
else
    set(fm.marss.procPhc0Dec3,'Enable','off')
    set(fm.marss.procPhc0Dec2,'Enable','off')
    set(fm.marss.procPhc0Dec1,'Enable','off')
    set(fm.marss.procPhc0Val,'Enable','off')
    set(fm.marss.procPhc0Inc1,'Enable','off')
    set(fm.marss.procPhc0Inc2,'Enable','off')
    set(fm.marss.procPhc0Inc3,'Enable','off')
    set(fm.marss.procPhc0Reset,'Enable','off')
end

%--- first order phase correction ---
if flag.marssProcPhc1
    set(fm.marss.procPhc1Dec3,'Enable','on')
    set(fm.marss.procPhc1Dec2,'Enable','on')
    set(fm.marss.procPhc1Dec1,'Enable','on')
    set(fm.marss.procPhc1Val,'Enable','on')
    set(fm.marss.procPhc1Inc1,'Enable','on')
    set(fm.marss.procPhc1Inc2,'Enable','on')
    set(fm.marss.procPhc1Inc3,'Enable','on')
    set(fm.marss.procPhc1Reset,'Enable','on')
else
    set(fm.marss.procPhc1Dec3,'Enable','off')
    set(fm.marss.procPhc1Dec2,'Enable','off')
    set(fm.marss.procPhc1Dec1,'Enable','off')
    set(fm.marss.procPhc1Val,'Enable','off')
    set(fm.marss.procPhc1Inc1,'Enable','off')
    set(fm.marss.procPhc1Inc2,'Enable','off')
    set(fm.marss.procPhc1Inc3,'Enable','off')
    set(fm.marss.procPhc1Reset,'Enable','off')
end

%--- amplitude scaling ---
if flag.marssProcScale==1
    set(fm.marss.procScaleDec3,'Enable','on')
    set(fm.marss.procScaleDec2,'Enable','on')
    set(fm.marss.procScaleDec1,'Enable','on')
    set(fm.marss.procScaleVal,'Enable','on')
    set(fm.marss.procScaleInc1,'Enable','on')
    set(fm.marss.procScaleInc2,'Enable','on')
    set(fm.marss.procScaleInc3,'Enable','on')
    set(fm.marss.procScaleReset,'Enable','on')
else
    set(fm.marss.procScaleDec3,'Enable','off')
    set(fm.marss.procScaleDec2,'Enable','off')
    set(fm.marss.procScaleDec1,'Enable','off')
    set(fm.marss.procScaleVal,'Enable','off')
    set(fm.marss.procScaleInc1,'Enable','off')
    set(fm.marss.procScaleInc2,'Enable','off')
    set(fm.marss.procScaleInc3,'Enable','off')
    set(fm.marss.procScaleReset,'Enable','off')
end

%--- frequency shift ---
if flag.marssProcShift==1
    set(fm.marss.procShiftDec3,'Enable','on')
    set(fm.marss.procShiftDec2,'Enable','on')
    set(fm.marss.procShiftDec1,'Enable','on')
    set(fm.marss.procShiftVal,'Enable','on')
    set(fm.marss.procShiftInc1,'Enable','on')
    set(fm.marss.procShiftInc2,'Enable','on')
    set(fm.marss.procShiftInc3,'Enable','on')
    set(fm.marss.procShiftReset,'Enable','on')
else
    set(fm.marss.procShiftDec3,'Enable','off')
    set(fm.marss.procShiftDec2,'Enable','off')
    set(fm.marss.procShiftDec1,'Enable','off')
    set(fm.marss.procShiftVal,'Enable','off')
    set(fm.marss.procShiftInc1,'Enable','off')
    set(fm.marss.procShiftInc2,'Enable','off')
    set(fm.marss.procShiftInc3,'Enable','off')
    set(fm.marss.procShiftReset,'Enable','off')
end

%--- analysis frequency mode ---
if flag.marssPpmShow                      % global loggingfile
    set(fm.marss.ppmShowMinDecr,'Enable','off')
    set(fm.marss.ppmShowMin,'Enable','off')
    set(fm.marss.ppmShowMinIncr,'Enable','off')
    set(fm.marss.ppmShowMaxDecr,'Enable','off')
    set(fm.marss.ppmShowMax,'Enable','off')
    set(fm.marss.ppmShowMaxIncr,'Enable','off')
else                                    % direct
    set(fm.marss.ppmShowMinDecr,'Enable','on')
    set(fm.marss.ppmShowMin,'Enable','on')
    set(fm.marss.ppmShowMinIncr,'Enable','on')
    set(fm.marss.ppmShowMaxDecr,'Enable','on')
    set(fm.marss.ppmShowMax,'Enable','on')
    set(fm.marss.ppmShowMaxIncr,'Enable','on')
end

%--- display amplitude mode ---
if flag.marssAmplShow                     % direct
    set(fm.marss.amplShowMin,'Enable','on')
    set(fm.marss.amplShowMax,'Enable','on')
else                                    % auto
    set(fm.marss.amplShowMin,'Enable','off')
    set(fm.marss.amplShowMax,'Enable','off')
end

%--- selection vs. all metabolites display ---
if flag.marssShowSelAll           % selection
    set(fm.marss.showSelStr,'Enable','on')
else
    set(fm.marss.showSelStr,'Enable','off')
end

%--- current display metabolite ---
set(fm.marss.singleCurr,'String',sprintf('%.0f',marss.currShow))


