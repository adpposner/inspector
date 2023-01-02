%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_Analysis(datSpec,parsStruct,plotLim,varargin)
%%
%%  Spectral analysis function (SNR, FWHM, integration, baseline correction).
%%  Function arguments:
%%  1: full spectral data vector
%%  2: parameter structure (of spectrum 1 or spectrum 2)
%%  3: plotting limits
%%
%%  02-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag


FCTNAME = 'SP2_MRSI_Analysis';


%--- init success flag ---
f_succ = 0;

%--- data format ---
if flag.mrsiFormat==1           % real part
    datSpec = real(datSpec);
elseif flag.mrsiFormat==2       % imaginary part
    datSpec = imag(datSpec);
else                            % magnitude
    datSpec = abs(datSpec);
end                           

%--- additional info ---
if nargin==4      % additional info
    f_addInfo = 1;
    infoKey   = SP2_Check4RowVecR( varargin{1} );
else            % no additional info
    f_addInfo = 0;
end

%--- target area extraction ---
[targetMinI,targetMaxI,targetPpmZoom,targetSpecZoom,f_done] = ...
    SP2_MRSI_ExtractPpmRange(mrsi.ppmTargetMin,mrsi.ppmTargetMax,mrsi.ppmCalib,parsStruct.sw,datSpec);
[targetMaxAmpl,targetMaxInd] = max(targetSpecZoom);
if ~f_done
    fprintf('%s ->\nTarget area extraction failed. Program aborted.\n',FCTNAME);
    return
end

%--- noise area extraction ---
if flag.mrsiAnaSNR
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
        SP2_MRSI_ExtractPpmRange(mrsi.ppmNoiseMin,mrsi.ppmNoiseMax,mrsi.ppmCalib,parsStruct.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME);
        return
    end
end

%--- analysis and visualization ---
hold on
%--- offset handling ---
if flag.mrsiOffset      % ppm window
    %--- offset area extraction ---
    [offsetMinI,offsetMaxI,offsetPpmZoom,offsetSpecZoom,f_done] = ...
        SP2_MRSI_ExtractPpmRange(mrsi.ppmOffsetMin,mrsi.ppmOffsetMax,mrsi.ppmCalib,parsStruct.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nOffset area extraction failed. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- offset calculation ---
    specOffset = mean(offsetSpecZoom);
    
    %--- display ppm range ---
    plot([mrsi.ppmOffsetMin mrsi.ppmOffsetMin],[plotLim(3) plotLim(4)],'y')
    plot([mrsi.ppmOffsetMax mrsi.ppmOffsetMax],[plotLim(3) plotLim(4)],'y')
else                    % direct assignment
    specOffset = mrsi.offsetVal;
end

%--- visualization of target area ---
if flag.mrsiAnaSNR || flag.mrsiAnaFWHM || flag.mrsiAnaIntegr
    plot([mrsi.ppmTargetMin mrsi.ppmTargetMin],[plotLim(3) plotLim(4)],'g')
    plot([mrsi.ppmTargetMax mrsi.ppmTargetMax],[plotLim(3) plotLim(4)],'g')
    plot([plotLim(1) plotLim(2)],[targetMaxAmpl targetMaxAmpl],'g')
    plot([plotLim(1) plotLim(2)],[specOffset specOffset],'Color','g')
end

%--- SNR ---
if flag.mrsiAnaSNR
    %--- visualization of noise area ---
    plot([mrsi.ppmNoiseMin mrsi.ppmNoiseMin],[plotLim(3) plotLim(4)],'r')
    plot([mrsi.ppmNoiseMax mrsi.ppmNoiseMax],[plotLim(3) plotLim(4)],'r')

    %--- removal of 2nd order polynomial fit from noise area ---
    coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1))';   % fitted noise vector
    plot(noisePpmZoom,noiseSpecZoomFit,'r')                         % plot fit
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    
    %--- info printout ---
    fprintf('Signal maximum (orig. spectrum): %.0f at %.3fppm\n',targetMaxAmpl,targetPpmZoom(targetMaxInd));
    if specOffset~=0
        fprintf('Signal maximum (offset corr.):   %.0f at %.3fppm\n',targetMaxAmpl-specOffset,targetPpmZoom(targetMaxInd));
    end    
    fprintf('Noise range %.3f..%.3fppm: S.D. %.1f\n',noisePpmZoom(1),noisePpmZoom(end),std(noiseSpecZoom));
    fprintf('SNR (orig. spectrum): %.0f\n',targetMaxAmpl/std(noiseSpecZoom));
    if specOffset~=0
        fprintf('SNR (offset corr.):   %.0f\n',(targetMaxAmpl-specOffset)/std(noiseSpecZoom));
    end
