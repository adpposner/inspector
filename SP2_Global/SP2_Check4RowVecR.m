%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [vector, f_succ] = SP2_Check4RowVecR(varargin)
%%
%%  function SP2_Check4RowVec(varargin)
%%  checks vector to be of row format. If the vector is a column vector, it is changed to a 
%%  row vector
%%
%%  01-2004, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Check4RowVecR';


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
    fprintf('%s -> more than 2 input arguments are not allowed ...',FCTNAME);
    return
end

%--- parameter assessment ---
if ~isnumeric(vector)
    fprintf('%s -> vector <%s> is not numeric!',FCTNAME,varName);
    return
end
vecSize = size(vector);
if length(vecSize)>2
    fprintf('%s -> function argument <%s> is not a vector\n',FCTNAME,varName);
    return
end
if vecSize(1)==1 && vecSize(2)>1
    % regular case
elseif vecSize(1)>1 && vecSize(2)==1
    fprintf('%s -> <%s> is a column vector, not a row vector',FCTNAME,varName);
    return
elseif vecSize(1)~=1 && vecSize(2)~=1
    fprintf('%s -> <%s> is a data array, not a vector\n',FCTNAME,varName);
    return
end

%--- update success flag ---
f_succ = 1;


