%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLinkLbUpdate
%% 
%%  Link LB for all metabolites for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag lcm

%--- flag handling ---
flag.lcmLinkLb = get(fm.lcm.fit.linkLb,'Value');

%--- update flag display ---
set(fm.lcm.fit.linkLb,'Value',flag.lcmLinkLb)

%--- apply last selected metabolite to all others ---
if flag.lcmLinkLb
    %--- get last entry ---
    eval(['lcmLbMinLast = str2double(get(fm.lcm.fit.lbMin' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.fit.lbMin(' sprintf('%i',mCnt) ') = lcmLbMinLast;'])
        end
    end

    %--- get last entry ---
    eval(['lcmAnaLbLast = str2double(get(fm.lcm.fit.anaLb' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.anaLb(' sprintf('%i',mCnt) ') = lcmAnaLbLast;'])
        end
    end

    %--- get last entry ---
    eval(['lcmLbMaxLast = str2double(get(fm.lcm.fit.lbMax' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.fit.lbMax(' sprintf('%i',mCnt) ') = lcmLbMaxLast;'])
        end
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

