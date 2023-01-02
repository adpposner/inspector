%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PvParsConversion(method,acqp,nData)
%% 
%%  Conversion of Bruker parameters to method structure to be used 
%%  in this software.
%%
%%  01-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_PvParsConversion';


%--- init success flag ---
f_succ = 0;

if nData == 1
    data_alias = data.spec1;
elseif nData == 2
    data_alias = data.spec2;
else
    warning('Invalid data spec value nData = %d',nData);
end

warning('data_alias has been set in %s',mfilename);

%--- parameter transfer to 'method' struct ---
if isfield(acqp,'PULPROG')
    data_alias.sequence = acqp.PULPROG;
else
    data_alias.sequence = '';
end
if isfield(acqp,'ACQ_protocol_name')
    data_alias.protocolName = acqp.ACQ_protocol_name;
else
    data_alias.protocolName = '';
end
if isfield(acqp,'ACQ_scan_name')
    data_alias.scanName = acqp.ACQ_scan_name;
else
    data_alias.scanName = '';
end

% if any(strfind(data.spec1.sequence,'JDE')) || any(strfind(data.spec1.sequence,'Jde')) || any(strfind(data.spec1.sequence,'jde'))
%     if isfield(acqp,'seqtype')
%         if strcmp(acqp.seqtype,'2x180')
%             data_alias.seqtype = 'PRESS';
%         elseif strcmp(acqp.seqtype,'4x180')
%             data_alias.seqtype = 'sLASER';
%         else        % unknown
            data_alias.seqtype = '';
%         end
%     end
% end

if isfield(method,'PVM_SpecMatrix')
    data_alias.nspecC   = method.PVM_SpecMatrix;
elseif isfield(acqp,'ACQ_size')
    data_alias.nspecC   = acqp.ACQ_size(1)/2;
else
    fprintf(loggingfile,'%s ->\nFID length not found in parameter file(s). Program aborted.\n',FCTNAME);
    return
end
if isfield(method,'Y_Mode') && isfield(method,'Y_CsiListSize')
    if method.Y_CsiListSize==0
        data_alias.nx = 1;
    else
        data_alias.nx = method.Y_CsiListSize;
    end
    data_alias.ny       = 1;
    data_alias.nz       = 1;
else
    data_alias.nx       = 1;
    data_alias.ny       = 1;
    data_alias.nz       = 1;
end
if isfield(acqp,'NSLICES')
    data_alias.ns   = acqp.NSLICES;
else
    data_alias.ns   = 1;
end
if isfield(acqp,'RG')
    data_alias.gain = acqp.RG;    
else
    data_alias.gain = 0;
end
if isfield(acqp,'NI')
    data_alias.ni = acqp.NI;    
else
    data_alias.ni = 1;
end

