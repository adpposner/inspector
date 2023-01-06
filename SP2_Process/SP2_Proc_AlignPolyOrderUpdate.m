%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignPolyOrderUpdate
%% 
%%  Update order of polynomial used for spectra alignment.
%%
%%  03-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- keep old value ---
procAlignPolyOrder = proc.alignPolyOrder;

%--- update percentage value ---
proc.alignPolyOrder = min(max(str2double(get(fm.proc.alignPolyOrder,'String')),0),10);
set(fm.proc.alignPolyOrder,'String',num2str(proc.alignPolyOrder))

%--- reset polynomial coefficients ---
if proc.alignPolyOrder<procAlignPolyOrder
    proc.spec1.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    proc.spec2.polycoeff = zeros(1,11);      % polynomial coefficients 0..10th order
    fprintf('Info: Polynomial coefficients reset\n');
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
