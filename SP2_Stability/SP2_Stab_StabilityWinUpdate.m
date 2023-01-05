%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_StabilityWinUpdate
%% 
%%  'Analysis' window update
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm pars flag stab data

FCTNAME = 'SP2_Stab_StabilityWinUpdate';



%--- update cut-off value ---
if flag.stabRealMagn            % real part
    set(fm.stab.phc0Lab,'Color',pars.fgTextColor)
    set(fm.stab.phc0,'Enable','on')
else                            % magnitude
    set(fm.stab.phc0Lab,'Color',pars.bgTextColor)
    set(fm.stab.phc0,'Enable','off')
end

%--- receiver mode: entry fields ---
if isfield(data,'nRcvrs')
    if data.nRcvrs==1               % single receiver
        set(fm.stab.transLab,'Color',pars.bgTextColor)
        set(fm.stab.transNumDecr,'Enable','off')
        set(fm.stab.transNum,'Enable','off','BackGroundColor',pars.bgColor)
        set(fm.stab.transNumIncr,'Enable','off')
        set(fm.stab.rcvrLab,'Color',pars.bgTextColor)
        set(fm.stab.rcvrNumDecr,'Enable','off')
        set(fm.stab.rcvrNum,'Enable','off','BackGroundColor',pars.bgColor)
        set(fm.stab.rcvrNumIncr,'Enable','off')
    else                            % multiple receivers
        set(fm.stab.transLab,'Color',pars.fgTextColor)
        set(fm.stab.transNumDecr,'Enable','on')
        set(fm.stab.transNum,'Enable','on','BackGroundColor',pars.fgColor)
        set(fm.stab.transNumIncr,'Enable','on')
        set(fm.stab.rcvrLab,'Color',pars.fgTextColor)
        set(fm.stab.rcvrNumDecr,'Enable','on')
        set(fm.stab.rcvrNum,'Enable','on','BackGroundColor',pars.fgColor)
        set(fm.stab.rcvrNumIncr,'Enable','on')
    end
end