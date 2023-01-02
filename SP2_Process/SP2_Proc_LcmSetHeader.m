%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_LcmSetHeader
%%
%%  Function to set header for Provencher LCModel.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc

      
%--- init success flag ---
f_succ = 0;

%--- user defined parameters -----------------------------------------------
proc.lcmHeader.DIRAPP    = '';
proc.lcmHeader.TWODIM    = 0;
proc.lcmHeader.LSHIFT    = 0;
proc.lcmHeader.CT        = 0;
proc.lcmHeader.WDWEM     = 0;
proc.lcmHeader.COMM      = {sprintf('Created: %s',date)};	    % cell array of comments
proc.lcmHeader.ID        = proc.expt.dataPathRaw;
proc.lcmHeader.SHOWRAW   = 0;
proc.lcmHeader.MACHINE   = '';                  % strarray of possible machines
proc.lcmHeader.XSIZE     = proc.expt.nspecC;
proc.lcmHeader.NODISPLAY = 0;
proc.lcmHeader.TRAMP     = 1.0;
proc.lcmHeader.VOLUME    = 1.0;
proc.lcmHeader.DEGZER    = 0;
proc.lcmHeader.SDDEGZ    = 20;                  % e.g. 20 for quite a bit of variability
proc.lcmHeader.DEGPPM    = 20;
proc.lcmHeader.SDDEGP    = 20;                  % e.g. 4 for only very little variability
proc.lcmHeader.PPMST     = 4.2;                 % 4.2
proc.lcmHeader.PPMEND    = 1.0;                 % 1.0
proc.lcmHeader.FWHMBA    = 0.013;               % default: 0.013
proc.lcmHeader.RFWHM     = 2.0;
proc.lcmHeader.SHIFMN    = [1.8 4.2];
proc.lcmHeader.NAMREL    = 'Cr+PCr';
proc.lcmHeader.CONREL    = 1;
proc.lcmHeader.ISDBOL    = 20;
proc.lcmHeader.PPMSHF    = 0;
proc.lcmHeader.NEACH     = 999;
proc.lcmHeader.CHOMIT    = '';
proc.lcmHeader.CHKEEP    = '';
proc.lcmHeader.VITRO     = 0;
proc.lcmHeader.DKNTMN    = 0.1;                 % -> parameter to handle base line flexibility (normally non-visible)
proc.lcmHeader.NOXXT2    = 0;

%--- automatically set parameters -------------------------------------
proc.lcmHeader.BASIS     = '/usr/local/mpi/LCModel/mpi_7T_TE10TM10/output/7T_TE10TM10.basis'; 
proc.lcmHeader.FILBAS    = proc.lcmHeader.BASIS;
proc.lcmHeader.HZPPPM    = proc.expt.sf;   
proc.lcmHeader.NUNFIL    = proc.expt.nspecC;
proc.lcmHeader.DELTAT    = 1/proc.expt.sw_h;
proc.lcmHeader.FILRAW    = 'lcm.RAW';
proc.lcmHeader.FILPS     = 'lcm_RAW.PS'; 
proc.lcmHeader.TITLE     = proc.expt.dataPathRaw;		% max length is 120 chars
proc.lcmHeader.FILPS2    = 'lcm.PS';
proc.lcmHeader.FILCOO    = 'lcm.COORD';


%--- consistency checks -----------------------------------------------
if length(proc.lcmHeader.SHIFMN)~=2
    fprintf('length(SHIFMN)~=2\nProgram aborted.');
end

%--- update success flag ---
f_succ = 1;




