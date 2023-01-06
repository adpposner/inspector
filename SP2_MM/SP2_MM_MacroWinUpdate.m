%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_MacroWinUpdate
%% 
%%  'MM' window update
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag mm pars

FCTNAME = 'SP2_MM_MacroWinUpdate';


%--- box car width [Hz] ---
set(fm.mm.boxCarHz,'String',sprintf('/ %.1f Hz',mm.boxCarHz))

%--- analysis frequency mode ---
if flag.mmAnaFrequMode        % global
    set(fm.mm.anaFrequMin,'Enable','off')
    set(fm.mm.anaFrequMax,'Enable','off')
else                                % direct
    set(fm.mm.anaFrequMin,'Enable','on')
    set(fm.mm.anaFrequMax,'Enable','on')
end

%--- T1 components ---
if flag.mmAnaTOneMode           % fixed
    set(fm.mm.anaTOneFlexN,'Enable','off')
    set(fm.mm.anaTOneFlexThLab,'Color',pars.bgTextColor)
    set(fm.mm.anaTOneFlexThMin,'Enable','off')
    set(fm.mm.anaTOneFlexThMax,'Enable','off')
    set(fm.mm.anaTOneLab,'String',sprintf('T1 selection (%.0f)',mm.anaTOneN),'Color',pars.fgTextColor)
    set(fm.mm.anaTOneStr,'String',mm.anaTOneStr,'Enable','on')
else
    set(fm.mm.anaTOneFlexN,'Enable','on')
    set(fm.mm.anaTOneFlexThLab,'Color',pars.fgTextColor)
    set(fm.mm.anaTOneFlexThMin,'Enable','on')
    set(fm.mm.anaTOneFlexThMax,'Enable','on')
    set(fm.mm.anaTOneLab,'Color',pars.bgTextColor)
    set(fm.mm.anaTOneStr,'String',mm.anaTOneStr,'Enable','off')
end

%--- analysis frequency mode ---
if flag.mmPpmShow                     % global
    set(fm.mm.ppmShowMin,'Enable','off')
    set(fm.mm.ppmShowMax,'Enable','off')
else                                % direct
    set(fm.mm.ppmShowMin,'Enable','on')
    set(fm.mm.ppmShowMax,'Enable','on')
end

%--- display amplitude mode ---
if flag.mmAmplShow                      % auto
    set(fm.mm.amplShowMin,'Enable','off')
    set(fm.mm.amplShowMax,'Enable','off')
else                                % direct
    set(fm.mm.amplShowMin,'Enable','on')
    set(fm.mm.amplShowMax,'Enable','on')
end

%--- saturation-recovery: considered string update ---
set(fm.mm.satRecConsStr,'String',mm.satRecConsStr)

%--- T1 components: considered string update ---
set(fm.mm.tOneConsStr,'String',mm.tOneConsStr)

%--- exponential fit analsysis ---
set(fm.mm.expPpmSelect,'String',sprintf('%.4f',mm.expPpmSelect))
set(fm.mm.expPointSelect,'String',num2str(mm.expPointSelect))

%--- ppm line display ---
set(fm.mm.ppmShowPosVal,'String',sprintf('%.4f',mm.ppmShowPos))

end
