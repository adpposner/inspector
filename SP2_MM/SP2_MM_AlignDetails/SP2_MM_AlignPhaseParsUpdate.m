%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignPhaseParsUpdate
%% 
%%  Parameter update for phase alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- parameter update ---
mm.phAlignExpLb = str2num(get(fm.mm.align.phExpLb,'String'));
set(fm.mm.align.phExpLb,'String',num2str(mm.phAlignExpLb))

mm.phAlignFftCut = str2num(get(fm.mm.align.phFftCut,'String'));
mm.phAlignFftCut = round(max(mm.phAlignFftCut,128));
set(fm.mm.align.phFftCut,'String',num2str(mm.phAlignFftCut))

mm.phAlignFftZf = str2num(get(fm.mm.align.phFftZf,'String'));
mm.phAlignFftZf = round(max(mm.phAlignFftZf,1024));
set(fm.mm.align.phFftZf,'String',num2str(mm.phAlignFftZf))

mm.phAlignPhStep = str2num(get(fm.mm.align.phPhStep,'String'));
mm.phAlignPhStep = max(mm.phAlignPhStep,1);
set(fm.mm.align.phPhStep,'String',num2str(mm.phAlignPhStep))

mm.phAlignRefFid = str2num(get(fm.mm.align.phRefFid,'String'));
mm.phAlignRefFid = round(max(mm.phAlignRefFid,1));
set(fm.mm.align.phRefFid,'String',num2str(mm.phAlignRefFid))

mm.phAlignIter = str2num(get(fm.mm.align.phIter,'String'));
mm.phAlignIter = round(max(mm.phAlignIter,1));
set(fm.mm.align.phIter,'String',num2str(mm.phAlignIter))

%--- window update ---
SP2_MM_AlignDetailsWinUpdate


end
