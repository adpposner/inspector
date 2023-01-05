%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [f_succ,dataSpec,updatedflags] = SP2_Data_PvParsConversion(method,acqp,nData,dataSpecX,dataflags)
%% 
%%  Conversion of Bruker parameters to method structure to be used 
%%  in this software.
%%
%%  01-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global verbose 

FCTNAME = 'SP2_Data_PvParsConversion';


%--- init success flag ---
f_succ = 0;

%warning('dataSpecX has been set in %s',mfilename);


%--- parameter transfer to 'method' struct ---
if isfield(acqp,'PULPROG')
    dataSpecX.sequence = acqp.PULPROG;
else
    dataSpecX.sequence = '';
end
if isfield(acqp,'ACQ_protocol_name')
    dataSpecX.protocolName = acqp.ACQ_protocol_name;
else
    dataSpecX.protocolName = '';
end
if isfield(acqp,'ACQ_scan_name')
    dataSpecX.scanName = acqp.ACQ_scan_name;
else
    dataSpecX.scanName = '';
end

% if any(strfind(data.spec1.sequence,'JDE')) || any(strfind(data.spec1.sequence,'Jde')) || any(strfind(data.spec1.sequence,'jde'))
%     if isfield(acqp,'seqtype')
%         if strcmp(acqp.seqtype,'2x180')
%             dataSpecX.seqtype = 'PRESS';
%         elseif strcmp(acqp.seqtype,'4x180')
%             dataSpecX.seqtype = 'sLASER';
%         else        % unknown
            dataSpecX.seqtype = '';
%         end
%     end
% end

if isfield(method,'PVM_SpecMatrix')
    dataSpecX.nspecC   = method.PVM_SpecMatrix;
elseif isfield(acqp,'ACQ_size')
    dataSpecX.nspecC   = acqp.ACQ_size(1)/2;
else
    SP2_Logger.log('%s ->\nFID length not found in parameter file(s). Program aborted.\n',FCTNAME);
    return
end
if isfield(method,'Y_Mode') && isfield(method,'Y_CsiListSize')
    if method.Y_CsiListSize==0
        dataSpecX.nx = 1;
    else
        dataSpecX.nx = method.Y_CsiListSize;
    end
    dataSpecX.ny       = 1;
    dataSpecX.nz       = 1;
else
    dataSpecX.nx       = 1;
    dataSpecX.ny       = 1;
    dataSpecX.nz       = 1;
end
if isfield(acqp,'NSLICES')
    dataSpecX.ns   = acqp.NSLICES;
else
    dataSpecX.ns   = 1;
end
if isfield(acqp,'RG')
    dataSpecX.gain = acqp.RG;    
else
    dataSpecX.gain = 0;
end
if isfield(acqp,'NI')
    dataSpecX.ni = acqp.NI;    
else
    dataSpecX.ni = 1;
end

