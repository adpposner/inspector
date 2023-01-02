%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function strOut = SP2_PathWinLin(strIn)
%%
%%  Path conversion between operiational systems (if needed).
%%  Note that the conversion not only replaces forward/backward slashes,
%%  but also initializes directory assignments whenever possible.
%%  
%%  Christoph Juchem, 07-2012
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_PathWinLin';


%--- analysis of incoming string ---
strIn = SP2_SlashWinLin(strIn);
if strcmp(strIn(2:3),':\')              % windows path
    f_linuxIn = 0;
elseif strncmp(strIn,'/home/',6)        % linux path
    f_linuxIn = 1;
elseif strncmp(strIn,'/Users/',7)       % mac path
    f_linuxIn = 2;
else                                    % no path name (nothing to be done)
    strOut = strIn;
    return
end

%--- string conversion (if necessary) ---
if f_linuxIn==0 && flag.OS==1                               % PC-to-linux conversion
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
elseif f_linuxIn==0 && flag.OS==2                           % PC-to-mac conversion
    if strfind(strIn,'juchem')
        %--- remove part before juchem ---
        jInd = strfind(strIn,'juchem');

        %--- replace initial path up to home directory ---
        if isdir('/Users/CJ/')
            strOut = ['/Users/CJ/' strIn(jInd:end)];        % add user directory
        elseif isdir('/Users/juchem/')
            strOut = ['/Users/juchem/' strIn(jInd:end)];    % add user directory
        elseif isdir('/Users/Juchem/')
            strOut = ['/Users/Juchem/' strIn(jInd:end)];    % add user directory
        else
            strOut = ['/Users/' strIn(jInd:end)];           % simply add home directory
        end
    else
        strOut = ['/Users/' strIn(4:end)];                  % simply add home directory
    end 
elseif f_linuxIn==1 && flag.OS==0                           % linux-to-PC conversion
    if strncmp(strIn,'\home\juchem\',13) || strncmp(strIn,'\home\Juchem\',13)
        strOut = ['C:\Users\juchem\' strIn(14:end)];        % add user directory
    elseif strncmp(strIn,'\home\CJ\',9)
        strOut = ['C:\Users\juchem\' strIn(10:end)];        % add user directory
    else
        strOut = ['C:\' strIn(2:end)];                      % simply add partition directory
    end 
elseif f_linuxIn==1 && flag.OS==2                           % linux-to-mac conversion
    if strncmp(strIn,'/home/juchem/',13) || strncmp(strIn,'/home/Juchem/',13)
        strOut = ['/Users/juchem/' strIn(14:end)];          % add user directory
    elseif strncmp(strIn,'/home/CJ/',9)
        strOut = ['/Users/juchem/' strIn(10:end)];          % add user directory
    else
        strOut = ['/Users/' strIn(2:end)];                  % simply add partition directory
    end 
elseif f_linuxIn==2 && flag.OS==0                           % mac-to-PC conversion
    if strncmp(strIn,'\Users\juchem\',13) || strncmp(strIn,'\Users\Juchem\',13)
        strOut = ['C:\Users\juchem\' strIn(14:end)];        % add user directory
    elseif strncmp(strIn,'\Users\CJ\',9)
        strOut = ['C:\Users\juchem\' strIn(10:end)];        % add user directory
    else
        strOut = ['C:\' strIn(2:end)];                      % simply add partition directory
    end 
elseif f_linuxIn==2 && flag.OS==1                           % mac-to-linux conversion
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
else                                % no conversion necessary
    strOut = strIn;
end


