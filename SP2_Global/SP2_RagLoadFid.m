%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fid, f_succ] = SP2_RagLoadFid(filePath)
%%
%%  Load FID in RAG text format from file.
%%
%%  03-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_RagLoadFid';


%--- init success flag ---
f_succ = 0;
fid    = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(filePath)
    return
end

%--- load data file ---
unit = fopen(filePath,'r');
if unit==-1
    fprintf('%s ->\nOpening data file failed. Program aborted.\n',FCTNAME)
    return
end
dataTmp = fscanf(unit,'%g		%g',[2 inf]);
fclose(unit);

%--- consistency check ---
if isempty(dataTmp)
    fprintf('%s ->\nData reading failed. Program aborted.\n',FCTNAME)
    return
end

%--- format data ---
fid = dataTmp(1,:)' + 1i*dataTmp(2,:)';

%--- update success flag ---
f_succ = 1;