%--- njde ---
switch dataflags.dataExpType
    case 1                      % regular data format
        dataSpecX.njde = 1;
        
    case 2                      % saturation-recovery series
        dataSpecX.njde = 1;
        
    case 3                      % JDE
        dataSpecX.njde = 2;
        
    case 4                      % stability analysis
        dataSpecX.njde = 1;
        
    case 5                      % T1/T2 series'
        dataSpecX.njde = 1;
        
    case 6                      % MRSI
        dataSpecX.njde = 1;
        
    case 7                      % JDE array
        dataSpecX.njde = 3;    
        
    otherwise
        SP2_Logger.log('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME);
        return
end

% if isfield(acqp,'saveSeparately')        % note the string-to-numeric conversion
%     dataSpecX.saveSep = strcmp(acqp.saveSeparately,'y'); 
% else
%     dataSpecX.saveSep = 0;      % default: off 
% end


% if isfield(acqp,'pscopt')
%     dataSpecX.nr = acqpopt;

% if isfield(acqp,'nexForUnacquiredEncodes')
%     dataSpecX.nref = acqp.nexForUnacquiredEncodes;
% else
%     dataSpecX.nref = 0;
% end
if isfield(acqp,'DECIM')
    dataSpecX.decim = acqp.DECIM;
else
    dataSpecX.decim = 1;
end
if isfield(acqp,'DSPFVS')
    dataSpecX.dspfvs = acqp.DSPFVS;
else
    dataSpecX.dspfvs = 1;
end


% if isfield(acqp,'NI')
%     dataSpecX.nv = acqp.NI;
% else
%     dataSpecX.nv = 1;
% end
if isfield(acqp,'SFO1')
    dataSpecX.sf = acqp.SFO1;                 % Larmor frequency in MHz
end

if isfield(acqp,'tof')
    dataSpecX.offset   = acqp.tof;                       % frequency offset in Hz
else
    dataSpecX.offset   = 0;                                 % frequency offset in Hz
end
if isfield(acqp,'SW_h')                                                         % 
    dataSpecX.sw_h  = acqp.SW_h;  % sweep width in Hz
    dataSpecX.dwell = 1/acqp.SW_h;               % orig: [ns]
    dataSpecX.sw    = dataSpecX.sw_h/dataSpecX.sf;         % sweep width in Hz
else
    dataSpecX.sw_h  = 0;
    dataSpecX.sw    = 0;
    dataSpecX.dwell = 0;
end
% if isfield(acqp.series,'prtcl')
%     dataSpecX.pp = acqp.series.prtcl;
% else
%     dataSpecX.pp = '';
% end


if isfield(acqp,'ACQ_word_size')                                 % number of bytes
    dataSpecX.wordSize = acqp.ACQ_word_size;
else
    dataSpecX.wordSize = '';
end
if isfield(acqp,'BYTORDA')                                             % data format
    dataSpecX.byteOrder = acqp.BYTORDA;
else                                                                % 2 bytes
    dataSpecX.byteOrder = '';
end


if isfield(method,'PVM_RepetitionTime')
    dataSpecX.tr = method.PVM_RepetitionTime;            % orig: [us]
else
    dataSpecX.tr = 0;
end
if isfield(method,'PVM_EchoTime1') && isfield(method,'PVM_EchoTime2') && ...
   strcmp(dataSpecX.sequence,'ragPT.ppg');      % e.g. ragPT.ppg
    dataSpecX.te = method.PVM_EchoTime1 + method.PVM_EchoTime2;   % orig: [us]
elseif isfield(method,'PVM_EchoTime')                                   % regular case
    dataSpecX.te = method.PVM_EchoTime;           % orig: [us]
else
    dataSpecX.te = 0;
end
if isfield(method,'StTM')
    dataSpecX.tm = method.StTM;                  % orig: [ms]
else
    dataSpecX.tm = 0;
end
if isfield(method,'PVM_VoxArrPosition')
    if length(method.PVM_VoxArrPosition)==3
        dataSpecX.pos(1) = method.PVM_VoxArrPosition(1);
        dataSpecX.pos(2) = method.PVM_VoxArrPosition(2);
        dataSpecX.pos(3) = method.PVM_VoxArrPosition(3);
    else
        dataSpecX.pos(1) = 0;
        dataSpecX.pos(2) = 0;
        dataSpecX.pos(3) = 0;
    end
else
    dataSpecX.pos(1) = 0;
    dataSpecX.pos(2) = 0;
    dataSpecX.pos(3) = 0;
end
if isfield(method,'PVM_VoxArrSize')
    if length(method.PVM_VoxArrSize)==3
        dataSpecX.vox(1) = method.PVM_VoxArrSize(1);
        dataSpecX.vox(2) = method.PVM_VoxArrSize(2);
        dataSpecX.vox(3) = method.PVM_VoxArrSize(3);
    else
        dataSpecX.vox(1) = 0;
        dataSpecX.vox(2) = 0;
        dataSpecX.vox(3) = 0;
    end
else
    dataSpecX.vox(1) = 0;
    dataSpecX.vox(2) = 0;
    dataSpecX.vox(3) = 0;
end
% if isfield(acqp,'DeviceSerialNumber')
%     dataSpecX.devSerial = acqp.DeviceSerialNumber;
% else
%     dataSpecX.devSerial = 0;
% end
% if isfield(acqp,'ModelName')
%     dataSpecX.gcoil = acqp.ModelName;
% else
%     dataSpecX.gcoil = 0;
% end

% if isfield(acqp,'gcoil')
%     dataSpecX.gradSys = acqp.gcoil;
% else
%     dataSpecX.gradSys = '';
% end


%--- RF 1 ---
if isfield(method,'VoxPul1Enum')
    dataSpecX.rf1.shape   = method.VoxPul1Enum;
else
    dataSpecX.rf1.shape   = '';
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1)
        dataSpecX.rf1.dur = str2num(method.VoxPul1{1});
    else
        dataSpecX.rf1.dur = 0;
    end