%--- njde ---
switch flag.dataExpType
    case 1                      % regular data format
        data_alias.njde = 1;
        
    case 2                      % saturation-recovery series
        data_alias.njde = 1;
        
    case 3                      % JDE
        data_alias.njde = 2;
        
    case 4                      % stability analysis
        data_alias.njde = 1;
        
    case 5                      % T1/T2 series'
        data_alias.njde = 1;
        
    case 6                      % MRSI
        data_alias.njde = 1;
        
    case 7                      % JDE array
        data_alias.njde = 3;    
        
    otherwise
        fprintf(loggingfile,'%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME);
        return
end

% if isfield(acqp,'saveSeparately')        % note the string-to-numeric conversion
%     data_alias.saveSep = strcmp(acqp.saveSeparately,'y'); 
% else
%     data_alias.saveSep = 0;      % default: off 
% end


% if isfield(acqp,'pscopt')
%     data_alias.nr = acqpopt;

% if isfield(acqp,'nexForUnacquiredEncodes')
%     data_alias.nref = acqp.nexForUnacquiredEncodes;
% else
%     data_alias.nref = 0;
% end
if isfield(acqp,'DECIM')
    data_alias.decim = acqp.DECIM;
else
    data_alias.decim = 1;
end
if isfield(acqp,'DSPFVS')
    data_alias.dspfvs = acqp.DSPFVS;
else
    data_alias.dspfvs = 1;
end


% if isfield(acqp,'NI')
%     data_alias.nv = acqp.NI;
% else
%     data_alias.nv = 1;
% end
if isfield(acqp,'SFO1')
    data_alias.sf = acqp.SFO1;                 % Larmor frequency in MHz
end

if isfield(acqp,'tof')
    data_alias.offset   = acqp.tof;                       % frequency offset in Hz
else
    data_alias.offset   = 0;                                 % frequency offset in Hz
end
if isfield(acqp,'SW_h')                                                         % 
    data_alias.sw_h  = acqp.SW_h;  % sweep width in Hz
    data_alias.dwell = 1/acqp.SW_h;               % orig: [ns]
    data_alias.sw    = data_alias.sw_h/data_alias.sf;         % sweep width in Hz
else
    data_alias.sw_h  = 0;
    data_alias.sw    = 0;
    data_alias.dwell = 0;
end
% if isfield(acqp.series,'prtcl')
%     data_alias.pp = acqp.series.prtcl;
% else
%     data_alias.pp = '';
% end


if isfield(acqp,'ACQ_word_size')                                 % number of bytes
    data_alias.wordSize = acqp.ACQ_word_size;
else
    data_alias.wordSize = '';
end
if isfield(acqp,'BYTORDA')                                             % data format
    data_alias.byteOrder = acqp.BYTORDA;
else                                                                % 2 bytes
    data_alias.byteOrder = '';
end


if isfield(method,'PVM_RepetitionTime')
    data_alias.tr = method.PVM_RepetitionTime;            % orig: [us]
else
    data_alias.tr = 0;
end
if isfield(method,'PVM_EchoTime1') && isfield(method,'PVM_EchoTime2') && ...
   strcmp(data_alias.sequence,'ragPT.ppg');      % e.g. ragPT.ppg
    data_alias.te = method.PVM_EchoTime1 + method.PVM_EchoTime2;   % orig: [us]
elseif isfield(method,'PVM_EchoTime')                                   % regular case
    data_alias.te = method.PVM_EchoTime;           % orig: [us]
else
    data_alias.te = 0;
end
if isfield(method,'StTM')
    data_alias.tm = method.StTM;                  % orig: [ms]
else
    data_alias.tm = 0;
end
if isfield(method,'PVM_VoxArrPosition')
    if length(method.PVM_VoxArrPosition)==3
        data_alias.pos(1) = method.PVM_VoxArrPosition(1);
        data_alias.pos(2) = method.PVM_VoxArrPosition(2);
        data_alias.pos(3) = method.PVM_VoxArrPosition(3);
    else
        data_alias.pos(1) = 0;
        data_alias.pos(2) = 0;
        data_alias.pos(3) = 0;
    end
else
    data_alias.pos(1) = 0;
    data_alias.pos(2) = 0;
    data_alias.pos(3) = 0;
end
if isfield(method,'PVM_VoxArrSize')
    if length(method.PVM_VoxArrSize)==3
        data_alias.vox(1) = method.PVM_VoxArrSize(1);
        data_alias.vox(2) = method.PVM_VoxArrSize(2);
        data_alias.vox(3) = method.PVM_VoxArrSize(3);
    else
        data_alias.vox(1) = 0;
        data_alias.vox(2) = 0;
        data_alias.vox(3) = 0;
    end
else
    data_alias.vox(1) = 0;
    data_alias.vox(2) = 0;
    data_alias.vox(3) = 0;
end
% if isfield(acqp,'DeviceSerialNumber')
%     data_alias.devSerial = acqp.DeviceSerialNumber;
% else
%     data_alias.devSerial = 0;
% end
% if isfield(acqp,'ModelName')
%     data_alias.gcoil = acqp.ModelName;
% else
%     data_alias.gcoil = 0;
% end

% if isfield(acqp,'gcoil')
%     data_alias.gradSys = acqp.gcoil;
% else
%     data_alias.gradSys = '';
% end


%--- RF 1 ---
if isfield(method,'VoxPul1Enum')
    data_alias.rf1.shape   = method.VoxPul1Enum;
else
    data_alias.rf1.shape   = '';
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1)
        data_alias.rf1.dur = str2num(method.VoxPul1{1});
    else
        data_alias.rf1.dur = 0;
    end
else
    data_alias.rf1.dur     = 0;
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1) && length(method.VoxPul1)>10
        data_alias.rf1.power = str2num(method.VoxPul1{11});
    else
        data_alias.rf1.power = 0;
    end
else
    data_alias.rf1.power     = 0;
