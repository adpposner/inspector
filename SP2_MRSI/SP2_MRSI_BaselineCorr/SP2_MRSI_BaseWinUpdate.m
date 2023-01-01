%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_BaseWinUpdate
%% 
%%  Baseline window update
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm pars flag

FCTNAME = 'SP2_MRSI_BaseWinUpdate';


% %--- baseline correction ---
% if flag.mrsiAnaBaseCorr         % on
%     set(fm.mrsi.base.anaPolyOrderL,'Color',pars.fgTextColor)
%     set(fm.mrsi.base.anaPolyOrder,'Enable','on')
%     set(fm.mrsi.base.anaPolyPpmLabel,'Color',pars.fgTextColor)
%     set(fm.mrsi.base.anaPolyPpmStr,'Enable','on')
% else                            % off
%     set(fm.mrsi.base.anaPolyOrderL,'Color',pars.bgTextColor)
%     set(fm.mrsi.base.anaPolyOrder,'Enable','off')
%     set(fm.mrsi.base.anaPolyPpmLabel,'Color',pars.bgTextColor)
%     set(fm.mrsi.base.anaPolyPpmStr,'Enable','off')
% end
