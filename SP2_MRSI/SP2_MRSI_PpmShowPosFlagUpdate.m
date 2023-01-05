%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowPosFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag mrsi


%--- parameter update ---
flag.mrsiPpmShowPos = get(fm.mrsi.ppmShowPos,'Value');

%--- window update ---
set(fm.mrsi.ppmShowPos,'Value',flag.mrsiPpmShowPos)

%--- info printout ---
if flag.mrsiPpmShowPos
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',mrsi.ppmShowPos,...
            mrsi.ppmCalib,mrsi.ppmShowPos-mrsi.ppmCalib,mrsi.spec1.sf*(mrsi.ppmShowPos-mrsi.ppmCalib))
    if flag.mrsiPpmShowPosMirr
        fprintf('Mirrored position:  %.3fppm/%.2fHz\n',mrsi.ppmShowPosMirr,...
                mrsi.spec1.sf*(mrsi.ppmShowPosMirr-mrsi.ppmCalib))
    end
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

