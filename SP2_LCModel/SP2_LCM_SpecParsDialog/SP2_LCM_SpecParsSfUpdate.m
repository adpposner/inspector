%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecParsSfUpdate
%% 
%%  Update SF.
%%
%%  05-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- parameter update ---
lcm.sf = max(str2num(get(fm.lcm.dialog1.sf,'String')),0);

%--- window update ---
set(fm.lcm.dialog1.sf,'String',num2str(lcm.sf))

end
