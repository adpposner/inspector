%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaDataUpdate
%% 
%%  Update function for data format.
%%  1: first points of FID
%%  2: peak height
%%  3: peak integral
%%  4: direct assignment of amplitude/time vectors
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

FCTNAME = 'SP2_T1T2_AnaDataUpdate';


%--- retrieve parameter ---
flag.t1t2AnaData = get(fm.t1t2.anaData,'Value');

%--- window update ---
SP2_T1T2_T1T2WinUpdate





