%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_Analysis(datSpec,parsStruct,plotLim,varargin)
%%
%%  Spectral analysis function (SNR, FWHM, integration, baseline correction).
%%  Function arguments:
%%  1: full spectral data vector
%%  2: parameter structure (of spectrum 1 or spectrum 2)
%%  3: plotting limits
%%
%%  02-2012, Christop Juchem
%%  09-2020, Martin Gajdosik
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag


FCTNAME = 'SP2_Proc_Analysis';


%--- init success flag ---
f_succ = 0;

%--- data format ---
if flag.procFormat==1           % real part
    datSpec = real(datSpec);
elseif flag.procFormat==2       % imaginary part
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
    SP2_Proc_ExtractPpmRange(proc.ppmTargetMin,proc.ppmTargetMax,proc.ppmCalib,parsStruct.sw,datSpec);
[targetMaxAmpl,targetMaxInd] = max(targetSpecZoom);
[targetMinAmpl,targetMinInd] = min(targetSpecZoom);
if ~f_done
    fprintf('%s ->\nTarget area extraction failed. Program aborted.\n',FCTNAME)
    return
end

%--- noise area extraction ---
if flag.procAnaSNR
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(proc.ppmNoiseMin,proc.ppmNoiseMax,proc.ppmCalib,parsStruct.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME)
        return
    end
end