else
    dataSpecX.rf1.dur     = 0;
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1) && length(method.VoxPul1)>10
        dataSpecX.rf1.power = str2num(method.VoxPul1{11});
    else
        dataSpecX.rf1.power = 0;
    end
else
    dataSpecX.rf1.power     = 0;
end
if isfield(method,'VoxPul1')            % not clear 
    if iscell(method.VoxPul1) && length(method.VoxPul1)>8
        dataSpecX.rf1.offset = str2num(method.VoxPul1{9});
    else
        dataSpecX.rf1.offset = 0;
    end
else
    dataSpecX.rf1.offset     = 0;
end
dataSpecX.rf1.method  = '';
dataSpecX.rf1.applied = 'y';

%--- RF 2 ---
if isfield(method,'VoxPul2Enum')
    dataSpecX.rf2.shape   = method.VoxPul2Enum;
else
    dataSpecX.rf2.shape   = '';
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2)
        dataSpecX.rf2.dur = str2num(method.VoxPul2{1});
    else
        dataSpecX.rf2.dur     = 0;
    end
else
    dataSpecX.rf2.dur     = 0;
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2) && length(method.VoxPul2)>10
        dataSpecX.rf2.power = str2num(method.VoxPul2{11});
    else
        dataSpecX.rf2.power = 0;
    end
else
    dataSpecX.rf2.power     = 0;
end
if isfield(method,'VoxPul2')            % not clear 
    if iscell(method.VoxPul2) && length(method.VoxPul2)>8
        dataSpecX.rf2.offset = str2num(method.VoxPul2{9});
    else
        dataSpecX.rf2.offset = 0;
    end
else
    dataSpecX.rf2.offset     = 0;
end
dataSpecX.rf2.method  = '';
dataSpecX.rf2.applied = 'y';

%--- water suppression ---
if isfield(acqp,'WSpat')
    dataSpecX.ws.shape = acqp.WSpat;
else
    dataSpecX.ws.shape = '';
end
if isfield(acqp,'pWS')
    dataSpecX.ws.dur   = acqp.pWS/1000;
else
    dataSpecX.ws.dur   = 0;
end
if isfield(acqp,'tpwrWS')
    dataSpecX.ws.power    = acqp.tpwrWS;
else
    dataSpecX.ws.power    = 0;
end
if isfield(acqp,'WSOffset')
    dataSpecX.ws.offset   = acqp.WSOffset;
else
    dataSpecX.ws.offset   = 0;
end
if isfield(acqp,'WSModule')
    dataSpecX.ws.method   = acqp.WSModule;
end
if isfield(acqp,'WS')
    dataSpecX.ws.applied  = acqp.WS;
end

%--- JDE ---
if isfield(method,'JDEPul1')
    if iscell(method.JDEPul1) && ~isempty(method.JDEPul1)
        dataSpecX.jde.dur = str2num(method.JDEPul1{1});
    else
        dataSpecX.jde.dur = 0;
    end
else
    dataSpecX.jde.dur     = 0;
end
if isfield(method,'JDEPul1')
    if length(method.JDEPul1)>10
        dataSpecX.jde.power = str2num(method.JDEPul1{11});
    else
        dataSpecX.jde.power = 0;
    end
else
    dataSpecX.jde.power     = 0;
