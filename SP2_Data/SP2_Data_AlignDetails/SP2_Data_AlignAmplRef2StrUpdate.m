%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplRef2StrUpdate
%% 
%%  Update function for FID string assignment for spectrum
%%  amplitude alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_AlignAmplRef2StrUpdate';


%--- initial string assignment ---
data.amAlignRef2Str = get(fm.data.align.amRef2Str,'String');

%--- consistency check ---
if any(data.amAlignRef2Str==',') || any(data.amAlignRef2Str==';') || ...
   any(data.amAlignRef2Str=='[') || any(data.amAlignRef2Str==']') || ...
   any(data.amAlignRef2Str=='(') || any(data.amAlignRef2Str==')') || ...
   any(data.amAlignRef2Str=='.') || any(data.amAlignRef2Str=='''')
    fprintf('\nFID scan ranges have to be assigned as single space\n')
    fprintf('integer list using the following format:\n')
    fprintf('example 1, FIDs 1 through 10:   1:10\n')
    fprintf('example 2, FIDS 1,3,5,7,9,15:   1:2:9 15\n\n')
    return
end

%--- string conversion ---
data.amAlignRef2Vec = str2num(data.amAlignRef2Str);

%--- consistency checks ---
if any(data.amAlignRef2Vec<0)
    fprintf('%s ->\nAt least one reference FID is <0.\n',FCTNAME)
    return
else
    data.amAlignRef2N = length(data.amAlignRef2Vec);    % number of reference scans
end

%--- update field ---
set(fm.data.align.amRef2Str,'String',data.amAlignRef2Str)

%--- info printout ---
fprintf('Reference series 2 for amplitude alignment:\n')
fprintf('%s\n',SP2_Vec2PrintStr(data.amAlignRef2Vec,0))
fprintf('\n')




