%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_RcvrSelectStrUpdate
%% 
%%  Update function for receiver selection vector and string
%%
%%  01-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data flag

%--- display setting variables ---
threshLen = 50;         % threshold length
cutLen    = 46;         % string length after which the next space is used for cutting

FCTNAME = 'SP2_Data_RcvrSelectStrUpdate';


%--- initial string assignment ---
rcvrSelectStr = get(fm.data.rcvrSelStr,'String');

%--- consistency check ---
if any(rcvrSelectStr==',') || any(rcvrSelectStr==';') || ...
   any(rcvrSelectStr=='[') || any(rcvrSelectStr==']') || ...
   any(rcvrSelectStr=='(') || any(rcvrSelectStr==')') || ...
   any(rcvrSelectStr=='''') || any(rcvrSelectStr=='.') || ...
   isempty(rcvrSelectStr)
    fprintf('\nReceivers have to be assigned as space\n')
    fprintf('separated list using the following format:\n')
    fprintf('min=1, max=#receivers, integer values & steps, no further formating\n')
    fprintf('example 1: 1:2:5\n')
    fprintf('example 2: 3:10 15:20 12\n\n')
    set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
    return
end

%--- calibration vector assignment ---
rcvrSelect = eval(['[' rcvrSelectStr ']']);         % temporary selection vector assignment
% rcvrSelectN = length(rcvrSelect);                 % number of selected FIDs (per receiver)

%--- check for vector consistency ---
if any(diff(rcvrSelect)==0)
    fprintf('%s ->\nMultiple assignments of the same experiment detected...\n',FCTNAME)
    set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
    return
end
if ~isnumeric(rcvrSelect)
    fprintf('%s ->\nVector formation failed\n',FCTNAME)
    set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
    return
end
if any(rcvrSelect<1)
    fprintf('%s ->\nMinimum experiment number <1 detected!\n',FCTNAME)
    set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
    return
end
if isfield(data.spec1,'nRcvrs')
    if any(rcvrSelect>data.spec1.nRcvrs)
        fprintf('%s ->\nMaximum receiver number exceeds number of available data set (rcvr max: %.0f)!\n',FCTNAME,data.spec1.nRcvrs)
        set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
        return
    end
end
if isempty(rcvrSelect)
    fprintf('%s ->\nEmpty receiver vector detected.\nMinimum: 1 receiver!\n',FCTNAME)
    set(fm.data.rcvrSelStr,'String',data.rcvrSelectStr)
    return
end

%--- current receiver assignment ---
data.rcvrSelectStr  = rcvrSelectStr;                            % note that data.rcvr is allowed to change without data.rcvrDisplayStr changing
data.rcvrInd        = eval(['[' data.rcvrSelectStr ']']);       % selection vector assignment
if isfield(data.spec1,'nRcvrs')
    data.rcvrInd    = data.rcvrInd(data.rcvrInd<=data.spec1.nRcvrs);
    data.rcvr       = zeros(1,data.spec1.nRcvrs);               % selection vector assignment
else
    data.rcvr       = zeros(1,data.rcvrMax);                    % selection vector assignment
end
data.rcvr(data.rcvrInd) = 1;
data.rcvrN          = length(data.rcvrInd);                     % number of selected receivers

%--- info printout ---
if flag.verbose
    fprintf('Current Rx selection (%.0f total):\n%s\n',data.rcvrN,SP2_Vec2PrintStr(data.rcvrInd,0))
end

%--- figure update ---
SP2_Data_FigureUpdate;



