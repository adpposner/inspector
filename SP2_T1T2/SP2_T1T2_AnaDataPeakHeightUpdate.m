%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaDataPeakHeightUpdate
%% 
%%  FID-based T2 analysis
%%
%%  1) FID
%%  2) peak height
%%  3) peak integral
%% 
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.t1t2AnaData = 2;

%--- switch radiobutton ---
set(fm.t1t2.anaDataFid,'Value',flag.t1t2AnaData==1)
set(fm.t1t2.anaDataSpecH,'Value',flag.t1t2AnaData==2)
set(fm.t1t2.anaDataSpecI,'Value',flag.t1t2AnaData==3)

%--- update window ---
SP2_T1T2_T1T2WinUpdate

end
