%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [coord, f_succ] = SP2_Proc_PlcmReadCoord( coordFile )
%%
%%  Read LCModel COORD files
%%
%%  02-2016, Christoph Juchem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_Proc_PlcmReadCoord';


%--- init data format ---
NUMHLINES   = 4;		% initial header lines
NDATABLOCKS = 4;	    % ppm-axis, phased data, fit, background 
NELTDIAG    = 10;		% minimum number of lines in tdiag


%--- init success flag ---
f_succ = 0;

%--- info printout ---
if flag.verbose
    fprintf('\n\nCOORD file:\n%s\n\n',coordFile);
end

%--- program start ---
coord = initCoord;
unit  = fopen(coordFile,'r');
if unit < 0
    fprintf('%s -> Can''t open <%s>',FCTNAME,coordFile);
    return
end

%--- read header1 ---------------------------
for i=1:NUMHLINES
    coord.header(i,1) = { fgetl(unit) };
    if flag.verbose
        fprintf('%s\n', char(coord.header(i,1)));
    end
end

%--- read header2 (tconc), determine NCONC ----------
line = fgetl(unit);
if flag.verbose
    fprintf('%s\n', line);
end
coord.nconc = strread(strtok(line),'%f') - 1;
for i=1:coord.nconc+1
    coord.tconc(i,1) = { fgetl(unit) };
    if flag.verbose
        fprintf('%s\n', char(coord.tconc(i,1)));
    end
end
for i=2:coord.nconc+1
    % [a,b,c,d,e] = strread( char(coord.tconc(i,1)),'%f%f%c%f%s');
    % dum = temporary dummy string
    [a,dum1] = strtok(char(coord.tconc(i,1)),' ');
    [b,dum2] = strtok(dum1,'%');
    [dum3,dum4] = strtok(dum2,' ');
    [dum5,dum6] = strtok(dum4,' ');
    if ~strcmp(dum5,strrep(dum4,' ',''))
        d = dum5;
        e = strtok(dum6,' ');
    else
        if ~isempty(findstr(dum5,'+'))
            [d,dum7] = strtok(dum5,'+');
            [e,dum8] = strtok(dum7,'+');
        elseif ~isempty(findstr(dum5,'-'))
            [d,dum7] = strtok(dum5,'-');
            [e,dum8] = strtok(dum7,'-');
        else
            fprintf('%s ->\nReading metabolite concentrations failed\n',FCTNAME);
            return
        end
    end
    coord.conc(i-1,1) = str2double(a);
    coord.SD(i-1,1) = str2double(b);
    coord.relconc(i-1,1) = str2double(d);
    coord.metab(i-1,1) = {e};
end
     
%--- read header3 (tmisc) ---------------------------
line = fgetl(unit);
nmisc = strread(strtok(line),'%f');
for i=1:nmisc
    coord.tmisc(i,1) = { fgetl(unit) };
    if flag.verbose
        fprintf('%s\n', char(coord.tmisc(i,1)));
    end
end
 
%--- read data blocks ----------------------
for idata=1:NDATABLOCKS 
    %   --- determine NY (coord.ndata)
    line = fgetl(unit);
    if idata == 1    % --- read NY from line/ init dataarr
        coord.ndata = strread(strtok(line),'%f');
        coord.data = zeros(coord.ndata, NDATABLOCKS);
    end
    [bdata,count] = fscanf(unit, '%f ', coord.ndata);   % !!! ' ' to get rest of line !!!
    if count ~= coord.ndata
        fprintf('%s -> Read format error <%s/%s> read\n',FCTNAME, count, coord.ndata);
        return
    else
        coord.data(:,idata) = bdata(:);
    end
    flagNY = 0;
    while ~flagNY    % read rest of line after last float
        unitpos = ftell(unit);
        line = fgetl(unit);
        NYstr = strtok(line);
        if strcmp(NYstr,'NY') || findstr(line,'Conc') || findstr(line,'line')
            flagNY = 1;
            fseek(unit,unitpos,'bof');
        end
    end    
end   % idata
    
%--- read mdata blocks ----------------------
line = fgetl(unit);
if flag.verbose
    fprintf('%s\n', line);
