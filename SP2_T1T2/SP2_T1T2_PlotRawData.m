%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_T1T2_PlotRawData( f_new )
%%
%%  Plot spectral array of multi-delay experiment.
%% 
%%  02-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global t1t2 flag

FCTNAME = 'SP2_T1T2_PlotSpecArray';


%--- init success flag ---
f_done = 0;

%--- check t1t2 existence ---
if ~isfield(t1t2,'fid')
    if ~SP2_T1T2_DataLoadAndReco
        return
    end
end

%--- data selection ---
if flag.t1t2AnaData==1      % FIDs
    if ~SP2_T1T2_PlotFidArray
        return
    end
else                        % spectra
    if ~SP2_T1T2_PlotSpecArray
        return
    end
end
    
%--- update success flag ---
f_done = 1;
