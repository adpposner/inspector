function [] = convertExptDatToRaw(file,exptDat)

%function written to convert exptDat to .raw for LCModel

proc.lcmHeader.VOLUME    = 1.0;
proc.lcmHeader.TRAMP     = 1.0;
proc.lcmHeader.COMM      = {sprintf('Created: %s',date)};	    % cell array of comments
proc.lcmHeader.ID        = file;
unit = fopen(file,'w');

%--- data formating ---
data2write = zeros(2,exptDat.nspecC);
fidData = exptDat.fid;
fidData = reshape(fidData,1,exptDat.nspecC);
data2write(1,:) = real(fidData);
data2write(2,:) = imag(fidData);
data2write = reshape(data2write,2*exptDat.nspecC,1);

%--- key strings ---       
FMTDAT  = '(8E13.5)';		% to define FORTRAN format for RAW data: '(8E13.5)'
NCOLS   = 8;

for i=1:length(proc.lcmHeader.COMM)
    fprintf(unit, ' %s\n', proc.lcmHeader.COMM{i});
end
fprintf(unit, ' $NMID\n');
str_id = deblank(upper(proc.lcmHeader.ID));
fprintf(unit, ' ID=''%s''\n', str_id(1:min(16,end)));
fprintf(unit, ' FMTDAT=''%s''\n', FMTDAT);
fprintf(unit, ' VOLUME=%14.5E\n', proc.lcmHeader.VOLUME);
fprintf(unit, ' TRAMP=%14.5E\n', proc.lcmHeader.TRAMP);
fprintf(unit, ' $END\n');

nrows = fix( length(data2write) / NCOLS );      % wieso abrunden???
for irow=1:nrows
    fprintf(unit, ' %+12.5E', data2write( ((irow-1)*NCOLS+1):irow*NCOLS));
    fprintf(unit, '\n');
end
fclose(unit);



end
