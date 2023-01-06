%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ResultFormatUpdate
%% 
%%  Update function for data format.
%%  1: 'Binary format (.mat)'
%%  2: 'Text format (.txt)'
%%  3: 'JMRUI (.mrui)'
%%  4: 'LCModel (.raw)'
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

FCTNAME = 'SP2_MARSS_ResultFormatUpdate';

%--- retrieve parameter ---
flag.marssResultFormat = get(fm.marss.resultFormat,'Value');

%--- update window ---
SP2_MARSS_MARSSWinUpdate






end
