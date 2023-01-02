%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_SiemensRdaParsConversion(procpar,nData)
%% 
%%  Conversion of GE procpar parameters to method structure to be used 
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

FCTNAME = 'SP2_Data_SiemensRdaParsConversion';


%--- init success flag ---
f_done = 0;

%--- parameter transfer to 'method' struct ---
if isfield(procpar,'SequenceName')
    eval(['data.spec' num2str(nData) '.sequence = procpar.SequenceName;'])
else
    eval(['data.spec' num2str(nData) '.sequence = '''';'])
end
% if any(strfind(data.spec1.sequence,'JDE'))    % STEAM
%     if isfield(procpar,'seqtype')
%         if strcmp(procpar.seqtype,'2x180')
%             eval(['data.spec' num2str(nData) '.seqtype = ''PRESS'';'])
%         elseif strcmp(procpar.seqtype,'4x180')
%             eval(['data.spec' num2str(nData) '.seqtype = ''sLASER'';'])
%         else        % unknown
%             eval(['data.spec' num2str(nData) '.seqtype = '''';'])
%         end
%     end
% end
if isfield(procpar,'VectorSize')
    eval(['data.spec' num2str(nData) '.nspecC   = procpar.VectorSize;'])
else
    eval(['data.spec' num2str(nData) '.nspecC   = 0;'])
end
if isfield(procpar,'CSIMatrixSize')
    eval(['data.spec' num2str(nData) '.nx       = procpar.CSIMatrixSize(1);'])
    eval(['data.spec' num2str(nData) '.ny       = procpar.CSIMatrixSize(2);'])
    eval(['data.spec' num2str(nData) '.nz       = procpar.CSIMatrixSize(3);'])
else
    eval(['data.spec' num2str(nData) '.nx       = 1;'])
    eval(['data.spec' num2str(nData) '.ny       = 1;'])
    eval(['data.spec' num2str(nData) '.nz       = 1;'])
end

if isfield(procpar,'SoftwareVersions')
    eval(['data.spec' num2str(nData) '.software = procpar.SoftwareVersions;'])
else
    eval(['data.spec' num2str(nData) '.software = '''';'])
end

% if isfield(procpar,'nslices')
%     eval(['data.spec' num2str(nData) '.ns   = procpar.nslices;'])
% else
%     eval(['data.spec' num2str(nData) '.ns   = 1;'])
% end
% if isfield(procpar,'nframes')
%     eval(['data.spec' num2str(nData) '.nf = procpar.nframes;'])    
% else
%     eval(['data.spec' num2str(nData) '.nf = 1;'])
% end
if isfield(procpar,'EchoNumber')
    eval(['data.spec' num2str(nData) '.njde = procpar.EchoNumber;'])    
end
% if isfield(procpar,'saveSeparately')        % note the string-to-numeric conversion
%     eval(['data.spec' num2str(nData) '.saveSep = strcmp(procpar.saveSeparately,''y'');']) 
% else
%     eval(['data.spec' num2str(nData) '.saveSep = 0;'])      % default: off 
% end
if isfield(procpar,'NR')
    eval(['data.spec' num2str(nData) '.nr = procpar.NR;'])
else
    eval(['data.spec' num2str(nData) '.nr = 1;'])
end
% if isfield(procpar,'pscopt')
%     eval(['data.spec' num2str(nData) '.nr = procparopt;'])

% if isfield(procpar,'nexForUnacquiredEncodes')
%     eval(['data.spec' num2str(nData) '.nref = procpar.nexForUnacquiredEncodes;'])
% else
%     eval(['data.spec' num2str(nData) '.nref = 0;'])
% end
if isfield(procpar,'NumberOfAverages')
    eval(['data.spec' num2str(nData) '.na = procpar.NumberOfAverages;'])
else
    eval(['data.spec' num2str(nData) '.na = 1;'])
end

% if isfield(procpar,'navs')
%     eval(['data.spec' num2str(nData) '.na = procpar.navs;'])
% else
%     eval(['data.spec' num2str(nData) '.na = 1;'])
% end
% eval(['data.spec' num2str(nData) '.nv       = procpar.nv;'])

if isfield(procpar,'MRFrequency')
    eval(['data.spec' num2str(nData) '.sf = procpar.MRFrequency;'])                     % Larmor frequency in MHz
end

if isfield(procpar,'tof')
    eval(['data.spec' num2str(nData) '.offset   = procpar.tof;'])                       % frequency offset in Hz
else
    eval(['data.spec' num2str(nData) '.offset   = 0;'])                                 % frequency offset in Hz
end
if isfield(procpar,'DwellTime')                                                         % 
    eval(['data.spec' num2str(nData) '.dwell = procpar.DwellTime*1e-6;'])               % orig: [us]
    eval(['data.spec' num2str(nData) '.sw_h  = 1/data.spec' num2str(nData) '.dwell;'])  % sweep width in Hz
    eval(['data.spec' num2str(nData) '.sw    = data.spec' num2str(nData) '.sw_h/data.spec' num2str(nData) '.sf;'])         % sweep width in Hz
else
    eval(['data.spec' num2str(nData) '.sw_h  = 0;'])
    eval(['data.spec' num2str(nData) '.sw    = 0;'])
    eval(['data.spec' num2str(nData) '.dwell = 0;'])
end
% if isfield(procpar.series,'prtcl')
%     eval(['data.spec' num2str(nData) '.pp = procpar.series.prtcl;'])
% else
%     eval(['data.spec' num2str(nData) '.pp = '''';'])
% end
if isfield(procpar,'point_size')                                 % number of bytes
    if procpar.point_size==4                                     % 4 bytes
        eval(['data.spec' num2str(nData) '.wordSize = ''32bit'';'])
    else                                                                % 2 bytes
        eval(['data.spec' num2str(nData) '.wordSize = ''16bit'';'])
    end
