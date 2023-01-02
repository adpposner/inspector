%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [ConvDat, f_succ] = SP2_Data_AvanceConvList
%%
%% function ConvDat = SP2_Data_AvanceConvList
%%
%% function that uses DECIM and DSPFVS (acqus file, part of global loggingfile acqp parameter)
%% to give back the corresponding value for data rotation and 1st order phasing
%% -> technical report of Westler & Abildgaard, 1996
%% http://garbanzo.scripps.edu/nmrgrp/wisdom/dig.nmrfam.txt
%% http://www.acdlabs.com/publish/offlproc.html
%%
%% 10-2002, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile acqp


%--- init success flag ---
f_succ = 0;

Decim = acqp.DECIM;
Dspfvs = acqp.DSPFVS;

Dspfvs10Vec = [44.75 33.5 66.625 59.0833 68.5625 60.375 69.5313 61.0208 70.0156 61.3438 70.2578 61.5052 70.3789...
               61.5859 70.4395 61.6263 70.4697 61.6465 70.4849 61.6566 70.4924];
Dspfvs11Vec = [46 36.5 48 50.1667 53.25 69.5 72.25 70.1667 72.75 70.5 73 70.6667 72.5 71.3333 72.25 71.6667 72.125 71.8333 72.0625 71.9167 72.0313];
Dspfvs12Vec = [46.311 36.53 47.87 50.229 53.289 69.551 71.6 70.184 72.138 70.528 72.348 70.7 72.524 0 0 0 0 0 0 0 0];

DatMat = zeros(3,21);
DatMat = [Dspfvs10Vec(1,:)',Dspfvs12Vec(1,:)',Dspfvs12Vec(1,:)'];

%--- DECIM selection ---
switch Decim
    case 2, DecimInd=1;
    case 3, DecimInd=2;
    case 4, DecimInd=3;
    case 6, DecimInd=4;
    case 8, DecimInd=5;
    case 12, DecimInd=6;
    case 16, DecimInd=7;
    case 24, DecimInd=8;
    case 32, DecimInd=9;
    case 48, DecimInd=10;
    case 64, DecimInd=11;
    case 96, DecimInd=12;
    case 128, DecimInd=13;
    case 192, DecimInd=14;
    case 256, DecimInd=15;
    case 384, DecimInd=16;
    case 512, DecimInd=17;
    case 768, DecimInd=18;
    case 1024, DecimInd=19;
    case 1536, DecimInd=20;
    case 2048, DecimInd=21;
    otherwise, fprintf('\n--- WARNING ---\nDECIM does not have a legal value\n\n');
end

%--- DSPFVS selection ---
switch Dspfvs
    case 10, DspfvsInd=1;
    case 11, DspfvsInd=2;
    case 12, DspfvsInd=3;
    otherwise, fprintf('\n--- WARNING ---\nDspfvs does not have a legal value\n\n');
end

%--- consistenc check ---
if(DspfvsInd==3 && DecimInd>13)
    printf('\n--- WARNING ---\nCombination of DECIM and DSPFVS is not possible\n');
    return
end

%--- convDat assignment ---
ConvDat = DatMat(DecimInd,DspfvsInd);

%--- update success flag ---
f_succ = 1;
