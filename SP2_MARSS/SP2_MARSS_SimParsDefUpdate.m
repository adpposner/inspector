%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SimParsDefUpdate
%% 
%%  Update function for data format.
%%  1: 'Data'
%%  2: 'Proc'
%%  3: 'MARSS'
%%  4: 'LCM'
%%  5: 'MRSI'
%%  6: 'Sim'
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

FCTNAME = 'SP2_MARSS_SimParsDefUpdate';

%--- retrieve parameter ---
flag.marssSimParsDef = get(fm.marss.simParsDef,'Value');

%--- update window ---
SP2_MARSS_MARSSWinUpdate






end
