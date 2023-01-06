%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid,f_done] = SP2_MRSI_FreqShift(datStruct)
%%
%%  Frequency shift.
%%
%%  09-2008, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_FreqShift';


%--- init success flag ---
f_done = 0;

%--- frequency correction ---
phVec   = 0:datStruct.nspecC-1;                                  % basic phase vector
phPerPt = datStruct.shift*datStruct.dwell*datStruct.nspecC*(pi/180)/(2*pi);    % corr phase per point
datFid  = datStruct.fid .* exp(-1i*phPerPt*phVec');                % apply phase correction

%--- update success flag ---
f_done = 1;

end
