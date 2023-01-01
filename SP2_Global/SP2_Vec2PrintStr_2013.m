%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function printStr = SP2_Vec2PrintStr(varargin)
%%
%%  printStr = SP2_Vec2PrintStr(vector)
%%  converts a vector to a string, that can directly be printed out
%%  e.g. vec = [1 2 3] -> '[1.0 2.0 3.0]' 
%%  A second function argument can be used to assign the number of digits (default: 1)
%%  A third function argument can be used to assign the number of spaces between the vector entries
%% 
%%  Christoph Juchem, 11-2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Vec2PrintStr';

narg = nargin;
if narg==1
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = 1;
    spaces  = 1;
    fSpaces = 0;
elseif narg==2
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    spaces  = 1;
    fSpaces = 0;
elseif narg==3
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    spaces  = SP2_Check4NumR(varargin{3});
    fSpaces = 0;
elseif narg==4
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    spaces  = SP2_Check4NumR(varargin{3});
    fSpaces = SP2_Check4NumR(varargin{4});
else
    error(sprintf('%s -> more than 2 function arguments are not supported!',FCTNAME))
end

vecSize = size(vector);
if length(vecSize)>2
    error(sprintf('%s -> only vectors are supported\n',FCTNAME));
end
if vecSize(1)==1 && vecSize(2)>1
    vecLen = vecSize(2);
elseif vecSize(1)>1 && vecSize(2)==1
    vector = vector';
    vecLen = vecSize(1);
elseif vecSize(1)==1 && vecSize(2)==1        % single point
    vecLen = 1;
else
    error(sprintf('%s -> data format of <vector> is not supported',FCTNAME))
end

spaceStr = '';      % intermediate spaces
for icnt = 1:spaces
    spaceStr = [spaceStr ' '];
end
printStr  = eval(['sprintf(''[%.' num2str(digits) 'f'',vector(1,1))']);
for icnt = 1:vecLen    
    if icnt>1
        printStr = [printStr spaceStr eval(['sprintf(''%.' num2str(digits) 'f'',vector(1,icnt))'])];
    end
end
fSpaceStr = '';     % final spaces
for icnt = 1:fSpaces
    fSpaceStr = [fSpaceStr ' '];
end
printStr = [printStr fSpaceStr ']'];


