%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_succ] = SP2_Data_GEReadFidJDE(dataSpec)
%%
%%  Function to read GE's regular MRS data files.
%%
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_GEReadFidJDE';



%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if ~SP2_CheckFileExistenceR(dataSpec.fidFile)
    return
end

%--- tmp pars assignment ---
nspecC      = dataSpec.nspecC;
nr          = dataSpec.nr;
numberBytes = dataSpec.numberBytes;
nRcvrs      = dataSpec.nRcvrs;
precision   = dataSpec.wordSize;
  
% Compute (byte) size of frames, echoes and slices
traceBytes    = (2*nspecC)*numberBytes;     % bytes of a single trace                 % 16384
rcvrBytes     = traceBytes*(nr+1);          % bytes per receiver for all traces       % 114688, note the +1
basePtrOffset = traceBytes;                 % bytes of baseline = 1 regular spec      % 16384

%--- file handling ---
[fileID,msg] = fopen(dataSpec.fidFile,'r',dataSpec.byteOrder);
if fileID==-1
    fprintf('%s ->\nOpening data file failed\n%s\n. Program aborted.\n',FCTNAME,msg);
    return
end

%--- read data ---
% inner loop: nr, outer loop: receivers
datFid = complex(zeros(nspecC*nr,nRcvrs));
for rCnt = 1:nRcvrs
    rcvrPtrOffset = (rCnt-1)*rcvrBytes;
    % fprintf('rcvrPtrOffset: %.0f\n',rcvrPtrOffset);
    rcvrPtr = dataSpec.headerSizeTot + rcvrPtrOffset + basePtrOffset;
    % fprintf('rcvrPtr position: %.0f\n',rcvrPtr);
    if fseek(fileID,rcvrPtr,'bof')==-1
        fprintf('%s ->\nPointer positioning failed for receiver #%.0f. Program abBytesorted.\n',FCTNAME,rCnt);
        return
    end
    [datRaw,fcount] = fread(fileID,2*nspecC*nr,precision);

    %--- consistency check: expected data size vs. file size ---
    if fcount==(2*nspecC)*nr
        if rCnt==1
            fprintf('Reading <%s>\n',dataSpec.fidFile);
            fprintf('nr/nspecC/nRcvrs: %d+%d/%d/%d\n',dataSpec.trOffset,nr-dataSpec.trOffset,nspecC,nRcvrs);
        end
    else
        fprintf('%s of receiver #%.0f failed ->\nRead %d ~= nspec*nr: %d*%d = %d\n',FCTNAME,rCnt,fcount,2*nspecC,nr,2*nspecC*nr);
        if fclose(fileID)==-1
            fprintf('%s ->\nClosing file %s failed\n',FCTNAME,dataSpec.fidFile)
        end
        return
    end
      
    %--- data assignment ---
    datFid(:,rCnt) = complex(datRaw(1:2:end),datRaw(2:2:end));
end

%--- close data file ---
if fclose(fileID)==-1
    fprintf('%s ->\nClosing file %s failed\n',FCTNAME,dataSpec.fidFile)
    return
end

%--- data reformating ---
datFid = permute(reshape(datFid,nspecC,nr,nRcvrs),[2 1 3]);    

%--- update success flag ---
f_succ = 1;



end
