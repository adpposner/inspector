%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SequOriginUpdate
%% 
%%  Update function for vendor selection.
%%  1: 'General Electric'
%%  2: 'Siemens'
%%  3: 'Phillips'
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

FCTNAME = 'SP2_MARSS_SequOriginUpdate';


%--- retrieve parameter ---
flag.marssSequOrigin = get(fm.marss.sequOrigin,'Value');

%--- update vendor-specific sequence selection ---
if ~SP2_MARSS_SimCaseUpdate
    return
end
    
%--- update window ---
SP2_MARSS_MARSSWinUpdate