end
if isfield(method,'JDEFrequency1')
    dataSpecX.jde.offset1 = method.JDEFrequency1;
else
    dataSpecX.jde.offset1 = 0;
end
if isfield(method,'JDEFrequency2')
    dataSpecX.jde.offset2 = method.JDEFrequency2;
else
    dataSpecX.jde.offset2 = 0;
end
dataSpecX.jde.method = '';
if isfield(method,'JDEOnOff')
    if strcmp(method.JDEOnOff,'On')
        dataSpecX.jde.applied = 'y';
        if isfield(method,'JDEFrequency1') && isfield(method,'JDEFrequency2')
            dataSpecX.jde.offset = {method.JDEFrequency1, method.JDEFrequency2};
        else
            dataSpecX.jde.offset   = '';
        end
        if isfield(method,'JDEPul1Enum') && isfield(method,'JDEPul2Enum')
            dataSpecX.jde.shape = {method.JDEPul1Enum, method.JDEPul2Enum};
        else
            dataSpecX.jde.shape   = '';
        end
    else
        dataSpecX.jde.applied = '';
        dataSpecX.jde.offset  = '';
        dataSpecX.jde.shape   = '';
    end
else
    dataSpecX.jde.applied = '';
    dataSpecX.jde.offset  = '';
    dataSpecX.jde.shape   = '';
end
dataSpecX.t2Series = 0;         % global init (potential later update)
if strcmp(dataSpecX.jde.applied,'y')
    if isfield(acqp,'t2TeExtra')
        if iscell(acqp.t2TeExtra)
            dataSpecX.t2TeExtra = cell2mat(acqp.t2TeExtra)*1000;
        else
            dataSpecX.t2TeExtra = acqp.t2TeExtra*1000;
        end
    else
        dataSpecX.t2TeExtra = 0;
    end
    dataSpecX.t2TeN = length(dataSpecX.t2TeExtra);
    if dataSpecX.t2TeN>1       % update T2 series flag
        dataSpecX.t2Series = 1;
    end
    if isfield(acqp,'t2TeExtraBal')
        if iscell(acqp.t2TeExtraBal)
            dataSpecX.t2TeExtraBal = cell2mat(acqp.t2TeExtraBal)*1000;
        else
            dataSpecX.t2TeExtraBal = acqp.t2TeExtraBal*1000;
        end
    else
        dataSpecX.t2TeExtraBal = 0;
    end
    if isfield(acqp,'t2DS')
        if iscell(acqp.t2DS)
            dataSpecX.t2DS = cell2mat(acqp.t2DS);
        else
            dataSpecX.t2DS = acqp.t2DS;
        end
    else
        dataSpecX.t2DS = 0;
    end
    if isfield(acqp,'T2offset')
        if iscell(acqp.T2offset)
            dataSpecX.T2offset = cell2mat(acqp.T2offset);
        else
            dataSpecX.T2offset = acqp.T2offset;
        end
    else
        dataSpecX.T2offset = 0;
    end
    if isfield(acqp,'T2offsetVal')
        if iscell(acqp.T2offsetVal)
            dataSpecX.T2offsetVal = cell2mat(acqp.T2offsetVal);
        else
            dataSpecX.T2offsetVal = acqp.T2offsetVal;
        end
    else
        dataSpecX.T2offsetVal = 0;
    end
    if isfield(acqp,'applT2offset')
        dataSpecX.applT2offset = acqp.applT2offset;
    else
        dataSpecX.applT2offset = 0;
    end
end

%--- inversion ---
if isfield(acqp,'p2pat')
    dataSpecX.inv.shape = acqp.p2pat;
else
    dataSpecX.inv.shape = '';
end
if isfield(acqp,'p2pat')
    dataSpecX.inv.dur   = acqp.p2/1000;
else
    dataSpecX.inv.dur   = 0;
end
if isfield(acqp,'p2pat')
    dataSpecX.inv.power = acqp.tpwr2;
else
    dataSpecX.inv.power = 0;
end
if isfield(acqp,'TIoffset')
    dataSpecX.inv.offset = acqp.TIoffset;
