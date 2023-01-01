%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_PrintCell(cEll,varargin)
%
% function printCell(cEll,varargin)
% creates command window printout of all cell array fields and their corresponding values.
% A second argument can be assigned as maximum entries per cell field to be plotted. This might
% make sense when a very long cell field would hide all the other fields within the display.
%
% In general, the easiest way to create such a printout would be to omit the semicolon thereby
% showing all struct entries. But this fails, when field vectors are long...
%
% 01-2005, Christoph Juchem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_PrintCell';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
f_lim = 0;      % flag to switch on/off limit of field entries
if nargin==2
    f_lim = 1;
    limVal = SP2_Check4NumR(varargin{1});
elseif nargin~=1
    fprintf('%s -> number of arguments must be 1 or 2...\n%s\n',FCTNAME,help('printCell'))
    return
end   
    
fprintf('\n')
if ~iscell(cEll)
    fprintf('%s -> function argument is not a cell array\n',FCTNAME)
    return
end
nCell = length(cEll);
for icnt = 1:nCell
    fieldLen = length(char(cEll(icnt)));
    if f_lim        % limit of cell field entries is used
        fieldLen = min(fieldLen,limVal);
    end
    printStr = [num2str(icnt) ')\t'];
    printStr = [printStr char(cEll{icnt}(1:fieldLen)) '\n'];
    fprintf(printStr)
end
fprintf('\n')    

%--- update success flag ---
f_succ = 1;



