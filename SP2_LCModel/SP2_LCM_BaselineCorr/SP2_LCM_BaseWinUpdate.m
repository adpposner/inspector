%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_BaseWinUpdate
%% 
%%  Baseline window update
%%
%%  10-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm pars flag

FCTNAME = 'SP2_LCM_BaseWinUpdate';


% %--- baseline correction ---
% if flag.lcmAnaBaseCorr         % on
%     set(fm.lcm.base.anaPolyOrderL,'Color',pars.fgTextColor)
%     set(fm.lcm.base.anaPolyOrder,'Enable','on')
%     set(fm.lcm.base.anaPolyPpmLabel,'Color',pars.fgTextColor)
%     set(fm.lcm.base.anaPolyPpmStr,'Enable','on')
% else                            % off
%     set(fm.lcm.base.anaPolyOrderL,'Color',pars.bgTextColor)
%     set(fm.lcm.base.anaPolyOrder,'Enable','off')
%     set(fm.lcm.base.anaPolyPpmLabel,'Color',pars.bgTextColor)
%     set(fm.lcm.base.anaPolyPpmStr,'Enable','off')
% end
