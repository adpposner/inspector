%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignDetailsWinUpdate
%% 
%%  'Alignment Details' window update
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm pars flag

FCTNAME = 'SP2_MM_AlignDetailsWinUpdate';



%--- optimization mode ---
% if flag.mmAlignPhMode         % congruency
%     set(fm.mm.align.phRefFidLab,'Color',pars.fgTextColor)
%     set(fm.mm.align.phRefFid,'Enable','on')
% else                            % spectral integral
%     set(fm.mm.align.phRefFidLab,'Color',pars.bgTextColor)
%     set(fm.mm.align.phRefFid,'Enable','off')
% end
    
%--- extra spectral window ---
if flag.amAlignExtraWin
    set(fm.mm.align.amExtraPpmMin,'Enable','on')
    set(fm.mm.align.amExtraPpmMax,'Enable','on')
else
    set(fm.mm.align.amExtraPpmMin,'Enable','off')
    set(fm.mm.align.amExtraPpmMax,'Enable','off')
end

    
    


