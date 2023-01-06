%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DataLoadAndReco
%%
%%  Load parameters and data of T1/T2 experiment from 'Data'
%%  page, resort the delays (if necessary) and perform the FFT.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_T1T2_DataLoadAndReco';


%--- init read flag ---
f_succ = 0;

%--- load data from 'data' page ---
if ~SP2_T1T2_DataLoad
    return
end

%--- resort delays ---
if ~SP2_T1T2_DataResort
    return
end

%--- resort delays ---
if ~SP2_T1T2_DataReco
    return
end

% %--- data export ---
% t1t2.expt = t1t2;
% if isfield(t1t2.expt,'spec')
%     t1t2.expt = rmfield(t1t2.expt,'spec');
% end
% t1t2.expt.fid = t1t2.fidOrig;

%--- update read flag ---
f_succ = 1;

end
