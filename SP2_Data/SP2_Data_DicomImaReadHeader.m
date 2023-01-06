%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [header, f_succ] = SP2_Data_DicomImaReadHeader( fidFile )
%%
%%  10/2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--- init success flag ---
f_succ = 0;

%--- file consistency ---
if ~SP2_CheckFileExistenceR(fidFile)
    return
end

%--- read header ---
header = dicominfo(fidFile);

%--- update success flag ---
f_succ = 1;



end
