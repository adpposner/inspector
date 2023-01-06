%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignAmplRef1StrUpdate
%% 
%%  Update function for FID string assignment for spectrum
%%  amplitude alignment.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm

FCTNAME = 'SP2_MM_AlignAmplRef1StrUpdate';


%--- initial string assignment ---
mm.amAlignRef1Str = get(fm.mm.align.amRef1Str,'String');

%--- consistency check ---
if any(mm.amAlignRef1Str==',') || any(mm.amAlignRef1Str==';') || ...
   any(mm.amAlignRef1Str=='[') || any(mm.amAlignRef1Str==']') || ...
   any(mm.amAlignRef1Str=='(') || any(mm.amAlignRef1Str==')') || ...
   any(mm.amAlignRef1Str=='.') || any(mm.amAlignRef1Str=='''')
    fprintf('\nFID scan ranges have to be assigned as single space\n');
    fprintf('integer list using the following format:\n');
    fprintf('example 1, FIDs 1 through 10:   1:10\n');
    fprintf('example 2, FIDS 1,3,5,7,9,15:   1:2:9 15\n\n');
    return
end

%--- string conversion ---
mm.amAlignRef1Vec = str2num(mm.amAlignRef1Str);

%--- consistency checks ---
if any(mm.amAlignRef1Vec<0)
    fprintf('%s ->\nAt least one reference FID is <0.\n',FCTNAME);
    return
else
    mm.amAlignRef1N = length(mm.amAlignRef1Vec);    % number of reference scans
end

%--- update field ---
set(fm.mm.align.amRef1Str,'String',mm.amAlignRef1Str)

%--- info printout ---
fprintf('Reference series 1 for amplitude alignment:\n');
fprintf('%s\n',SP2_Vec2PrintStr(mm.amAlignRef1Vec,0));
fprintf('\n');





end