end
if isfield(method,'VoxPul1')            % not clear 
    if iscell(method.VoxPul1) && length(method.VoxPul1)>8
        data_alias.rf1.offset = str2num(method.VoxPul1{9});
    else
        data_alias.rf1.offset = 0;
    end
else
    data_alias.rf1.offset     = 0;
end
data_alias.rf1.method  = '';
data_alias.rf1.applied = 'y';

%--- RF 2 ---
if isfield(method,'VoxPul2Enum')
    data_alias.rf2.shape   = method.VoxPul2Enum;
else
    data_alias.rf2.shape   = '';
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2)
        data_alias.rf2.dur = str2num(method.VoxPul2{1});
    else
        data_alias.rf2.dur     = 0;
    end
else
    data_alias.rf2.dur     = 0;
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2) && length(method.VoxPul2)>10
        data_alias.rf2.power = str2num(method.VoxPul2{11});
    else
        data_alias.rf2.power = 0;
    end
else
    data_alias.rf2.power     = 0;
end
if isfield(method,'VoxPul2')            % not clear 
    if iscell(method.VoxPul2) && length(method.VoxPul2)>8
        data_alias.rf2.offset = str2num(method.VoxPul2{9});
    else
        data_alias.rf2.offset = 0;
    end
else
    data_alias.rf2.offset     = 0;
end
data_alias.rf2.method  = '';
data_alias.rf2.applied = 'y';

%--- water suppression ---
if isfield(acqp,'WSpat')
    data_alias.ws.shape = acqp.WSpat;
else
    data_alias.ws.shape = '';
end
if isfield(acqp,'pWS')
    data_alias.ws.dur   = acqp.pWS/1000;
else
    data_alias.ws.dur   = 0;
end
if isfield(acqp,'tpwrWS')
    data_alias.ws.power    = acqp.tpwrWS;
else
    data_alias.ws.power    = 0;
end
if isfield(acqp,'WSOffset')
    data_alias.ws.offset   = acqp.WSOffset;
else
    data_alias.ws.offset   = 0;
end
if isfield(acqp,'WSModule')
    data_alias.ws.method   = acqp.WSModule;
end
if isfield(acqp,'WS')
    data_alias.ws.applied  = acqp.WS;
end

%--- JDE ---
if isfield(method,'JDEPul1')
    if iscell(method.JDEPul1) && ~isempty(method.JDEPul1)
        data_alias.jde.dur = str2num(method.JDEPul1{1});
    else
        data_alias.jde.dur = 0;
    end
else
    data_alias.jde.dur     = 0;
end
if isfield(method,'JDEPul1')
    if length(method.JDEPul1)>10
        data_alias.jde.power = str2num(method.JDEPul1{11});
    else
        data_alias.jde.power = 0;
    end
else
    data_alias.jde.power     = 0;
end
if isfield(method,'JDEFrequency1')
    data_alias.jde.offset1 = method.JDEFrequency1;
else
    data_alias.jde.offset1 = 0;
end
if isfield(method,'JDEFrequency2')
    data_alias.jde.offset2 = method.JDEFrequency2;
else
    data_alias.jde.offset2 = 0;
end
data_alias.jde.method = '';
if isfield(method,'JDEOnOff')
    if strcmp(method.JDEOnOff,'On')
        data_alias.jde.applied = 'y';
        if isfield(method,'JDEFrequency1') && isfield(method,'JDEFrequency2')
            data_alias.jde.offset = {method.JDEFrequency1, method.JDEFrequency2};
        else
            data_alias.jde.offset   = '';
        end
        if isfield(method,'JDEPul1Enum') && isfield(method,'JDEPul2Enum')
            data_alias.jde.shape = {method.JDEPul1Enum, method.JDEPul2Enum};
        else
            data_alias.jde.shape   = '';
        end
    else
        data_alias.jde.applied = '';
        data_alias.jde.offset  = '';
        data_alias.jde.shape   = '';
    end
else
    data_alias.jde.applied = '';
    data_alias.jde.offset  = '';
    data_alias.jde.shape   = '';
