%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_LcmWriteRaw
%%
%%  Function to write FIDs to file in Provencher LCModel format.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc


FCTNAME = 'SP2_Proc_LcmWriteRaw';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    return
end

%--- key strings ---       
FMTDAT  = '(8E13.5)';		% to define FORTRAN format for RAW data: '(8E13.5)'
NCOLS   = 8;

%--- data formating ---
data2write = zeros(2,proc.expt.nspecC);
data2write(1,:) = real(proc.expt.fid);
data2write(2,:) = -imag(proc.expt.fid);
data2write = reshape(data2write,2*proc.expt.nspecC,1);

% ---- writing RAW file ---
unit = fopen(proc.expt.dataPathRaw,'w');
if unit<0
    fprintf('Can not open <%s>.\nProgram aborted',proc.expt.dataPathRaw);
    return
end
fprintf('%s -> writing <%s>\n',FCTNAME,proc.expt.dataPathRaw);

for i=1:length(proc.lcmHeader.COMM) 
    fprintf(unit, ' %s\n', proc.lcmHeader.COMM{i});
end
fprintf(unit, ' $NMID\n');
str_id = deblank(upper(proc.lcmHeader.ID));
fprintf(unit, ' ID=''%s''\n', str_id(1:min(16,end)));
fprintf(unit, ' FMTDAT=''%s''\n', FMTDAT);
fprintf(unit, ' VOLUME=%14.5E\n', proc.lcmHeader.VOLUME);
fprintf(unit, ' TRAMP=%14.5E\n', proc.lcmHeader.TRAMP);
% fprintf(unit, ' HZPPPM=%14.5E\n', proc.lcmHeader.HZPPPM);       % added, no core parameter
% fprintf(unit, ' DELTAT=%14.5E\n', proc.lcmHeader.DELTAT);       % added, no core parameter
fprintf(unit, ' $END\n');

nrows = fix( length(data2write) / NCOLS );      % wieso abrunden???
for irow=1:nrows
    fprintf(unit, ' %+12.5E', data2write( ((irow-1)*NCOLS+1):irow*NCOLS));
    fprintf(unit, '\n');
end
fclose(unit);

%--- consistency check ---
ndatalost = mod(length(data2write), NCOLS);
if ndatalost ~= 0
   fprint('%s -> %d data points lost!',FCTNAME,ndatalost);
end

%--- update success flag ---
f_succ = 1;

