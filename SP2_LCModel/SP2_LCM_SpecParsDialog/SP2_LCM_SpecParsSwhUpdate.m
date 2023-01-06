%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecParsSwhUpdate
%% 
%%  Update sweep width in Hertz.
%%
%%  06-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- parameter update ---
lcm.sw_h = max(str2num(get(fm.lcm.dialog1.swh,'String')),0);

%--- window update ---
set(fm.lcm.dialog1.swh,'String',num2str(lcm.sw_h))

end
