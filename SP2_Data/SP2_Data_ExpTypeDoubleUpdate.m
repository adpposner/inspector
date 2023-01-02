%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ExpTypeDoubleUpdate
%% 
%%  Experiment and data format:
%%  1: single spectrum
%%  2: 2 individual spectra
%%  3: editing experiment (in 1 data set)
%%  4: stability measurement
%%  5: T1/T2 measurement
%%  6: MRSI
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.dataExpType = 2;

%--- update display ---
set(fm.data.single,'Value',flag.dataExpType==1)
set(fm.data.double,'Value',flag.dataExpType==2)
set(fm.data.editing,'Value',flag.dataExpType==3)
set(fm.data.stability,'Value',flag.dataExpType==4)
set(fm.data.t1t2,'Value',flag.dataExpType==5)
set(fm.data.mrsi,'Value',flag.dataExpType==6)

%--- window update ---
SP2_Data_DataWinUpdate
