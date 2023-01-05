%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function outdata = SP2_Proc_AlignSpec1FitFct(coeff,data)
%%
%%  Fitting function for alignment of spectrum 1 with spectrum 2.
%%
%%  09-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc align flag



%--- data assignment: spectrum 1 ---
align.fid    = proc.spec1.fidOrig;
align.nspecC = proc.spec1.nspecCOrig;

%--- exponential line broadening ---
if flag.procSpec1Lb
    %--- generation of weighting function ---
    if flag.procAlignLb
        align.lbWeight = exp(-coeff(align.indLb)*proc.spec1.dwell*(0:align.nspecC-1)*pi)';
    else
        align.lbWeight = exp(-proc.spec1.lb*proc.spec1.dwell*(0:align.nspecC-1)*pi)';
    end
        
    %--- line broadening --------------------
    align.fid = align.fid .* align.lbWeight;
end

%--- Gaussian line broadening ---
if flag.procSpec1Gb
    %--- generation of weighting function ---
    if flag.procAlignGb
        align.gbWeight = exp(-coeff(align.indGb)*(proc.spec1.dwell*(0:align.nspecC-1)*pi).^2)';
        % align.gbWeight = exp(-pi^2/(4*log(2)) * coeff(align.indGb)^2*(proc.spec1.dwell*(0:align.nspecC-1)).^2)';
    else
        align.gbWeight = exp(-proc.spec1.gb*(proc.spec1.dwell*(0:align.nspecC-1)*pi).^2)';
        % align.gbWeight = exp(-pi^2/(4*log(2)) * proc.spec1.gb*(proc.spec1.dwell*(0:align.nspecC-1)).^2)';
    end
    
    %--- line broadening --------------------
    align.fid = align.fid .* align.gbWeight;
end

