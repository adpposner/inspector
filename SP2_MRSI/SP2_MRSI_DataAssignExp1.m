%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_MRSI_DataAssignExp1
%% 
%%  Assignment of specral data set 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data mrsi flag


FCTNAME = 'SP2_MRSI_DataAssignExp1';


%--- init read flag ---
f_read = 0;

%--- data assignment ---
if isfield(data,'spec1')
    if isfield(data.spec1,'fid')
        %--- consistency check ---
        if ndims(data.spec1.fid)~=3
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(data.spec1.fid),0))
        end
        
        %--- format handling ---
        if flag.mrsiNumSpec==0          % one data set, i.e. non-JDE
            mrsi.spec1.fidkspvec = data.spec1.fid;
        else
            mrsi.spec1.fidkspvec = data.spec1.fid(:,1:2:end,:);
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME)
        return
    end
else
    fprintf('%s ->\nNo data structure for FID 1 found (''data.spec2''). Program aborted.\n',FCTNAME)
    return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    mrsi.spec1.nspecCOrig = data.spec1.nspecC;       % number of complex data points (to be modified: cut, ZF)
    mrsi.spec1.nspecC     = data.spec1.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'nRcvrs')
    mrsi.spec1.nRcvrs = data.spec1.nRcvrs;
else
    fprintf('%s -> Number of receivers (nRcvrs) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'na')
    mrsi.spec1.na = data.spec1.na;
else
    fprintf('%s -> # of averages (na) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'nr')
    mrsi.spec1.nr = data.spec1.nr/2;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'sf')
    mrsi.spec1.sf = data.spec1.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'sw')
    mrsi.spec1.sw_h  = data.spec1.sw_h;                         % sweep width in Hz
    mrsi.spec1.dwell = 1/mrsi.spec1.sw_h;               % dwell time
    mrsi.spec1.sw    = mrsi.spec1.sw_h/mrsi.spec1.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw) not found. Program aborted.\n\n',FCTNAME)
    return
end
if isfield(data.spec1,'mrsi')
    if isfield(data.spec1.mrsi,'aver')
        mrsi.spec1.aver = data.spec1.mrsi.aver;
    else
        fprintf('%s -> MRSI average parameter not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'nEnc')
        mrsi.spec1.nEnc = data.spec1.mrsi.nEnc;
    else
        fprintf('%s -> MRSI number of encoding steps not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'nEncR')
        mrsi.spec1.nEncR = data.spec1.mrsi.nEncR;
        mrsi.spec1.nEncROrig = mrsi.spec1.nEncR;
    else
        fprintf('%s -> MRSI number of encoding steps along read dimension not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'nEncP')
        mrsi.spec1.nEncP = data.spec1.mrsi.nEncP;
        mrsi.spec1.nEncPOrig = mrsi.spec1.nEncP;
    else
        fprintf('%s -> MRSI number of encoding steps along phase dimension not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'nEncS')
        mrsi.spec1.nEncS = data.spec1.mrsi.nEncS;
    else
        fprintf('%s -> MRSI number of encoding steps along slice dimension not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'durSec')
        mrsi.spec1.durSec = data.spec1.mrsi.durSec;
    else
        fprintf('%s -> MRSI experiment duration [s] not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'durMin')
        mrsi.spec1.durMin = data.spec1.mrsi.durMin;
    else
        fprintf('%s -> MRSI experiment duration [min] not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encFileR')
        mrsi.spec1.encFileR = data.spec1.mrsi.encFileR;
    else
        fprintf('%s -> MRSI encoding file (read) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encFileP')
        mrsi.spec1.encFileP = data.spec1.mrsi.encFileP;
    else
        fprintf('%s -> MRSI encoding file (phase) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encFileS')
        mrsi.spec1.encFileS = data.spec1.mrsi.encFileS;
    else
        fprintf('%s -> MRSI encoding file (slice) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encTableR')
        mrsi.spec1.encTableR = data.spec1.mrsi.encTableR;
    else
        fprintf('%s -> MRSI encoding table (read) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encTableP')
        mrsi.spec1.encTableP = data.spec1.mrsi.encTableP;
    else
        fprintf('%s -> MRSI encoding table (phase) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'encTableS')
        mrsi.spec1.encTableS = data.spec1.mrsi.encTableS;
    else
        fprintf('%s -> MRSI encoding table (slice) not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'mat')
        mrsi.spec1.mat = data.spec1.mrsi.mat;
        mrsi.spec1.matOrig = mrsi.spec1.mat;
    else
        fprintf('%s -> MRSI encoding matrix not found. Program aborted.\n\n',FCTNAME)
        return
    end
    if isfield(data.spec1.mrsi,'fov')
        mrsi.spec1.fov = data.spec1.mrsi.fov;
    else
        fprintf('%s -> MRSI FOV not found. Program aborted.\n\n',FCTNAME)
        return
    end
    
    %--- data formating ---
    [mrsi.spec1,f_done] = SP2_MRSI_FormatList2Mat(mrsi.spec1);
    mrsi.spec1.fidkspOrig = mrsi.spec1.fidksp;
    if ~f_done
        return
    end
    
    %--- name assignment ---
    mrsi.spec1.name = 'Data 1';
    
    %--- shift indices to positive center ---
    mrsi.spec1.encVecR = mrsi.spec1.encTableR + round(mrsi.spec1.mat(1)/2);
    mrsi.spec1.encVecP = mrsi.spec1.encTableP + round(mrsi.spec1.mat(2)/2);

    %--- convert to matrix scheme ---
    mrsi.spec1.encMat = zeros(mrsi.spec1.mat(1),mrsi.spec1.mat(2));
    for encCnt = 1:mrsi.spec1.nEnc
        mrsi.spec1.encMat(mrsi.spec1.encVecR(encCnt),mrsi.spec1.encVecP(encCnt)) = ...
            mrsi.spec1.encMat(mrsi.spec1.encVecR(encCnt),mrsi.spec1.encVecP(encCnt)) + 1;
    end
else
    fprintf('%s -> MRSI parameters not found. Program aborted.\n\n',FCTNAME)
    return
end

%--- info string ---
fprintf('\nSpectral data set 1 loaded from data sheet:\n')
fprintf('larmor frequency: %.1f MHz\n',mrsi.spec1.sf)
fprintf('sweep width:      %.1f Hz\n',mrsi.spec1.sw_h)
fprintf('Complex points:   %.0f\n',mrsi.spec1.nspecC)
fprintf('MRSI encoding:    %s (%.0f steps)\n\n',mrsi.spec1.encFileR,mrsi.spec1.nEnc)

%--- data export ---
mrsi.expt     = mrsi.spec1;
if isfield(mrsi.expt,'spec')
    mrsi.expt = rmfield(mrsi.expt,'spec');
end
mrsi.expt.fidksp = mrsi.spec1.fidksp;

%--- update read flag ---
f_read = 1;
