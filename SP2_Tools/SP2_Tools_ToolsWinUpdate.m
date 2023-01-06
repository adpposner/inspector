%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Tools_ToolsWinUpdate
%% 
%%  'Tools' window update
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm fmfig pars flag data proc

FCTNAME = 'SP2_Tools_ToolsWinUpdate';


%--- switch back to SPEC window ---
set(0,'CurrentFigure',fmfig)



% ,'Color',pars.fgTextColor)
%     set(fm.data.amplMax,'Enable','on')
% else                    % full (automatically determined) amplitude range
%     set(fm.data.amplMinLab,'Color',pars.bgTextColor)
%     set(fm.data.amplMin,'Enable','off')
%     set(fm.data.amplMaxLab,'Color',pars.bgTextColor)
%     set(fm.data.amplMax,'Enable','off')
% end
% 
% %--- ppm window ---
% if flag.dataPpmShow     % direct assignment of ppm window
%     set(fm.data.ppmShowMinLab,'Color',pars.fgTextColor)
%     set(fm.data.ppmShowMin,'Enable','on')
%     set(fm.data.ppmShowMaxLab,'Color',pars.fgTextColor)
%     set(fm.data.ppmShowMax,'Enable','on')
% else                    % full spectral range
%     set(fm.data.ppmShowMinLab,'Color',pars.bgTextColor)
%     set(fm.data.ppmShowMin,'Enable','off')
%     set(fm.data.ppmShowMaxLab,'Color',pars.bgTextColor)
%     set(fm.data.ppmShowMax,'Enable','off')
% end
% 
% %--- frequency correction ---
% if flag.dataFormat==4       % phase mode
%     set(fm.data.phaseLinCorr,'Enable','on')
% else
%     set(fm.data.phaseLinCorr,'Enable','off')
% end
% 

                

                


end
