%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_CalcFidArrSerial
%%
%%  Calculation of Rx-combined FID array.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_MM_CalcFidArrSerial';


%--- init success flag ---
f_done = 0;

%--- data reformating: merge series ---
% from fid(series,nspecC,individual NR) to fid(nspecC, total NR)
% note that this step is outside the above processing module in case
% further corrections have been applied, ie. to make sure the
% latest/current data is used.
% fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 1 3]),data.spec1.nspecC,...
%                        data.spec1.seriesN*data.spec1.nr);
data.spec1.fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
                                  data.spec1.seriesN*data.spec1.nr);

%--- update success flag ---
f_done = 1;
