%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignDetailsWinUpdate
%% 
%%  'Alignment Details' window update
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm pars flag

FCTNAME = 'SP2_Data_AlignDetailsWinUpdate';



% %--- optimization mode ---
% if flag.dataAlignPhMode         % congruency
%     if flag.dataExpType==3 || flag.dataExpType==7      % editing / 2 conditions
%         set(fm.data.align.phRef1FidLab,'Color',pars.fgTextColor)
%         set(fm.data.align.phRef1Fid,'Enable','on')
%         set(fm.data.align.phRef2FidLab,'Color',pars.fgTextColor)
%         set(fm.data.align.phRef2Fid,'Enable','on')
%     else                        % all others / 1 condition
%         set(fm.data.align.phRefFidLab,'Color',pars.fgTextColor)
%             set(fm.data.align.phRefFid,'Enable','on')
%     end
% else                            % spectral integral
%     if flag.dataExpType==3 || flag.dataExpType==7      % editing / 2 conditions
%         set(fm.data.align.phRef1FidLab,'Color',pars.bgTextColor)
%         set(fm.data.align.phRef1Fid,'Enable','off')
%         set(fm.data.align.phRef2FidLab,'Color',pars.bgTextColor)
%         set(fm.data.align.phRef2Fid,'Enable','off')
%     else                        % all others / 1 condition
%         set(fm.data.align.phRefFidLab,'Color',pars.bgTextColor)
%             set(fm.data.align.phRefFid,'Enable','off')
%     end
% end
    
%--- extra spectral window ---
if flag.amAlignExtraWin
    set(fm.data.align.amExtraPpmMin,'Enable','on')
    set(fm.data.align.amExtraPpmMax,'Enable','on')
else
    set(fm.data.align.amExtraPpmMin,'Enable','off')
    set(fm.data.align.amExtraPpmMax,'Enable','off')
end

    
    



end
