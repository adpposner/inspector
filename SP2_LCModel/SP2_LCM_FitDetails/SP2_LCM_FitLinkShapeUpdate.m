%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLinkShapeUpdate
%% 
%%  Link frequency shape for all metabolites for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag lcm

%--- flag handling ---
flag.lcmLinkShape = get(fm.lcm.fit.linkShape,'Value');

%--- update flag display ---
set(fm.lcm.fit.linkShape,'Value',flag.lcmLinkShape)

%--- apply last selected metabolite to all others ---
if flag.lcmLinkShape
    %--- get first entry ---
    eval(['lcmShapeVarLast = str2double(get(fm.lcm.fit.shapeVar' sprintf('%02i',max(find(lcm.fit.select))) ',''String''));'])

    %--- assign to all ---
    for mCnt = 1:lcm.basis.n
        if lcm.fit.select(mCnt)
            eval(['lcm.fit.shapeVar(' sprintf('%i',mCnt) ') = lcmShapeVarLast;'])
        end
    end
end

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

