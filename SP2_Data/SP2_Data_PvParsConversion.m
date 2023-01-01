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

global data flag

FCTNAME = 'SP2_Data_PvParsConversion';


%--- init success flag ---
f_succ = 0;

%--- parameter transfer to 'method' struct ---
if isfield(acqp,'PULPROG')
    eval(['data.spec' num2str(nData) '.sequence = acqp.PULPROG;'])
else
    eval(['data.spec' num2str(nData) '.sequence = '''';'])
end
if isfield(acqp,'ACQ_protocol_name')
    eval(['data.spec' num2str(nData) '.protocolName = acqp.ACQ_protocol_name;'])
else
    eval(['data.spec' num2str(nData) '.protocolName = '''';'])
end
if isfield(acqp,'ACQ_scan_name')
    eval(['data.spec' num2str(nData) '.scanName = acqp.ACQ_scan_name;'])
else
    eval(['data.spec' num2str(nData) '.scanName = '''';'])
end

% if any(strfind(data.spec1.sequence,'JDE')) || any(strfind(data.spec1.sequence,'Jde')) || any(strfind(data.spec1.sequence,'jde'))
%     if isfield(acqp,'seqtype')
%         if strcmp(acqp.seqtype,'2x180')
%             eval(['data.spec' num2str(nData) '.seqtype = ''PRESS'';'])
%         elseif strcmp(acqp.seqtype,'4x180')
%             eval(['data.spec' num2str(nData) '.seqtype = ''sLASER'';'])
%         else        % unknown
            eval(['data.spec' num2str(nData) '.seqtype = '''';'])
%         end
%     end
% end

if isfield(method,'PVM_SpecMatrix')
    eval(['data.spec' num2str(nData) '.nspecC   = method.PVM_SpecMatrix;'])
elseif isfield(acqp,'ACQ_size')
    eval(['data.spec' num2str(nData) '.nspecC   = acqp.ACQ_size(1)/2;'])
else
    fprintf('%s ->\nFID length not found in parameter file(s). Program aborted.\n',FCTNAME)
    return
end
if isfield(method,'Y_Mode') && isfield(method,'Y_CsiListSize')
    if method.Y_CsiListSize==0
        eval(['data.spec' num2str(nData) '.nx = 1;'])
    else
        eval(['data.spec' num2str(nData) '.nx = method.Y_CsiListSize;'])
    end
    eval(['data.spec' num2str(nData) '.ny       = 1;'])
    eval(['data.spec' num2str(nData) '.nz       = 1;'])
else
    eval(['data.spec' num2str(nData) '.nx       = 1;'])
    eval(['data.spec' num2str(nData) '.ny       = 1;'])
    eval(['data.spec' num2str(nData) '.nz       = 1;'])
end
if isfield(acqp,'NSLICES')
    eval(['data.spec' num2str(nData) '.ns   = acqp.NSLICES;'])
else
    eval(['data.spec' num2str(nData) '.ns   = 1;'])
end
if isfield(acqp,'RG')
    eval(['data.spec' num2str(nData) '.gain = acqp.RG;'])    
else
    eval(['data.spec' num2str(nData) '.gain = 0;'])
end
if isfield(acqp,'NI')
    eval(['data.spec' num2str(nData) '.ni = acqp.NI;'])    
else
    eval(['data.spec' num2str(nData) '.ni = 1;'])
end

%--- njde ---
switch flag.dataExpType
    case 1                      % regular data format
        eval(['data.spec' num2str(nData) '.njde = 1;'])
        
    case 2                      % saturation-recovery series
        eval(['data.spec' num2str(nData) '.njde = 1;'])
        
    case 3                      % JDE
        eval(['data.spec' num2str(nData) '.njde = 2;'])
        
    case 4                      % stability analysis
        eval(['data.spec' num2str(nData) '.njde = 1;'])
        
    case 5                      % T1/T2 series'
        eval(['data.spec' num2str(nData) '.njde = 1;'])
        
    case 6                      % MRSI
        eval(['data.spec' num2str(nData) '.njde = 1;'])
        
    case 7                      % JDE array
        eval(['data.spec' num2str(nData) '.njde = 3;'])    
        
    otherwise
        fprintf('%s ->\nThis data mode is not supported. Program aborted.\n',FCTNAME)
        return
end

% if isfield(acqp,'saveSeparately')        % note the string-to-numeric conversion
%     eval(['data.spec' num2str(nData) '.saveSep = strcmp(acqp.saveSeparately,''y'');']) 
% else
%     eval(['data.spec' num2str(nData) '.saveSep = 0;'])      % default: off 
% end


% if isfield(acqp,'pscopt')
%     eval(['data.spec' num2str(nData) '.nr = acqpopt;'])

% if isfield(acqp,'nexForUnacquiredEncodes')
%     eval(['data.spec' num2str(nData) '.nref = acqp.nexForUnacquiredEncodes;'])
% else
%     eval(['data.spec' num2str(nData) '.nref = 0;'])
% end
if isfield(acqp,'DECIM')
    eval(['data.spec' num2str(nData) '.decim = acqp.DECIM;'])