end
data_alias.t2Series = 0;         % global loggingfile init (potential later update)
if strcmp(data_alias.jde.applied,'y')
    if isfield(acqp,'t2TeExtra')
        if iscell(acqp.t2TeExtra)
            data_alias.t2TeExtra = cell2mat(acqp.t2TeExtra)*1000;
        else
            data_alias.t2TeExtra = acqp.t2TeExtra*1000;
        end
    else
        data_alias.t2TeExtra = 0;
    end
    data_alias.t2TeN = length(data_alias.t2TeExtra);
    if data_alias.t2TeN>1;       % update T2 series flag
        data_alias.t2Series = 1;
    end
    if isfield(acqp,'t2TeExtraBal')
        if iscell(acqp.t2TeExtraBal)
            data_alias.t2TeExtraBal = cell2mat(acqp.t2TeExtraBal)*1000;
        else
            data_alias.t2TeExtraBal = acqp.t2TeExtraBal*1000;
        end
    else
        data_alias.t2TeExtraBal = 0;
    end
    if isfield(acqp,'t2DS')
        if iscell(acqp.t2DS)
            data_alias.t2DS = cell2mat(acqp.t2DS);
        else
            data_alias.t2DS = acqp.t2DS;
        end
    else
        data_alias.t2DS = 0;
    end
    if isfield(acqp,'T2offset')
        if iscell(acqp.T2offset)
            data_alias.T2offset = cell2mat(acqp.T2offset);
        else
            data_alias.T2offset = acqp.T2offset;
        end
    else
        data_alias.T2offset = 0;
    end
    if isfield(acqp,'T2offsetVal')
        if iscell(acqp.T2offsetVal)
            data_alias.T2offsetVal = cell2mat(acqp.T2offsetVal);
        else
            data_alias.T2offsetVal = acqp.T2offsetVal;
        end
    else
        data_alias.T2offsetVal = 0;
    end
    if isfield(acqp,'applT2offset')
        data_alias.applT2offset = acqp.applT2offset;
    else
        data_alias.applT2offset = 0;
    end
end

%--- inversion ---
if isfield(acqp,'p2pat')
    data_alias.inv.shape = acqp.p2pat;
else
    data_alias.inv.shape = '';
end
if isfield(acqp,'p2pat')
    data_alias.inv.dur   = acqp.p2/1000;
else
    data_alias.inv.dur   = 0;
end
if isfield(acqp,'p2pat')
    data_alias.inv.power = acqp.tpwr2;
else
    data_alias.inv.power = 0;
end
if isfield(acqp,'TIoffset')
    data_alias.inv.offset = acqp.TIoffset;
else
    data_alias.inv.offset = 0;
end
if isfield(acqp,'TI')
    data_alias.inv.ti = acqp.TI;              % orig [ms]
else
    data_alias.inv.ti = 0;
end
data_alias.inv.method = '';
if isfield(acqp,'Inversion')
    data_alias.inv.applied = acqp.Inversion;
else
    data_alias.inv.applied = '';
end

%--- OVS ---
if isfield(acqp,'OVS')
    data_alias.ovs.applied = acqp.OVS;
else
    data_alias.ovs.applied = '';
end
if isfield(acqp,'OVSmode')
    data_alias.ovs.mode = acqp.OVSmode;
else
    data_alias.ovs.mode = '';
end
if isfield(acqp,'OVSInterl')
    data_alias.ovs.interleaved = acqp.OVSInterl;
else
    data_alias.ovs.interleaved = '';
end
if isfield(acqp,'ovspat1')
    data_alias.ovs.shape = acqp.ovspat1;
else
    data_alias.ovs.shape = '';
end
if isfield(acqp,'ovsthk')
    data_alias.ovs.thk = acqp.ovsthk;
else
    data_alias.ovs.thk = '';
end
if isfield(acqp,'ovssep')
    data_alias.ovs.separation = acqp.ovssep;
else
    data_alias.ovs.separation = '';
end
if isfield(acqp,'ovsGlobOffset')
    data_alias.ovs.offset = acqp.ovsGlobOffset;
else
    data_alias.ovs.offset = '';
end
if isfield(acqp,'novs')
    data_alias.ovs.n = acqp.novs;
else
    data_alias.ovs.n = '';
end
if isfield(acqp,'povs1')
    data_alias.ovs.dur = acqp.povs1/1000;
else
    data_alias.ovs.dur = '';
end
if isfield(acqp,'tpwrovs1')
    data_alias.ovs.power = acqp.tpwrovs1;
else
    data_alias.ovs.power = '';
