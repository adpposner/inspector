%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecParsNspeccUpdate
%% 
%%  Update number of complex points (i.e. FID length).
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- parameter update ---
lcm.nspecC     = max(round(str2num(get(fm.lcm.dialog1.nspecC,'String'))),0);
lcm.nspecCOrig = lcm.nspecC;

%--- window update ---
set(fm.lcm.dialog1.nspecC,'String',num2str(lcm.nspecC))

end
