%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PvConvdta(FILENAME)
%%
%%  function SP2_Data_PvConvdta(FILENAME)
%%  converts digitally filtered Avance aquistion data to 'analog' data format. Data vector length and file
%%  size are reduced accordingly
%%  http://garbanzo.scripps.edu/nmrgrp/wisdom/dig.nmrfam.txt
%%  http://www.acdlabs.com/publish/offlproc.html
%%
%% 02-2004, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global acqp acqpRef 
global nx ny nspecC
global hflag hcte pars


FCTNAME  = 'CSI11_Convdta';
ANGTORAD = pi/180;       % proportionaliy factor to change format degree in radiant degree*RADIANT = angle in rad
FAKENAME = 'fake';
if strcmp(FILENAME,'data')
    EXPNO = pars.expNo;    
    ni    = acqp.NI;
    ns    = acqp.NSLICES;
    nr    = acqp.NR;
else
    EXPNO = pars.expNoRef;
    ni    = acqpRef.NI;
    ns    = acqpRef.NSLICES;
    nr    = acqpRef.NR;
end

%----- determination of PhaseFac & datShift out of ConvDat -----
[ConvDat,f_done] = SP2_Data_AvanceConvList;
if ~f_done
    fprintf('\nReading CONVDTA details failed. Program aborted.\n\n');
    return
end
PhaseFac = mod(ConvDat,1);
datShift = ConvDat - PhaseFac;
nspecTmp = nspecC - datShift;


%--- create secoundary file for final data storage ---------
fakeSize = 2*nspecTmp*nx*ny*ni;       % = new array size
fakeData = zeros(fakeSize,1);
fakefile = sprintf('%s%s/%s/%s',pars.stdpath,pars.study,num2str(EXPNO),FAKENAME);
[fakefid,message] = fopen(fakefile,'w');
if ~isempty(message)
    fprintf('%s -> can''t create fake file',FCTNAME);
    return
end
fcount = fwrite(fakefid,fakeData,'double');
if fcount ~= fakeSize
    fprintf('%s -> writing fakeData into file failed',FCTNAME);
    return
end
fseek(fakefid,0,'bof');
clear fakeData


%---- 'convdta' routine ---------------------------------
file = sprintf('%s%s/%s/%s',pars.stdpath,pars.study,num2str(EXPNO),FILENAME);
fid = fopen(file, 'r');
if fid <= 0   
    fprintf('%s -> opening %s failed',FCTNAME,file);
    return
end

dataTmp  = complex(zeros(2,nspecC));
dataTmp2 = complex(zeros(1,nspecC-datShift));
for iNX = 1:nx
    for iNY = 1:ny
        for iNI = 1:ni
            if ftell(fid) ~= (2*((iNY+(iNX-1)*ny)-1)+(iNI-1))*2*nspecC*pars.nbyte
                fprintf('%s -> file pointer handling for data access failed at (iNX,iNY)=(%i,%i)\nftell(fid)=%i, product=%i\n'...
                        ,FCTNAME,iNX,iNY,ftell(fid),(2*((iNY+(iNX-1)*ny)-1)+(iNI-1))*2*nspecC*pars.nbyte)
                return
            end 
            % fseek(fid,(2*((iNY+(iNX-1)*ny)-1)+(iNI-1))*2*nspecC*pars.nbyte,'bof');
            [data,fcount] = fread(fid,2*nspecC,'*double');
            if fcount ~= 2*nspecC
                fprintf('%s -> reading file %s failed at iNX/iNY/fcount/2*nspecC=%.0f/%0.f/%.0f/%.0f'...
                        ,FCTNAME,FILENAME,iNX,iNY,fcount,2*nspecC)
                return
            end
            dataTmp = reshape(data,2,nspecC);
            datRaw = complex(dataTmp(1,:),dataTmp(2,:));

            %------- circular shift/data rotation --------------
            dataTmp2 = datRaw(1,datShift+1:nspecC);

            dataTmp2 = fftshift(fft(dataTmp2)); 
            FirstPhase  = 360 * PhaseFac;
            % Bruker notation for phasing is used

            %------- 1st order phase correction --------
            if FirstPhase==0
                phaseCorr = zeros(1,nspecTmp);
            else
                phaseCorr = (0:FirstPhase/(nspecTmp-1):FirstPhase);
            end

            datConvdta = dataTmp2 .* exp(i*phaseCorr*ANGTORAD);
            clear datTmp phaseCorr
            datConvdta = ifft(ifftshift(datConvdta));
            % fprintf('CSI_Convdta() -> (nx,ny)=(%i,%i)\n',iNX,iNY);

            %--- write data into fakefile --------
            datTmp = zeros(2,nspecTmp);             % it's still the reduced 'nspecC'!!!
            datTmp(1,:) = real(datConvdta);
            datTmp(2,:) = imag(datConvdta);
            % fprintf('nspecC=%i, iNX=%i, iNY=%i\n',nspecC,iNX,iNY);
            data2write = reshape(datTmp,2*nspecTmp,1);        
            % fseek(fakefid,((iNY+(iNX-1)*ny)-1)*2*nspecTmp*pars.nbyte,'bof');
            if ftell(fakefid) ~= (2*((iNY+(iNX-1)*ny)-1)+(iNI-1))*2*nspecTmp*pars.nbyte
                fprintf('%s -> file pointer handling for writing data into fakefile failed',FCTNAME);
                return
            end 
            fcount = fwrite(fakefid,data2write,'double');
            if fcount ~= 2*nspecTmp
                fprintf('%s -> writing data into fakefile failed',FCTNAME);
                return
            end

            if hflag.Debug
                if (iNX==1 && iNY==1)
                    figh = figure;
                    set(figh,'Name','CSI_Convdta');
                    subplot(2,2,1)
                    plot(real(fftshift(fft(datRaw))));
                    title('real(fft(datRaw))')
                    subplot(2,2,2)
                    plot(imag(fftshift(fft(datRaw))));
                    title('imag(fft(datRaw))')
                    subplot(2,2,3)
                    plot(real(fftshift(fft(datConvdta))));
                    title('real(fft(datConvdta))')
                    subplot(2,2,4)
                    plot(imag(fftshift(fft(datConvdta))));
                    title('imag(fft(datConvdta))')
                end
            end
            clear datRaw datConvdta
        end
    end
end
clear data2write datTmp

nspecC = nspecTmp;
fprintf('%s -> nspecC reduced to %i\n',FCTNAME,nspecC);
ans = fclose(fid);
if ans ~= 0
    fprintf('%s -> original data file ''%s'' hasn''t couldn''t be closed...',FCTNAME,FILENAME);
    return
end
ans = fclose(fakefid);
if ans ~= 0
    fprintf('%s -> fake file couldn''t be closed ...',FCTNAME);
    return
end
      
%--- delete original FILENAME file & rename fake file to be the new FILENAME file ---
delete(file)
[status,msg] = copyfile(fakefile,file);
if status ~= 1
    fprintf('%s -> copying of fakefile into new data file ''%s'' failed',FCTNAME,FILENAME);
    return
end
delete(fakefile)
clear file fakefile

fprintf('%s of ''%s''\n',FCTNAME,FILENAME);


fake_line = 1;

end
