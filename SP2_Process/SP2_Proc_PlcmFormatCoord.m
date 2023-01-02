%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [plcm,f_succ] = SP2_Proc_PlcmFormatCoord( coord )
%%
%%  Reformat and plot LCModel COORD content.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile f_verbose

FCTNAME = 'SP2_Proc_PlcmFormatCoord';


%--- plot characteristics ---
overviewPPL  = 6;                   % plots per line for overview
diffPPL      = 4;                   % plots per line for difference plot

%--- init success flag ---
f_succ = 0;

%--- plot metabolite overview (maximally 6 plots per line) ---
if f_verbose
    NoResid = mod(coord.nconc,overviewPPL);
    NoRows  = (coord.nconc-NoResid)/overviewPPL+1;
    figh1   = figure;
    slashI  = find(coordFile=='\');
    namestr1 = sprintf(' %s: Metabolite Overview',coordFile(slashI(end-1)+1:slashI(end)-1));
    set(figh1,'Name',namestr1)
    set(figh1,'Position',[73 1 1208 956]);      
    for PlotCnt = 1:coord.nconc
        subplot(NoRows,overviewPPL,PlotCnt)
        plot(coord.mdata(:,PlotCnt))
        hold on
            plot(coord.data(:,4))
        hold off
        [MinXd, MaxXd, MinYd, MaxYd]     = SP2_IdealAxisValues(coord.mdata(:,PlotCnt));
        [MinXmd, MaxXmd, MinYmd, MaxYmd] = SP2_IdealAxisValues(coord.data(:,4));
        MinX = min(MinXd,MinXmd);
	    MaxX = max(MaxXd,MaxXmd);
	    MinY = min(MinYd,MinYmd);
	    MaxY = max(MaxYd,MaxYmd);
	    axis([MinX, MaxX, MinY, MaxY]);
	    xLabel = sprintf('%s',char(coord.metab(PlotCnt)));
	    xlabel(xLabel)
    end
end

%--- create array with single metabolite spectra for those that ------
%--- have been identified by LCModel --------------------------------------
plcm = [];          % init data array
coord.nconcI = 0;           % counting variable, number of identified metabolites
for icnt = 1:coord.nconc
    if (max(coord.mdata(:,icnt))>0 || min(coord.mdata(:,icnt))<0)   % check for values ~=0 
	    coord.nconcI = coord.nconcI + 1;
	    plcm.data{coord.nconcI}  = coord.mdata(:,icnt);
	    plcm.diff{coord.nconcI}  = coord.mdata(:,icnt) - coord.data(:,4);
	    plcm.metab{coord.nconcI} = coord.metab(icnt);
		plcm.conc{coord.nconcI}  = coord.conc(icnt);
		plcm.rconc{coord.nconcI} = coord.relconc(icnt);
        plcm.crlb{coord.nconcI}  = coord.SD(icnt);
        plcm.nconc           = coord.nconcI;
    end
end
plcm.orig   = coord.data(:,2);
plcm.fit    = coord.data(:,3);
plcm.basel  = coord.data(:,4);

%--- plot result ---
if f_verbose
    NoResidD = mod(coord.nconcI,diffPPL);
    NoRowsD  = (coord.nconcI-NoResidD)/diffPPL+1;
    figh2 = figure;
    namestr2 = sprintf(' Single Metabolites',FCTNAME);
    set(figh2,'Name',namestr1)
    set(figh2,'Position',[73 1 1208 956]);   
    for PlotCnt = 1:coord.nconcI
        subplot(NoRowsD,diffPPL,PlotCnt)
        plot(plcm.diff{PlotCnt})
        [MinXdiff, MaxXdiff, MinYdiff, MaxYdiff] = SP2_IdealAxisValues(plcm.diff{PlotCnt});
	    axis([MinXdiff, MaxXdiff, MinYdiff, MaxYdiff]);
	    xLabel = sprintf('%s',char(plcm.metab{PlotCnt}));
	    xlabel(xLabel)
    end
end

%--- update success flag ---
f_succ = 1;




