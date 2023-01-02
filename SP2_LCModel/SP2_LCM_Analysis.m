%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_Analysis(datSpec,plotLim,varargin)
%%
%%  Spectral analysis function (SNR, FWHM, integration, baseline correction).
%%  Function arguments:
%%  1: full spectral data vector
%%  2: parameter structure (of spectrum 1 or spectrum 2)
%%  3: plotting limits
%%
%%  10-2015, Christop Juchem
%%  09-2020, Martin Gajdosik
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag lcm

FCTNAME = 'SP2_LCM_Analysis';


%--- init success flag ---
f_succ = 0;

%--- data format ---
datSpec = real(datSpec);

%--- additional info ---
if nargin==4      % additional info
    f_addInfo = 1;
    infoKey   = SP2_Check4RowVecR( varargin{1} );
else            % no additional info
    f_addInfo = 0;
end

%--- target area extraction ---
[targetMinI,targetMaxI,targetPpmZoom,targetSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmTargetMin,lcm.ppmTargetMax,lcm.ppmCalib,lcm.sw,datSpec);
[targetMaxAmpl,targetMaxInd] = max(targetSpecZoom);
[targetMinAmpl,targetMinInd] = min(targetSpecZoom);
if ~f_done
    fprintf('%s ->\nTarget area extraction failed. Program aborted.\n',FCTNAME);
    return
end

%--- noise area extraction ---
if flag.lcmAnaSNR
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME);
        return
    end
end

%--- analysis and visualization ---
hold on
%--- offset handling ---
if flag.lcmOffset      % ppm window
    %--- offset area extraction ---
    [offsetMinI,offsetMaxI,offsetPpmZoom,offsetSpecZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.ppmOffsetMin,lcm.ppmOffsetMax,lcm.ppmCalib,lcm.sw,datSpec);
    if ~f_done
        fprintf('%s ->\nOffset area extraction failed. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- offset calculation ---
    specOffset = mean(offsetSpecZoom);
    
    %--- display ppm range ---
    plot([lcm.ppmOffsetMin lcm.ppmOffsetMin],[plotLim(3) plotLim(4)],'y')
    plot([lcm.ppmOffsetMax lcm.ppmOffsetMax],[plotLim(3) plotLim(4)],'y')
else                    % direct assignment
    specOffset = lcm.offsetVal;
end

%--- visualization of target area ---
if flag.lcmAnaSNR || flag.lcmAnaFWHM || flag.lcmAnaIntegr
    plot([lcm.ppmTargetMin lcm.ppmTargetMin],[plotLim(3) plotLim(4)],'g')
    plot([lcm.ppmTargetMax lcm.ppmTargetMax],[plotLim(3) plotLim(4)],'g')
    if flag.lcmAnaSign                 % positive sign
        plot([plotLim(1) plotLim(2)],[targetMaxAmpl targetMaxAmpl],'g')
        plot([plotLim(1) plotLim(2)],[specOffset specOffset],'Color','g')
    else                                % negative sign
        plot([plotLim(1) plotLim(2)],[targetMinAmpl targetMinAmpl],'g')
        plot([plotLim(1) plotLim(2)],[specOffset specOffset],'Color','g')
    end
end

%--- SNR ---
if flag.lcmAnaSNR
    %--- visualization of noise area ---
    plot([lcm.ppmNoiseMin lcm.ppmNoiseMin],[plotLim(3) plotLim(4)],'r')
    plot([lcm.ppmNoiseMax lcm.ppmNoiseMax],[plotLim(3) plotLim(4)],'r')

    %--- removal of 2nd order polynomial fit from noise area ---
    coeff = SP2_Polyfit2(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % MAG
    %oeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1))';   % fitted noise vector
    plot(noisePpmZoom,noiseSpecZoomFit,'r')                         % plot fit
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    
    %--- info printout ---
    if flag.lcmAnaSign             % positive sign
        if targetMaxAmpl>1
            fprintf('Signal maximum (orig. spectrum): %.0f at %.3f ppm\n',targetMaxAmpl,targetPpmZoom(targetMaxInd));
            if specOffset~=0
                fprintf('Signal maximum (offset corr.):   %.0f at %.3f ppm\n',targetMaxAmpl-specOffset,targetPpmZoom(targetMaxInd));
            end    
        else
            fprintf('Signal maximum (orig. spectrum): %0.3e at %.3f ppm\n',targetMaxAmpl,targetPpmZoom(targetMaxInd));
            if specOffset~=0
                fprintf('Signal maximum (offset corr.):   %0.3e at %.3f ppm\n',targetMaxAmpl-specOffset,targetPpmZoom(targetMaxInd));
            end    
        end
        if std(noiseSpecZoom)>1
            fprintf('Noise range %.3f..%.3f ppm (%.0fpts): S.D. %.1f\n',noisePpmZoom(1),noisePpmZoom(end),noiseMaxI-noiseMinI+1,std(noiseSpecZoom));
        else
            fprintf('Noise range %.3f..%.3f ppm (%.0fpts): S.D. %0.3e\n',noisePpmZoom(1),noisePpmZoom(end),noiseMaxI-noiseMinI+1,std(noiseSpecZoom));
        end
        fprintf('SNR (orig. spectrum): %.0f\n',targetMaxAmpl/std(noiseSpecZoom));
        if specOffset~=0
            fprintf('SNR (offset corr.):   %.0f\n',(targetMaxAmpl-specOffset)/std(noiseSpecZoom));
        end
    else                            % negative sign
        fprintf('Signal minimum (orig. spectrum): %.0f at %.3f ppm\n',targetMinAmpl,targetPpmZoom(targetMinInd));
        if specOffset~=0
            fprintf('Signal minimum (offset corr.):   %.0f at %.3f ppm\n',targetMinAmpl-specOffset,targetPpmZoom(targetMinInd));
        end    
        fprintf('Noise range %.3f..%.3f ppm (%.0fpts): S.D. %.1f\n',noisePpmZoom(1),noisePpmZoom(end),noiseMaxI-noiseMinI+1,std(noiseSpecZoom));
        fprintf('SNR (orig. spectrum): %.0f\n',-targetMinAmpl/std(noiseSpecZoom));
        if specOffset~=0
            fprintf('SNR (offset corr.):   %.0f\n',-(targetMinAmpl-specOffset)/std(noiseSpecZoom));
        end
    end