end

%--- FWHM ---
if flag.mrsiAnaFWHM
    %--- FWHM analysis ---
    if flag.mrsiAnaSign             % positive sign
        [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg,f_done] = SP2_FWHM(targetSpecZoom-specOffset,1,flag.verbose);
    else
        [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg,f_done] = SP2_FWHM(-(targetSpecZoom-specOffset),1,flag.verbose);
    end
    if ~f_done
        fprintf('Peak detection failed. FWHM calculation aborted.\n');
        fprintf('Hint: Check baseline/reference level.\n');
        return
    else
        fwhmPpm    = fwhmPts * (targetPpmZoom(2)-targetPpmZoom(1));
        minFwhmPpm = SP2_BestApprox(targetPpmZoom',1:length(targetPpmZoom),minFwhmPts);
        maxFwhmPpm = SP2_BestApprox(targetPpmZoom',1:length(targetPpmZoom),maxFwhmPts);
        maxAmplPpm = SP2_BestApprox(targetPpmZoom',1:length(targetPpmZoom),maxAmplPts);

        %--- visualization of FWHM parameters ---
        plot([minFwhmPpm minFwhmPpm],[plotLim(3) plotLim(4)],'Color',[1 0 1])
        plot([maxFwhmPpm maxFwhmPpm],[plotLim(3) plotLim(4)],'Color',[1 0 1])
        plot([maxAmplPpm maxAmplPpm],[plotLim(3) plotLim(4)],'Color',[1 0 1])
        plot([plotLim(1) plotLim(2)],[maxAmpl maxAmpl]+specOffset,'Color',[1 0 1])
        plot([plotLim(1) plotLim(2)],[maxAmpl maxAmpl]/2+specOffset,'Color',[1 0 1])
        plot([plotLim(1) plotLim(2)],specOffset*[1 1],'Color',[1 0 1])

        %--- info printout ---
        if f_addInfo
            if infoKey(1) && infoKey(2)
                fprintf('FWHM %.3fppm/%.1fHz (LB %.1fHz, GB %.1fHz)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.lb,parsStruct.gb)
            elseif infoKey(1) && ~infoKey(2)
                fprintf('FWHM %.3fppm/%.1fHz (LB %.1fHz, GB off)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.lb)
            elseif ~infoKey(1) && infoKey(2)
                fprintf('FWHM %.3fppm/%.1fHz (LB off, GB %.1fHz)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.gb)
            else
                fprintf('FWHM %.3fppm/%.1fHz (LB off, GB off)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf)
            end
        else
            fprintf('FWHM %.3fppm/%.1fHz\n',fwhmPpm,fwhmPpm*parsStruct.sf);
        end
        fprintf('FWHM amplitude maximum: %.3fppm, amplitude %.0f\n',maxAmplPpm,maxAmpl+specOffset);
        fprintf('FWHM amplitude max./2:  %.3f..%.3fppm, amplitude %.0f\n',minFwhmPpm,maxFwhmPpm,maxAmpl/2);
        fprintf('FWHM frequency range:   %.3f..%.3fppm\n',minFwhmPpm,maxFwhmPpm);
    end
end

%--- spectral integration ---
if flag.mrsiAnaIntegr
    %--- info printout ---
    targetSpecZoom = targetSpecZoom - specOffset;       % offset correction
    fprintf('Integration %.2f..%.2f ppm, offset %.0f, maximum %.0f:\nTotal %.0f, %.0f per point\n',...
            targetPpmZoom(1),targetPpmZoom(end),specOffset,targetMaxAmpl,...
            sum(targetSpecZoom),sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
end

%--- visualization of base line fit ---
% if flag.mrsiAnaBaseCorr
%     
% end
hold off

%--- additional line break ---
fprintf('\n');

%--- update success flag ---
f_succ = 1;