end
coord.mdata = zeros(coord.ndata, coord.nconc);
while isempty( findstr(line,'diagnostic') )
    curMetabolite = strtok(line);
    [bdata,count] = fscanf(unit, '%f ', coord.ndata);   % !!! ' ' to get rest of line !!!
    if count ~= coord.ndata
        fprintf('%s -> Read format error <%s/%s> read\n',FCTNAME,count,coord.ndata);
        return
    else
        midx = 0;
        for i=1:length(coord.metab)
            if strcmp(char(coord.metab(i)), curMetabolite)
                midx = i;
            end
        end
        if midx > 0
            coord.mdata(:,midx) = bdata(:);
        else
            fprintf('%s -> metabolite assignment index not found <%s> read\n',FCTNAME,curMetabolite);
            return
        end
    end
        
    line = fgetl(unit);
    if flag.verbose
        fprintf('%s\n', line);
    end
end

%--- calculate fit sums (e.g. NAA+NAAG, Glu+Gln), since they do not exist in the COORD file
for icnt = 1:coord.nconc
    if ~isempty(findstr(char(coord.metab(icnt)),'+'))       % '+' found in name
        [first,second] = strtok(char(coord.metab(icnt)),'+');    % separate metabolites
        second = second(2:end);                                   % get rid of the '+'
        for jcnt = 1:coord.nconc                
            if strcmp(char(coord.metab(jcnt)),first) || strcmp(char(coord.metab(jcnt)),second)
                coord.mdata(:,icnt) = coord.mdata(:,icnt) + coord.mdata(:,jcnt);
            end
        end
        coord.mdata(:,icnt) = coord.mdata(:,icnt) - coord.data(:,4);   % correct for 2x the base
    end
end
        
%--- read header4 (tdiag) ---------------------------
ndiag = strread(strtok(line),'%f');
ndiag = max([ndiag 1]);    % read at least 1 line 
for i=1:ndiag
    coord.tdiag(i,1) = { fgetl(unit) };
    if flag.verbose
        fprintf('%s\n', char(coord.tdiag(i,1)));
    end
end

%--- read header5 (tinput) ---------------------------
line = fgetl(unit);
if flag.verbose
    fprintf('%s\n', line);
end
ninput = strread(strtok(line),'%f');
for i=1:ninput
    coord.tinput(i,1) = { fgetl(unit) };
    if strfind(coord.tinput{i,1},'DELTAT')
        [fake,b]     = strtok(coord.tinput{i,1},'=');
        coord.deltat = str2double(strtok(b,'='));
    end
    if strfind(coord.tinput{i,1},'HZPPPM')
        [fake,b]     = strtok(coord.tinput{i,1},'=');
        coord.hzpppm = str2double(strtok(b,'='));
    end
    if strfind(coord.tinput{i,1},'PPMST')
        [fake,b]    = strtok(coord.tinput{i,1},'=');
        coord.ppmst = str2double(strtok(b,'='));
    end
    if strfind(coord.tinput{i,1},'PPMEND')
        [fake,b]     = strtok(coord.tinput{i,1},'=');
        coord.ppmend = str2double(strtok(b,'='));
    end
    if flag.verbose
        fprintf('%s\n',char(coord.tinput(i,1)));
    end
end
fclose(unit);

%--- update success flag ---
f_succ = 1;



%--------------------------------------------------------------------------
%---    L O C A L    F U N C T I O N                                    ---
%--------------------------------------------------------------------------
function coord = initCoord
%
%  init coord struct
%

	coord.metab   = {''};
	coord.conc    = 0;
 	coord.relconc = 0;
	coord.SD      = 0;
	coord.ndata   = 0;
	coord.data    = 0;
	coord.mdata   = 0;
	coord.header  = {''};
	coord.nconc   = 0;
	coord.tconc   = {''};
	coord.tmisc   = {''};
	coord.tdiag   = {''};
	coord.tinput  = {''};
    coord.ppmst   = 0;
    coord.ppmend  = 0;
    coord.hzppm   = 0;
    coord.deltat  = 0;
    
