%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ScrollRepetitionIncr
%% 
%%  Increase repetition number of spectral data set to be visualized.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- update receiver number ---
if isfield(data.spec1,'nr')
    data.scrollRep = min(data.scrollRep+1,data.spec1.nr);
else
    data.scrollRep = data.scrollRep + 1;
end

%--- update display
set(fm.data.scrRepNum,'String',num2str(data.scrollRep))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
