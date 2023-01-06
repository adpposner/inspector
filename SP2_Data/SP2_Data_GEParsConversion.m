%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_GEParsConversion(header,nData)
%% 
%%  Conversion of GE header parameters to method structure to be used 
%%  in this software.
%%  Note the nomenclature for nr, nt and nv:
%%  nr refers to the number of acquisitions. For regular, scanner-summed
%%  acquisitions it therefore equals nt. For phase-cycled acquisitions it
%%  equals nv, i.e. the number of sequence repetitions. In fact, nr was
%%  introduced to allow above distinction and provide the corresponding
%%  experiment flexibility.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_GEParsConversion';



%--- init success flag ---
f_succ = 0;

%--- parameter transfer to 'method' struct ---
if isfield(header,'sequence')              % image, psd_iname
    eval(['data.spec' num2str(nData) '.sequence = header.sequence;'])
else
    eval(['data.spec' num2str(nData) '.sequence = '''';'])
end

if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'user1')
    eval(['data.spec' num2str(nData) '.nspecC   = header.user1;'])
elseif isfield(header,'nspecC')
    eval(['data.spec' num2str(nData) '.nspecC   = header.nspecC;'])
end
if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'xcsi')
    eval(['data.spec' num2str(nData) '.nx = header.xcsi;'])
else
    eval(['data.spec' num2str(nData) '.nx = 1;'])
end
if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'ycsi')
    eval(['data.spec' num2str(nData) '.ny = header.ycsi;'])
else
    eval(['data.spec' num2str(nData) '.ny = 1;'])
end
if isfield(header,'nSlices')
    eval(['data.spec' num2str(nData) '.ns   = header.nSlices;'])
elseif eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'zcsi')
    eval(['data.spec' num2str(nData) '.ns = header.zcsi;'])
else
    eval(['data.spec' num2str(nData) '.ns   = 1;'])
end
if isfield(header,'nEchoes')
    eval(['data.spec' num2str(nData) '.ne   = header.nEchoes;'])
else
    eval(['data.spec' num2str(nData) '.ne   = 1;'])
end
if isfield(header,'nFrames')            % includes both water and metabs
    eval(['data.spec' num2str(nData) '.nf = header.nFrames;'])    
else
    eval(['data.spec' num2str(nData) '.nf = 1;'])
end
if data.expTypeDisplay==2 || data.expTypeDisplay==3             % 1st&last, 2nd&last JDE
    eval(['data.spec' num2str(nData) '.njde = 2;'])    
elseif data.expTypeDisplay==4                                   % JDE array
    eval(['data.spec' num2str(nData) '.njde = 3;'])
else                                                            % regular MRS
    eval(['data.spec' num2str(nData) '.njde = 1;'])    
end
if isfield(header,'user24')             % image
    eval(['data.spec' num2str(nData) '.savesep = header.user24;'])
end
% if isfield(header,'saveSeparately')        % note the string-to-numeric conversion
%     eval(['data.spec' num2str(nData) '.saveSep = strcmp(header.saveSeparately,''y'');']) 
% else
%     eval(['data.spec' num2str(nData) '.saveSep = 0;'])      % default: off 
% end
% if isfield(header,'nex')          % image
%     eval(['data.spec' num2str(nData) '.nr = header.nex;'])
% else
%     eval(['data.spec' num2str(nData) '.nr = 1;'])
% end
% if isfield(header,'pscopt')           % image
%     eval(['data.spec' num2str(nData) '.nr = header.pscopt;'])

if isfield(header,'nexForUnacquiredEncodes')
    eval(['data.spec' num2str(nData) '.nref = header.nexForUnacquiredEncodes;'])
else
    eval(['data.spec' num2str(nData) '.nref = 0;'])
end

% h.rdb_hdr.user4 -- number of acquisitions
% if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'user4')
%     eval(['data.spec' num2str(nData) '.nr = header.user4;'])
% else
    eval(['data.spec' num2str(nData) '.nr = header.nFrames;'])
% end

% also: rdb_hdr.da_nxres - nspecC
%       rdb_hdr.da_nyres - nr



% h.rdb_hdr.navs --- Number of averages/phase cycling
% if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'navs')
%     eval(['data.spec' num2str(nData) '.na = header.navs;'])
% else
if isfield(header,'nAverages')
    eval(['data.spec' num2str(nData) '.na = header.nAverages;'])
else
    eval(['data.spec' num2str(nData) '.na = 1;'])
end
% %--- genuine GE, MR-SCIENCE, Kay/Leavitt ---
% if isfield(header,'user19')
%     if isfield(eval(['data.spec' num2str(nData)]),'ne')
%         if eval(['data.spec' num2str(nData) '.ne'])>0
%             % for ne>0
%             eval(['data.spec' num2str(nData) '.trOffset = header.user19 * data.spec' num2str(nData) '.ne;'])
%         else
%             eval(['data.spec' num2str(nData) '.trOffset = header.user19;'])
%         end
%     else
%         eval(['data.spec' num2str(nData) '.trOffset = header.user19;'])
%     end
% else
%     eval(['data.spec' num2str(nData) '.trOffset = 1;'])
% end

%--- trOffset ---
% Ann Arbor, University of Michigan
if eval(['data.spec' num2str(nData) '.nr'])>1 && header.user4>1 && ...
   eval(['data.spec' num2str(nData) '.nr'])>header.user4 && strcmp(header.sequDesc,'sLASER CMRR 30')
    % user4: NR, .nr: DS+NR, therefore: DS = .nr - NR 
    % CMRR sLASER, e.g. at Ann Arbor
    eval(['data.spec' num2str(nData) '.trOffset = data.spec' num2str(nData) '.nr - header.user4;'])

% Wei Shen, body
elseif strcmp(header.protocol,'AAAA4898 - BODY COMPOSIT')
    eval(['data.spec' num2str(nData) '.trOffset = 0;'])
    eval(['data.spec' num2str(nData) '.na = 1;'])
%     eval(['data.spec' num2str(nData) '.nr = header.nFrames + header.nAverages;'])
    eval(['data.spec' num2str(nData) '.nr = header.nFrames;'])
    % eval(['data.spec' num2str(nData) '.nRcvrs = 6;'])

%--- genuine GE, MR-SCIENCE, Kay/Leavitt ---
% nAverages includes as water references, for Karl, 03/2019
elseif isfield(header,'user19')
    if isfield(eval(['data.spec' num2str(nData)]),'na')
        if eval(['data.spec' num2str(nData) '.na'])>0 && header.rdbmRev~=14.300 && header.rdbmRev~=15.001      % Camilo, MX
            % for ne>0
            eval(['data.spec' num2str(nData) '.trOffset = header.user19 * data.spec' num2str(nData) '.na;'])
        else
            eval(['data.spec' num2str(nData) '.trOffset = header.user19;'])
        end
    else
        eval(['data.spec' num2str(nData) '.trOffset = header.user19;'])
    end
else
    eval(['data.spec' num2str(nData) '.trOffset = 1;'])
end

%--- Feng Liu: number of metab scans ---
if isfield(header,'user4')
    eval(['data.spec' num2str(nData) '.nr_FL = header.user4;'])
end

% eval(['data.spec' num2str(nData) '.nv       = header.nv;'])
if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'ps_mps_freq')
    eval(['data.spec' num2str(nData) '.sf = header.ps_mps_freq/1e7;'])       % Larmor frequency in MHz
elseif isfield(header,'freq')           % rdb
    eval(['data.spec' num2str(nData) '.sf = header.freq/1e7;'])       % Larmor frequency in MHz
end

if isfield(header,'tof')
    eval(['data.spec' num2str(nData) '.offset   = header.tof;'])               % frequency offset in Hz
else
    eval(['data.spec' num2str(nData) '.offset   = 0;'])               % frequency offset in Hz
end
if eval(['strcmp(data.spec' num2str(nData) '.sequence,''fidcsi'')']) && isfield(header,'spectral_width')
    eval(['data.spec' num2str(nData) '.sw_h  = header.spectral_width;'])    % sweep width in Hz
    eval(['data.spec' num2str(nData) '.dwell = 1/data.spec' num2str(nData) '.sw_h;'])    % sweep width in Hz
    eval(['data.spec' num2str(nData) '.sw    = data.spec' num2str(nData) '.sw_h/data.spec' num2str(nData) '.sf;'])         % sweep width in Hz
elseif isfield(header,'sw')               % rdb
    eval(['data.spec' num2str(nData) '.sw_h  = header.sw;'])    % sweep width in Hz
    eval(['data.spec' num2str(nData) '.dwell = 1/data.spec' num2str(nData) '.sw_h;'])    % sweep width in Hz
    eval(['data.spec' num2str(nData) '.sw    = data.spec' num2str(nData) '.sw_h/data.spec' num2str(nData) '.sf;'])         % sweep width in Hz
else
    eval(['data.spec' num2str(nData) '.sw_h  = 0;'])
    eval(['data.spec' num2str(nData) '.sw    = 0;'])
    eval(['data.spec' num2str(nData) '.dwell = 0;'])
end
if isfield(header,'protocol')
    eval(['data.spec' num2str(nData) '.pp = header.protocol;'])
else
    eval(['data.spec' num2str(nData) '.pp = '''';'])