else
    eval(['data.spec' num2str(nData) '.wordSize = '''';'])
end
if isfield(procpar,'endian')                                             % data format
    if procpar.point_size==4                                     % 4 bytes
        eval(['data.spec' num2str(nData) '.byteOrder = procpar.endian;'])
    else                                                                % 2 bytes
        eval(['data.spec' num2str(nData) '.byteOrder = '''';'])
    end
end
if isfield(procpar,'TR')
    eval(['data.spec' num2str(nData) '.tr = procpar.TR;'])                  % orig: [ms]
else
    eval(['data.spec' num2str(nData) '.tr = 0;'])
end
if isfield(procpar,'TE')
    eval(['data.spec' num2str(nData) '.te = procpar.TE;'])                  % orig: [ms]
else
    eval(['data.spec' num2str(nData) '.te = 0;'])
end
if isfield(procpar,'TM')
    eval(['data.spec' num2str(nData) '.tm = procpar.TM;'])                  % orig: [ms]
else
    eval(['data.spec' num2str(nData) '.tm = 0;'])
end
if isfield(procpar,'PositionVector')
    eval(['data.spec' num2str(nData) '.pos(1) = procpar.PositionVector(1);'])
    eval(['data.spec' num2str(nData) '.pos(2) = procpar.PositionVector(2);'])
    eval(['data.spec' num2str(nData) '.pos(3) = procpar.PositionVector(3);'])
else
    eval(['data.spec' num2str(nData) '.pos(1) = 0;'])
    eval(['data.spec' num2str(nData) '.pos(2) = 0;'])
    eval(['data.spec' num2str(nData) '.pos(3) = 0;'])
end
if isfield(procpar,'FoVHeight')
    eval(['data.spec' num2str(nData) '.vox(1) = procpar.FoVHeight;'])
else
    eval(['data.spec' num2str(nData) '.vox(1) = 0;'])
end
if isfield(procpar,'FoVWidth')
    eval(['data.spec' num2str(nData) '.vox(2) = procpar.FoVWidth;'])
else
    eval(['data.spec' num2str(nData) '.vox(2) = 0;'])
end
if isfield(procpar,'FoV3D')
    eval(['data.spec' num2str(nData) '.vox(3) = procpar.FoV3D;'])
else
    eval(['data.spec' num2str(nData) '.vox(3) = 0;'])
end
if isfield(procpar,'DeviceSerialNumber')
    eval(['data.spec' num2str(nData) '.devSerial = procpar.DeviceSerialNumber;'])
