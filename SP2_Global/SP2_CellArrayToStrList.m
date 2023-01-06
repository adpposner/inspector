%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function [strList, nFields, f_succ] = SP2_CellArrayToStrList(cellArray,varargin)
%%
%%  [strList, nFields] = CellArrayToStrList(cellArray)
%%  conversion of cell array to string list
%%  e.g. {'axial' 'sagittal' 'coronal'} -> 'axial sagittal coronal'
%%  for the opposite transformation see StrListToCellArray.m
%%  If a string is assigned as 2nd function argument, this string is used
%%  to separate the cells (defaul: single space)
%%
%%  Christoph Juchem, 01-2005
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_CellArrayToStrList';


%--- init success string ---
f_succ = 0;

%--- parameter handling ---
if nargin==1
    substStr = ' ';
elseif nargin==2
    substStr = SP2_Check4StrR(varargin{1});
else
    fprintf('%s -> only one or two function arguments are supported!',FCTNAME);
    return
end
    
%--- cell characterization ---
if iscell(cellArray)   
    nFields = length(cellArray);
    strList = cellArray{1};
    if nFields>1
        for fCnt = 2:nFields
            strList = [strList substStr cellArray{fCnt}];
        end
    end
else
    fprintf('%s -> function argument is not of type ''cell''',FCTNAME);
    return
end

%--- update success flag ---
f_succ = 1;




end
