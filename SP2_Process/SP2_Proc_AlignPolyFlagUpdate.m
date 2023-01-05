%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignPolyFlagUpdate
%% 
%%  Switching on/off polynomial for spectrum alignment.
%%
%%  03-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag proc


%--- update flag parameter ---
flag.procAlignPoly = get(fm.proc.alignPolyFlag,'Value');
set(fm.proc.alignPolyFlag,'Value',flag.procAlignPoly)

%--- reset polynomial coefficients ---
if ~flag.procAlignPoly
    proc.spec1.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    proc.spec2.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    fprintf('Info: Polynomial coefficients reset\n');
end

%--- window update ---
SP2_Proc_ProcessWinUpdate
