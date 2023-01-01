%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_LcmWritePars
%%
%%  Function to write parameters to file in Provencher LCModel format.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc


FCTNAME = 'SP2_Proc_LcmWritePars';


%--- init success flag ---
f_succ = 0;

%--- parameter handling ---
LCMEXT   = '.lcm';	% of LCM data directory
FNAMEDEF = 'lcm';	 

LCMEXT2  = '.PLOTIN';
NLBEGIN2 = '$PLTRAW';
NLEND2   = '$END';

LCMEXT3  = '.CONTROL';
NLBEGIN3 = '$LCMODL';
NLEND3   = '$END';


%--- write PLOTIN file ---
file = [proc.expt.dataDir 'lcm_default.PLOTIN'];
unit = fopen(file,'w');
if unit<0
    fprintf('%s -> Cannot open <%s>',FCTNAME,file);
    return
end
fprintf('%s -> writing <%s>\n',FCTNAME,file);
    
fprintf(unit,' %s\n',NLBEGIN2);
fprintf(unit,' HZPPPM=%g\n',proc.lcmHeader.HZPPPM);
fprintf(unit,' NUNFIL=%d\n',proc.lcmHeader.NUNFIL);
fprintf(unit,' DELTAT=%g\n',proc.lcmHeader.DELTAT);
fprintf(unit,' FILRAW=''%s''\n',proc.lcmHeader.FILRAW);
fprintf(unit,' FILPS=''%s''\n',proc.lcmHeader.FILPS);
fprintf(unit,' PPMST=%g\n',proc.lcmHeader.PPMST);
fprintf(unit,' PPMEND=%g\n',proc.lcmHeader.PPMEND);
%     fprintf(unit,' DEGPPM=%g\n',proc.lcmHeader.DEGPPM);
%     fprintf(unit,' DEGZER=%g\n',proc.lcmHeader.DEGZER);
fprintf(unit,' %s\n',NLEND2);

fclose(unit);
 
%--- write CONTROL file ---
file = [proc.expt.dataDir 'lcm_default.CONTROL'];
unit = fopen(file,'w');
if unit<0
    fprintf('%s -> Cannot open <%s>',FCTNAME,file);
    return
end
fprintf('%s -> writing <%s>\n',FCTNAME,file);
 
fprintf(unit,' %s\n',NLBEGIN3);
fprintf(unit,' TITLE=''%s''\n',proc.lcmHeader.TITLE);
fprintf(unit,' OWNER=''Yale University''\n');
fprintf(unit,' KEY=   3517309\n');
fprintf(unit,' FILRAW=''%s''\n',proc.lcmHeader.FILRAW);
fprintf(unit,' FILBAS=''%s''\n',proc.lcmHeader.FILBAS);
fprintf(unit,' FILPS=''%s''\n',proc.lcmHeader.FILPS2);
fprintf(unit,' FILCOO=''%s''\n',proc.lcmHeader.FILCOO);
fprintf(unit,' LCOORD=9\n');
fprintf(unit,' FILPRI=''lcm.PRI''\n');
fprintf(unit,' LPRINT=6\n');
fprintf(unit,' PGNORM=''A4''\n');
 
% add macromolecule/lipid spectrum:
% fprintf(unit,' CHSIMU(1) =''MM @ 0.88 +- .001 FWHM= .099 < .1 +- .001 AMP= 1.16 @ 0.94 FWHM= .1 AMP= 1.24 @ 1.22 FWHM= .1 AMP= 0.58 @ 1.41 FWHM= .1 AMP= 1.19 @ 1.70 FWHM= .15 AMP= 1.02 @ 2.05 FWHM= .25 AMP= 1.82 @ 2.29 FWHM= .15 AMP= 1.02 @ 2.54 FWHM= .25 AMP= 0.001 @ 2.74 FWHM= .1 AMP= 0.19 @ 3.00 FWHM= .1 AMP= 0.55 @ 3.22 FWHM= .1 AMP= 0.65 @ 3.80 FWHM= .35 AMP= 2.96 @ 4.29 FWHM= .35 AMP= 0.77''\n');
% fprintf(unit,' NSIMUL=1\n');

fprintf(unit,' DKNTMN=10\n');
fprintf(unit,' NOMIT=%d\n',16);
fprintf(unit,' CHOMIT(16)=''Scyllo''\n');
fprintf(unit,' CHOMIT(15)=''Ala''\n');
fprintf(unit,' CHOMIT(14)=''MM09''\n');
fprintf(unit,' CHOMIT(13)=''MM12''\n');
fprintf(unit,' CHOMIT(12)=''MM14''\n');
fprintf(unit,' CHOMIT(11)=''MM17''\n');
fprintf(unit,' CHOMIT(10)=''MM20''\n');
fprintf(unit,' CHOMIT(9)=''Lip09''\n');
fprintf(unit,' CHOMIT(8)=''Lip13a''\n');
fprintf(unit,' CHOMIT(7)=''Lip13b''\n');
fprintf(unit,' CHOMIT(6)=''Lip20''\n');
fprintf(unit,' CHOMIT(5)=''Gly''\n');
fprintf(unit,' CHOMIT(4)=''PCho''\n');
fprintf(unit,' CHOMIT(3)=''-CrCH2''\n');
fprintf(unit,' CHOMIT(2)=''Gua''\n');
fprintf(unit,' CHOMIT(1)=''Cho''\n');

%     fprintf(unit,' CHOMIT(1)=''GPC''\n');
%     fprintf(unit,' NUSE1=%g\n',6);
%     fprintf(unit,' CHUSE1=''NAA'',''Cr'',''Lac'',''Ins'',''Glu'',''Glc''\n');
fprintf(unit,' NEACH=%d\n',proc.lcmHeader.NEACH);
%     fprintf(unit,' PPMSHF=%g\n',proc.lcmHeader.PPMSHF);
fprintf(unit,' FWHMBA=%g\n',proc.lcmHeader.FWHMBA);
%     fprintf(unit,' RFWHM=%g\n',proc.lcmHeader.RFWHM);
%     fprintf(unit,' DOREFS(1)=%s\n','T');
%     fprintf(unit,' DOREFS(2)=%s\n','T');
% fprintf(unit,' DKNTMN=%g\n',proc.lcmHeader.DKNTMN);
fprintf(unit,' PPMEND=%g\n',proc.lcmHeader.PPMEND);
fprintf(unit,' PPMST=%g\n',proc.lcmHeader.PPMST);
fprintf(unit,' DEGZER=%g\n',proc.lcmHeader.DEGZER);
fprintf(unit,' SDDEGZ=%g\n',proc.lcmHeader.SDDEGZ);
fprintf(unit,' DEGPPM=%g\n',proc.lcmHeader.DEGPPM);
fprintf(unit,' SDDEGP=%g\n',proc.lcmHeader.SDDEGP);
fprintf(unit,' NAMREL=''%s''\n',proc.lcmHeader.NAMREL);
fprintf(unit,' CONREL=%g\n',proc.lcmHeader.CONREL);
fprintf(unit,' ISDBOL=%g\n',proc.lcmHeader.ISDBOL);
fprintf(unit,' DELTAT=%g\n',1/proc.lcmHeader.DELTAT);
fprintf(unit,' NUNFIL=%d\n',proc.lcmHeader.NUNFIL);
fprintf(unit,' HZPPPM=%g\n',proc.lcmHeader.HZPPPM);
fprintf(unit,' %s\n',NLEND3);
fclose(unit);

%--- info printout ---
fprintf('%s ->\nParameters successfully written to file.\n',FCTNAME)

%--- update success flag ---
f_succ = 1;


   
