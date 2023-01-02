%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityDetailsWinUpdate
%% 
%%  'Quality Details' window update
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

FCTNAME = 'SP2_Data_QualityDetailsWinUpdate';


%--- amplitude mode ---
if flag.dataQualityAmplMode         % auto
    set(fm.data.qualityDet.amplMin,'Enable','off')
    set(fm.data.qualityDet.amplMax,'Enable','off')
else                                % direct
    set(fm.data.qualityDet.amplMin,'Enable','on')
    set(fm.data.qualityDet.amplMax,'Enable','on')
end

%--- frequency mode ---
if flag.dataQualityFrequMode        % global loggingfile
    set(fm.data.qualityDet.frequMin,'Enable','off')
    set(fm.data.qualityDet.frequMax,'Enable','off')
else                                % direct
    set(fm.data.qualityDet.frequMin,'Enable','on')
    set(fm.data.qualityDet.frequMax,'Enable','on')
end


% %--- 1 vs. 2 spectral windows for phase alignment ---
% if flag.dataAlignPhSpecRg==0        % 1 window
%     set(fm.data.alignDet.phPpmDnLab,'Color',pars.bgTextColor)
%     set(fm.data.alignDet.phPpmDnMin,'Enable','off')
%     set(fm.data.alignDet.phPpmDnMax,'Enable','off')
% else
%     set(fm.data.alignDet.phPpmDnLab,'Color',pars.fgTextColor)
%     set(fm.data.alignDet.phPpmDnMin,'Enable','on')
%     set(fm.data.alignDet.phPpmDnMax,'Enable','on')
% end

