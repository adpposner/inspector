%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignAmplParsUpdate
%% 
%%  Parameter update for frequency alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- parameter update ---
mm.amAlignExpLb = str2num(get(fm.mm.align.amExpLb,'String'));
set(fm.mm.align.amExpLb,'String',num2str(mm.amAlignExpLb))

%--- apodization ---
mm.amAlignFftCut = str2num(get(fm.mm.align.amFftCut,'String'));
mm.amAlignFftCut = round(max(mm.amAlignFftCut,128));
set(fm.mm.align.amFftCut,'String',num2str(mm.amAlignFftCut))

%--- zero-filling ---
mm.amAlignFftZf = str2num(get(fm.mm.align.amFftZf,'String'));
mm.amAlignFftZf = round(max(mm.amAlignFftZf,1024));
set(fm.mm.align.amFftZf,'String',num2str(mm.amAlignFftZf))

%--- polynomial order ---
mm.amAlignPolyOrder = str2num(get(fm.mm.align.amPolyOrder,'String'));
mm.amAlignPolyOrder = round(min(max(mm.amAlignPolyOrder,0),5));
set(fm.mm.align.amPolyOrder,'String',num2str(mm.amAlignPolyOrder))

%--- extra window limits ---
mm.amAlignExtraPpm(1) = str2num(get(fm.mm.align.amExtraPpmMin,'String'));
mm.amAlignExtraPpm(1) = min(mm.amAlignExtraPpm(1),mm.amAlignExtraPpm(2)-0.1);
set(fm.mm.align.amExtraPpmMin,'String',num2str(mm.amAlignExtraPpm(1)))
mm.amAlignExtraPpm(2) = str2num(get(fm.mm.align.amExtraPpmMax,'String'));
mm.amAlignExtraPpm(2) = max(mm.amAlignExtraPpm(1)+0.1,mm.amAlignExtraPpm(2));
set(fm.mm.align.amExtraPpmMax,'String',num2str(mm.amAlignExtraPpm(2)))

%--- window update ---
SP2_MM_AlignDetailsWinUpdate


     

end