else
    eval(['data.spec' num2str(nData) '.decim = 1;'])
end
if isfield(acqp,'DSPFVS')
    eval(['data.spec' num2str(nData) '.dspfvs = acqp.DSPFVS;'])
else
    eval(['data.spec' num2str(nData) '.dspfvs = 1;'])
end


% if isfield(acqp,'NI')
%     eval(['data.spec' num2str(nData) '.nv = acqp.NI;'])
% else
%     eval(['data.spec' num2str(nData) '.nv = 1;'])
% end
if isfield(acqp,'SFO1')
    eval(['data.spec' num2str(nData) '.sf = acqp.SFO1;'])                 % Larmor frequency in MHz
end

if isfield(acqp,'tof')
    eval(['data.spec' num2str(nData) '.offset   = acqp.tof;'])                       % frequency offset in Hz
else
    eval(['data.spec' num2str(nData) '.offset   = 0;'])                                 % frequency offset in Hz
end
if isfield(acqp,'SW_h')                                                         % 
    eval(['data.spec' num2str(nData) '.sw_h  = acqp.SW_h;'])  % sweep width in Hz
    eval(['data.spec' num2str(nData) '.dwell = 1/acqp.SW_h;'])               % orig: [ns]
    eval(['data.spec' num2str(nData) '.sw    = data.spec' num2str(nData) '.sw_h/data.spec' num2str(nData) '.sf;'])         % sweep width in Hz
else
    eval(['data.spec' num2str(nData) '.sw_h  = 0;'])
    eval(['data.spec' num2str(nData) '.sw    = 0;'])
    eval(['data.spec' num2str(nData) '.dwell = 0;'])
end
% if isfield(acqp.series,'prtcl')
%     eval(['data.spec' num2str(nData) '.pp = acqp.series.prtcl;'])
% else
%     eval(['data.spec' num2str(nData) '.pp = '''';'])
% end


if isfield(acqp,'ACQ_word_size')                                 % number of bytes
    eval(['data.spec' num2str(nData) '.wordSize = acqp.ACQ_word_size;'])
else
    eval(['data.spec' num2str(nData) '.wordSize = '''';'])
end
if isfield(acqp,'BYTORDA')                                             % data format
    eval(['data.spec' num2str(nData) '.byteOrder = acqp.BYTORDA;'])
else                                                                % 2 bytes
    eval(['data.spec' num2str(nData) '.byteOrder = '''';'])
end


if isfield(method,'PVM_RepetitionTime')
    eval(['data.spec' num2str(nData) '.tr = method.PVM_RepetitionTime;'])            % orig: [us]
else
    eval(['data.spec' num2str(nData) '.tr = 0;'])
end
if isfield(method,'PVM_EchoTime1') && isfield(method,'PVM_EchoTime2') && ...
   eval(['strcmp(data.spec' num2str(nData) '.sequence,''ragPT.ppg'');'])      % e.g. ragPT.ppg
    eval(['data.spec' num2str(nData) '.te = method.PVM_EchoTime1 + method.PVM_EchoTime2;'])   % orig: [us]
elseif isfield(method,'PVM_EchoTime')                                   % regular case
    eval(['data.spec' num2str(nData) '.te = method.PVM_EchoTime;'])           % orig: [us]
else
    eval(['data.spec' num2str(nData) '.te = 0;'])
end
if isfield(method,'StTM')
    eval(['data.spec' num2str(nData) '.tm = method.StTM;'])                  % orig: [ms]
else
    eval(['data.spec' num2str(nData) '.tm = 0;'])
end
if isfield(method,'PVM_VoxArrPosition')
    if length(method.PVM_VoxArrPosition)==3
        eval(['data.spec' num2str(nData) '.pos(1) = method.PVM_VoxArrPosition(1);'])
        eval(['data.spec' num2str(nData) '.pos(2) = method.PVM_VoxArrPosition(2);'])
        eval(['data.spec' num2str(nData) '.pos(3) = method.PVM_VoxArrPosition(3);'])
    else
        eval(['data.spec' num2str(nData) '.pos(1) = 0;'])
        eval(['data.spec' num2str(nData) '.pos(2) = 0;'])
        eval(['data.spec' num2str(nData) '.pos(3) = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.pos(1) = 0;'])
    eval(['data.spec' num2str(nData) '.pos(2) = 0;'])
    eval(['data.spec' num2str(nData) '.pos(3) = 0;'])
end
if isfield(method,'PVM_VoxArrSize')
    if length(method.PVM_VoxArrSize)==3
        eval(['data.spec' num2str(nData) '.vox(1) = method.PVM_VoxArrSize(1);'])
        eval(['data.spec' num2str(nData) '.vox(2) = method.PVM_VoxArrSize(2);'])
        eval(['data.spec' num2str(nData) '.vox(3) = method.PVM_VoxArrSize(3);'])
    else
        eval(['data.spec' num2str(nData) '.vox(1) = 0;'])
        eval(['data.spec' num2str(nData) '.vox(2) = 0;'])
        eval(['data.spec' num2str(nData) '.vox(3) = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.vox(1) = 0;'])
    eval(['data.spec' num2str(nData) '.vox(2) = 0;'])
    eval(['data.spec' num2str(nData) '.vox(3) = 0;'])
end
% if isfield(acqp,'DeviceSerialNumber')
%     eval(['data.spec' num2str(nData) '.devSerial = acqp.DeviceSerialNumber;'])
% else
%     eval(['data.spec' num2str(nData) '.devSerial = 0;'])
% end
% if isfield(acqp,'ModelName')
%     eval(['data.spec' num2str(nData) '.gcoil = acqp.ModelName;'])
% else
%     eval(['data.spec' num2str(nData) '.gcoil = 0;'])
% end

% if isfield(acqp,'gcoil')
%     eval(['data.spec' num2str(nData) '.gradSys = acqp.gcoil;'])
% else
%     eval(['data.spec' num2str(nData) '.gradSys = '''';'])
% end


