%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SPECIAL
%%
%%  2D processing of 1D spectral data set 1.
%% 
%%  03-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag proc

FCTNAME = 'SP2_Proc_SPECIAL';


gb     = [-100 100];
lb     = [100 -100];
nSteps = 400;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     P R O G R A M      S T A R T                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- data assignment ---
if ~isfield(proc.spec1,'fidOrig')
    fprintf('%s ->\nFID 1 does not exist. Load/assign first.\n\n',FCTNAME);
    return
end

%--- keep original parameter setting ---
gbOrig = proc.spec1.gb;
lbOrig = proc.spec1.lb;

%--- gb vector generation ---
gbVec = gb(1):(gb(2)-gb(1))/(nSteps-1):gb(2);
lbVec = lb(1):(lb(2)-lb(1))/(nSteps-1):lb(2);

%--- serial manipulation of FID 1 ---
for nCnt = 1:nSteps
    %--- parameter update ---
    proc.spec1.gb = gbVec(nCnt);    
    proc.spec1.lb = lbVec(nCnt);    
    
    %--- FID manipulation ---
    if ~SP2_Proc_ProcessFid1
        fprintf('%s ->\nTime-domain manipulation of FID 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end

    %--- keep data ---
    if nCnt==1          % first run (remember that ZF/cut can change the original data size)
        fidArray = complex(zeros(proc.spec1.nspecC,nSteps));
    end
    fidArray(:,nCnt) = proc.spec1.fid;
end

%--- reset original gb value ---
proc.spec1.gb = gbOrig;
proc.spec1.lb = lbOrig;

%--- 2D processing ---
specArray = fftshift(fft2(fftshift(fidArray)));

fake = 1;










