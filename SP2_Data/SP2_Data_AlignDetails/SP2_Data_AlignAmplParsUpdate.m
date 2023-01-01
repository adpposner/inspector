%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplParsUpdate
%% 
%%  Parameter update for frequency alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- retrieve parameter ---
data.amAlignExpLb = str2num(get(fm.data.align.amExpLb,'String'));
set(fm.data.align.amExpLb,'String',num2str(data.amAlignExpLb))

%--- apodization ---
data.amAlignFftCut = str2num(get(fm.data.align.amFftCut,'String'));
data.amAlignFftCut = round(max(data.amAlignFftCut,128));
set(fm.data.align.amFftCut,'String',num2str(data.amAlignFftCut))

%--- zero-filling ---
data.amAlignFftZf = str2num(get(fm.data.align.amFftZf,'String'));
data.amAlignFftZf = round(max(data.amAlignFftZf,1024));
set(fm.data.align.amFftZf,'String',num2str(data.amAlignFftZf))

%--- polynomial order ---
data.amAlignPolyOrder = str2num(get(fm.data.align.amPolyOrder,'String'));
data.amAlignPolyOrder = round(min(max(data.amAlignPolyOrder,0),5));
set(fm.data.align.amPolyOrder,'String',num2str(data.amAlignPolyOrder))

%--- extra window limits ---
data.amAlignExtraPpm(1) = str2num(get(fm.data.align.amExtraPpmMin,'String'));
data.amAlignExtraPpm(1) = min(data.amAlignExtraPpm(1),data.amAlignExtraPpm(2)-0.1);
set(fm.data.align.amExtraPpmMin,'String',num2str(data.amAlignExtraPpm(1)))
data.amAlignExtraPpm(2) = str2num(get(fm.data.align.amExtraPpmMax,'String'));
data.amAlignExtraPpm(2) = max(data.amAlignExtraPpm(1)+0.1,data.amAlignExtraPpm(2));
set(fm.data.align.amExtraPpmMax,'String',num2str(data.amAlignExtraPpm(2)))

%--- window update ---
SP2_Data_AlignDetailsWinUpdate


     