%--- frequency shift ---
if flag.procSpec1Shift
    if flag.procAlignShift
        align.fid = align.fid .* exp(1i*2*pi*(0:align.nspecC-1)' * proc.spec1.dwell * coeff(align.indShift));   % corr phase per point
    else
        align.fid = align.fid .* exp(1i*2*pi*(0:align.nspecC-1)' * proc.spec1.dwell * proc.spec1.shift);        % corr phase per point
    end
end

%--- FID data cut-off ---
if flag.procSpec1Cut
    if proc.spec1.cut<align.nspecC
        align.fid    = align.fid(1:proc.spec1.cut,1);
        align.nspecC = proc.spec1.cut;
    end
end

%--- time-domaine zero-filling ---
if flag.procSpec1Zf
    if proc.spec1.zf>align.nspecC
        align.fid1Zf = complex(zeros(proc.spec1.zf,1));
        align.fid1Zf(1:align.nspecC,1) = align.fid;
        align.fid = align.fid1Zf;
        align.nspecC = proc.spec1.zf;
    end
end

%--- spectral baseline offset ---
if flag.procSpec1Offset
    if flag.procAlignOffset
        align.fid(1) = align.fid(1)*coeff(align.indOffset);
    else
        align.fid(1) = align.fid(1)*proc.spec1.offset;
    end
end

%--- spectral FFT ---
align.spec = fftshift(fft(align.fid,[],1),1);

%--- zero order phase correction ---
if flag.procSpec1Phc0
    if flag.procAlignPhc0
        align.phaseVec = ones(1,align.nspecC)*coeff(align.indPhc0);
    else
        align.phaseVec = ones(1,align.nspecC)*proc.spec1.phc0;
    end
    align.spec = align.spec .* exp(1i*align.phaseVec*pi/180)';
end

%--- first order phase correction ---
if flag.procSpec1Phc1
    if flag.procAlignPhc1
        if coeff(align.indPhc1)~=0
            align.phaseVec = (0:coeff(align.indPhc1)/(align.nspecC-1):coeff(align.indPhc1)); 
            align.spec = align.spec .* exp(1i*align.phaseVec*pi/180)';
        end
    else
        if proc.spec1.phc1~=0
            align.phaseVec = (0:proc.spec1.phc1/(align.nspecC-1):proc.spec1.phc1); 
            align.spec = align.spec .* exp(1i*align.phaseVec*pi/180)';
        end
    end
end

%--- amplitude scaling ---
if flag.procSpec1Scale
    if flag.procAlignScale
        align.spec = coeff(align.indScale) * align.spec;
    else
        align.spec = proc.spec1.scale * align.spec;
    end
end

%--- spectral stretching ---
if flag.procSpec1Stretch
    if flag.procAlignStretch
        align.frequVecNew = 1/(1+coeff(align.indStretch)/proc.spec1.sf)*align.frequVecOrig;
    else
        align.frequVecNew = 1/(1+proc.spec1.stretch/proc.spec1.sf)*align.frequVecOrig;
    end
    align.specReal    = spline(align.frequVecOrig,real(align.spec),align.frequVecNew);
    align.specImag    = spline(align.frequVecOrig,imag(align.spec),align.frequVecNew);
    align.spec        = complex(align.specReal.',align.specImag.');
end

%--- extraction of spectral range ---
if proc.alignAmpWeight==1.0         % no weighting
    if flag.procFormat==1           % real part
        outdata = real(align.spec(proc.alignAllInd));
    elseif flag.procFormat==2       % imaginary part
        outdata = imag(align.spec(proc.alignAllInd));
    elseif flag.procFormat==3       % magnitude
        outdata = abs(align.spec(proc.alignAllInd));
    else                            % phase, here: real AND imaginary
        outdata = [real(align.spec(proc.alignAllInd)); imag(align.spec(proc.alignAllInd))];
    end
else                                % amplitude weighting
    if flag.procFormat==1           % real part
        outdata = (abs(real(align.spec(proc.alignAllInd)))).^proc.alignAmpWeight .* sign(real(align.spec(proc.alignAllInd)));
    elseif flag.procFormat==2       % imaginary part
        outdata = (abs(imag(align.spec(proc.alignAllInd)))).^proc.alignAmpWeight .* sign(imag(align.spec(proc.alignAllInd)));
    elseif flag.procFormat==3       % magnitude
        outdata = (abs(align.spec(proc.alignAllInd))).^proc.alignAmpWeight;
    else                            % phase, here: real AND imaginary
        outdata = abs([real(align.spec(proc.alignAllInd)); imag(align.spec(proc.alignAllInd))]).^proc.alignAmpWeight .* ...
                  sign([real(align.spec(proc.alignAllInd)); imag(align.spec(proc.alignAllInd))]);
    end
end

%--- polynomial baseline ---
if flag.procAlignPoly
    switch proc.alignPolyOrder
        case 0
            outdata = outdata - coeff(align.indPoly);
        case 1
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+1);
        case 2
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+2);
        case 3
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+3);
        case 4
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+4);
        case 5
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+5);
        case 6
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm6 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+5)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+6);
        case 7
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm7 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm6 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+5)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+6)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+7);
        case 8
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm8 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm7 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm6 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+5)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+6)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+7)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+8);
        case 9
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm9 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm8 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm7 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm6 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+5)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+6)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+7)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+8)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+9);
        case 10
            outdata = outdata - ...
                      coeff(align.indPoly)*proc.alignAllIndPpm10 - ...
                      coeff(align.indPoly+1)*proc.alignAllIndPpm9 - ...
                      coeff(align.indPoly+2)*proc.alignAllIndPpm8 - ...
                      coeff(align.indPoly+3)*proc.alignAllIndPpm7 - ...
                      coeff(align.indPoly+4)*proc.alignAllIndPpm6 - ...
                      coeff(align.indPoly+5)*proc.alignAllIndPpm5 - ...
                      coeff(align.indPoly+6)*proc.alignAllIndPpm4 - ...
                      coeff(align.indPoly+7)*proc.alignAllIndPpm3 - ...
                      coeff(align.indPoly+8)*proc.alignAllIndPpm2 - ...
                      coeff(align.indPoly+9)*proc.alignAllIndPpm - ...
                      coeff(align.indPoly+10);
    end
end

%--- integral cost-function ---
% outdata(end+1) = sum(outdata);
% nOrig          = length(outdata);
% outdata        = [outdata; outdata];
% outdata(nOrig+1:end) = sum(outdata);





