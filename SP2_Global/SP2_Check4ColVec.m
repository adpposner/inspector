%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Check4ColVec(varargin)
%%
%%  Checks function argument to be a numberic column vector.
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Check4ColVec';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
narg = nargin;
if narg==1
    vector  = varargin{1};
    varName = inputname(1);
    if isempty(varName)
        % fprintf('%s -> variable name can not be displayed (inputname.m does not work) ...',FCTNAME);
        varName = '...';
    end
elseif narg==2
    vector  = varargin{1};
    varName = SP2_Check4StrR(varargin{2});
else
    fprintf('%s -> More than 2 input arguments are not allowed ...',FCTNAME);
    return
end

if ~isnumeric(vector)
    fprintf('%s -> Vector <%s> is not numeric!',FCTNAME,varName);
    return
end
vecSize = size(vector);
if length(vecSize)>2
    fprintf('%s -> Function argument <%s> is not a vector\n',FCTNAME,varName);
    return
end
if vecSize(1)>1 && vecSize(2)==1
    % regular case
elseif vecSize(1)==1 && vecSize(2)>1
    fprintf('%s -> <%s> is a row vector, not a column vector',FCTNAME,varName);
    return
elseif vecSize(1)~=1 && vecSize(2)~=1
    fprintf('%s -> <%s> is a data array, not a vector\n',FCTNAME,varName);
    return
end

%--- update success flag ---
f_succ = 1;

end
