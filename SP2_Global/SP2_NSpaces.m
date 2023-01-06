%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function spacesStr = SP2_NSpaces( nSpaces )
%%
%%  spaceStr = SP2_NSpaces( nSpaces )
%%  creates a string of n spaces/
%% 
%%  Christoph Juchem, 02-2016
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_NSpaces';


%--- consistency checks ---
nSpaces = SP2_Check4IntBigger0R( nSpaces );
    
%--- string generation ---
spacesStr = '';
for nCnt = 1:nSpaces
    spacesStr = sprintf('%s ',spacesStr);
end
    
    
end