end
if isfield(header,'numberBytes')                                        % number of bytes
    eval(['data.spec' num2str(nData) '.numberBytes = header.numberBytes;'])
    if header.numberBytes==4                                            % 4 bytes
        eval(['data.spec' num2str(nData) '.wordSize = ''int32'';'])
    else                                                                % 2 bytes
        eval(['data.spec' num2str(nData) '.wordSize = ''int16'';'])
    end
else
    eval(['data.spec' num2str(nData) '.numberBytes = 0;'])
    eval(['data.spec' num2str(nData) '.wordSize    = '''';'])
end
if isfield(header,'endian')                                             % data format
    if header.numberBytes==4                                            % 4 bytes
        eval(['data.spec' num2str(nData) '.byteOrder = header.endian;'])
    else                                                                % 2 bytes
        eval(['data.spec' num2str(nData) '.byteOrder = '''';'])
    end
end
if isfield(header,'tr')             % image
    eval(['data.spec' num2str(nData) '.tr = header.tr/1000;'])        % orig: [us]
else
    eval(['data.spec' num2str(nData) '.tr = 0;'])
end
if isfield(header,'te')             % image
    eval(['data.spec' num2str(nData) '.te = header.te/1000;'])        % orig: [us]
else
    eval(['data.spec' num2str(nData) '.te = 0;'])