else
    dataSpecX.inv.offset = 0;
end
if isfield(acqp,'TI')
    dataSpecX.inv.ti = acqp.TI;              % orig [ms]
else
    dataSpecX.inv.ti = 0;
end
dataSpecX.inv.method = '';
if isfield(acqp,'Inversion')
    dataSpecX.inv.applied = acqp.Inversion;
else
    dataSpecX.inv.applied = '';
end

%--- OVS ---
if isfield(acqp,'OVS')
    dataSpecX.ovs.applied = acqp.OVS;
else
    dataSpecX.ovs.applied = '';
end
if isfield(acqp,'OVSmode')
    dataSpecX.ovs.mode = acqp.OVSmode;
else
    dataSpecX.ovs.mode = '';
end
if isfield(acqp,'OVSInterl')
    dataSpecX.ovs.interleaved = acqp.OVSInterl;
else
    dataSpecX.ovs.interleaved = '';
end
if isfield(acqp,'ovspat1')
    dataSpecX.ovs.shape = acqp.ovspat1;
else
    dataSpecX.ovs.shape = '';
end
if isfield(acqp,'ovsthk')
    dataSpecX.ovs.thk = acqp.ovsthk;
else
    dataSpecX.ovs.thk = '';
end
if isfield(acqp,'ovssep')
    dataSpecX.ovs.separation = acqp.ovssep;
else
    dataSpecX.ovs.separation = '';
end
if isfield(acqp,'ovsGlobOffset')
    dataSpecX.ovs.offset = acqp.ovsGlobOffset;
else
    dataSpecX.ovs.offset = '';
end
if isfield(acqp,'novs')
    dataSpecX.ovs.n = acqp.novs;
else
    dataSpecX.ovs.n = '';
end
if isfield(acqp,'povs1')
    dataSpecX.ovs.dur = acqp.povs1/1000;
else
    dataSpecX.ovs.dur = '';
end
if isfield(acqp,'tpwrovs1')
    dataSpecX.ovs.power = acqp.tpwrovs1;
else
    dataSpecX.ovs.power = '';
end
if isfield(acqp,'tpwrovsVar1') && isfield(acqp,'tpwrovsVar2') && ...
   isfield(acqp,'tpwrovsVar3') && isfield(acqp,'tpwrovsVar4')
    dataSpecX.ovs.variation(1) = acqp.tpwrovsVar1;
    dataSpecX.ovs.variation(2) = acqp.tpwrovsVar2;
    dataSpecX.ovs.variation(3) = acqp.tpwrovsVar3;
    dataSpecX.ovs.variation(4) = acqp.tpwrovsVar4;
else
    dataSpecX.ovs.power = '';
end
% if isfield(acqp,'mrsiAver')
%     dataSpecX.mrsi.aver = acqp.mrsiAver;
% end
% if isfield(acqp,'nvMrsi')
%     dataSpecX.mrsi.nEnc = acqp.nvMrsi;
% end
% if isfield(acqp,'nvR')
%     dataSpecX.mrsi.nEncR = acqp.nvR;
% end
% if isfield(acqp,'nvP')
%     dataSpecX.mrsi.nEncP = acqp.nvP;
% end
% if isfield(acqp,'nvS')
%     dataSpecX.mrsi.nEncS = acqp.nvS;
% end
% if isfield(acqp,'nvR') && isfield(acqp,'nvP')
%     dataSpecX.mrsi.mat = [acqp.nvR acqp.nvP];
% end
% if isfield(acqp,'lro_mrsi') && isfield(acqp,'lpe_mrsi')
%     dataSpecX.mrsi.fov = 10*[acqp.lro_mrsi acqp.lpe_mrsi];
% end
% if isfield(acqp,'mrsiDurSec')
%     dataSpecX.mrsi.durSec = acqp.mrsiDurSec;
% end
% if isfield(acqp,'mrsiDurMin')
%     dataSpecX.mrsi.durMin = acqp.mrsiDurMin;
% end
% if isfield(acqp,'TMrsiEnc')
%     dataSpecX.mrsi.tEnc = acqp.TMrsiEnc;
% end
% if isfield(acqp,'mrsiEncR')
%     dataSpecX.mrsi.encFileR = acqp.mrsiEncR;
% end
% if isfield(acqp,'mrsiEncP')
%     dataSpecX.mrsi.encFileP = acqp.mrsiEncP;
% end
% if isfield(acqp,'mrsiEncS')
%     dataSpecX.mrsi.encFileS = acqp.mrsiEncS;
% end
% if isfield(acqp,'mrsiTableR')
%     dataSpecX.mrsi.encTableR = acqp.mrsiTableR;
% end
% if isfield(acqp,'mrsiTableP')
%     dataSpecX.mrsi.encTableP = acqp.mrsiTableP;
% end
% if isfield(acqp,'mrsiTableS')
%     dataSpecX.mrsi.encTableS = acqp.mrsiTableS;
% end

