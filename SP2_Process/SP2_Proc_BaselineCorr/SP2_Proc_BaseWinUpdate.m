%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_BaseWinUpdate
%% 
%%  Baseline window update
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm pars flag

FCTNAME = 'SP2_Proc_BaseWinUpdate';


% %--- baseline correction ---
% if flag.procAnaBaseCorr         % on
%     set(fm.proc.base.anaPolyOrderL,'Color',pars.fgTextColor)
%     set(fm.proc.base.anaPolyOrder,'Enable','on')
%     set(fm.proc.base.anaPolyPpmLabel,'Color',pars.fgTextColor)
%     set(fm.proc.base.anaPolyPpmStr,'Enable','on')
% else                            % off
%     set(fm.proc.base.anaPolyOrderL,'Color',pars.bgTextColor)
%     set(fm.proc.base.anaPolyOrder,'Enable','off')
%     set(fm.proc.base.anaPolyPpmLabel,'Color',pars.bgTextColor)
%     set(fm.proc.base.anaPolyPpmStr,'Enable','off')
% end