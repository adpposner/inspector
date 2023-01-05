%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplRef1StrUpdate
%% 
%%  Update function for FID string assignment for spectrum
%%  amplitude alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

FCTNAME = 'SP2_Data_AlignAmplRef1StrUpdate';


%--- initial string assignment ---
data.amAlignRef1Str = get(fm.data.align.amRef1Str,'String');

%--- consistency check ---
if any(data.amAlignRef1Str==',') || any(data.amAlignRef1Str==';') || ...
   any(data.amAlignRef1Str=='[') || any(data.amAlignRef1Str==']') || ...
   any(data.amAlignRef1Str=='(') || any(data.amAlignRef1Str==')') || ...
   any(data.amAlignRef1Str=='.') || any(data.amAlignRef1Str=='''')
    fprintf('\nFID scan ranges have to be assigned as single space\n');
    fprintf('integer list using the following format:\n');
    fprintf('example 1, FIDs 1 through 10:   1:10\n');
    fprintf('example 2, FIDS 1,3,5,7,9,15:   1:2:9 15\n\n');
    return
end

%--- string conversion ---
data.amAlignRef1Vec = str2num(data.amAlignRef1Str);

%--- consistency checks ---
if any(data.amAlignRef1Vec<0)
    fprintf('%s ->\nAt least one reference FID is <0.\n',FCTNAME);
    return
else
    data.amAlignRef1N = length(data.amAlignRef1Vec);    % number of reference scans
end

%--- update field ---
set(fm.data.align.amRef1Str,'String',data.amAlignRef1Str)

%--- info printout ---
fprintf('Reference series 1 for amplitude alignment:\n');
fprintf('%s\n',SP2_Vec2PrintStr(data.amAlignRef1Vec,0));
fprintf('\n');




