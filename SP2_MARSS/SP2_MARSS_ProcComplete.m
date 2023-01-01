%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_ProcComplete( varargin )
%% 
%%  Processing function for data set.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss

FCTNAME = 'SP2_MARSS_ProcComplete';


%--- success flag init ---
f_succ = 0;

%--- data assignment ---
if ~isfield(marss.basis,'fidOrig')
    fprintf('%s ->\nFID does not exist. Load/assign first.\n\n',FCTNAME)
    return
end

%--- FID manipulation ---
if ~SP2_MARSS_ProcessFid
    fprintf('%s ->\nTime-domain manipulation of FID failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- spetral analysis ---
if ~SP2_MARSS_ProcessSpec
    fprintf('%s ->\nSpectral processing of FID failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- info printout ---
if nargin==1
    if ~SP2_Check4FlagR(varargin{1})
        return
    end
    if varargin{1}
        fprintf('%s ->\nSpectrum successfully processed.\n',FCTNAME)
    end
end

%--- success flag update ---
f_succ = 1;
