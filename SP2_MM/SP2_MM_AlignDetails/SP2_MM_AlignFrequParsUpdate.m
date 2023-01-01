%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignFrequParsUpdate
%% 
%%  Parameter update for frequency alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- parameter update ---
mm.frAlignExpLb = str2num(get(fm.mm.align.frExpLb,'String'));
set(fm.mm.align.frExpLb,'String',num2str(mm.frAlignExpLb))

mm.frAlignFftCut = str2num(get(fm.mm.align.frFftCut,'String'));
mm.frAlignFftCut = round(max(mm.frAlignFftCut,128));
set(fm.mm.align.frFftCut,'String',num2str(mm.frAlignFftCut))

mm.frAlignFftZf = str2num(get(fm.mm.align.frFftZf,'String'));
mm.frAlignFftZf = round(max(mm.frAlignFftZf,1024));
set(fm.mm.align.frFftZf,'String',num2str(mm.frAlignFftZf))

mm.frAlignFrequRg = str2num(get(fm.mm.align.frFrequRg,'String'));
mm.frAlignFrequRg = round(min(mm.frAlignFrequRg,100));
set(fm.mm.align.frFrequRg,'String',num2str(mm.frAlignFrequRg))

mm.frAlignFrequRes = str2num(get(fm.mm.align.frFrequRes,'String'));
mm.frAlignFrequRes = min(max(mm.frAlignFrequRes,0.001),10);
set(fm.mm.align.frFrequRes,'String',num2str(mm.frAlignFrequRes))

mm.frAlignRefFid = str2num(get(fm.mm.align.frRefFid,'String'));
mm.frAlignRefFid = round(max(mm.frAlignRefFid,1));
set(fm.mm.align.frRefFid,'String',num2str(mm.frAlignRefFid))

mm.frAlignIter = str2num(get(fm.mm.align.frIter,'String'));
mm.frAlignIter = round(max(mm.frAlignIter,1));
set(fm.mm.align.frIter,'String',num2str(mm.frAlignIter))

%--- window update ---
SP2_MM_AlignDetailsWinUpdate


     