end
if isfield(acqp,'tpwrovsVar1') && isfield(acqp,'tpwrovsVar2') && ...
   isfield(acqp,'tpwrovsVar3') && isfield(acqp,'tpwrovsVar4')
    data_alias.ovs.variation(1) = acqp.tpwrovsVar1;
    data_alias.ovs.variation(2) = acqp.tpwrovsVar2;
    data_alias.ovs.variation(3) = acqp.tpwrovsVar3;
    data_alias.ovs.variation(4) = acqp.tpwrovsVar4;
else
    data_alias.ovs.power = '';
end
% if isfield(acqp,'mrsiAver')
%     data_alias.mrsi.aver = acqp.mrsiAver;
% end
% if isfield(acqp,'nvMrsi')
%     data_alias.mrsi.nEnc = acqp.nvMrsi;
% end
% if isfield(acqp,'nvR')
%     data_alias.mrsi.nEncR = acqp.nvR;
% end
% if isfield(acqp,'nvP')
%     data_alias.mrsi.nEncP = acqp.nvP;
% end
% if isfield(acqp,'nvS')
%     data_alias.mrsi.nEncS = acqp.nvS;
% end
% if isfield(acqp,'nvR') && isfield(acqp,'nvP')
%     data_alias.mrsi.mat = [acqp.nvR acqp.nvP];
% end
% if isfield(acqp,'lro_mrsi') && isfield(acqp,'lpe_mrsi')
%     data_alias.mrsi.fov = 10*[acqp.lro_mrsi acqp.lpe_mrsi];
% end
% if isfield(acqp,'mrsiDurSec')
%     data_alias.mrsi.durSec = acqp.mrsiDurSec;
% end
% if isfield(acqp,'mrsiDurMin')
%     data_alias.mrsi.durMin = acqp.mrsiDurMin;
% end
% if isfield(acqp,'TMrsiEnc')
%     data_alias.mrsi.tEnc = acqp.TMrsiEnc;
% end
% if isfield(acqp,'mrsiEncR')
%     data_alias.mrsi.encFileR = acqp.mrsiEncR;
% end
% if isfield(acqp,'mrsiEncP')
%     data_alias.mrsi.encFileP = acqp.mrsiEncP;
% end
% if isfield(acqp,'mrsiEncS')
%     data_alias.mrsi.encFileS = acqp.mrsiEncS;
% end
% if isfield(acqp,'mrsiTableR')
%     data_alias.mrsi.encTableR = acqp.mrsiTableR;
% end
% if isfield(acqp,'mrsiTableP')
%     data_alias.mrsi.encTableP = acqp.mrsiTableP;
% end
% if isfield(acqp,'mrsiTableS')
%     data_alias.mrsi.encTableS = acqp.mrsiTableS;
% end

if isfield(acqp,'shim0')
    data_alias.z0 = acqp.shim0;
else
    data_alias.z0 = 0;
end
data_alias.yz      = 0;
data_alias.xy      = 0;
data_alias.x2y2    = 0;
if isfield(acqp,'shim1')
    data_alias.x1 = acqp.shim1;
else
    data_alias.x1 = 0;
end
data_alias.x3      = 0;
if isfield(acqp,'shim3')
    data_alias.y1 = acqp.shim3;
else
    data_alias.y1 = 0;
end
data_alias.xz      = 0;
data_alias.xz2     = 0;
data_alias.y3      = 0;
if isfield(acqp,'shim2')
    data_alias.z1c = acqp.shim2;
else
    data_alias.z1c = 0;
end
data_alias.yz2     = 0;
data_alias.z2c     = 0;
data_alias.z5      = 0;
data_alias.z3c     = 0;
data_alias.z4c     = 0;
data_alias.zx2y2   = 0;
data_alias.zxy     = 0;
% if isfield(acqp,'Gslice1')
%     data_alias.Gslice1 = acqp.Gslice1;
% end
% if isfield(acqp,'Gslice1ref')
%     data_alias.Gslice1ref = acqp.Gslice1ref;
% end
% if isfield(acqp,'Gslice2')
%     data_alias.Gslice2 = acqp.Gslice2;
% end
% if isfield(acqp,'Gslice3')
%     data_alias.Gslice3 = acqp.Gslice3;
% end
% if isfield(acqp,'TxFreqExc')
%     data_alias.txFreqExc = acqp.TxFreqExc;
% end
% if isfield(acqp,'TxFreqRef1')
%     data_alias.txFreqRef1 = acqp.TxFreqRef1;
% end
% if isfield(acqp,'TxFreqRef2')
%     data_alias.txFreqRef2 = acqp.TxFreqRef2;
% end