%--- RF 1 ---
if isfield(method,'VoxPul1Enum')
    eval(['data.spec' num2str(nData) '.rf1.shape   = method.VoxPul1Enum;'])
else
    eval(['data.spec' num2str(nData) '.rf1.shape   = '''';'])
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1)
        eval(['data.spec' num2str(nData) '.rf1.dur = str2num(method.VoxPul1{1});'])
    else
        eval(['data.spec' num2str(nData) '.rf1.dur = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf1.dur     = 0;'])
end
if isfield(method,'VoxPul1')
    if iscell(method.VoxPul1) && length(method.VoxPul1)>10
        eval(['data.spec' num2str(nData) '.rf1.power = str2num(method.VoxPul1{11});'])
    else
        eval(['data.spec' num2str(nData) '.rf1.power = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf1.power     = 0;'])
end
if isfield(method,'VoxPul1')            % not clear 
    if iscell(method.VoxPul1) && length(method.VoxPul1)>8
        eval(['data.spec' num2str(nData) '.rf1.offset = str2num(method.VoxPul1{9});'])
    else
        eval(['data.spec' num2str(nData) '.rf1.offset = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf1.offset     = 0;'])
end
eval(['data.spec' num2str(nData) '.rf1.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf1.applied = ''y'';'])

%--- RF 2 ---
if isfield(method,'VoxPul2Enum')
    eval(['data.spec' num2str(nData) '.rf2.shape   = method.VoxPul2Enum;'])
else
    eval(['data.spec' num2str(nData) '.rf2.shape   = '''';'])
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2)
        eval(['data.spec' num2str(nData) '.rf2.dur = str2num(method.VoxPul2{1});'])
    else
        eval(['data.spec' num2str(nData) '.rf2.dur     = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf2.dur     = 0;'])
end
if isfield(method,'VoxPul2')
    if iscell(method.VoxPul2) && length(method.VoxPul2)>10
        eval(['data.spec' num2str(nData) '.rf2.power = str2num(method.VoxPul2{11});'])
    else
        eval(['data.spec' num2str(nData) '.rf2.power = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf2.power     = 0;'])
end
if isfield(method,'VoxPul2')            % not clear 
    if iscell(method.VoxPul2) && length(method.VoxPul2)>8
        eval(['data.spec' num2str(nData) '.rf2.offset = str2num(method.VoxPul2{9});'])
    else
        eval(['data.spec' num2str(nData) '.rf2.offset = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.rf2.offset     = 0;'])
end
eval(['data.spec' num2str(nData) '.rf2.method  = '''';'])
eval(['data.spec' num2str(nData) '.rf2.applied = ''y'';'])

%--- water suppression ---
if isfield(acqp,'WSpat')
    eval(['data.spec' num2str(nData) '.ws.shape = acqp.WSpat;'])
else
    eval(['data.spec' num2str(nData) '.ws.shape = '''';'])
end
if isfield(acqp,'pWS')
    eval(['data.spec' num2str(nData) '.ws.dur   = acqp.pWS/1000;'])
else
    eval(['data.spec' num2str(nData) '.ws.dur   = 0;'])
end
if isfield(acqp,'tpwrWS')
    eval(['data.spec' num2str(nData) '.ws.power    = acqp.tpwrWS;'])
else
    eval(['data.spec' num2str(nData) '.ws.power    = 0;'])
end
if isfield(acqp,'WSOffset')
    eval(['data.spec' num2str(nData) '.ws.offset   = acqp.WSOffset;'])
else
    eval(['data.spec' num2str(nData) '.ws.offset   = 0;'])
end
if isfield(acqp,'WSModule')
    eval(['data.spec' num2str(nData) '.ws.method   = acqp.WSModule;'])
end
if isfield(acqp,'WS')
    eval(['data.spec' num2str(nData) '.ws.applied  = acqp.WS;'])
end

