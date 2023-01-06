%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_VerboseFlagUpdate
%% 
%%  Switching on/off extended parameter display
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.verbose = get(fm.data.verbose,'Value');

%--- window update ---
set(fm.data.verbose,'Value',flag.verbose)

%--- figure update ---
SP2_Data_FigureUpdate;

end