else
    eval(['data.spec' num2str(nData) '.devSerial = 0;'])
end
if isfield(procpar,'ModelName')
    eval(['data.spec' num2str(nData) '.gcoil = procpar.ModelName;'])
else
    eval(['data.spec' num2str(nData) '.gcoil = 0;'])
end

% if isfield(procpar,'gcoil')
%     eval(['data.spec' num2str(nData) '.gradSys = procpar.gcoil;'])
% else
%     eval(['data.spec' num2str(nData) '.gradSys = '''';'])
% end
if isfield(procpar,'gain')
    eval(['data.spec' num2str(nData) '.gain    = procpar.gain;'])
else
    eval(['data.spec' num2str(nData) '.gain    = 0;'])
end

%--- RF 1 ---
if isfield(procpar,'pwpat')
    eval(['data.spec' num2str(nData) '.rf1.shape   = procpar.pwpat;'])
else
    eval(['data.spec' num2str(nData) '.rf1.shape   = '''';'])
end
if isfield(procpar,'pw')
    eval(['data.spec' num2str(nData) '.rf1.dur     = procpar.pw/1000;'])
else
    eval(['data.spec' num2str(nData) '.rf1.dur     = 0;'])
end
if any(strfind(data.spec1.sequence,'spuls'))    % spulse
    eval(['data.spec' num2str(nData) '.rf1.power   = procpar.CoarsePwr;'])
    % additional info printout
    fprintf('spuls powers: CoarsePwr=%.0f dB, FinePwr=%.0f\n',procpar.CoarsePwr,...
            procpar.FinePwr)
else
    eval(['data.spec' num2str(nData) '.rf1.power   = 0;'])
end
if isfield(procpar,'csdOffset')
    eval(['data.spec' num2str(nData) '.rf1.offset  = procpar.csdOffset;'])
else
    eval(['data.spec' num2str(nData) '.rf1.offset  = 0;'])
end
eval(['data.spec' num2str(nData) '.rf1.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf1.applied = ''y'';'])

%--- RF 2 ---
if isfield(procpar,'p1pat')
    eval(['data.spec' num2str(nData) '.rf2.shape   = procpar.p1pat;'])
else
    eval(['data.spec' num2str(nData) '.rf2.shape   = '''';'])
end
if isfield(procpar,'p1')
    eval(['data.spec' num2str(nData) '.rf2.dur     = procpar.p1/1000;'])
else
    eval(['data.spec' num2str(nData) '.rf2.dur     = 0;'])
end
if any(strfind(data.spec1.sequence,'STEAM'))    % STEAM
    eval(['data.spec' num2str(nData) '.rf2.power   = procpar.tpwr;'])
else                                            % all other sequences
    if isfield(procpar,'tpwr1')
        eval(['data.spec' num2str(nData) '.rf2.power   = procpar.tpwr1;'])
    else
        eval(['data.spec' num2str(nData) '.rf2.power   = 0;'])
    end
end
if isfield(procpar,'csdOffset')
    eval(['data.spec' num2str(nData) '.rf2.offset  = procpar.csdOffset;'])      % parameter?
else
    eval(['data.spec' num2str(nData) '.rf2.offset  = 0;'])      % parameter?
end
eval(['data.spec' num2str(nData) '.rf2.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf2.applied = ''y'';'])

%--- water suppression ---
if isfield(procpar,'WSpat')
    eval(['data.spec' num2str(nData) '.ws.shape = procpar.WSpat;'])
else
    eval(['data.spec' num2str(nData) '.ws.shape = '''';'])
end
if isfield(procpar,'pWS')
    eval(['data.spec' num2str(nData) '.ws.dur   = procpar.pWS/1000;'])
else
    eval(['data.spec' num2str(nData) '.ws.dur   = 0;'])
end
if isfield(procpar,'tpwrWS')
    eval(['data.spec' num2str(nData) '.ws.power    = procpar.tpwrWS;'])
else
    eval(['data.spec' num2str(nData) '.ws.power    = 0;'])
end
if isfield(procpar,'WSOffset')
    eval(['data.spec' num2str(nData) '.ws.offset   = procpar.WSOffset;'])
else
    eval(['data.spec' num2str(nData) '.ws.offset   = 0;'])
