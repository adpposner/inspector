%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MARSS_SimParsLoadFromData
%% 
%%  Assignment of specral parameters from Data page.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data marss pars


FCTNAME = 'SP2_MARSS_SimParsLoadFromData';


%--- init success flag ---
f_succ = 0;

%--- data assignment ---
if data.expTypeDisplay==1 || data.expTypeDisplay==2 || ...      % regular MRS || JDE 1st&Last || ...
   data.expTypeDisplay==3 || data.expTypeDisplay==4             % JDE 2nd&Last || JDE array
    if isfield(data,'spec1')
        if isfield(data.spec1,'fid')
            %--- format handling ---
            % proc.spec1.fidOrig = data.spec1.fid;

            %--- consistency check ---
            if ndims(data.spec1.fid)~=2
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(data.spec1.fid),0));
                return
            elseif size(data.spec1.fid,2)~=1
                fprintf('%s ->\nIncompatible FID dimension %s detected.\n',FCTNAME,SP2_Vec2PrintStr(size(data.spec1.fid),0));
                return
            end
        else
            fprintf('%s ->\nRaw data (FID 1) not found. Program aborted.\n\n',FCTNAME);
            return
        end
    else
        fprintf('%s ->\nNo data structure for FID 1 found (''data.spec1''). Program aborted.\n',FCTNAME);
        return
    end
else
   fprintf('%s ->\nSelected data format is not supported.\nMake sure the data to be loaded is meaningful. \n',FCTNAME);
   return
end

%--- assignment of further parameters ---
if isfield(data.spec1,'nspecC')
    marss.nspecCBasic = data.spec1.nspecC;       % number of complex data points (to be modified: cut, ZF)
    marss.nspecC      = data.spec1.nspecC;
else
    fprintf('%s -> data set dimension (nspecC) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sf')
    marss.sf = data.spec1.sf;
    marss.b0 = marss.sf / pars.gyroRatio;
else
    fprintf('%s -> synthesizer frequency (sf) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'sw_h')
    marss.sw_h  = data.spec1.sw_h;                 % sweep width in Hz
    marss.dwell = 1/data.spec1.sw_h;               % dwell time
    marss.sw    = data.spec1.sw_h/data.spec1.sf;   % sweep width in ppm
else
    fprintf('%s -> sweep width (sw_h) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data,'ppmCalib')
    marss.ppmCalib = data.ppmCalib;              % frequency calibration
else
    fprintf('%s -> frequency calibration not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'te')
    marss.te = data.spec1.te;                      % echo time in ms
else
    fprintf('%s -> Echo time (te) not found. Program aborted.\n\n',FCTNAME);
    return
end
if isfield(data.spec1,'tm')
    marss.tm = data.spec1.tm;                      % mixing time in ms
else
    fprintf('%s -> Mixing time (tm) not found. Program aborted.\n\n',FCTNAME);
    return
end

%--- info string ---
fprintf('\nSpectral parameters loaded from data sheet:\n');
fprintf('larmor frequency: %.1f MHz\n',marss.sf);
fprintf('sweep width:      %.1f Hz\n',marss.sw_h);
fprintf('Complex points:   %.0f\n\n',marss.nspecC);

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- update read flag ---
f_succ = 1;