%--- JDE ---
if isfield(method,'JDEPul1')
    if iscell(method.JDEPul1) && ~isempty(method.JDEPul1)
        eval(['data.spec' num2str(nData) '.jde.dur = str2num(method.JDEPul1{1});'])
    else
        eval(['data.spec' num2str(nData) '.jde.dur = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.jde.dur     = 0;'])
end
if isfield(method,'JDEPul1')
    if length(method.JDEPul1)>10
        eval(['data.spec' num2str(nData) '.jde.power = str2num(method.JDEPul1{11});'])
    else
        eval(['data.spec' num2str(nData) '.jde.power = 0;'])
    end
else
    eval(['data.spec' num2str(nData) '.jde.power     = 0;'])
end
if isfield(method,'JDEFrequency1')
    eval(['data.spec' num2str(nData) '.jde.offset1 = method.JDEFrequency1;'])
else
    eval(['data.spec' num2str(nData) '.jde.offset1 = 0;'])
end
if isfield(method,'JDEFrequency2')
    eval(['data.spec' num2str(nData) '.jde.offset2 = method.JDEFrequency2;'])
else
    eval(['data.spec' num2str(nData) '.jde.offset2 = 0;'])
end
eval(['data.spec' num2str(nData) '.jde.method = '''';'])
if isfield(method,'JDEOnOff')
    if strcmp(method.JDEOnOff,'On')
        eval(['data.spec' num2str(nData) '.jde.applied = ''y'';'])
        if isfield(method,'JDEFrequency1') && isfield(method,'JDEFrequency2')
            eval(['data.spec' num2str(nData) '.jde.offset = {method.JDEFrequency1, method.JDEFrequency2};'])
        else
            eval(['data.spec' num2str(nData) '.jde.offset   = '''';'])
        end
        if isfield(method,'JDEPul1Enum') && isfield(method,'JDEPul2Enum')
            eval(['data.spec' num2str(nData) '.jde.shape = {method.JDEPul1Enum, method.JDEPul2Enum};'])
        else
            eval(['data.spec' num2str(nData) '.jde.shape   = '''';'])
        end
    else
        eval(['data.spec' num2str(nData) '.jde.applied = '''';'])
        eval(['data.spec' num2str(nData) '.jde.offset  = '''';'])
        eval(['data.spec' num2str(nData) '.jde.shape   = '''';'])
    end
else
    eval(['data.spec' num2str(nData) '.jde.applied = '''';'])
    eval(['data.spec' num2str(nData) '.jde.offset  = '''';'])
    eval(['data.spec' num2str(nData) '.jde.shape   = '''';'])
end
eval(['data.spec' num2str(nData) '.t2Series = 0;'])         % global init (potential later update)
if eval(['strcmp(data.spec' num2str(nData) '.jde.applied,''y'');'])
    if isfield(acqp,'t2TeExtra')
        if iscell(acqp.t2TeExtra)
            eval(['data.spec' num2str(nData) '.t2TeExtra = cell2mat(acqp.t2TeExtra)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtra = acqp.t2TeExtra*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtra = 0;'])
    end
    eval(['data.spec' num2str(nData) '.t2TeN = length(data.spec' num2str(nData) '.t2TeExtra);'])
    if eval(['data.spec' num2str(nData) '.t2TeN>1;'])       % update T2 series flag
        eval(['data.spec' num2str(nData) '.t2Series = 1;'])
    end
    if isfield(acqp,'t2TeExtraBal')
        if iscell(acqp.t2TeExtraBal)
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = cell2mat(acqp.t2TeExtraBal)*1000;'])
        else
            eval(['data.spec' num2str(nData) '.t2TeExtraBal = acqp.t2TeExtraBal*1000;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2TeExtraBal = 0;'])
    end
    if isfield(acqp,'t2DS')
        if iscell(acqp.t2DS)
            eval(['data.spec' num2str(nData) '.t2DS = cell2mat(acqp.t2DS);'])
        else
            eval(['data.spec' num2str(nData) '.t2DS = acqp.t2DS;'])
        end
    else
        eval(['data.spec' num2str(nData) '.t2DS = 0;'])
    end
    if isfield(acqp,'T2offset')
        if iscell(acqp.T2offset)
            eval(['data.spec' num2str(nData) '.T2offset = cell2mat(acqp.T2offset);'])
        else
            eval(['data.spec' num2str(nData) '.T2offset = acqp.T2offset;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offset = 0;'])
    end
    if isfield(acqp,'T2offsetVal')
        if iscell(acqp.T2offsetVal)
            eval(['data.spec' num2str(nData) '.T2offsetVal = cell2mat(acqp.T2offsetVal);'])
        else
            eval(['data.spec' num2str(nData) '.T2offsetVal = acqp.T2offsetVal;'])
        end
    else
        eval(['data.spec' num2str(nData) '.T2offsetVal = 0;'])
    end
    if isfield(acqp,'applT2offset')
        eval(['data.spec' num2str(nData) '.applT2offset = acqp.applT2offset;'])
    else
        eval(['data.spec' num2str(nData) '.applT2offset = 0;'])
    end
end

%--- inversion ---
if isfield(acqp,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.shape = acqp.p2pat;'])
else
    eval(['data.spec' num2str(nData) '.inv.shape = '''';'])
