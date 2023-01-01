%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function strOut = SP2_PathWinLin(strIn)
%%
%%  Path conversion from linux to windows and vice versa (if needed).
%%  
%%  Christoph Juchem, 07-2012
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_PathWinLin';


%--- analysis of incoming string ---
if strncmp(strIn,':\',3) || strncmp(strIn,':/',3)                   % windows path
    f_linuxIn = 0;
elseif strncmp(strIn,'/home/',6) || strncmp(strIn,'\home\',6)       % linux path
    f_linuxIn = 1;
else                                % no path name (nothing to be done)
    strOut = strIn;
    return
end

%--- string conversion (if necessary) ---
if flag.OS && ~f_linuxIn         % windows-to-linux conversion
    strIn = SP2_SlashWinLin(strIn);
    if strfind(strIn,'juchem')
        %--- remove part before juchem ---
        jInd = strfind(strIn,'juchem');
        
        %--- replace initial path up to home directory ---
        if isdir('/home/CJ/')
            strOut = ['/home/CJ/' strIn(jInd:end)];         % add user directory
        elseif isdir('/home/juchem/')
            strOut = ['/home/juchem/' strIn(jInd:end)];     % add user directory
        elseif isdir('/home/Juchem/')
            strOut = ['/home/Juchem/' strIn(jInd:end)];     % add user directory
        else
            strOut = ['/home/' strIn(jInd:end)];            % simply add home directory
        end
    else
        strOut = ['/home/' strIn(4:end)];                   % simply add home directory
    end 
elseif ~flag.OS && f_linuxIn     % linux-to-windows conversion
    strIn = SP2_SlashWinLin(strIn);
    if strncmp(strIn,'\home\juchem\',13) || strncmp(strIn,'\home\Juchem\',13)
        strOut = ['C:\Users\juchem\' strIn(14:end)];        % add user directory
    elseif strncmp(strIn,'\home\CJ\',9)
        strOut = ['C:\Users\juchem\' strIn(10:end)];        % add user directory
    else
        strOut = ['C:\' strIn(2:end)];                      % simply add partition directory
    end 
else                                % no conversion necessary
    strOut = strIn;
end


