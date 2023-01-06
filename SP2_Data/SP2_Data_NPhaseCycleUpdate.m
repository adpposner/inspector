%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_NPhaseCycleUpdate
%% 
%%  Update number of employed phase cycling steps.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
data.nPhCycle = str2double(get(fm.data.nPhCycle,'String'));

%--- parameter check ---
pwr2Vec = 2.^(0:10);
[val,ind] = min(abs(pwr2Vec-data.nPhCycle));
data.nPhCycle = pwr2Vec(ind);

%--- window update ---
set(fm.data.nPhCycle,'String',sprintf('%.0f',data.nPhCycle))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
