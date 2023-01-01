%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid,f_succ] = SP2_Proc_FreqShift(datStruct)
%%
%%  Frequency shift.
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_FreqShift';


%--- init success flag ---
f_succ = 0;

%--- frequency correction ---
tVec   = (0:datStruct.nspecC-1)' * datStruct.dwell;                 % time vector
datFid = datStruct.fid .* exp(1i*tVec*datStruct.shift*2*pi);       % apply phase correction

%--- update success flag ---
f_succ = 1;