end
if isfield(acqp,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.dur   = acqp.p2/1000;'])
else
    eval(['data.spec' num2str(nData) '.inv.dur   = 0;'])
end
if isfield(acqp,'p2pat')
    eval(['data.spec' num2str(nData) '.inv.power = acqp.tpwr2;'])
else
    eval(['data.spec' num2str(nData) '.inv.power = 0;'])
end
if isfield(acqp,'TIoffset')
    eval(['data.spec' num2str(nData) '.inv.offset = acqp.TIoffset;'])
else
    eval(['data.spec' num2str(nData) '.inv.offset = 0;'])
end
if isfield(acqp,'TI')
    eval(['data.spec' num2str(nData) '.inv.ti = acqp.TI;'])              % orig [ms]
else
    eval(['data.spec' num2str(nData) '.inv.ti = 0;'])
end
eval(['data.spec' num2str(nData) '.inv.method = '''';'])
if isfield(acqp,'Inversion')
    eval(['data.spec' num2str(nData) '.inv.applied = acqp.Inversion;'])
else
    eval(['data.spec' num2str(nData) '.inv.applied = '''';'])
end

%--- OVS ---
if isfield(acqp,'OVS')
    eval(['data.spec' num2str(nData) '.ovs.applied = acqp.OVS;'])
else
    eval(['data.spec' num2str(nData) '.ovs.applied = '''';'])
end
if isfield(acqp,'OVSmode')
    eval(['data.spec' num2str(nData) '.ovs.mode = acqp.OVSmode;'])
else
    eval(['data.spec' num2str(nData) '.ovs.mode = '''';'])
end
if isfield(acqp,'OVSInterl')
    eval(['data.spec' num2str(nData) '.ovs.interleaved = acqp.OVSInterl;'])
else
    eval(['data.spec' num2str(nData) '.ovs.interleaved = '''';'])
end
if isfield(acqp,'ovspat1')
    eval(['data.spec' num2str(nData) '.ovs.shape = acqp.ovspat1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.shape = '''';'])
end
if isfield(acqp,'ovsthk')
    eval(['data.spec' num2str(nData) '.ovs.thk = acqp.ovsthk;'])
else
    eval(['data.spec' num2str(nData) '.ovs.thk = '''';'])
end
if isfield(acqp,'ovssep')
    eval(['data.spec' num2str(nData) '.ovs.separation = acqp.ovssep;'])
else
    eval(['data.spec' num2str(nData) '.ovs.separation = '''';'])
end
if isfield(acqp,'ovsGlobOffset')
    eval(['data.spec' num2str(nData) '.ovs.offset = acqp.ovsGlobOffset;'])
else
    eval(['data.spec' num2str(nData) '.ovs.offset = '''';'])
end
if isfield(acqp,'novs')
    eval(['data.spec' num2str(nData) '.ovs.n = acqp.novs;'])
else
    eval(['data.spec' num2str(nData) '.ovs.n = '''';'])
end
if isfield(acqp,'povs1')
    eval(['data.spec' num2str(nData) '.ovs.dur = acqp.povs1/1000;'])
else
    eval(['data.spec' num2str(nData) '.ovs.dur = '''';'])
end
if isfield(acqp,'tpwrovs1')
    eval(['data.spec' num2str(nData) '.ovs.power = acqp.tpwrovs1;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
if isfield(acqp,'tpwrovsVar1') && isfield(acqp,'tpwrovsVar2') && ...
   isfield(acqp,'tpwrovsVar3') && isfield(acqp,'tpwrovsVar4')
    eval(['data.spec' num2str(nData) '.ovs.variation(1) = acqp.tpwrovsVar1;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(2) = acqp.tpwrovsVar2;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(3) = acqp.tpwrovsVar3;'])
    eval(['data.spec' num2str(nData) '.ovs.variation(4) = acqp.tpwrovsVar4;'])
else
    eval(['data.spec' num2str(nData) '.ovs.power = '''';'])
end
% if isfield(acqp,'mrsiAver')
%     eval(['data.spec' num2str(nData) '.mrsi.aver = acqp.mrsiAver;'])
% end
% if isfield(acqp,'nvMrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.nEnc = acqp.nvMrsi;'])
% end
% if isfield(acqp,'nvR')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncR = acqp.nvR;'])
% end
% if isfield(acqp,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncP = acqp.nvP;'])
% end
% if isfield(acqp,'nvS')
%     eval(['data.spec' num2str(nData) '.mrsi.nEncS = acqp.nvS;'])
% end
% if isfield(acqp,'nvR') && isfield(acqp,'nvP')
%     eval(['data.spec' num2str(nData) '.mrsi.mat = [acqp.nvR acqp.nvP];'])
% end
% if isfield(acqp,'lro_mrsi') && isfield(acqp,'lpe_mrsi')
%     eval(['data.spec' num2str(nData) '.mrsi.fov = 10*[acqp.lro_mrsi acqp.lpe_mrsi];'])
% end
% if isfield(acqp,'mrsiDurSec')
%     eval(['data.spec' num2str(nData) '.mrsi.durSec = acqp.mrsiDurSec;'])
% end
% if isfield(acqp,'mrsiDurMin')
%     eval(['data.spec' num2str(nData) '.mrsi.durMin = acqp.mrsiDurMin;'])
% end
% if isfield(acqp,'TMrsiEnc')
%     eval(['data.spec' num2str(nData) '.mrsi.tEnc = acqp.TMrsiEnc;'])
% end
% if isfield(acqp,'mrsiEncR')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileR = acqp.mrsiEncR;'])
% end
% if isfield(acqp,'mrsiEncP')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileP = acqp.mrsiEncP;'])
% end
% if isfield(acqp,'mrsiEncS')
%     eval(['data.spec' num2str(nData) '.mrsi.encFileS = acqp.mrsiEncS;'])
% end
% if isfield(acqp,'mrsiTableR')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableR = acqp.mrsiTableR;'])
% end
% if isfield(acqp,'mrsiTableP')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableP = acqp.mrsiTableP;'])
% end
% if isfield(acqp,'mrsiTableS')
%     eval(['data.spec' num2str(nData) '.mrsi.encTableS = acqp.mrsiTableS;'])
% end

if isfield(acqp,'shim0')
    eval(['data.spec' num2str(nData) '.z0 = acqp.shim0;'])
else
    eval(['data.spec' num2str(nData) '.z0 = 0;'])
end
eval(['data.spec' num2str(nData) '.yz      = 0;'])
eval(['data.spec' num2str(nData) '.xy      = 0;'])
eval(['data.spec' num2str(nData) '.x2y2    = 0;'])
if isfield(acqp,'shim1')
    eval(['data.spec' num2str(nData) '.x1 = acqp.shim1;'])
else
    eval(['data.spec' num2str(nData) '.x1 = 0;'])
end
eval(['data.spec' num2str(nData) '.x3      = 0;'])
if isfield(acqp,'shim3')
    eval(['data.spec' num2str(nData) '.y1 = acqp.shim3;'])
else
    eval(['data.spec' num2str(nData) '.y1 = 0;'])
end
eval(['data.spec' num2str(nData) '.xz      = 0;'])
eval(['data.spec' num2str(nData) '.xz2     = 0;'])
eval(['data.spec' num2str(nData) '.y3      = 0;'])
if isfield(acqp,'shim2')
    eval(['data.spec' num2str(nData) '.z1c = acqp.shim2;'])
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
% if isfield(acqp,'Gslice1')
%     eval(['data.spec' num2str(nData) '.Gslice1 = acqp.Gslice1;'])
% end
% if isfield(acqp,'Gslice1ref')
%     eval(['data.spec' num2str(nData) '.Gslice1ref = acqp.Gslice1ref;'])
% end
% if isfield(acqp,'Gslice2')
%     eval(['data.spec' num2str(nData) '.Gslice2 = acqp.Gslice2;'])
% end
% if isfield(acqp,'Gslice3')
%     eval(['data.spec' num2str(nData) '.Gslice3 = acqp.Gslice3;'])
% end
% if isfield(acqp,'TxFreqExc')
%     eval(['data.spec' num2str(nData) '.txFreqExc = acqp.TxFreqExc;'])
% end
% if isfield(acqp,'TxFreqRef1')
%     eval(['data.spec' num2str(nData) '.txFreqRef1 = acqp.TxFreqRef1;'])
% end
% if isfield(acqp,'TxFreqRef2')
%     eval(['data.spec' num2str(nData) '.txFreqRef2 = acqp.TxFreqRef2;'])
% end

%--- Bruker data format ---
if isfield(acqp,'ACQ_ReceiverSelect')
    flag.dataBrukerNewOld = 1;
    if eval(['strcmp(data.spec' num2str(nData) '.fidName,''fid'')'])
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
            eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple effective receivers
            eval(['data.spec' num2str(nData) '.nRcvrs = method.PVM_EncNReceivers;'])
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple receivers
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,''Yes'');'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);'])
        end
    else
        % assume 1 receiver
        eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
        % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
    end
    if isfield(method,'PVM_NRepetitions')
        eval(['data.spec' num2str(nData) '.nr = method.PVM_NRepetitions;'])
    else
        eval(['data.spec' num2str(nData) '.nr = 1;'])
    end
    if isfield(method,'PVM_NAverages')
        eval(['data.spec' num2str(nData) '.na = method.PVM_NAverages;'])
    else
        eval(['data.spec' num2str(nData) '.na = 1;'])
    end
