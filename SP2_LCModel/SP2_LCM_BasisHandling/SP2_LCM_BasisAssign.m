%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_BasisAssign(nMetab)
%% 
%%  Function to assign FID to individual metabolite.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm

FCTNAME = 'SP2_LCM_BasisAssign';


%--- init success flag ---
f_succ = 0;

%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if ~isnumeric(lcm.basis.data)           % existing basis
    if nMetab>lcm.basis.n
        fprintf('%s ->\nThere are only %.0f metabolites in the basis set. Program aborted.\n',FCTNAME,nMetab);
        return
    end
end

%--- consistency check ---
if nMetab>lcm.basis.nLim
    fprintf('Assigned basis position is outside the range currently supported by the software (0..%.0f)\n',lcm.basis.n);
    fprintf('Program aborted.\n');
    return
end

%--- check data existence ---
if ~isfield(lcm,'fid')
    fprintf('No FID data found. Assignment to LCM basis aborted.\n');
    return
end
if ~isfield(lcm,'spec')
    lcm.spec = fftshift(fft(lcm.fid,[],1),1);
    return
end

%--- FID assignment ---
if isnumeric(lcm.basis.data)                            % init basis set if no basis set loaded (default: 0)
    lcm.basis.data       = {};
    lcm.basis.data{1}{1} = 'new metabolite';
    lcm.basis.data{1}{2} = 1.5;
    lcm.basis.data{1}{3} = 0.025;
%     lcm.basis.data{1}{4} = lcm.fid;
    lcm.basis.data{1}{4} = ifft(ifftshift(lcm.spec,1),[],1);
    lcm.basis.data{1}{5} = '';

    %--- transfer fields to basis struct ---
    lcm.basis.sw_h      = lcm.sw_h;
    lcm.basis.sf        = lcm.sf;
    lcm.basis.ppmCalib  = lcm.ppmCalib;
    lcm.basis.dwell     = 1/lcm.basis.sw_h;
    lcm.basis.sw        = lcm.basis.sw_h/lcm.basis.sf;
    
    %--- parameter assessment ---
    lcm.basis.n         = length(lcm.basis.data);       % number of metabolites, =1
    lcm.basis.reorder   = 1;                            % init reordering vector
else                                % assign to existing basis field
    %--- consistency checks ---
    % sweep width
    if SP2_RoundToNthDigit(lcm.sw,2)~=SP2_RoundToNthDigit(lcm.basis.sw,2)
        fprintf('%s ->\nSW mismatch detected (%.2f ppm ~= %.2f ppm)\n',FCTNAME,...
                lcm.sw,lcm.basis.sw)
        return
    end

    % Larmor frequency
    if SP2_RoundToNthDigit(lcm.sf,1)~=SP2_RoundToNthDigit(lcm.basis.sf,1)
        fprintf('%s ->\nMismatch of Larmor frequency detected (%.2f MHz ~= %.2f MHz)\n',FCTNAME,...
                lcm.sf,lcm.basis.sf)
        return
    end
    if SP2_RoundToNthDigit(lcm.sf,2)~=SP2_RoundToNthDigit(lcm.basis.sf,2)
        fprintf('%s / WARNING:\nSmall mismatch of Larmor frequency detected (%.2f MHz ~= %.2f MHz)\n',FCTNAME,...
                lcm.sf,lcm.basis.sf)
    end

    % frequency calibration
    if SP2_RoundToNthDigit(lcm.ppmCalib,2)~=SP2_RoundToNthDigit(lcm.basis.ppmCalib,2)
        fprintf('%s ->\nMismatch of frequency calibration detected (%.2f ppm ~= %.2f ppm)\n',FCTNAME,...
                lcm.ppmCalib,lcm.basis.ppmCalib)
        return
    end    
    
    %--- assign metabolite-specific FID ---
%     lcm.basis.data{nMetab}{4} = lcm.fid;
    lcm.basis.data{nMetab}{4} = ifft(ifftshift(lcm.spec,1),[],1);

    %--- info printout ---
    fprintf('Current FID assigned as <%s> basis function\n',lcm.basis.data{nMetab}{1});
end

%--- basis set characterization ---
lcm.basis.ptsMin    = 1e6;                          % length of shortest FID
lcm.basis.ptsMax    = 0;                            % length of longest FID
lcm.basis.fidLength = zeros(1,lcm.basis.n);         % metabolite-specific FID length
for bCnt = 1:lcm.basis.n
    % FID length
    lcm.basis.fidLength(bCnt) = length(lcm.basis.data{bCnt}{4});

    % update shortest
    if lcm.basis.fidLength(bCnt)<lcm.basis.ptsMin
        lcm.basis.ptsMin = lcm.basis.fidLength(bCnt);
    end

    % update longest
    if lcm.basis.fidLength(bCnt)>lcm.basis.ptsMax
        lcm.basis.ptsMax = lcm.basis.fidLength(bCnt);
    end
end

%--- info printout ---
fprintf('\nBasis set characteristics:\n');
fprintf('1) # of metabolites:  %.0f\n',lcm.basis.n);
fprintf('2) sweep width:       %.1f Hz\n',lcm.basis.sw_h);
fprintf('3) Larmor frequency:  %.3f MHz\n',lcm.basis.sf);
fprintf('4) reference frequ.:  %.3f ppm\n',lcm.basis.ppmCalib);
fprintf('5) Shortest FID:      %.0f pts\n',lcm.basis.ptsMin);
fprintf('6) Longest FID:       %.0f pts\n\n',lcm.basis.ptsMax);

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- update success flag ---
f_succ = 1;






