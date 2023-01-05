%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcData2( varargin )
%% 
%%  Processing function for data set 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_ProcData2';


%--- success flag init ---
f_done = 0;

%--- data assignment ---
if ~isfield(mrsi.spec2,'fidimg_orig')
    fprintf('%s ->\nFID image 2 does not exist. Reconstruct first.\n\n',FCTNAME);
    return
end

%--- FID manipulation ---
if ~SP2_MRSI_ProcessFid2
    fprintf('%s ->\nTime-domain manipulation of FID 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- spetral analysis ---
if ~SP2_MRSI_ProcessSpec2
    fprintf('%s ->\nSpectral processing of FID 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
if nargin==1
    if ~SP2_Check4FlagR(varargin{1})
        return
    end
    if varargin{1}
        fprintf('%s ->\nSpectrum 2 successfully processed.\n',FCTNAME);
    end
end

%--- success flag update ---
f_done = 1;