elseif flag.dataBrukerFormat==2         % new, fid
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple effective receivers
            eval(['data.spec' num2str(nData) '.nRcvrs = method.PVM_EncNReceivers;'])
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple receivers
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,''Yes'');'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);'])
        end
    else
        % assume 1 receiver
        eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
        % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
    end
    if isfield(method,'PVM_NAverages')
        eval(['data.spec' num2str(nData) '.na = method.PVM_NAverages;'])
    else
        eval(['data.spec' num2str(nData) '.na = 1;'])
    end
    % eval(['data.spec' num2str(nData) '.nr = 1;'])           % collapsed
    if isfield(method,'PVM_NRepetitions')
        eval(['data.spec' num2str(nData) '.nr = method.PVM_NRepetitions;'])
    else
        eval(['data.spec' num2str(nData) '.nr = 1;'])
    end
else                                    % new, rawdata.job0
    if isfield(method,'PVM_EncNReceivers')
        if isempty(method.PVM_EncNReceivers)            % 1 effective receiver
            eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple effective receivers
            eval(['data.spec' num2str(nData) '.nRcvrs = method.PVM_EncNReceivers;'])
        end
    end
    if isfield(acqp,'ACQ_ReceiverSelect')
        if isempty(acqp.ACQ_ReceiverSelect)             % 1 receiver
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
        else                                            % multiple receivers
            eval(['data.spec' num2str(nData) '.acqpRcvrSelect = strcmp(acqp.ACQ_ReceiverSelect,''Yes'');'])
            % eval(['data.spec' num2str(nData) '.nRcvrs = length(data.spec' num2str(nData) '.acqpRcvrSelect);'])
            % fixed for Merck data (Corey Miller, 12/2021) since length()
            % effectively considers 0's (i.e. 'No') as valid entries, i.e.
            % disabled coil elements are misinterpreted as active coils
            % eval(['data.spec' num2str(nData) '.nRcvrs = sum(data.spec' num2str(nData) '.acqpRcvrSelect);'])
        end
    else
        % assume 1 receiver
        eval(['data.spec' num2str(nData) '.acqpRcvrSelect = 1;'])
        % eval(['data.spec' num2str(nData) '.nRcvrs = 1;'])
    end
    if flag.dataExpType==1              % regular MRS
        % RAG's STEAM sequence
        if eval(['strcmp(data.spec' num2str(nData) '.sequence,''ragSTEAM.ppg'');']) && ...
           isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
         
            eval(['data.spec' num2str(nData) '.nr = method.PVM_NAverages*method.PVM_NRepetitions;'])      
            if flag.verbose
                fprintf('ragSTEAM:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions)
                if isfield(method,'IsisNAverages')
                    fprintf('IsisNAverages    = %.0f\n',method.IsisNAverages)
                end
            end
            eval(['data.spec' num2str(nData) '.na = 1;'])
        elseif eval(['strcmp(data.spec' num2str(nData) '.sequence,''ragPT.ppg'');']) && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % RAG's polarization transfer (ISIS) sequence
            eval(['data.spec' num2str(nData) '.nr = method.PVM_NRepetitions*method.IsisNAverages;'])      
            if flag.verbose
                fprintf('ragPT:\n')
                fprintf('PVM_NAverages    = %.0f\n',method.PVM_NAverages)
                fprintf('PVM_NRepetitions = %.0f\n',method.PVM_NRepetitions)
                fprintf('IsisNAverages    = %.0f\n',method.IsisNAverages)
            end
            eval(['data.spec' num2str(nData) '.na = 1;'])
        elseif eval(['strcmp(data.spec' num2str(nData) '.sequence,''ISIS.ppg'');']) && ...
               strcmp(method.Method,'Bruker:ISIS') && ...
               isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions') && ...
               isfield(method,'IsisNAverages')
            % Bruker's ISIS sequence
            eval(['data.spec' num2str(nData) '.nr = method.IsisNAverages;'])      
            if flag.verbose
                fprintf('Bruker ISIS:\n')
                fprintf('PVM_NAverages     = %.0f\n',method.PVM_NAverages)
                fprintf('PVM_NRepetitions  = %.0f\n',method.PVM_NRepetitions)
                fprintf('IsisNAverages     = %.0f\n',method.IsisNAverages)
            end
            eval(['data.spec' num2str(nData) '.na = 1;'])
        else                    % regular case
            % e.g. including regular Bruker PRESS
            if nData==2 && flag.dataIdentScan && strcmp(method.PVM_RefScanYN,'Yes')
                if isfield(method,'PVM_NRepetitions')
                    eval(['data.spec' num2str(nData) '.nr = method.PVM_RefScanNA;'])        % note the NA <=> NR flip since data is saved separately
                else
                    eval(['data.spec' num2str(nData) '.nr = 1;'])
                end
                if isfield(method,'PVM_NAverages')
                    eval(['data.spec' num2str(nData) '.na = method.PVM_NRepetitions;'])     % note the NA <=> NR flip since data is saved separately
                else
                    eval(['data.spec' num2str(nData) '.na = 1;'])
                end
            else        % all other cases, ie. data 1, regular (non-ref) data, etc
%                 if strcmp(acqp.ACQ_sw_version,'PV-360.1.1')      % although this should be the default rather than the exception
%                     % ShanghaiTech / Chao: PV-360.1.1
%                     if isfield(method,'PVM_NRepetitions')
%                         eval(['data.spec' num2str(nData) '.nr = method.PVM_NRepetitions;'])     
%                     else
%                         eval(['data.spec' num2str(nData) '.nr = 1;'])
%                     end
%                     if isfield(method,'PVM_NAverages')
%                         eval(['data.spec' num2str(nData) '.na = method.PVM_NAverages;'])        
%                     else
%                         eval(['data.spec' num2str(nData) '.na = 1;'])
%                     end    
%                 else
                    % Merck / Cory Miller: PV-360.2.0.pl.1
                    if isfield(method,'PVM_NRepetitions')
                        eval(['data.spec' num2str(nData) '.nr = method.PVM_NAverages;'])        % note the NA <=> NR flip since data is saved separately
                    else
                        eval(['data.spec' num2str(nData) '.nr = 1;'])
                    end
                    if isfield(method,'PVM_NAverages')
                        eval(['data.spec' num2str(nData) '.na = method.PVM_NRepetitions;'])     % note the NA <=> NR flip since data is saved separately
                    else
                        eval(['data.spec' num2str(nData) '.na = 1;'])
                    end    
%                 end
            end
        end
    elseif flag.dataExpType==3          % JDE
        if isfield(method,'PVM_NAverages') && isfield(method,'PVM_NRepetitions')
            eval(['data.spec' num2str(nData) '.nr = method.PVM_NAverages*method.PVM_NRepetitions;'])      
            if flag.verbose
                fprintf('JDE:\nPVM_NAverages    = %.0f\nPVM_NRepetitions = %.0f\n',method.PVM_NAverages,method.PVM_NRepetitions)
                if isfield(method,'IsisNAverages')
                    fprintf('IsisNAverages    = %.0f\n',method.IsisNAverages)
                end
            end
        else
            eval(['data.spec' num2str(nData) '.nr = 1;'])
        end
        if isfield(method,'PVM_NAverages')
            eval(['data.spec' num2str(nData) '.na = 1;'])     
        else
            eval(['data.spec' num2str(nData) '.na = 1;'])
        end
    else
        eval(['data.spec' num2str(nData) '.nr = 0;'])           % default
        eval(['data.spec' num2str(nData) '.na = 0;'])           % default
    end
end
if isfield(acqp,'InstanceTime')          % -> date vector
    eval(['data.spec' num2str(nData) '.time_start = datevec(acqp.InstanceTime);'])
end
if isfield(acqp,'lScanTimeSec')
    eval(['data.spec' num2str(nData) '.durSec = acqp.lScanTimeSec/1e6;'])
    eval(['data.spec' num2str(nData) '.durMin = acqp.lScanTimeSec/6e8;'])
else
    eval(['data.spec' num2str(nData) '.durSec = 0;'])
    eval(['data.spec' num2str(nData) '.durMin = 0;'])
end
% if isfield(acqp,'time_complete')     % ISO 8601 -> date vector
%     eval(['data.spec' num2str(nData) '.time_end = datevec(acqp.time_complete,''yyyymmddTHHMMSS'');'])
% end

    
%--- institution / scanner ---
if isfield(acqp,'ACQ_institution')
    eval(['data.spec' num2str(nData) '.institution = acqp.ACQ_institution;'])
else
    eval(['data.spec' num2str(nData) '.institution = ''unknown'';'])
end
if isfield(acqp,'ACQ_station')
    eval(['data.spec' num2str(nData) '.system = acqp.ACQ_station;'])
else
    eval(['data.spec' num2str(nData) '.system = ''unknown'';'])
end
if isfield(acqp,'ACQ_sw_version')               % software version
    eval(['data.spec' num2str(nData) '.software = acqp.ACQ_sw_version;'])
else
    eval(['data.spec' num2str(nData) '.software = ''unknown'';'])
end

%--- info printout ---
eval(['fprintf(''\nInstitution: %s\n'',data.spec' num2str(nData) '.institution)'])
if eval(['strcmp(data.spec' num2str(nData) '.system,''Medspec S400 AVIIIHD'')'])
    eval(['fprintf(''System:      %s (human 4T)\n'',data.spec' num2str(nData) '.system)'])
else
    eval(['fprintf(''System:      %s\n'',data.spec' num2str(nData) '.system)'])
end
eval(['fprintf(''Software:    Bruker %s\n'',data.spec' num2str(nData) '.software)'])
eval(['fprintf(''Protocol:    %s\n'',data.spec' num2str(nData) '.protocolName)'])
eval(['fprintf(''Scan:        %s\n\n'',data.spec' num2str(nData) '.scanName)'])

%--- update success flag ---
f_succ = 1;