end
if isfield(header,'tm')             % image
    eval(['data.spec' num2str(nData) '.tm = header.tm/1000;'])        % orig: [us]
else
    eval(['data.spec' num2str(nData) '.tm = 0;'])
end
if isfield(header,'posX')        % rdb, roilocx
    % note the x/y swap
    eval(['data.spec' num2str(nData) '.pos(1) = header.posY;'])
else
    eval(['data.spec' num2str(nData) '.pos(1) = 0;'])
end
if isfield(header,'posY')        % rdb, roilocy
    % note the x/y swap and the reversed polarity
    eval(['data.spec' num2str(nData) '.pos(2) = -header.posX;'])
else
    eval(['data.spec' num2str(nData) '.pos(2) = 0;'])
end
if isfield(header,'posZ')        % rdb, roilocz
    eval(['data.spec' num2str(nData) '.pos(3) = header.posZ;'])
else
    eval(['data.spec' num2str(nData) '.pos(3) = 0;'])
end
if isfield(header,'fovX')        % rdb, roilenx
    eval(['data.spec' num2str(nData) '.vox(1) = header.fovX;'])
else
    eval(['data.spec' num2str(nData) '.vox(1) = 0;'])
end
if isfield(header,'fovY')        % rdb, roileny
    eval(['data.spec' num2str(nData) '.vox(2) = header.fovY;'])
else
    eval(['data.spec' num2str(nData) '.vox(2) = 0;'])
end
if isfield(header,'fovZ')        % rdb, roilenz
    eval(['data.spec' num2str(nData) '.vox(3) = header.fovZ;'])
else
    eval(['data.spec' num2str(nData) '.vox(3) = 0;'])
end


if isfield(header,'gcoil')
    eval(['data.spec' num2str(nData) '.gradSys = header.gcoil;'])
else
    eval(['data.spec' num2str(nData) '.gradSys = '''';'])
end
if isfield(header,'gain')
    eval(['data.spec' num2str(nData) '.gain    = header.gain;'])
else
    eval(['data.spec' num2str(nData) '.gain    = 0;'])
end

%--- RF 1 ---
if isfield(header,'pwpat')
    eval(['data.spec' num2str(nData) '.rf1.shape   = header.pwpat;'])
else
    eval(['data.spec' num2str(nData) '.rf1.shape   = '''';'])
end
if isfield(header,'pw')
    eval(['data.spec' num2str(nData) '.rf1.dur     = header.pw/1000;'])
