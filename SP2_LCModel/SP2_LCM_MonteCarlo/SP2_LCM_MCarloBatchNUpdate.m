%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloBatchNUpdate
%% 
%%  Update number of Monte-Carlo computations.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- get value ---
lcm.batch.n = max(round(str2num(get(fm.lcm.anaDoMcBatchN,'String'))),0);
if lcm.batch.n<3
    lcm.batch.n = 0;
end

%--- update display ---
set(fm.lcm.anaDoMcBatchN,'String',sprintf('%.0f',lcm.batch.n))