%--- analysis and visualization ---
hold on
%--- offset handling ---
if flag.procOffset      % ppm window
    %--- offset area extraction ---
    [offsetMinI,offsetMaxI,offsetPpmZoom,offsetSpecZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(proc.ppmOffsetMin,proc.ppmOffsetMax,proc.ppmCalib,parsStruct.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nOffset area extraction failed. Program aborted.\n',FCTNAME)
        return
    end
    
    %--- offset calculation ---
    specOffset = mean(offsetSpecZoom);
    
    %--- display ppm range ---
    plot([proc.ppmOffsetMin proc.ppmOffsetMin],[plotLim(3) plotLim(4)],'y')
    plot([proc.ppmOffsetMax proc.ppmOffsetMax],[plotLim(3) plotLim(4)],'y')
else                    % direct assignment
    specOffset = proc.offsetVal;
end

%--- visualization of target area ---
if flag.procAnaSNR || flag.procAnaFWHM || flag.procAnaIntegr
    plot([proc.ppmTargetMin proc.ppmTargetMin],[plotLim(3) plotLim(4)],'g')
    plot([proc.ppmTargetMax proc.ppmTargetMax],[plotLim(3) plotLim(4)],'g')
    if flag.procAnaSign                 % positive sign
        plot([plotLim(1) plotLim(2)],[targetMaxAmpl targetMaxAmpl],'g')
        plot([plotLim(1) plotLim(2)],[specOffset specOffset],'Color','g')
    else                                % negative sign
        plot([plotLim(1) plotLim(2)],[targetMinAmpl targetMinAmpl],'g')
        plot([plotLim(1) plotLim(2)],[specOffset specOffset],'Color','g')
    end
end

%--- SNR ---
if flag.procAnaSNR
    %--- visualization of noise area ---
    plot([proc.ppmNoiseMin proc.ppmNoiseMin],[plotLim(3) plotLim(4)],'r')
    plot([proc.ppmNoiseMax proc.ppmNoiseMax],[plotLim(3) plotLim(4)],'r')

    %--- removal of 2nd order polynomial fit from noise area ---
    coeff = SP2_Polyfit2(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % MAG
    %coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1))';   % fitted noise vector
    plot(noisePpmZoom,noiseSpecZoomFit,'r')                         % plot fit
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    
    %--- info printout ---
    if flag.procAnaSign             % positive sign
        if targetMaxAmpl>1
            fprintf('Signal maximum (orig. spectrum): %.0f at %.3f ppm\n',targetMaxAmpl,targetPpmZoom(targetMaxInd))
            if specOffset~=0
                fprintf('Signal maximum (offset corr.):   %.0f at %.3f ppm\n',targetMaxAmpl-specOffset,targetPpmZoom(targetMaxInd))
            end    
        else
            fprintf('Signal maximum (orig. spectrum): %0.3e at %.3f ppm\n',targetMaxAmpl,targetPpmZoom(targetMaxInd))
            if specOffset~=0
                fprintf('Signal maximum (offset corr.):   %0.3e at %.3f ppm\n',targetMaxAmpl-specOffset,targetPpmZoom(targetMaxInd))
            end    
        end
        if std(noiseSpecZoom)>1 
            fprintf('Noise range %.3f..%.3f ppm: S.D. %.1f\n',noisePpmZoom(1),noisePpmZoom(end),std(noiseSpecZoom))
        else
            fprintf('Noise range %.3f..%.3f ppm: S.D. %0.3e\n',noisePpmZoom(1),noisePpmZoom(end),std(noiseSpecZoom))
        end
        fprintf('SNR (orig. spectrum): %.0f\n',targetMaxAmpl/std(noiseSpecZoom))
        if specOffset~=0
            fprintf('SNR (offset corr.):   %.0f\n',(targetMaxAmpl-specOffset)/std(noiseSpecZoom))
        end
    else                            % negative sign
        fprintf('Signal minimum (orig. spectrum): %.0f at %.3f ppm\n',targetMinAmpl,targetPpmZoom(targetMinInd))
        if specOffset~=0
            fprintf('Signal minimum (offset corr.):   %.0f at %.3f ppm\n',targetMinAmpl-specOffset,targetPpmZoom(targetMinInd))
        end    
        fprintf('Noise range %.3f..%.3f ppm: S.D. %.1f\n',noisePpmZoom(1),noisePpmZoom(end),std(noiseSpecZoom))
        fprintf('SNR (orig. spectrum): %.0f\n',-targetMinAmpl/std(noiseSpecZoom))
        if specOffset~=0
            fprintf('SNR (offset corr.):   %.0f\n',-(targetMinAmpl-specOffset)/std(noiseSpecZoom))
        end
    end
end

%--- FWHM ---
if flag.procAnaFWHM
    %--- FWHM analysis ---
    if flag.procAnaSign             % positive sign
        [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg,f_done] = SP2_FWHM(targetSpecZoom-specOffset,1,flag.verbose);
    else
        [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg,f_done] = SP2_FWHM(-(targetSpecZoom-specOffset),1,flag.verbose);
    end
    if ~f_done
        fprintf('Peak detection failed. FWHM calculation aborted.\n')
        fprintf('Hint: Check baseline/reference level.\n')
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
        if flag.procAnaSign         % positive sign
            plot([plotLim(1) plotLim(2)],[maxAmpl maxAmpl]+specOffset,'Color',[1 0 1])
            plot([plotLim(1) plotLim(2)],[maxAmpl maxAmpl]/2+specOffset,'Color',[1 0 1])
        else
            plot([plotLim(1) plotLim(2)],[-maxAmpl -maxAmpl]+specOffset,'Color',[1 0 1])
            plot([plotLim(1) plotLim(2)],[-maxAmpl -maxAmpl]/2+specOffset,'Color',[1 0 1])
        end
        plot([plotLim(1) plotLim(2)],specOffset*[1 1],'Color',[1 0 1])

        %--- info printout ---
        if f_addInfo
            if infoKey(1) && infoKey(2)
                fprintf('FWHM %.3f ppm / %.1f Hz (LB %.1f Hz, GB %.1f Hz)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.lb,parsStruct.gb)
            elseif infoKey(1) && ~infoKey(2)
                fprintf('FWHM %.3f ppm / %.1f Hz (LB %.1f Hz, GB off)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.lb)
            elseif ~infoKey(1) && infoKey(2)
                fprintf('FWHM %.3f ppm / %.1f Hz (LB off, GB %.1f Hz)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf,parsStruct.gb)
            else
                fprintf('FWHM %.3f ppm / %.1f Hz (LB off, GB off)\n',...
                        fwhmPpm,fwhmPpm*parsStruct.sf)
            end
        else
            fprintf('FWHM %.3f ppm / %.1f Hz\n',fwhmPpm,fwhmPpm*parsStruct.sf)
        end
        if maxAmpl+specOffset>1
            fprintf('FWHM amplitude maximum: %.3f ppm, amplitude %.0f\n',maxAmplPpm,maxAmpl+specOffset)
            fprintf('FWHM amplitude max./2:  %.3f..%.3f ppm, amplitude %.0f\n',minFwhmPpm,maxFwhmPpm,maxAmpl/2)
        else
            fprintf('FWHM amplitude maximum: %.3f ppm, amplitude %0.3e\n',maxAmplPpm,maxAmpl+specOffset)
            fprintf('FWHM amplitude max./2:  %.3f..%.3f ppm, amplitude %0.3e\n',minFwhmPpm,maxFwhmPpm,maxAmpl/2)
        end
        fprintf('FWHM frequency range:   %.3f..%.3f ppm\n',minFwhmPpm,maxFwhmPpm)
    end
end

%--- spectral integration ---
if flag.procAnaIntegr
    %--- info printout ---
    targetSpecZoom = targetSpecZoom - specOffset;       % offset correction
    if flag.procAnaSign                 % positive sign
        if targetMaxAmpl>1
            fprintf('Integration %.2f..%.2f ppm, offset %.0f, maximum %.0f:\nTotal %.0f, %.0f per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),specOffset,targetMaxAmpl,...
                    sum(targetSpecZoom),sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        else
            fprintf('Integration %.2f..%.2f ppm, offset %0.3e, maximum %0.3e:\nTotal %0.3e, %0.3e per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),specOffset,targetMaxAmpl,...
                    sum(targetSpecZoom),sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        end
    else                                % negative sign
        if abs(targetMinAmpl)>1
            fprintf('Integration %.2f..%.2f ppm, offset %.0f, minimum %.0f:\nTotal %.0f, %.0f per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),specOffset,targetMinAmpl,...
                    -sum(targetSpecZoom),-sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        else
            fprintf('Integration %.2f..%.2f ppm, offset %0.3e, minimum %0.3e:\nTotal %0.3e, %0.3e per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),specOffset,targetMinAmpl,...
                    -sum(targetSpecZoom),-sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        end
    end
end

%--- visualization of base line fit ---
% if flag.procAnaBaseCorr
%     
% end
hold off

%--- additional line break ---
fprintf('\n')

%--- update success flag ---
f_succ = 1;
