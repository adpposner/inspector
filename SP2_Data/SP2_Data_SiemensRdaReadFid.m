%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [dataSpec, f_succ] = SP2_Data_SiemensRdaReadFid(dataSpec)
%%
%%  Function to read MR spectroscopy data in Siemens' raw data format (rda).
%%
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile procpar

FCTNAME = 'SP2_Data_SiemensRdaReadFid';


%--- init success flag ---
f_succ = 0;

%--- check file existence ---
if 2==exist(dataSpec.fidFile)
    thedir = dir(dataSpec.fidFile);
    fSize  = thedir.bytes;
else
    fprintf('%s -> File %s doesn''nt exist\n\n',FCTNAME,dataSpec.fidFile)
    return
end
    
%--- get header length ---
[fid,msg] = fopen(dataSpec.fidFile,'r');
tline     = '';
f_found   = 0;
if fid>0
    %--- parameter extraction ---
    while ~feof(fid)
        tline = fgetl(fid);
        if strcmp(tline,'>>> End of header <<<')
            headerSize = ftell(fid);
            f_found = 1;
            break
        end
    end
    fclose(fid);
    
    %--- consistency check ---
    if ~f_found
        fprintf('%s ->\nReading file header has not been successful. Program aborted.\n',FCTNAME)
        return
    end
else
    fprintf('%s ->\nOpening <%s> not successful.\n%s\n\n',FCTNAME,file,msg);
    return
end

%--- info printout ---
fprintf('%s ->\nHeader size: %.0f bytes\n',FCTNAME,headerSize)

%--- file handling ---
% [fid, msg] = fopen(dataSpec.fidFile,'r',byteOrder);
[fid, msg] = fopen(dataSpec.fidFile,'rb');
if fid <= 0
    fprintf('%s ->\nOpening %s failed;\n%s\n\n',FCTNAME,dataSpec.fidFile,msg)
    return
end

%--- read data from file ---
% original format:
% outer loop: 3D partitions
% middle loop: lines
% inner loop: columns
% 2*VectorSize points per trace (nspec)
fseek(fid,headerSize,'bof');                    % jump to end of header
[datFid,nBytes] = fread(fid,inf,'double');

%--- consistency check here ---
fprintf('%s ->\n%.0f bytes read.\n',FCTNAME,nBytes)

%--- data formating ---
datFid       = reshape(datFid,2,procpar.VectorSize,procpar.CSIMatrixSize(1),procpar.CSIMatrixSize(2),procpar.CSIMatrixSize(3));
dataSpec.fid = complex(datFid(2,:,:,:,:),datFid(1,:,:,:,:));
if size(dataSpec.fid,1)==1
    dataSpec.fid = dataSpec.fid.';
end

%--- info printout ---
dataSpec.trOffset = 0;          % for now...
fprintf('nr/nspecC/nRcvrs: %d+%d/%d/%d\n',dataSpec.trOffset,...
        dataSpec.nr-dataSpec.trOffset,dataSpec.nspecC,dataSpec.nRcvrs);

%--- update success flag ---
f_succ = 1;



end
