%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [ConvDat, f_succ] = SP2_Data_PvAvanceConvList(dataSpec)

%% function that uses DECIM and DSPFVS (acqus file, part of global acqp parameter)
%% to give back the corresponding value for data rotation and 1st order phasing
%% -> technical report of Westler & Abildgaard, 1996
%% http://garbanzo.scripps.edu/nmrgrp/wisdom/dig.nmrfam.txt
%% http://www.acdlabs.com/publish/offlproc.html
%% http://sbtools.uchc.edu/help/nmr/nmr_toolkit/bruker_dsp_table.asp        (partial list, 01/2017)
%%
%% 10-2002 / 03-2017, Christoph Juchem
%% 10/2019, Irvine Cancer Center (9.4T) format added, Kenneth Olive, DECIM 2000, DSPFVS 20
%% 04/2020, Saaussan Madi (GSK) format added, P31, PV6.0.1, DECIM 1000
%% 12/2021, Corey Miller (Merck) format added, PV-360.2.0.pl.1, DECIM 0
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dspfvs00Vec = [zeros(1,25) -77.8];
Dspfvs00Vec = [zeros(1,25) 76.1];
Dspfvs10Vec = [44.75 33.5 66.625 59.0833 68.5625 60.375 69.5313 61.0208 70.0156 61.3438 70.2578 61.5052 70.3789...
               61.5859 70.4395 61.6263 70.4697 61.6465 70.4849 61.6566 70.4924 0 0 0 0 0];
Dspfvs11Vec = [46 36.5 48 50.1667 53.25 69.5 72.25 70.1667 72.75 70.5 73 70.6667 72.5 71.3333 72.25 71.6667 72.125 71.8333 72.0625 71.9167 72.0313 0 0 0 0 0];
Dspfvs12Vec = [46.311 36.53 47.87 50.229 53.289 69.551 71.6 70.184 72.138 70.528 72.348 70.7 72.524 0 0 0 0 0 0 0 0 0 0 0 0 0];
Dspfvs20Vec = [zeros(1,21) 69.01 68.06 68.06 68.3 0];     % for element content 22+ compare below
% 22: GFM data, DECIM=4000, DSPFVS=20
% 23: Ken Olive data (Irvine), DECIM 2000, DSPFVS=20
% 24: Ken Olive data (Irvine), DECIM 4544, DSPFVS=20
% 25: Saaussan Madi (GSK), DECIM 1000, DSPFVS 20
% 26: Corey Miller (Merck), DECIM 0, DSPFVS 0 (PV-360.2.0.pl.1)
% compare method.PVM_DigShift
                                                    
% DatMat = [Dspfvs10Vec(1,:)',Dspfvs12Vec(1,:)',Dspfvs12Vec(1,:)'];
DatMat = [Dspfvs00Vec(1,:)',Dspfvs10Vec(1,:)',Dspfvs11Vec(1,:)',Dspfvs12Vec(1,:)',Dspfvs20Vec(1,:)'];


%--- init success flag ---
f_succ  = 0;
ConvDat = 0;

%--- decimal factor of the digital filter ---
switch dataSpec.decim
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
    case 4000, DecimInd=22;             % GFM data
    case 2000, DecimInd=23;             % Ken Olive, Irvine Cancer Center
    case 4544, DecimInd=24;             % Ken Olive, Irvine Cancer Center
    case 1000, DecimInd=25;             % Saaussan Madi, GSK
    case 0, DecimInd=26;                % Corey Miller, Merck
    otherwise, fprintf('\n\nERROR:\nDECIM=%.0f is not supported.\n\n\n',dataSpec.decim); return
end

%--- DSP firmware version ---
switch dataSpec.dspfvs
    case 0, DspfvsInd=1;                % Corey Miller (Merck)
    case 10, DspfvsInd=2;
    case 11, DspfvsInd=3;
    case 12, DspfvsInd=4;
    case 20, DspfvsInd=5;               % GFM (Yale) data, Ken Olive (Irvine Cancer Center), Saaussan Madi (GSK), Corey Miller (Merck)
    otherwise, fprintf('\n\nERROR:\nDSPFVS=%.0f is not supported.\n\n\n',dataSpec.dspfvs); return
end

%--- convdat assignment ---
ConvDat = DatMat(DecimInd,DspfvsInd);

%--- update success flag ---
f_succ = 1;







end
