%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_BasisMove(nMetab)
%% 
%%  Function to move individual metabolite to selected position.
%%  (note that the othe rest of the basis is arranged accordingly)
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm

FCTNAME = 'SP2_LCM_BasisMove';


%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.n
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- consistency check ---
if nMetab>lcm.basis.n || nMetab>lcm.basis.nLim
    fprintf('Assigned basis position is outside the allowable range (0..%.0f)\n',lcm.basis.n);
    fprintf('Program aborted.\n');
    return
end

%--- new order ---
newOrder = zeros(1,lcm.basis.n);
if lcm.basis.reorder(nMetab)>nMetab                             % move down
    for mCnt = 1:lcm.basis.n
       if mCnt<nMetab                                           % before old 
           newOrder(mCnt)   = mCnt;
       elseif mCnt==nMetab                                      % new position
           newOrder(lcm.basis.reorder(nMetab)) = nMetab;
       elseif mCnt>nMetab && mCnt<=lcm.basis.reorder(nMetab)    % between old and new position
           newOrder(mCnt-1) = mCnt;
       else                                                     % after new position
           newOrder(mCnt)   = mCnt;
       end
    end
else                                                            % move up
    for mCnt = 1:lcm.basis.n
       if mCnt<lcm.basis.reorder(nMetab)                        % before 
           newOrder(mCnt)   = mCnt;
       elseif mCnt==lcm.basis.reorder(nMetab)                   % new position
           newOrder(mCnt)   = nMetab;
       elseif mCnt>lcm.basis.reorder(nMetab) && mCnt<=nMetab    % between new and old position
           newOrder(mCnt)   = mCnt-1;
       else                                                     % after old position
           newOrder(mCnt)   = mCnt;
       end
    end
end
lcm.basis.reorder = 1:lcm.basis.n;                          % reset order

%--- create temporary basis ---
lcmBasisData = lcm.basis.data;
for mCnt = 1:lcm.basis.n                % metabolites
    for fCnt = 1:4                      % array fields
        lcmBasisData{mCnt}{fCnt} = lcm.basis.data{newOrder(mCnt)}{fCnt};
    end
end
lcm.basis.data = lcmBasisData;

%--- window update ---
SP2_LCM_BasisWinUpdate

%--- update success flag ---
f_done = 1;