if isfield(acqp,'shim0')
    dataSpecX.z0 = acqp.shim0;
else
    dataSpecX.z0 = 0;
end
dataSpecX.yz      = 0;
dataSpecX.xy      = 0;
dataSpecX.x2y2    = 0;
if isfield(acqp,'shim1')
    dataSpecX.x1 = acqp.shim1;
else
    dataSpecX.x1 = 0;
end
dataSpecX.x3      = 0;
if isfield(acqp,'shim3')
    dataSpecX.y1 = acqp.shim3;
else
    dataSpecX.y1 = 0;
end
dataSpecX.xz      = 0;
dataSpecX.xz2     = 0;
dataSpecX.y3      = 0;
if isfield(acqp,'shim2')
    dataSpecX.z1c = acqp.shim2;
else
    dataSpecX.z1c = 0;
end
dataSpecX.yz2     = 0;
dataSpecX.z2c     = 0;
dataSpecX.z5      = 0;
dataSpecX.z3c     = 0;
dataSpecX.z4c     = 0;
dataSpecX.zx2y2   = 0;
dataSpecX.zxy     = 0;
% if isfield(acqp,'Gslice1')
%     dataSpecX.Gslice1 = acqp.Gslice1;
% end
% if isfield(acqp,'Gslice1ref')
%     dataSpecX.Gslice1ref = acqp.Gslice1ref;
% end
% if isfield(acqp,'Gslice2')
%     dataSpecX.Gslice2 = acqp.Gslice2;
% end
% if isfield(acqp,'Gslice3')
%     dataSpecX.Gslice3 = acqp.Gslice3;
% end
% if isfield(acqp,'TxFreqExc')
%     dataSpecX.txFreqExc = acqp.TxFreqExc;
% end
% if isfield(acqp,'TxFreqRef1')
%     dataSpecX.txFreqRef1 = acqp.TxFreqRef1;
% end
% if isfield(acqp,'TxFreqRef2')
%     dataSpecX.txFreqRef2 = acqp.TxFreqRef2;
% end

%--- Bruker data format ---
if isfield(acqp,'ACQ_ReceiverSelect')
    dataflags.dataBrukerNewOld = 1;
    if strcmp(dataSpecX.fidName,'fid')
        dataflags.dataBrukerFormat = 2;      % new fid format
    else
        dataflags.dataBrukerFormat = 3;      % new rawdata.job0 format
    end
else
    dataflags.dataBrukerNewOld = 0;          % old format
    dataflags.dataBrukerFormat = 1;          % old -> fid (only)
end
% note dataflags.dataBrukerFormat definition:
% 1: old, potential multi-dimensional <fid>, 2: new, single FID in fid file, 3: new, rawdata.job0

if dataflags.dataBrukerFormat==1             % old, fid (might need updating)
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            dataSpecX.nRcvrs = 1;
        else                                            % multiple effective receivers
            dataSpecX.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            dataSpecX.acqpRcvrSelect = 1;
            % dataSpecX.nRcvrs = 1;
        else                                            % multiple receivers
            dataSpecX.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % dataSpecX.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        dataSpecX.acqpRcvrSelect = 1;
        % dataSpecX.nRcvrs = 1;
    end
    if isfield(method,'PVM_NRepetitions')
        dataSpecX.nr = method.PVM_NRepetitions;
    else
        dataSpecX.nr = 1;
    end
    if isfield(method,'PVM_NAverages')
        dataSpecX.na = method.PVM_NAverages;
    else
        dataSpecX.na = 1;
    end
