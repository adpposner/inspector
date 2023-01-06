%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function strOut = strIn
%%
%%  Slash/Backslash selection for string variable that becomes necessary
%%  for the correct assignment of directory and file paths on 
%%  Windows/Linux systems.
%%  
%%  Note that linux and Mac both use forward slashs. flag.OS > 0 therefore
%%  applies to both Mac and linux.
%%  flag.OS = 0;    % PC, \
%%  flag.OS = 1;    % Linux, /
%%  flag.OS = 2;    % Mac, /
%%
%%  Christoph Juchem, 03-2008
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_SlashWinLin';


%--- slash / backslash selection ---
if flag.OS>0     % Linux/Mac 
    strOut = SP2_SubstStrPart(strIn,'\','/');     % substitute / by \
else             % Windows
    strOut = SP2_SubstStrPart(strIn,'/','\');     % substitute \ by /
end



end
