%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ProcData1( varargin )
%% 
%%  Processing function for data set 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc

FCTNAME = 'SP2_Proc_ProcData1';


%--- success flag init ---
f_done = 0;

%--- data assignment ---
if ~isfield(proc.spec1,'fidOrig') || ~isfield(proc.spec1,'nspecCOrig')
    fprintf('%s ->\nFID 1 does not exist. Load/assign first.\n\n',FCTNAME);
    return
end

%--- FID manipulation ---
if ~SP2_Proc_ProcessFid1
    fprintf('%s ->\nTime-domain manipulation of FID 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- spetral analysis ---
if ~SP2_Proc_ProcessSpec1
    fprintf('%s ->\nSpectral processing of FID 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
if nargin==1
    if ~SP2_Check4FlagR(varargin{1})
        return
    end
    if varargin{1}
        fprintf('%s ->\nSpectrum 1 successfully processed.\n',FCTNAME);
    end
end

%--- success flag update ---
f_done = 1;