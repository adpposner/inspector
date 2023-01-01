%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignFrequParsUpdate
%% 
%%  Parameter update for frequency alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data flag


%--- retrieve parameter ---
data.frAlignExpLb = str2num(get(fm.data.align.frExpLb,'String'));
set(fm.data.align.frExpLb,'String',num2str(data.frAlignExpLb))

data.frAlignFftCut = str2num(get(fm.data.align.frFftCut,'String'));
data.frAlignFftCut = round(max(data.frAlignFftCut,128));
set(fm.data.align.frFftCut,'String',num2str(data.frAlignFftCut))

data.frAlignFftZf = str2num(get(fm.data.align.frFftZf,'String'));
data.frAlignFftZf = round(max(data.frAlignFftZf,1024));
set(fm.data.align.frFftZf,'String',num2str(data.frAlignFftZf))

data.frAlignFrequRg = str2num(get(fm.data.align.frFrequRg,'String'));
data.frAlignFrequRg = round(max(min(data.frAlignFrequRg,100),3));
set(fm.data.align.frFrequRg,'String',num2str(data.frAlignFrequRg))

data.frAlignFrequRes = str2num(get(fm.data.align.frFrequRes,'String'));
data.frAlignFrequRes = min(max(data.frAlignFrequRes,0.001),10);
set(fm.data.align.frFrequRes,'String',num2str(data.frAlignFrequRes))

if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    data.frAlignRefFid(1) = str2num(get(fm.data.align.frRef1Fid,'String'));
    data.frAlignRefFid(1) = round(max(data.frAlignRefFid(1),1));
    set(fm.data.align.frRef1Fid,'String',num2str(data.frAlignRefFid(1)))
    data.frAlignRefFid(2) = str2num(get(fm.data.align.frRef2Fid,'String'));
    data.frAlignRefFid(2) = round(max(data.frAlignRefFid(2),1));
    set(fm.data.align.frRef2Fid,'String',num2str(data.frAlignRefFid(2)))
    
    %--- consistency check ---
    if ~mod(data.frAlignRefFid(1),2)
        fprintf('\nWARNING:\nSpectra of condition 1 are frequency aligned\nwith reference from condition 2!!!\n\n')
    end
    if mod(data.frAlignRefFid(2),2)
        fprintf('\nWARNING:\nSpectra of condition 2 are frequency aligned\nwith reference from condition 1!!!\n\n')
    end
else                            % all other cases: single condition
    data.frAlignRefFid = str2num(get(fm.data.align.frRefFid,'String'));
    data.frAlignRefFid = round(max(data.frAlignRefFid,0));
    data.frAlignRefFid = [data.frAlignRefFid data.frAlignRefFid];
    set(fm.data.align.frRefFid,'String',num2str(data.frAlignRefFid(1)))
end

data.frAlignIter = str2num(get(fm.data.align.frIter,'String'));
data.frAlignIter = round(max(data.frAlignIter,1));
set(fm.data.align.frIter,'String',num2str(data.frAlignIter))

data.frAlignVerbMax = str2double(get(fm.data.align.frVerbMax,'String'));
data.frAlignVerbMax = round(max(data.frAlignVerbMax,1));
set(fm.data.align.frVerbMax,'String',num2str(data.frAlignVerbMax));

%--- window update ---
SP2_Data_AlignDetailsWinUpdate


