%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_RcvrAllUpdate
%% 
%%  Receiver selection mode:
%%  1: all available receivers
%%  0: selected receiver range
%%
%%  01-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data


%--- retrieve parameter ---
flag.dataRcvrAllSelect = get(fm.data.rcvrAll,'Value');

%--- update switches ---
set(fm.data.rcvrAll,'Value',flag.dataRcvrAllSelect)
set(fm.data.rcvrSelect,'Value',~flag.dataRcvrAllSelect)

%--- update of current receiver assignment ---
if flag.dataRcvrAllSelect                                           % all
    if isfield(data.spec1,'nRcvrs')
        data.rcvr       = ones(1,data.spec1.nRcvrs);                % selection vector assignment
    else
        data.rcvr       = ones(1,data.rcvrMax);                     % selection vector assignment
    end
    data.rcvrInd        = find(data.rcvr);                          %            
    data.rcvrN          = length(data.rcvrInd);                     % number of selected receivers
else                                                                % selection
    data.rcvrInd        = eval(['[' data.rcvrSelectStr ']']);       % selection vector assignment
    data.rcvr           = zeros(1,data.rcvrMax);                    %            
    data.rcvr(data.rcvrInd) = 1;
    data.rcvrN          = length(data.rcvrInd);                     % number of selected receivers
end

%--- info printout ---
if flag.verbose
    fprintf('Current Rx selection (%.0f total):\n%s\n',data.rcvrN,SP2_Vec2PrintStr(data.rcvrInd,0))
end

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate