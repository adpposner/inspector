%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function f_succ = SP2_PrintStructure(sTruct,varargin)
%%
%%  f_succ = SP2_PrintStructure(sTruct)
%%  Complete display of the content of a cell array including all 
%%  field names and their respective content.
%%
%%  Christoph Juchem, 04-2020
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_PrintStructure';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
if nargin==1
    substStr = ' ';
elseif nargin==2
    substStr = SP2_Check4StrR(varargin{1});
else
    fprintf('%s ->\nOnly one or two function arguments are supported!\n\n',FCTNAME);
    return
end

%--- consistency check ---
if ~isstruct(sTruct)
    fprintf('%s ->\nFunction argument is not a structure. Program aborted.\n\n',FCTNAME);
    return
end 
    
%--- cell handling ---
structFields = fields(sTruct);
structN      = length(structFields);

%--- cell display ---
fprintf('\nStructure <%s>\n',inputname(1));
for cCnt = 1:structN
    if cCnt==148
        stopHere = 1;
    end
    fieldVal = eval(['sTruct.' structFields{cCnt}]);
    if isnumeric(fieldVal)
        if isempty(fieldVal)
            fprintf('%.0f: %s.%s = []\n',cCnt,inputname(1),structFields{cCnt});
        elseif length(fieldVal)==1
            fprintf('%.0f: %s.%s = %f\n',cCnt,inputname(1),structFields{cCnt},fieldVal);
        else
            vecSize = size(fieldVal);
            if vecSize(1)==1 && vecSize(2)>1
                fprintf('%.0f: %s.%s = %s\n',cCnt,inputname(1),structFields{cCnt},SP2_Vec2PrintStr(fieldVal,6));
            elseif vecSize(1)>1 && vecSize(2)==1
                fprintf('%.0f: %s.%s = %s\n',cCnt,inputname(1),structFields{cCnt},SP2_Vec2PrintStr(fieldVal',6));
            elseif vecSize(1)~=1 && vecSize(2)~=1
                fprintf('%.0f: %s.%s = (is data array)\n',cCnt,inputname(1),structFields{cCnt});
            end
        end
    elseif ischar(fieldVal)
        if isempty(fieldVal)
            fprintf('%.0f: %s.%s = ''''\n',cCnt,inputname(1),structFields{cCnt});
        else
            fprintf('%.0f: %s.%s = %s\n',cCnt,inputname(1),structFields{cCnt},fieldVal);
        end
    elseif isstruct(fieldVal)
        fprintf('%.0f: %s.%s = (is struct)\n',cCnt,inputname(1),structFields{cCnt});
    elseif iscell(fieldVal)
        nCell = length(fieldVal);
        for fCnt = 1:nCell
            if fCnt==1
                printStr = char(fieldVal{fCnt});
            else
                printStr = [printStr ' ' char(fieldVal{fCnt})];
            end
        end
        if nCell>0
            fprintf('%.0f: %s.%s = %s\n',cCnt,inputname(1),structFields{cCnt},printStr);
        else
            fprintf('%.0f: %s.%s = {}\n',cCnt,inputname(1),structFields{cCnt});
        end
    else
        fprintf('%.0f: %s.%s = (format not recognized)\n',cCnt,inputname(1),structFields{cCnt});
    end
    fake = 1;
end
fprintf('\n');
    
%--- update success flag ---
f_succ = 1;

    

