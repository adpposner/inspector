%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLinkGbUpdate
%% 
%%  Link LB for all metabolites for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag lcm

%--- flag handling ---
flag.lcmLinkGb = get(fm.lcm.fit.linkGb,'Value');

%--- update flag display ---
set(fm.lcm.fit.linkGb,'Value',flag.lcmLinkGb)

%--- apply last selected metabolite to all others ---
if flag.lcmLinkGb
    %--- get last entry ---
    eval(['lcmGbMinLast = str2double(get(fm.lcm.fit.gbMin' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.fit.gbMin(' sprintf('%i',mCnt) ') = lcmGbMinLast;'])
        end
    end

    %--- get last entry ---
    eval(['lcmAnaGbLast = str2double(get(fm.lcm.fit.anaGb' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.anaGb(' sprintf('%i',mCnt) ') = lcmAnaGbLast;'])
        end
    end

    %--- get last entry ---
    eval(['lcmGbMaxLast = str2double(get(fm.lcm.fit.gbMax' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.fit.gbMax(' sprintf('%i',mCnt) ') = lcmGbMaxLast;'])
        end
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

