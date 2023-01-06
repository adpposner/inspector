%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Syn_ProcData( varargin )
%% 
%%  Processing function for data set.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn

FCTNAME = 'SP2_Syn_ProcData';


%--- success flag init ---
f_done = 0;

%--- data assignment ---
if ~isfield(syn,'fidOrig')
    fprintf('%s ->\nFID does not exist. Load/assign first.\n\n',FCTNAME);
    return
end

%--- FID manipulation ---
if ~SP2_Syn_ProcessFid
    fprintf('%s ->\nTime-domain manipulation of FID failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- spetral analysis ---
if ~SP2_Syn_ProcessSpec
    fprintf('%s ->\nSpectral processing of FID failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
if nargin==1
    if ~SP2_Check4FlagR(varargin{1})
        return
    end
    if varargin{1}
        fprintf('%s ->\nSpectrum successfully processed.\n',FCTNAME);
    end
end

%--- success flag update ---
f_done = 1;

end