end

%--- FWHM ---
if flag.lcmAnaFWHM
    %--- FWHM analysis ---
    if flag.lcmAnaSign             % positive sign
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
        if flag.lcmAnaSign         % positive sign
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
                        fwhmPpm,fwhmPpm*lcm.sf,lcm.lb,lcm.gb)
            elseif infoKey(1) && ~infoKey(2)
                fprintf('FWHM %.3f ppm / %.1f Hz (LB %.1f Hz, GB off)\n',...
                        fwhmPpm,fwhmPpm*lcm.sf,lcm.lb)
            elseif ~infoKey(1) && infoKey(2)
                fprintf('FWHM %.3f ppm / %.1f Hz (LB off, GB %.1f Hz)\n',...
                        fwhmPpm,fwhmPpm*lcm.sf,lcm.gb)
            else
                fprintf('FWHM %.3f ppm / %.1f Hz (LB off, GB off)\n',...
                        fwhmPpm,fwhmPpm*lcm.sf)
            end
        else
            fprintf('FWHM %.3f ppm / %.1f Hz\n',fwhmPpm,fwhmPpm*lcm.sf);
        end
        if maxAmpl+specOffset>1
            fprintf('FWHM amplitude maximum: %.3f ppm, amplitude %.0f\n',maxAmplPpm,maxAmpl+specOffset);
            fprintf('FWHM amplitude max./2:  %.3f..%.3f ppm (%.0f pts), amplitude %.0f\n',...
                    minFwhmPpm,maxFwhmPpm,maxFwhmPts-minFwhmPts+1,maxAmpl/2)
        else
            fprintf('FWHM amplitude maximum: %.3f ppm, amplitude %0.3e\n',maxAmplPpm,maxAmpl+specOffset);
            fprintf('FWHM amplitude max./2:  %.3f..%.3f ppm (%.0f pts), amplitude %0.3e\n',...
                    minFwhmPpm,maxFwhmPpm,maxFwhmPts-minFwhmPts+1,maxAmpl/2)
        end
        fprintf('FWHM frequency range:   %.3f..%.3f ppm (%.0f pts)\n',minFwhmPpm,maxFwhmPpm,maxFwhmPts-minFwhmPts+1);
    end
end

%--- spectral integration ---
if flag.lcmAnaIntegr
    %--- info printout ---
    targetSpecZoom = targetSpecZoom - specOffset;       % offset correction
    if flag.lcmAnaSign                 % positive sign
        if targetMaxAmpl>1
            fprintf('Integration %.2f..%.2f ppm (%.0fpts), offset %.0f, maximum %.0f:\nTotal %.0f, %.0f per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),targetMaxI-targetMinI+1,specOffset,targetMaxAmpl,...
                    sum(targetSpecZoom),sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        else
            fprintf('Integration %.2f..%.2f ppm (%.0fpts), offset %0.3e, maximum %0.3e:\nTotal %0.3e, %0.3e per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),targetMaxI-targetMinI+1,specOffset,targetMaxAmpl,...
                    sum(targetSpecZoom),sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        end
    else                                % negative sign
        if abs(targetMinAmpl)>1
            fprintf('Integration %.2f..%.2f ppm (%.0fpts), offset %.0f, minimum %.0f:\nTotal %.0f, %.0f per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),targetMaxI-targetMinI+1,specOffset,targetMinAmpl,...
                    -sum(targetSpecZoom),-sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        else
            fprintf('Integration %.2f..%.2f ppm (%.0fpts), offset %0.3e, minimum %0.3e:\nTotal %0.3e, %0.3e per point\n',...
                    targetPpmZoom(1),targetPpmZoom(end),targetMaxI-targetMinI+1,specOffset,targetMinAmpl,...
                    -sum(targetSpecZoom),-sum(targetSpecZoom)/(targetMaxI-targetMinI+1))
        end
    end
end

%--- visualization of base line fit ---
% if flag.lcmAnaBaseCorr
%     
% end
hold off

%--- additional line break ---
fprintf('\n');

%--- update success flag ---
f_succ = 1;
