%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitSelectAdoptLast
%% 
%%  Update function copy metabolite selection from last overall basis
%%  function to all basis functions.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
global fm lcm

FCTNAME = 'SP2_LCM_FitSelectAdoptFirst';


%--- get first entry ---
eval(['lcmSelectLast = get(fm.lcm.fit.select' sprintf('%02i',lcm.basis.n) ',''Value'');'])
    
%--- assign to all ---
for mCnt = 1:lcm.basis.n
    eval(['lcm.fit.select(' sprintf('%i',mCnt) ') = lcmSelectLast;'])
end

%--- update applied vector ---
lcm.fit.applied  = find(lcm.fit.select);
lcm.fit.appliedN = length(lcm.fit.applied);

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

end
