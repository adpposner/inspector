%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_JdeEfficiencyWinUpdate
%% 
%%  Window update for JDE efficiency analysis.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm pars flag proc

FCTNAME = 'SP2_Proc_JdeEfficiencyWinUpdate';


%--- spectral amplitude offset ---
set(fm.proc.jdeEff.offsetVal,'String',sprintf('%.1f',proc.jdeEffOffset))


% 
% %--- optimization mode ---
% if flag.dataAlignPhMode         % congruency
%     set(fm.data.alignDet.phRefFidLab,'Color',pars.fgTextColor)
%     set(fm.data.alignDet.phRefFid,'Enable','on')
% else                            % spectral integral
%     set(fm.data.alignDet.phRefFidLab,'Color',pars.bgTextColor)
%     set(fm.data.alignDet.phRefFid,'Enable','off')
% end
%     
% %--- 1 vs. 2 spectral windows for phase alignment ---
% if flag.dataAlignPhSpecRg==0        % 1 window
%     set(fm.data.alignDet.phPpmDnLab,'Color',pars.bgTextColor)
%     set(fm.data.alignDet.phPpmDnMin,'Enable','off')
%     set(fm.data.alignDet.phPpmDnMax,'Enable','off')
% else
%     set(fm.data.alignDet.phPpmDnLab,'Color',pars.fgTextColor)
%     set(fm.data.alignDet.phPpmDnMin,'Enable','on')
%     set(fm.data.alignDet.phPpmDnMax,'Enable','on')
% end

