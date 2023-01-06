%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowPosValUpdate
%% 
%%  Update value for frequency visualization.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag

%--- update percentage value ---
mrsi.ppmShowPos = str2num(get(fm.mrsi.ppmShowPosVal,'String'));         % frequency update
mrsi.ppmShowPosMirr = mrsi.ppmCalib+(mrsi.ppmCalib-mrsi.ppmShowPos);    % mirrored frequency position

%--- display update ---
set(fm.mrsi.ppmShowPosVal,'String',num2str(mrsi.ppmShowPos))

%--- info printout ---
fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mrsi.ppmShowPos,...
        mrsi.ppmCalib,mrsi.ppmShowPos-mrsi.ppmCalib,mrsi.spec1.sf*(mrsi.ppmShowPos-mrsi.ppmCalib))
if flag.mrsiPpmShowPosMirr
    fprintf('Mirrored position:  %.3fppm/%.2fHz\n',mrsi.ppmShowPosMirr,...
            mrsi.spec1.sf*(mrsi.ppmShowPosMirr-mrsi.ppmCalib))
end    

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
