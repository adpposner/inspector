%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_T1T2WinUpdate
%% 
%%  'Analysis' window update
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag t1t2 pars

FCTNAME = 'SP2_T1T2_T1T2WinUpdate';


%--- data selection ---
if flag.t1t2AnaData==1                                  % FIDs
    set(fm.t1t2.anaOriginLab,'Color',pars.fgTextColor)
    set(fm.t1t2.anaFidLab,'Color',pars.fgTextColor)
    set(fm.t1t2.anaFidMin,'Enable','on')
    set(fm.t1t2.anaFidMax,'Enable','on')
    set(fm.t1t2.ppmWinLab,'Color',pars.bgTextColor)
    set(fm.t1t2.ppmWinMin,'Enable','off')
    set(fm.t1t2.ppmWinMax,'Enable','off')
    set(fm.t1t2.anaFormatReal,'Enable','on')
    set(fm.t1t2.anaFormatMagn,'Enable','on')
    if flag.t1t2AnaSignFlip
        set(fm.t1t2.anaSignFlipN,'Enable','on')
    else
        set(fm.t1t2.anaSignFlipN,'Enable','off')
    end
    set(fm.t1t2.anaTimeLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaTimeStr,'Enable','off')            
    set(fm.t1t2.anaAmpLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaAmpStr,'Enable','off')
elseif flag.t1t2AnaData==2 || flag.t1t2AnaData==3       % spectra
    set(fm.t1t2.anaOriginLab,'Color',pars.fgTextColor)
    set(fm.t1t2.anaFidLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaFidMin,'Enable','off')
    set(fm.t1t2.anaFidMax,'Enable','off')
    set(fm.t1t2.ppmWinLab,'Color',pars.fgTextColor)
    set(fm.t1t2.ppmWinMin,'Enable','on')
    set(fm.t1t2.ppmWinMax,'Enable','on')
    set(fm.t1t2.anaFormatReal,'Enable','on')
    set(fm.t1t2.anaFormatMagn,'Enable','on')
    if flag.t1t2AnaSignFlip
        set(fm.t1t2.anaSignFlipN,'Enable','on')
    else
        set(fm.t1t2.anaSignFlipN,'Enable','off')
    end
    set(fm.t1t2.anaTimeLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaTimeStr,'Enable','off')            
    set(fm.t1t2.anaAmpLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaAmpStr,'Enable','off')
else                                                    % direct assignment
    set(fm.t1t2.anaOriginLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaFidLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaFidMin,'Enable','off')
    set(fm.t1t2.anaFidMax,'Enable','off')
    set(fm.t1t2.ppmWinLab,'Color',pars.bgTextColor)
    set(fm.t1t2.ppmWinMin,'Enable','off')
    set(fm.t1t2.ppmWinMax,'Enable','off')
    set(fm.t1t2.anaFormatReal,'Enable','off')
    set(fm.t1t2.anaFormatMagn,'Enable','off')
    if flag.t1t2AnaSignFlip
        set(fm.t1t2.anaSignFlipN,'Enable','on')
    else
        set(fm.t1t2.anaSignFlipN,'Enable','off')
    end
    set(fm.t1t2.anaTimeLab,'Color',pars.fgTextColor)
    set(fm.t1t2.anaTimeStr,'Enable','on')            
    set(fm.t1t2.anaAmpLab,'Color',pars.fgTextColor)
    set(fm.t1t2.anaAmpStr,'Enable','on')
end

%--- T1 components ---
if flag.t1t2AnaMode           % fixed
    set(fm.t1t2.anaTConstFlexN,'Enable','off')
    set(fm.t1t2.anaTConstLab,'String',sprintf('T1 selection (%.0f)',t1t2.anaTConstN),'Color',pars.fgTextColor)
    set(fm.t1t2.anaTConstStr,'String',t1t2.anaTConstStr,'Enable','on')
    set(fm.t1t2.anaModeFlex1Fix,'Enable','off')
    set(fm.t1t2.anaTConstFlex1Fix,'Enable','off')
else
    set(fm.t1t2.anaTConstFlexN,'Enable','on')
    set(fm.t1t2.anaTConstLab,'Color',pars.bgTextColor)
    set(fm.t1t2.anaTConstStr,'String',t1t2.anaTConstStr,'Enable','off')
    set(fm.t1t2.anaModeFlex1Fix,'Enable','on')
    if flag.t1t2AnaFlex1Fix
        set(fm.t1t2.anaTConstFlex1Fix,'Enable','on')
    else
        set(fm.t1t2.anaTConstFlex1Fix,'Enable','off')
    end
end

%--- analysis frequency mode ---
if flag.t1t2PpmShow                     % global loggingfile
    set(fm.t1t2.ppmShowMin,'Enable','off')
    set(fm.t1t2.ppmShowMax,'Enable','off')
else                                % direct
    set(fm.t1t2.ppmShowMin,'Enable','on')
    set(fm.t1t2.ppmShowMax,'Enable','on')
end

%--- display amplitude mode ---
if flag.t1t2AmplShow                      % auto
    set(fm.t1t2.amplShowMin,'Enable','off')
    set(fm.t1t2.amplShowMax,'Enable','off')
else                                % direct
    set(fm.t1t2.amplShowMin,'Enable','on')
    set(fm.t1t2.amplShowMax,'Enable','on')
end



