%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_LCM_SpecDataLoadFromDataPage
%% 
%%  Assignment of experimental FID from Data page.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data lcm

FCTNAME = 'SP2_LCM_SpecDataLoadFromDataPage';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(data,'spec1')
    if isfield(data.spec1,'fid')
        %--- format handling ---
        lcm.fidOrig = data.spec1.fid;
        lcm.fid     = data.spec1.fid;
        
        %--- consistency check ---
        if ndims(lcm.fidOrig)>1
            fprintf('%s ->\nWARNING: FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(lcm.fidOrig),0));
        end
    else
        fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure found. Program aborted.\n',FCTNAME);
    return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    lcm.nspecCOrig = data.spec1.nspecC;       % number of complex data points (to be modified: cut, ZF)
    lcm.nspecC     = data.spec1.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'na')
    lcm.na = data.spec1.na;
else
    fprintf('%s -> # of averages (na) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'nr')
    lcm.nr = data.spec1.nr;
else
    fprintf('%s -> # of repetitions (nr) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sf')
    lcm.sf = data.spec1.sf;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sw')
    lcm.sw_h  = data.spec1.sw_h;                 % sweep width in Hz
    lcm.dwell = 1/lcm.sw_h;               % dwell time
    lcm.sw    = lcm.sw_h/lcm.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral data set loaded from Data page:\n');
fprintf('Larmor frequency: %.1f MHz\n',lcm.sf);
fprintf('Sweep width:      %.1f Hz\n',lcm.sw_h);
fprintf('Complex points:   %.0f\n\n',lcm.nspecC);

%--- data export ---
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;
if isfield(lcm.expt,'spec')
    lcm.expt = rmfield(lcm.expt,'spec');
end
lcm.expt.fid = lcm.fidOrig;

%--- update read flag ---
f_succ = 1;
