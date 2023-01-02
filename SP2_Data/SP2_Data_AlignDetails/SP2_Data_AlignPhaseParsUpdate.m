%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhaseParsUpdate
%% 
%%  Parameter update for phase alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data flag


%--- retrieve parameter ---
% data.phAlignPpmDnMin = str2num(get(fm.data.align.phPpmDnMin,'String'));
% data.phAlignPpmDnMin = min(data.phAlignPpmDnMin,data.phAlignPpmDnMax);
% set(fm.data.align.phPpmDnMin,'String',num2str(data.phAlignPpmDnMin))
% 
% data.phAlignPpmDnMax = str2num(get(fm.data.align.phPpmDnMax,'String'));
% data.phAlignPpmDnMax = max(data.phAlignPpmDnMin,data.phAlignPpmDnMax);
% set(fm.data.align.phPpmDnMax,'String',num2str(data.phAlignPpmDnMax))
% 
% data.phAlignPpmUpMin = str2num(get(fm.data.align.phPpmUpMin,'String'));
% data.phAlignPpmUpMin = min(data.phAlignPpmUpMin,data.phAlignPpmUpMax);
% set(fm.data.align.phPpmUpMin,'String',num2str(data.phAlignPpmUpMin))
% 
% data.phAlignPpmUpMax = str2num(get(fm.data.align.phPpmUpMax,'String'));
% data.phAlignPpmUpMax = max(data.phAlignPpmUpMin,data.phAlignPpmUpMax);
% set(fm.data.align.phPpmUpMax,'String',num2str(data.phAlignPpmUpMax))

data.phAlignExpLb = str2num(get(fm.data.align.phExpLb,'String'));
set(fm.data.align.phExpLb,'String',num2str(data.phAlignExpLb))

data.phAlignFftCut = str2num(get(fm.data.align.phFftCut,'String'));
data.phAlignFftCut = round(max(data.phAlignFftCut,128));
set(fm.data.align.phFftCut,'String',num2str(data.phAlignFftCut))

data.phAlignFftZf = str2num(get(fm.data.align.phFftZf,'String'));
data.phAlignFftZf = round(max(data.phAlignFftZf,1024));
set(fm.data.align.phFftZf,'String',num2str(data.phAlignFftZf))

data.phAlignPhStep = str2num(get(fm.data.align.phPhStep,'String'));
data.phAlignPhStep = max(data.phAlignPhStep,1);
set(fm.data.align.phPhStep,'String',num2str(data.phAlignPhStep))

if flag.dataExpType==3 || flag.dataExpType==7          % editing experiment, i.e. 2 conditions                                     
    data.phAlignRefFid(1) = str2num(get(fm.data.align.phRef1Fid,'String'));
    data.phAlignRefFid(1) = round(max(data.phAlignRefFid(1),1));
    set(fm.data.align.phRef1Fid,'String',num2str(data.phAlignRefFid(1)))
    data.phAlignRefFid(2) = str2num(get(fm.data.align.phRef2Fid,'String'));
    data.phAlignRefFid(2) = round(max(data.phAlignRefFid(2),1));
    set(fm.data.align.phRef2Fid,'String',num2str(data.phAlignRefFid(2)))
    
    %--- consistency check ---
    if ~mod(data.phAlignRefFid(1),2)
        fprintf('\nWARNING:\nSpectra of condition 1 are phase aligned\nwith reference from condition 2!!!\n\n');
    end
    if mod(data.phAlignRefFid(2),2)
        fprintf('\nWARNING:\nSpectra of condition 2 are phase aligned\nwith reference from condition 1!!!\n\n');
    end
else                            % all other experiments: single condition
    data.phAlignRefFid = str2num(get(fm.data.align.phRefFid,'String'));
    data.phAlignRefFid = round(max(data.phAlignRefFid,0));
    data.phAlignRefFid = [data.phAlignRefFid data.phAlignRefFid];       % duplicate
    set(fm.data.align.phRefFid,'String',num2str(data.phAlignRefFid(1)))
end

data.phAlignIter = str2double(get(fm.data.align.phIter,'String'));
data.phAlignIter = round(max(data.phAlignIter,1));
set(fm.data.align.phIter,'String',num2str(data.phAlignIter))

data.phAlignVerbMax = str2double(get(fm.data.align.phVerbMax,'String'));
data.phAlignVerbMax = round(max(data.phAlignVerbMax,1));
set(fm.data.align.phVerbMax,'String',num2str(data.phAlignVerbMax));

%--- window update ---
SP2_Data_AlignDetailsWinUpdate

