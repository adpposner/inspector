%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesAlign
%% 
%%  Phase and frequency alignment of MRS experiment series.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag fm

FCTNAME = 'SP2_Data_Dat1SeriesAlign';


%--- init success flag ---
f_succ = 0;

%--- temporarily disable data (NR) averaging ---
if ishandle(fm.data.spec1SeriesSum)
    set(fm.data.spec1SeriesSum,'Enable','off')
end

%--- experiment selection ---
if flag.dataExpType==2          % saturation-recovery
    if ~SP2_Data_Dat1SeriesAlignSatRec
        return
    end
elseif flag.dataExpType==3      % JDE
    if ~SP2_Data_Dat1SeriesAlignJde
        return
    end
elseif flag.dataExpType==7      % JDE array
    if ~SP2_Data_Dat1SeriesAlignJdeArray
        return
    end
else                            % all other cases (incl. simple STEAM/PRESS/LASER and JDE
    if ~SP2_Data_Dat1SeriesAlignRegular
        return
    end
end

%--- re-anable data averaging ---
if ishandle(fm.data.spec1SeriesSum)
    set(fm.data.spec1SeriesSum,'Enable','on')
end

%--- update success flag ---
f_succ = 1;