%--- Bruker data format ---
if isfield(acqp,'ACQ_ReceiverSelect')
    flag.dataBrukerNewOld = 1;
    if strcmp(data_alias.fidName,'fid')
        flag.dataBrukerFormat = 2;      % new fid format
    else
        flag.dataBrukerFormat = 3;      % new rawdata.job0 format
    end
else
    flag.dataBrukerNewOld = 0;          % old format
    flag.dataBrukerFormat = 1;          % old -> fid (only)
end
% note flag.dataBrukerFormat definition:
% 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0

if flag.dataBrukerFormat==1             % old, fid (might need updating)
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            data_alias.nRcvrs = 1;
        else                                            % multiple effective receivers
            data_alias.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            data_alias.acqpRcvrSelect = 1;
            % data_alias.nRcvrs = 1;
        else                                            % multiple receivers
            data_alias.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % data_alias.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        data_alias.acqpRcvrSelect = 1;
        % data_alias.nRcvrs = 1;
    end
    if isfield(method,'PVM_NRepetitions')
        data_alias.nr = method.PVM_NRepetitions;
    else
        data_alias.nr = 1;
    end
    if isfield(method,'PVM_NAverages')
        data_alias.na = method.PVM_NAverages;
    else
        data_alias.na = 1;
    end
elseif flag.dataBrukerFormat==2         % new, fid
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            data_alias.nRcvrs = 1;
        else                                            % multiple effective receivers
            data_alias.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            data_alias.acqpRcvrSelect = 1;
            % data_alias.nRcvrs = 1;
        else                                            % multiple receivers
            data_alias.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % data_alias.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        data_alias.acqpRcvrSelect = 1;
        % data_alias.nRcvrs = 1;
    end
    if isfield(method,'PVM_NAverages')
        data_alias.na = method.PVM_NAverages;
    else
        data_alias.na = 1;
    end
    % data_alias.nr = 1;           % collapsed
    if isfield(method,'PVM_NRepetitions')
        data_alias.nr = method.PVM_NRepetitions;
    else
        data_alias.nr = 1;
    end
