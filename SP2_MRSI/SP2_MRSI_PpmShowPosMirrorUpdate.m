%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowPosMirrorUpdate
%% 
%%  Enable/disable additional visualization of mirrored frequency position.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag mrsi


%--- parameter update ---
flag.mrsiPpmShowPosMirr = get(fm.mrsi.ppmShowPosMirr,'Value');

%--- window update ---
set(fm.mrsi.ppmShowPosMirr,'Value',flag.mrsiPpmShowPosMirr)

%--- info printout ---
if flag.mrsiPpmShowPosMirr
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mrsi.ppmShowPos,...
            mrsi.ppmCalib,mrsi.ppmShowPos-mrsi.ppmCalib,mrsi.spec1.sf*(mrsi.ppmShowPos-mrsi.ppmCalib))
    fprintf('Mirrored position:  %.3fppm/%.2fHz\n',mrsi.ppmShowPosMirr,...
            mrsi.spec1.sf*(mrsi.ppmShowPosMirr-mrsi.ppmCalib))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

