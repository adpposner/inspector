%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SequenceUpdate
%% 
%%  Update function for MRS sequence selection.
%%  1: 'STEAM'
%%  2: 'PRESS'
%%  3: 'sLASER'
%%  4: 'Custom'
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

FCTNAME = 'SP2_MARSS_SequenceUpdate';


%--- retrieve parameter ---
flag.marssSequName = get(fm.marss.sequName,'Value');

%--- update vendor-specific sequence selection ---
if ~SP2_MARSS_SimCaseUpdate
    return
end
   
%--- update window ---
SP2_MARSS_MARSSWinUpdate





