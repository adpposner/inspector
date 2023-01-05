%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcData1( varargin )
%% 
%%  Processing function for data set 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_ProcData1';


%--- success flag init ---
f_done = 0;

%--- data assignment ---
if ~isfield(mrsi.spec1,'fidimg_orig')
    fprintf('%s ->\nFID image 1 does not exist. Reconstruct first.\n\n',FCTNAME);
    return
end

%--- FID manipulation ---
if ~SP2_MRSI_ProcessFid1
    fprintf('%s ->\nTime-domain manipulation of FID 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- spetral analysis ---
if ~SP2_MRSI_ProcessSpec1
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
