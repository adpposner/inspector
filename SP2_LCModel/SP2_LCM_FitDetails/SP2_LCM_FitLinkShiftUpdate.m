%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLinkShiftUpdate
%% 
%%  Link frequency shift for all metabolites for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag lcm

%--- flag handling ---
flag.lcmLinkShift = get(fm.lcm.fit.linkShift,'Value');

%--- update flag display ---
set(fm.lcm.fit.linkShift,'Value',flag.lcmLinkShift)

%--- apply last selected metabolite to all others ---
if flag.lcmLinkShift
    %--- get last entry ---
    eval(['lcmAnaShiftLast = str2double(get(fm.lcm.fit.anaShift' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.anaShift(' sprintf('%i',mCnt) ') = lcmAnaShiftLast;'])
        end
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