elseif dataflags.dataBrukerFormat==2         % new, fid
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            dataSpecX.nRcvrs = 1;
        else                                            % multiple effective receivers
            dataSpecX.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            dataSpecX.acqpRcvrSelect = 1;
            % dataSpecX.nRcvrs = 1;
        else                                            % multiple receivers
            dataSpecX.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % dataSpecX.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        dataSpecX.acqpRcvrSelect = 1;
        % dataSpecX.nRcvrs = 1;
    end
    if isfield(method,'PVM_NAverages')
        dataSpecX.na = method.PVM_NAverages;
    else
        dataSpecX.na = 1;
    end
    % dataSpecX.nr = 1;           % collapsed
    if isfield(method,'PVM_NRepetitions')
        dataSpecX.nr = method.PVM_NRepetitions;
    else
        dataSpecX.nr = 1;
    end
else                                    % new, rawdata.job0
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            dataSpecX.nRcvrs = 1;
        else                                            % multiple effective receivers
            dataSpecX.nRcvrs = method.PVM_EncNReceivers;
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            dataSpecX.acqpRcvrSelect = 1;
            % dataSpecX.nRcvrs = 1;
        else                                            % multiple receivers
            dataSpecX.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,'Yes');
            % dataSpecX.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);
            % fixed for Merck data (Corey Miller, 12/2021) since length()
            % effectively considers 0's (i.e. 'No') as valid entries, i.e.
            % disabled coil elements are misinterpreted as active coils
            % dataSpecX.nRcvrs = sum(data.spec' num2str(nData) '.acqpRcvrSelect);
        end
    else
        % assume 1 receiver
        dataSpecX.acqpRcvrSelect = 1;
        % dataSpecX.nRcvrs = 1;
    end
    if dataflags.dataExpType==1              % regular MRS
        % RAG's STEAM sequence
        if strcmp(dataSpecX.sequence,'ragSTEAM.ppg') && ...
           isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
         
            dataSpecX.nr = method.PVM_NAverages*method.PVM_NRepetitions;      
            if dataflags.verbose
                SP2_Logger.log('ragSTEAM:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions);
                if isfield(method,'IsisNAverages')
                    SP2_Logger.log('IsisNAverages    = %.0f\n',method.IsisNAverages);
                end
            end
            dataSpecX.na = 1;
        elseif strcmp(dataSpecX.sequence,'ragPT.ppg') && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % RAG's polarization transfer (ISIS) sequence
            dataSpecX.nr = method.PVM_NRepetitions*method.IsisNAverages;      
            if verbose
                SP2_Logger.log('ragPT:\n');
                SP2_Logger.log('PVM_NAverages    = %.0f\n',method.PVM_NAverages);
                SP2_Logger.log('PVM_NRepetitions = %.0f\n',method.PVM_NRepetitions);
                SP2_Logger.log('IsisNAverages    = %.0f\n',method.IsisNAverages);
            end
            dataSpecX.na = 1;
        elseif strcmp(dataSpecX.sequence,'ISIS.ppg') && ...
               strcmp(method.Method,'Bruker:ISIS') && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % Bruker's ISIS sequence
            dataSpecX.nr = method.IsisNAverages;      
            if verbose
                SP2_Logger.log('Bruker ISIS:\n');
                SP2_Logger.log('PVM_NAverages     = %.0f\n',method.PVM_NAverages);
                SP2_Logger.log('PVM_NRepetitions  = %.0f\n',method.PVM_NRepetitions);
                SP2_Logger.log('IsisNAverages     = %.0f\n',method.IsisNAverages);
            end
            dataSpecX.na = 1;
        else                    % regular case
            % e.g. including regular Bruker PRESS
            if nData==2 && dataflags.dataIdentScan && strcmp(method.PVM_RefScanYN,'Yes')
                if isfield(method,'PVM_NRepetitions')
                    dataSpecX.nr = method.PVM_RefScanNA;        % note the NA <=> NR flip since data is saved separately
                else
                    dataSpecX.nr = 1;
                end
                if isfield(method,'PVM_NAverages')
                    dataSpecX.na = method.PVM_NRepetitions;     % note the NA <=> NR flip since data is saved separately
                else
                    dataSpecX.na = 1;
                end
            else        % all other cases, ie. data 1, regular (non-ref) data, etc
%                 if strcmp(acqp.ACQ_sw_version,'PV-360.1.1')      % although this should be the default rather than the exception
%                     % ShanghaiTech / Chao: PV-360.1.1
%                     if isfield(method,'PVM_NRepetitions')
%                         dataSpecX.nr = method.PVM_NRepetitions;     
%                     else
%                         dataSpecX.nr = 1;
%                     end
%                     if isfield(method,'PVM_NAverages')
%                         dataSpecX.na = method.PVM_NAverages;        
%                     else
%                         dataSpecX.na = 1;
%                     end    
%                 else
                    % Merck / Cory Miller: PV-360.2.0.pl.1
                    if isfield(method,'PVM_NRepetitions')
                        dataSpecX.nr = method.PVM_NAverages;        % note the NA <=> NR flip since data is saved separately
                    else
                        dataSpecX.nr = 1;
                    end
                    if isfield(method,'PVM_NAverages')
                        dataSpecX.na = method.PVM_NRepetitions;     % note the NA <=> NR flip since data is saved separately
                    else
                        dataSpecX.na = 1;
                    end    
%                 end
            end
        end
    elseif dataflags.dataExpType==3          % JDE
        if isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
            dataSpecX.nr = method.PVM_NAverages*method.PVM_NRepetitions;      
            if dataflags.verbose
                SP2_Logger.log('JDE:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions);
                if isfield(method,'IsisNAverages')
                    SP2_Logger.log('IsisNAverages    = %.0f\n',method.IsisNAverages);
                end
            end
        else
            dataSpecX.nr = 1;
        end
        if isfield(method,'PVM_NAverages')
            dataSpecX.na = 1;     
        else
            dataSpecX.na = 1;
        end
    else
        dataSpecX.nr = 0;           % default
        dataSpecX.na = 0;           % default
    end
end
if isfield(acqp,'InstanceTime')          % -> date vector
    dataSpecX.time_start = datevec(acqp.InstanceTime);
end
if isfield(acqp,'lScanTimeSec')
    dataSpecX.durSec = acqp.lScanTimeSec/1e6;
    dataSpecX.durMin = acqp.lScanTimeSec/6e8;
else
    dataSpecX.durSec = 0;
    dataSpecX.durMin = 0;
end
% if isfield(acqp,'time_complete')     % ISO 8601 -> date vector
%     dataSpecX.time_end = datevec(acqp.time_complete,'yyyymmddTHHMMSS');
% end

    
%--- institution / scanner ---
if isfield(acqp,'ACQ_institution')
    dataSpecX.institution = acqp.ACQ_institution;
else
    dataSpecX.institution = 'unknown';
end
if isfield(acqp,'ACQ_station')
    dataSpecX.system = acqp.ACQ_station;
else
    dataSpecX.system = 'unknown';
end
if isfield(acqp,'ACQ_sw_version')               % software version
    dataSpecX.software = acqp.ACQ_sw_version;
else
    dataSpecX.software = 'unknown';
end

%--- info printout ---
dataSpecX.institution;
% if strcmp(dataSpecX.system,'Medspec S400 AVIIIHD')
%     dataSpecX.system;
% else
%     dataSpecX.system;
% end
dataSpecX.software;
dataSpecX.protocolName;
dataSpecX.scanName;

dataSpec = dataSpecX

updatedflags = dataflags;

%--- update success flag ---
f_succ = 1;