else
    eval(['data.spec' num2str(nData) '.rf1.dur     = 0;'])
end
if any(strfind(data.spec1.sequence,'spuls'))    % spulse
    eval(['data.spec' num2str(nData) '.rf1.power   = header.CoarsePwr;'])
    % additional info printout
    fprintf('spuls powers: CoarsePwr=%.0f dB, FinePwr=%.0f\n',header.CoarsePwr,...
            header.FinePwr)
else
    eval(['data.spec' num2str(nData) '.rf1.power   = 0;'])
end
if isfield(header,'csdOffset')
    eval(['data.spec' num2str(nData) '.rf1.offset  = header.csdOffset;'])
else
    eval(['data.spec' num2str(nData) '.rf1.offset  = 0;'])
end
eval(['data.spec' num2str(nData) '.rf1.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf1.applied = ''y'';'])

%--- RF 2 ---
if isfield(header,'p1pat')
    eval(['data.spec' num2str(nData) '.rf2.shape   = header.p1pat;'])
else
    eval(['data.spec' num2str(nData) '.rf2.shape   = '''';'])
end
if isfield(header,'p1')
    eval(['data.spec' num2str(nData) '.rf2.dur     = header.p1/1000;'])
else
    eval(['data.spec' num2str(nData) '.rf2.dur     = 0;'])
end
if any(strfind(data.spec1.sequence,'STEAM'))    % STEAM
    eval(['data.spec' num2str(nData) '.rf2.power   = header.tpwr;'])
else                                            % all other sequences
    if isfield(header,'tpwr1')
        eval(['data.spec' num2str(nData) '.rf2.power   = header.tpwr1;'])
    else
        eval(['data.spec' num2str(nData) '.rf2.power   = 0;'])
    end
end
if isfield(header,'csdOffset')
    eval(['data.spec' num2str(nData) '.rf2.offset  = header.csdOffset;'])      % parameter?
else
    eval(['data.spec' num2str(nData) '.rf2.offset  = 0;'])      % parameter?
end
eval(['data.spec' num2str(nData) '.rf2.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf2.applied = ''y'';'])

%--- water suppression ---
if isfield(header,'WSpat')
    eval(['data.spec' num2str(nData) '.ws.shape = header.WSpat;'])
else
    eval(['data.spec' num2str(nData) '.ws.shape = '''';'])
end
if isfield(header,'pWS')
    eval(['data.spec' num2str(nData) '.ws.dur   = header.pWS/1000;'])
else
    eval(['data.spec' num2str(nData) '.ws.dur   = 0;'])
end
if isfield(header,'tpwrWS')
    eval(['data.spec' num2str(nData) '.ws.power    = header.tpwrWS;'])
else
    eval(['data.spec' num2str(nData) '.ws.power    = 0;'])
end
if isfield(header,'WSOffset')
    eval(['data.spec' num2str(nData) '.ws.offset   = header.WSOffset;'])
else
    eval(['data.spec' num2str(nData) '.ws.offset   = 0;'])
end
if isfield(header,'WSModule')
    eval(['data.spec' num2str(nData) '.ws.method   = header.WSModule;'])
end
if isfield(header,'WS')
    eval(['data.spec' num2str(nData) '.ws.applied  = header.WS;'])
end