end
if isfield(procpar,'WSModule')
    eval(['data.spec' num2str(nData) '.ws.method   = procpar.WSModule;'])
end
if isfield(procpar,'WS')
    eval(['data.spec' num2str(nData) '.ws.applied  = procpar.WS;'])
end

%--- JDE ---
if isfield(procpar,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.shape = procpar.jdepat;'])
else
    eval(['data.spec' num2str(nData) '.jde.shape = '''';'])
end
if isfield(procpar,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.dur   = procpar.pjde/1000;'])
else
    eval(['data.spec' num2str(nData) '.jde.dur   = 0;'])
end
if isfield(procpar,'jdepat')
    eval(['data.spec' num2str(nData) '.jde.power = procpar.tpwrjde;'])
else
    eval(['data.spec' num2str(nData) '.jde.power = 0;'])
end
if isfield(procpar,'offsetjde')
    eval(['data.spec' num2str(nData) '.jde.offset = procpar.offsetjde;'])
    
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
if isfield(procpar,'JDE')
    eval(['data.spec' num2str(nData) '.jde.applied = procpar.JDE;'])
else
    eval(['data.spec' num2str(nData) '.jde.applied = '''';'])
end
eval(['data.spec' num2str(nData) '.t2Series = 0;'])         % global loggingfile init (potential later update)
if eval(['strcmp(data.spec' num2str(nData) '.jde.applied,''y'');'])
    if isfield(procpar,'t2TeExtra')
        if iscell(procpar.t2TeExtra)
            eval(['data.spec' num2str(nData) '.t2TeExtra = cell2mat(procpar.t2TeExtra)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtra = procpar.t2TeExtra*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtra = 0;'])
    end
    eval(['data.spec' num2str(nData) '.t2TeN = length(data.spec' num2str(nData) '.t2TeExtra);'])
    if eval(['data.spec' num2str(nData) '.t2TeN>1;'])       % update T2 series flag
        eval(['data.spec' num2str(nData) '.t2Series = 1;'])
    end
    if isfield(procpar,'t2TeExtraBal')
        if iscell(procpar.t2TeExtraBal)
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = cell2mat(procpar.t2TeExtraBal)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = procpar.t2TeExtraBal*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtraBal = 0;'])
    end
    if isfield(procpar,'t2DS')
        if iscell(procpar.t2DS)
            eval(['data.spec' num2str(nData) '.t2DS = cell2mat(procpar.t2DS);'])
        else
            eval(['data.spec' num2str(nData) '.t2DS = procpar.t2DS;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2DS = 0;'])
    end
    if isfield(procpar,'T2offset')
        if iscell(procpar.T2offset)
            eval(['data.spec' num2str(nData) '.T2offset = cell2mat(procpar.T2offset);'])
        else
            eval(['data.spec' num2str(nData) '.T2offset = procpar.T2offset;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offset = 0;'])
    end
    if isfield(procpar,'T2offsetVal')
        if iscell(procpar.T2offsetVal)
            eval(['data.spec' num2str(nData) '.T2offsetVal = cell2mat(procpar.T2offsetVal);'])
        else
            eval(['data.spec' num2str(nData) '.T2offsetVal = procpar.T2offsetVal;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offsetVal = 0;'])
    end
    if isfield(procpar,'applT2offset')
        eval(['data.spec' num2str(nData) '.applT2offset = procpar.applT2offset;'])
    else
        eval(['data.spec' num2str(nData) '.applT2offset = 0;'])
    end
end

%--- inversion ---
if isfield(procpar,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.shape = procpar.p2pat;'])
else
    eval(['data.spec' num2str(nData) '.inv.shape = '''';'])
end
if isfield(procpar,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.dur   = procpar.p2/1000;'])
else
    eval(['data.spec' num2str(nData) '.inv.dur   = 0;'])
end
if isfield(procpar,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.power = procpar.tpwr2;'])
else
    eval(['data.spec' num2str(nData) '.inv.power = 0;'])
end
if isfield(procpar,'TIoffset')
    eval(['data.spec' num2str(nData) '.inv.offset = procpar.TIoffset;'])
else
    eval(['data.spec' num2str(nData) '.inv.offset = 0;'])
end
if isfield(procpar,'TI')
    eval(['data.spec' num2str(nData) '.inv.ti = procpar.TI;'])              % orig [ms]
else
    eval(['data.spec' num2str(nData) '.inv.ti = 0;'])
end
eval(['data.spec' num2str(nData) '.inv.method = '''';'])
if isfield(procpar,'Inversion')
    eval(['data.spec' num2str(nData) '.inv.applied = procpar.Inversion;'])
else
    eval(['data.spec' num2str(nData) '.inv.applied = '''';'])
end

%--- OVS ---
if isfield(procpar,'OVS')
    eval(['data.spec' num2str(nData) '.ovs.applied = procpar.OVS;'])
else
    eval(['data.spec' num2str(nData) '.ovs.applied = '''';'])
end
if isfield(procpar,'OVSmode')
    eval(['data.spec' num2str(nData) '.ovs.mode = procpar.OVSmode;'])
else
    eval(['data.spec' num2str(nData) '.ovs.mode = '''';'])
end
if isfield(procpar,'OVSInterl')
    eval(['data.spec' num2str(nData) '.ovs.interleaved = procpar.OVSInterl;'])
else
    eval(['data.spec' num2str(nData) '.ovs.interleaved = '''';'])
end
if isfield(procpar,'ovspat1')
    eval(['data.spec' num2str(nData) '.ovs.shape = procpar.ovspat1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.shape = '''';'])
end
if isfield(procpar,'ovsthk')
    eval(['data.spec' num2str(nData) '.ovs.thk = procpar.ovsthk;'])
else
    eval(['data.spec' num2str(nData) '.ovs.thk = '''';'])
end
if isfield(procpar,'ovssep')
    eval(['data.spec' num2str(nData) '.ovs.separation = procpar.ovssep;'])
else
    eval(['data.spec' num2str(nData) '.ovs.separation = '''';'])
end
if isfield(procpar,'ovsGlobOffset')
    eval(['data.spec' num2str(nData) '.ovs.offset = procpar.ovsGlobOffset;'])
else
    eval(['data.spec' num2str(nData) '.ovs.offset = '''';'])
end
if isfield(procpar,'novs')
    eval(['data.spec' num2str(nData) '.ovs.n = procpar.novs;'])
else
    eval(['data.spec' num2str(nData) '.ovs.n = '''';'])
end
if isfield(procpar,'povs1')
    eval(['data.spec' num2str(nData) '.ovs.dur = procpar.povs1/1000;'])
else
    eval(['data.spec' num2str(nData) '.ovs.dur = '''';'])
end
if isfield(procpar,'tpwrovs1')
    eval(['data.spec' num2str(nData) '.ovs.power = procpar.tpwrovs1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
if isfield(procpar,'tpwrovsVar1') && isfield(procpar,'tpwrovsVar2') && ...
   isfield(procpar,'tpwrovsVar3') && isfield(procpar,'tpwrovsVar4')
    eval(['data.spec' num2str(nData) '.ovs.variation(1) = procpar.tpwrovsVar1;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(2) = procpar.tpwrovsVar2;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(3) = procpar.tpwrovsVar3;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(4) = procpar.tpwrovsVar4;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
% if isfield(procpar,'mrsiAver')
%     eval(['data.spec' num2str(nData) '.mrsi.aver = procpar.mrsiAver;'])
% end
% if isfield(procpar,'nvMrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.nEnc = procpar.nvMrsi;'])
% end
% if isfield(procpar,'nvR')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncR = procpar.nvR;'])
% end
% if isfield(procpar,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncP = procpar.nvP;'])
% end
% if isfield(procpar,'nvS')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncS = procpar.nvS;'])
% end
% if isfield(procpar,'nvR') && isfield(procpar,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.mat = [procpar.nvR procpar.nvP];'])
% end
% if isfield(procpar,'lro_mrsi') && isfield(procpar,'lpe_mrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.fov = 10*[procpar.lro_mrsi procpar.lpe_mrsi];'])
% end
% if isfield(procpar,'mrsiDurSec')
%     eval(['data.spec' num2str(nData) '.mrsi.durSec = procpar.mrsiDurSec;'])
% end
% if isfield(procpar,'mrsiDurMin')
%     eval(['data.spec' num2str(nData) '.mrsi.durMin = procpar.mrsiDurMin;'])
% end
% if isfield(procpar,'TMrsiEnc')
%     eval(['data.spec' num2str(nData) '.mrsi.tEnc = procpar.TMrsiEnc;'])
% end
% if isfield(procpar,'mrsiEncR')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileR = procpar.mrsiEncR;'])
% end
% if isfield(procpar,'mrsiEncP')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileP = procpar.mrsiEncP;'])
% end
% if isfield(procpar,'mrsiEncS')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileS = procpar.mrsiEncS;'])
% end
% if isfield(procpar,'mrsiTableR')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableR = procpar.mrsiTableR;'])
% end
% if isfield(procpar,'mrsiTableP')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableP = procpar.mrsiTableP;'])
% end
% if isfield(procpar,'mrsiTableS')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableS = procpar.mrsiTableS;'])
% end
eval(['data.spec' num2str(nData) '.z0      = 0;'])
eval(['data.spec' num2str(nData) '.yz      = 0;'])
eval(['data.spec' num2str(nData) '.xy      = 0;'])
eval(['data.spec' num2str(nData) '.x2y2    = 0;'])
if isfield(procpar,'xshim')
    eval(['data.spec' num2str(nData) '.x1 = procpar.xshim;'])
else
    eval(['data.spec' num2str(nData) '.x1 = 0;'])
end
eval(['data.spec' num2str(nData) '.x3      = 0;'])
if isfield(procpar,'yshim')
    eval(['data.spec' num2str(nData) '.y1 = procpar.yshim;'])
else
    eval(['data.spec' num2str(nData) '.y1 = 0;'])
end
eval(['data.spec' num2str(nData) '.xz      = 0;'])
eval(['data.spec' num2str(nData) '.xz2     = 0;'])
eval(['data.spec' num2str(nData) '.y3      = 0;'])
if isfield(procpar,'zshim')
    eval(['data.spec' num2str(nData) '.z1c = procpar.zshim;'])
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
% if isfield(procpar,'Gslice1')
%     eval(['data.spec' num2str(nData) '.Gslice1 = procpar.Gslice1;'])
% end
% if isfield(procpar,'Gslice1ref')
%     eval(['data.spec' num2str(nData) '.Gslice1ref = procpar.Gslice1ref;'])
% end
% if isfield(procpar,'Gslice2')
%     eval(['data.spec' num2str(nData) '.Gslice2 = procpar.Gslice2;'])
% end
% if isfield(procpar,'Gslice3')
%     eval(['data.spec' num2str(nData) '.Gslice3 = procpar.Gslice3;'])
% end
% if isfield(procpar,'TxFreqExc')
%     eval(['data.spec' num2str(nData) '.txFreqExc = procpar.TxFreqExc;'])
% end
% if isfield(procpar,'TxFreqRef1')
%     eval(['data.spec' num2str(nData) '.txFreqRef1 = procpar.TxFreqRef1;'])
% end
% if isfield(procpar,'TxFreqRef2')
%     eval(['data.spec' num2str(nData) '.txFreqRef2 = procpar.TxFreqRef2;'])
% end

if isfield(procpar,'dab')
    eval(['data.spec' num2str(nData) '.nRcvrs = (procpar.dab(2)-procpar.dab(1))+1;'])
else
    eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
end
if isfield(procpar,'InstanceTime')          % -> date vector
    eval(['data.spec' num2str(nData) '.time_start = datevec(procpar.InstanceTime);'])
end
if isfield(procpar,'sctime')
    eval(['data.spec' num2str(nData) '.durSec = procpar.sctime/1e6;'])
    eval(['data.spec' num2str(nData) '.durMin = procpar.sctime/6e8;'])
else
    eval(['data.spec' num2str(nData) '.durSec = 0;'])
    eval(['data.spec' num2str(nData) '.durMin = 0;'])
end
% if isfield(procpar,'time_complete')     % ISO 8601 -> date vector
%     eval(['data.spec' num2str(nData) '.time_end = datevec(procpar.time_complete,''yyyymmddTHHMMSS'');'])
% end

%--- update success flag ---
f_done = 1;