else                                    % new, rawdata.job0
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            data_alias.nRcvrs = 1;
        else                                            % multiple effective receivers
            data_alias.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            data_alias.acqpRcvrSelect = 1;
            % data_alias.nRcvrs = 1;
        else                                            % multiple receivers
            data_alias.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % data_alias.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
            % fixed for Merck data (Corey Miller, 12/2021) since length()
            % effectively considers 0's (i.e. 'No') as valid entries, i.e.
            % disabled coil elements are misinterpreted as active coils
            % data_alias.nRcvrs = sum(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        data_alias.acqpRcvrSelect = 1;
        % data_alias.nRcvrs = 1;
    end
    if flag.dataExpType==1              % regular MRS
        % RAG's STEAM sequence
        if strcmp(data_alias.sequence,'ragSTEAM.ppg') && ...
           isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
         
            data_alias.nr = method.PVM_NAverages*method.PVM_NRepetitions;      
            if flag.verbose
                fprintf(loggingfile,'ragSTEAM:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions);
                if isfield(method,'IsisNAverages')
                    fprintf(loggingfile,'IsisNAverages    = %.0f\n',method.IsisNAverages);
                end
            end
            data_alias.na = 1;
        elseif strcmp(data_alias.sequence,'ragPT.ppg') && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % RAG's polarization transfer (ISIS) sequence
            data_alias.nr = method.PVM_NRepetitions*method.IsisNAverages;      
            if flag.verbose
                fprintf(loggingfile,'ragPT:\n');
                fprintf(loggingfile,'PVM_NAverages    = %.0f\n',method.PVM_NAverages);
                fprintf(loggingfile,'PVM_NRepetitions = %.0f\n',method.PVM_NRepetitions);
                fprintf(loggingfile,'IsisNAverages    = %.0f\n',method.IsisNAverages);
            end
            data_alias.na = 1;
        elseif strcmp(data_alias.sequence,'ISIS.ppg') && ...
               strcmp(method.Method,'Bruker:ISIS') && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % Bruker's ISIS sequence
            data_alias.nr = method.IsisNAverages;      
            if flag.verbose
                fprintf(loggingfile,'Bruker ISIS:\n');
                fprintf(loggingfile,'PVM_NAverages     = %.0f\n',method.PVM_NAverages);
                fprintf(loggingfile,'PVM_NRepetitions  = %.0f\n',method.PVM_NRepetitions);
                fprintf(loggingfile,'IsisNAverages     = %.0f\n',method.IsisNAverages);
            end
            data_alias.na = 1;
        else                    % regular case
            % e.g. including regular Bruker PRESS
            if nData==2 && flag.dataIdentScan && strcmp(method.PVM_RefScanYN,'Yes')
                if isfield(method,'PVM_NRepetitions')
                    data_alias.nr = method.PVM_RefScanNA;        % note the NA <=> NR flip since data is saved separately
                else
                    data_alias.nr = 1;
                end
                if isfield(method,'PVM_NAverages')
                    data_alias.na = method.PVM_NRepetitions;     % note the NA <=> NR flip since data is saved separately
                else
                    data_alias.na = 1;
                end
            else        % all other cases, ie. data 1, regular (non-ref) data, etc
%                 if strcmp(acqp.ACQ_sw_version,'PV-360.1.1')      % although this should be the default rather than the exception
%                     % ShanghaiTech / Chao: PV-360.1.1
%                     if isfield(method,'PVM_NRepetitions')
%                         data_alias.nr = method.PVM_NRepetitions;     
%                     else
%                         data_alias.nr = 1;
%                     end
%                     if isfield(method,'PVM_NAverages')
%                         data_alias.na = method.PVM_NAverages;        
%                     else
%                         data_alias.na = 1;
%                     end    
%                 else
                    % Merck / Cory Miller: PV-360.2.0.pl.1
                    if isfield(method,'PVM_NRepetitions')
                        data_alias.nr = method.PVM_NAverages;        % note the NA <=> NR flip since data is saved separately
                    else
                        data_alias.nr = 1;
                    end
                    if isfield(method,'PVM_NAverages')
                        data_alias.na = method.PVM_NRepetitions;     % note the NA <=> NR flip since data is saved separately
                    else
                        data_alias.na = 1;
                    end    
%                 end
            end
        end
    elseif flag.dataExpType==3          % JDE
        if isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
            data_alias.nr = method.PVM_NAverages*method.PVM_NRepetitions;      
            if flag.verbose
                fprintf(loggingfile,'JDE:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions);
                if isfield(method,'IsisNAverages')
                    fprintf(loggingfile,'IsisNAverages    = %.0f\n',method.IsisNAverages);
                end
            end
        else
            data_alias.nr = 1;
        end
        if isfield(method,'PVM_NAverages')
            data_alias.na = 1;     
        else
            data_alias.na = 1;
        end
    else
        data_alias.nr = 0;           % default
        data_alias.na = 0;           % default
    end
end
if isfield(acqp,'InstanceTime')          % -> date vector
    data_alias.time_start = datevec(acqp.InstanceTime);
end
if isfield(acqp,'lScanTimeSec')
    data_alias.durSec = acqp.lScanTimeSec/1e6;
    data_alias.durMin = acqp.lScanTimeSec/6e8;
else
    data_alias.durSec = 0;
    data_alias.durMin = 0;
end
% if isfield(acqp,'time_complete')     % ISO 8601 -> date vector
%     data_alias.time_end = datevec(acqp.time_complete,'yyyymmddTHHMMSS');
% end

    
%--- institution / scanner ---
if isfield(acqp,'ACQ_institution')
    data_alias.institution = acqp.ACQ_institution;
else
    data_alias.institution = 'unknown';
end
if isfield(acqp,'ACQ_station')
    data_alias.system = acqp.ACQ_station;
else
    data_alias.system = 'unknown';
end
if isfield(acqp,'ACQ_sw_version')               % software version
    data_alias.software = acqp.ACQ_sw_version;
else
    data_alias.software = 'unknown';
end

%--- info printout ---
data_alias.institution;
% if strcmp(data_alias.system,'Medspec S400 AVIIIHD')
%     data_alias.system;
% else
%     data_alias.system;
% end
data_alias.software;
data_alias.protocolName;
data_alias.scanName;


%%%%REPLACE DATA VALUES AT END
if nData == 1
    data.spec1 = data_alias;
elseif nData == 2
    data.spec2 = data_alias;
else
    warning('Invalid data spec value nData = %d',nData);
end

%--- update success flag ---
f_succ = 1;

