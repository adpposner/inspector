%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_read = SP2_MRSI_DataAssignRef
%% 
%%  Assignment of reference data set.
%%
%%  03-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data mrsi


FCTNAME = 'SP2_MRSI_DataAssignRef';


%--- init read flag ---
f_read = 0;

%--- data assignment ---
if isfield(data,'spec2')
    if isfield(data.spec2,'fid')
        %--- format handling ---
        mrsi.ref.fidkspvec = data.spec2.fid;
        
        %--- consistency check ---
        if ndims(mrsi.ref.fidkspvec)<3 || ndims(mrsi.ref.fidkspvec)>3
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(mrsi.ref.fid),0));
        end
    else
        fprintf('%s ->\nRaw data (ref. FID) not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure for reference FID found (''data.spec2''). Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(data.spec2,'nspecC')
    mrsi.ref.nspecCOrig = data.spec2.nspecC;       % number of complex data points (to be modified: cut, ZF)
    mrsi.ref.nspecC     = data.spec2.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'nRcvrs')
    mrsi.ref.nRcvrs = data.spec2.nRcvrs;
else
    fprintf('%s -> Number of receivers (nRcvrs) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'na')
    mrsi.ref.na = data.spec2.na;
else
    fprintf('%s -> # of averages (na) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'nr')
    mrsi.ref.nr = data.spec2.nr;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'sf')
    mrsi.ref.sf = data.spec2.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'sw')
    mrsi.ref.sw_h  = data.spec2.sw_h;                         % sweep width in Hz
    mrsi.ref.dwell = 1/mrsi.ref.sw_h;               % dwell time
    mrsi.ref.sw    = mrsi.ref.sw_h/mrsi.ref.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec2,'mrsi')
    if isfield(data.spec2.mrsi,'aver')
        mrsi.ref.aver = data.spec2.mrsi.aver;
    else
        fprintf('%s -> MRSI average parameter not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'nEnc')
        mrsi.ref.nEnc = data.spec2.mrsi.nEnc;
    else
        fprintf('%s -> MRSI number of encoding steps not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'nEncR')
        mrsi.ref.nEncR = data.spec2.mrsi.nEncR;
        mrsi.ref.nEncROrig = mrsi.ref.nEncR;
    else
        fprintf('%s -> MRSI number of encoding steps along read dimension not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'nEncP')
        mrsi.ref.nEncP = data.spec2.mrsi.nEncP;
        mrsi.ref.nEncPOrig = mrsi.ref.nEncP;
    else
        fprintf('%s -> MRSI number of encoding steps along phase dimension not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'nEncS')
        mrsi.ref.nEncS = data.spec2.mrsi.nEncS;
    else
        fprintf('%s -> MRSI number of encoding steps along slice dimension not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'durSec')
        mrsi.ref.durSec = data.spec2.mrsi.durSec;
    else
        fprintf('%s -> MRSI experiment duration [s] not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'durMin')
        mrsi.ref.durMin = data.spec2.mrsi.durMin;
    else
        fprintf('%s -> MRSI experiment duration [min] not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encFileR')
        mrsi.ref.encFileR = data.spec2.mrsi.encFileR;
    else
        fprintf('%s -> MRSI encoding file (read) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encFileP')
        mrsi.ref.encFileP = data.spec2.mrsi.encFileP;
    else
        fprintf('%s -> MRSI encoding file (phase) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encFileS')
        mrsi.ref.encFileS = data.spec2.mrsi.encFileS;
    else
        fprintf('%s -> MRSI encoding file (slice) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encTableR')
        mrsi.ref.encTableR = data.spec2.mrsi.encTableR;
    else
        fprintf('%s -> MRSI encoding table (read) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encTableP')
        mrsi.ref.encTableP = data.spec2.mrsi.encTableP;
    else
        fprintf('%s -> MRSI encoding table (phase) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'encTableS')
        mrsi.ref.encTableS = data.spec2.mrsi.encTableS;
    else
        fprintf('%s -> MRSI encoding table (slice) not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'mat')
        mrsi.ref.mat = data.spec2.mrsi.mat;
        mrsi.ref.matOrig = mrsi.ref.mat;
    else
        fprintf('%s -> MRSI encoding matrix not found. Program aborted.\n\n',FCTNAME);
        return
    end
    if isfield(data.spec2.mrsi,'fov')
        mrsi.ref.fov = data.spec2.mrsi.fov;
    else
        fprintf('%s -> MRSI FOV not found. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- data formating ---
    [mrsi.ref,f_done] = SP2_MRSI_FormatList2Mat(mrsi.ref);
    mrsi.ref.fidkspOrig = mrsi.ref.fidksp;
    if ~f_done
        return
    end
    
    %--- name assignment ---
    mrsi.ref.name = 'Reference';

    %--- shift indices to positive center ---
    mrsi.ref.encVecR = mrsi.ref.encTableR + round(mrsi.ref.mat(1)/2);
    mrsi.ref.encVecP = mrsi.ref.encTableP + round(mrsi.ref.mat(2)/2);

    %--- convert to matrix scheme ---
    mrsi.ref.encMat = zeros(mrsi.ref.mat(1),mrsi.ref.mat(2));
    for encCnt = 1:mrsi.ref.nEnc
        mrsi.ref.encMat(mrsi.ref.encVecR(encCnt),mrsi.ref.encVecP(encCnt)) = ...
            mrsi.ref.encMat(mrsi.ref.encVecR(encCnt),mrsi.ref.encVecP(encCnt)) + 1;
    end
else
    fprintf('%s -> MRSI parameters not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral reference data set loaded from data sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',mrsi.ref.sf);
fprintf('sweep width:      %.1f Hz\n',mrsi.ref.sw_h);
fprintf('Complex points:   %.0f\n',mrsi.ref.nspecC);
fprintf('MRSI encoding:    %s (%.0f steps)\n\n',mrsi.ref.encFileR,mrsi.ref.nEnc);

%--- data export ---
mrsi.expt     = mrsi.ref;
if isfield(mrsi.expt,'spec')
    mrsi.expt = rmfield(mrsi.expt,'spec');
end
mrsi.expt.fidksp = mrsi.ref.fidksp;

%--- update read flag ---
f_read = 1;