%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function printStr = SP2_Vec2PrintStrSign(varargin)
%%
%%  printStr = SP2_Vec2PrintStr(vector)
%%  converts a vector to a string, that can directly be printed out
%%  e.g. vec = [1 2 3] -> '[1.0 2.0 3.0]' 
%%  A second function argument can be used to assign the number of digits (default: 1)
%%  A third argument can be used to limit the maximum number of digits (default: number of significan digits)
%%  A fourth argument can be used to switcht the brackets off (default: on)
%%  A fifth function argument can be used to assign the number of spaces between the vector entries (default: 1)
%% 
%%  Christoph Juchem, 06-2013
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Vec2PrintStr';

narg = nargin;
if narg==1
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = 1;
    digmax  = digits;
    brFlag  = 1;
    spaces  = 1;
elseif narg==2
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    digmax  = digits;
    brFlag  = 1;
    spaces  = 1;
elseif narg==3
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    digmax  = SP2_Check4IntBigger0R(varargin{3});
    brFlag  = 1;
    spaces  = 1;
elseif narg==4
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    digmax  = SP2_Check4IntBigger0R(varargin{3});
    brFlag  = SP2_Check4FlagR(varargin{4});
    spaces  = 1;
elseif narg==5
    vector  = SP2_Check4RowVecR(varargin{1});
    digits  = SP2_Check4NumR(varargin{2});
    digmax  = SP2_Check4IntBigger0R(varargin{3});
    brFlag  = SP2_Check4FlagR(varargin{4});
    spaces  = SP2_Check4NumR(varargin{5});
else
    fprintf('%s ->\nMore than 4 function arguments are not supported!\n\n',FCTNAME);
    return
end

vecSize = size(vector);
if length(vecSize)>2
    fprintf('%s ->\nOnly vectors are supported.\n\n',FCTNAME);
    return
end
if vecSize(1)==1 && vecSize(2)>1
    vecLen = vecSize(2);
elseif vecSize(1)>1 && vecSize(2)==1
    vector = vector';
    vecLen = vecSize(1);
elseif vecSize(1)==1 && vecSize(2)==1        % single point
    vecLen = 1;
else
    fprintf('%s ->\nData format of <vector> is not supported.\n\n',FCTNAME);
    return
end

spaceStr = '';      % intermediate spaces
for icnt = 1:spaces
    spaceStr = [spaceStr ' '];
end
if brFlag           % brackets
    printStr = eval(['sprintf(''[%.' strtok(num2str(min(SP2_SignDigitN(vector(1,1),digits),digmax)),' ') 'f'',vector(1,1))']);
else
    printStr = eval(['sprintf(''%.' strtok(num2str(min(SP2_SignDigitN(vector(1,1),digits),digmax)),' ') 'f'',vector(1,1))']);
end
for icnt = 1:vecLen
    if icnt>1
        printStr = [printStr spaceStr eval(['sprintf(''%.' num2str(min(SP2_SignDigitN(vector(1,icnt),digits),digmax)) 'f'',vector(1,icnt))'])];
    end
end
if brFlag
    printStr = [printStr ']'];
end
end