%--- JDE ---
if isfield(header,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.shape = header.jdepat;'])
else
    eval(['data.spec' num2str(nData) '.jde.shape = '''';'])
end
if isfield(header,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.dur   = header.pjde/1000;'])
else
    eval(['data.spec' num2str(nData) '.jde.dur   = 0;'])
end
if isfield(header,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.power = header.tpwrjde;'])
else
    eval(['data.spec' num2str(nData) '.jde.power = 0;'])
end
if isfield(header,'offsetjde')
    eval(['data.spec' num2str(nData) '.jde.offset = header.offsetjde;'])
    
    %--- multi-metabolite JDE ---
    if nData==1
        if data.spec1.njde==2           % single JDE experiment
            if eval(['iscell(data.spec' num2str(nData) '.jde.offset)'])
                data.spec1.jde.offset1 = data.spec1.jde.offset{1};
                data.spec1.jde.offset2 = data.spec1.jde.offset{2};
            else
                data.spec1.jde.offset1 = data.spec1.jde.offset;
                data.spec1.jde.offset2 = data.spec1.jde.offset;
            end
        else                            % combined / multi-molecule JDE
            if flag.dataEditNo==1       % [1 3]
                data.spec1.jde.offset1 = data.spec1.jde.offset{1};
                data.spec1.jde.offset2 = data.spec1.jde.offset{3};
            else                        % [2 3[
                data.spec1.jde.offset1 = data.spec1.jde.offset{2};
                data.spec1.jde.offset2 = data.spec1.jde.offset{3};
            end
        end
    end
else
    eval(['data.spec' num2str(nData) '.jde.offset = 0;'])
end
eval(['data.spec' num2str(nData) '.jde.method = '''';'])
if isfield(header,'JDE')
    eval(['data.spec' num2str(nData) '.jde.applied = header.JDE;'])
else
    eval(['data.spec' num2str(nData) '.jde.applied = '''';'])
end
eval(['data.spec' num2str(nData) '.t2Series = 0;'])         % global loggingfile init (potential later update)
if eval(['strcmp(data.spec' num2str(nData) '.jde.applied,''y'');'])
    if isfield(header,'t2TeExtra')
        if iscell(header.t2TeExtra)
            eval(['data.spec' num2str(nData) '.t2TeExtra = cell2mat(header.t2TeExtra)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtra = header.t2TeExtra*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtra = 0;'])
    end
    eval(['data.spec' num2str(nData) '.t2TeN = length(data.spec' num2str(nData) '.t2TeExtra);'])
    if eval(['data.spec' num2str(nData) '.t2TeN>1;'])       % update T2 series flag
        eval(['data.spec' num2str(nData) '.t2Series = 1;'])
    end
    if isfield(header,'t2TeExtraBal')
        if iscell(header.t2TeExtraBal)
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = cell2mat(header.t2TeExtraBal)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = header.t2TeExtraBal*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtraBal = 0;'])
    end
    if isfield(header,'t2DS')
        if iscell(header.t2DS)
            eval(['data.spec' num2str(nData) '.t2DS = cell2mat(header.t2DS);'])
        else
            eval(['data.spec' num2str(nData) '.t2DS = header.t2DS;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2DS = 0;'])
    end
    if isfield(header,'T2offset')
        if iscell(header.T2offset)
            eval(['data.spec' num2str(nData) '.T2offset = cell2mat(header.T2offset);'])
        else
            eval(['data.spec' num2str(nData) '.T2offset = header.T2offset;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offset = 0;'])
    end
    if isfield(header,'T2offsetVal')
        if iscell(header.T2offsetVal)
            eval(['data.spec' num2str(nData) '.T2offsetVal = cell2mat(header.T2offsetVal);'])
        else
            eval(['data.spec' num2str(nData) '.T2offsetVal = header.T2offsetVal;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offsetVal = 0;'])
    end
    if isfield(header,'applT2offset')
        eval(['data.spec' num2str(nData) '.applT2offset = header.applT2offset;'])
    else
        eval(['data.spec' num2str(nData) '.applT2offset = 0;'])
    end
end

%--- inversion ---
if isfield(header,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.shape = header.p2pat;'])
else
    eval(['data.spec' num2str(nData) '.inv.shape = '''';'])
end
if isfield(header,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.dur   = header.p2/1000;'])
else
    eval(['data.spec' num2str(nData) '.inv.dur   = 0;'])
end
if isfield(header,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.power = header.tpwr2;'])
else
    eval(['data.spec' num2str(nData) '.inv.power = 0;'])
end
if isfield(header,'TIoffset')
    eval(['data.spec' num2str(nData) '.inv.offset = header.TIoffset;'])
else
    eval(['data.spec' num2str(nData) '.inv.offset = 0;'])
end
if isfield(header,'ti')             % image
    eval(['data.spec' num2str(nData) '.inv.ti = header.ti/1000;'])
else
    eval(['data.spec' num2str(nData) '.inv.ti = 0;'])
end
eval(['data.spec' num2str(nData) '.inv.method = '''';'])
if isfield(header,'Inversion')
    eval(['data.spec' num2str(nData) '.inv.applied = header.Inversion;'])
else
    eval(['data.spec' num2str(nData) '.inv.applied = '''';'])
end

%--- OVS ---
if isfield(header,'OVS')
    eval(['data.spec' num2str(nData) '.ovs.applied = header.OVS;'])
else
    eval(['data.spec' num2str(nData) '.ovs.applied = '''';'])
end
if isfield(header,'OVSmode')
    eval(['data.spec' num2str(nData) '.ovs.mode = header.OVSmode;'])
else
    eval(['data.spec' num2str(nData) '.ovs.mode = '''';'])
end
if isfield(header,'OVSInterl')
    eval(['data.spec' num2str(nData) '.ovs.interleaved = header.OVSInterl;'])
else
    eval(['data.spec' num2str(nData) '.ovs.interleaved = '''';'])
end
if isfield(header,'ovspat1')
    eval(['data.spec' num2str(nData) '.ovs.shape = header.ovspat1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.shape = '''';'])
end
if isfield(header,'ovsthk')
    eval(['data.spec' num2str(nData) '.ovs.thk = header.ovsthk;'])
else
    eval(['data.spec' num2str(nData) '.ovs.thk = '''';'])
end
if isfield(header,'ovssep')
    eval(['data.spec' num2str(nData) '.ovs.separation = header.ovssep;'])
else
    eval(['data.spec' num2str(nData) '.ovs.separation = '''';'])
end
if isfield(header,'ovsGlobOffset')
    eval(['data.spec' num2str(nData) '.ovs.offset = header.ovsGlobOffset;'])
else
    eval(['data.spec' num2str(nData) '.ovs.offset = '''';'])
end
if isfield(header,'novs')
    eval(['data.spec' num2str(nData) '.ovs.n = header.novs;'])
else
    eval(['data.spec' num2str(nData) '.ovs.n = '''';'])
end
if isfield(header,'povs1')
    eval(['data.spec' num2str(nData) '.ovs.dur = header.povs1/1000;'])
else
    eval(['data.spec' num2str(nData) '.ovs.dur = '''';'])
end
if isfield(header,'tpwrovs1')
    eval(['data.spec' num2str(nData) '.ovs.power = header.tpwrovs1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
if isfield(header,'tpwrovsVar1') && isfield(header,'tpwrovsVar2') && ...
   isfield(header,'tpwrovsVar3') && isfield(header,'tpwrovsVar4')
    eval(['data.spec' num2str(nData) '.ovs.variation(1) = header.tpwrovsVar1;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(2) = header.tpwrovsVar2;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(3) = header.tpwrovsVar3;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(4) = header.tpwrovsVar4;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
% if isfield(header,'mrsiAver')
%     eval(['data.spec' num2str(nData) '.mrsi.aver = header.mrsiAver;'])
% end
% if isfield(header,'nvMrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.nEnc = header.nvMrsi;'])
% end
% if isfield(header,'nvR')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncR = header.nvR;'])
% end
% if isfield(header,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncP = header.nvP;'])
% end
% if isfield(header,'nvS')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncS = header.nvS;'])
% end
% if isfield(header,'nvR') && isfield(header,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.mat = [header.nvR header.nvP];'])
% end
% if isfield(header,'lro_mrsi') && isfield(header,'lpe_mrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.fov = 10*[header.lro_mrsi header.lpe_mrsi];'])
% end
% if isfield(header,'mrsiDurSec')
%     eval(['data.spec' num2str(nData) '.mrsi.durSec = header.mrsiDurSec;'])
% end
% if isfield(header,'mrsiDurMin')
%     eval(['data.spec' num2str(nData) '.mrsi.durMin = header.mrsiDurMin;'])
% end
% if isfield(header,'TMrsiEnc')
%     eval(['data.spec' num2str(nData) '.mrsi.tEnc = header.TMrsiEnc;'])
% end
% if isfield(header,'mrsiEncR')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileR = header.mrsiEncR;'])
% end
% if isfield(header,'mrsiEncP')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileP = header.mrsiEncP;'])
% end
% if isfield(header,'mrsiEncS')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileS = header.mrsiEncS;'])
% end
% if isfield(header,'mrsiTableR')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableR = header.mrsiTableR;'])
% end
% if isfield(header,'mrsiTableP')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableP = header.mrsiTableP;'])
% end
% if isfield(header,'mrsiTableS')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableS = header.mrsiTableS;'])
% end
eval(['data.spec' num2str(nData) '.z0      = 0;'])
eval(['data.spec' num2str(nData) '.yz      = 0;'])
eval(['data.spec' num2str(nData) '.xy      = 0;'])
eval(['data.spec' num2str(nData) '.x2y2    = 0;'])
if isfield(header,'xshim')
    eval(['data.spec' num2str(nData) '.x1  = header.xshim;'])
else
    eval(['data.spec' num2str(nData) '.x1  = 0;'])
end
eval(['data.spec' num2str(nData) '.x3      = 0;'])
if isfield(header,'yshim')
    eval(['data.spec' num2str(nData) '.y1  = header.yshim;'])
else
    eval(['data.spec' num2str(nData) '.y1  = 0;'])
end
eval(['data.spec' num2str(nData) '.xz      = 0;'])
eval(['data.spec' num2str(nData) '.xz2     = 0;'])
eval(['data.spec' num2str(nData) '.y3      = 0;'])
if isfield(header,'zshim')
    eval(['data.spec' num2str(nData) '.z1c = header.zshim;'])
else
    eval(['data.spec' num2str(nData) '.z1c = 0;'])
end
eval(['data.spec' num2str(nData) '.yz2     = 0;'])
eval(['data.spec' num2str(nData) '.z2c     = 0;'])
eval(['data.spec' num2str(nData) '.z5      = 0;'])
eval(['data.spec' num2str(nData) '.z3c     = 0;'])
eval(['data.spec' num2str(nData) '.z4c     = 0;'])
eval(['data.spec' num2str(nData) '.zx2y2   = 0;'])
eval(['data.spec' num2str(nData) '.zxy     = 0;'])
% if isfield(header,'Gslice1')
%     eval(['data.spec' num2str(nData) '.Gslice1 = header.Gslice1;'])
% end
% if isfield(header,'Gslice1ref')
%     eval(['data.spec' num2str(nData) '.Gslice1ref = header.Gslice1ref;'])
% end
% if isfield(header,'Gslice2')
%     eval(['data.spec' num2str(nData) '.Gslice2 = header.Gslice2;'])
% end
% if isfield(header,'Gslice3')
%     eval(['data.spec' num2str(nData) '.Gslice3 = header.Gslice3;'])
% end
% if isfield(header,'TxFreqExc')
%     eval(['data.spec' num2str(nData) '.txFreqExc = header.TxFreqExc;'])
% end
% if isfield(header,'TxFreqRef1')
%     eval(['data.spec' num2str(nData) '.txFreqRef1 = header.TxFreqRef1;'])
% end
% if isfield(header,'TxFreqRef2')
%     eval(['data.spec' num2str(nData) '.txFreqRef2 = header.TxFreqRef2;'])
% end

if isfield(header,'dab')
    eval(['data.spec' num2str(nData) '.nRcvrs = (header.dab(2)-header.dab(1))+1;'])
else
    eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
end
if isfield(header,'scanDate') && isfield(header,'scanTime')          % -> date vector
    eval(['data.spec' num2str(nData) '.time_start = datevec([' header.scanDate ' ' header.scanTime ']);'])
end
if isfield(header,'scanDur')            % image
    eval(['data.spec' num2str(nData) '.durSec = header.scanDur/1e6;'])
    eval(['data.spec' num2str(nData) '.durMin = header.scanDur/6e8;'])
else
    eval(['data.spec' num2str(nData) '.durSec = 0;'])
    eval(['data.spec' num2str(nData) '.durMin = 0;'])
end
% if isfield(header,'time_complete')     % ISO 8601 -> date vector
%     eval(['data.spec' num2str(nData) '.time_end = datevec(header.time_complete,''yyyymmddTHHMMSS'');'])
% end

if isfield(header,'headerN')
    eval(['data.spec' num2str(nData) '.headerN = header.headerN;'])
else
    eval(['data.spec' num2str(nData) '.headerN = 0;'])
end
if isfield(header,'headerSizeTot')
    eval(['data.spec' num2str(nData) '.headerSizeTot = header.headerSizeTot;'])
else
    eval(['data.spec' num2str(nData) '.headerSizeTot = 0;'])
end
if isfield(header,'rdbmRev')
    eval(['data.spec' num2str(nData) '.rdbmRev = header.rdbmRev;'])
else
    eval(['data.spec' num2str(nData) '.rdbmRev = 0;'])
end
if isfield(header,'pFormat')
    eval(['data.spec' num2str(nData) '.pFormat = header.pFormat;'])
else
    eval(['data.spec' num2str(nData) '.pFormat = 0;'])
end

%--- update success flag ---
f_succ = 1;


end
