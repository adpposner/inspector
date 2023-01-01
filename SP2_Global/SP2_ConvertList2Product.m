%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function parvalStr =  SP2_ConvertList2Product(parvalStr)

% converts comma separated list of numbers to a single number which is
% given by the product of the particular numbers. This is useful, when
% parameter files (method, acqp) are read and one has to know what the size
% of the following list will be.
% e.g. ( 1, 3 ) -> ( 3 ), ( 60, 3 ) -> ( 180 )
%
% Ch. Juchem, 03-2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~SP2_Check4Str(parvalStr)
    return
end
if length(findstr(parvalStr,','))~=1                        % more than one comma found, i.e. more/other than 2 entries
    return
end
cIndList = findstr(parvalStr,',');                          % commata index list
if ~isempty(cIndList)
    nCom = length(cIndList)+1;                              % number of numbers
    valStr = parvalStr(1+2:end-2);                          % get rid of '( ' at the beginning and ' )' at the end
    for icnt = 1:nCom-1
        [valTmp,valStr] = strtok(valStr,',');
        vec(icnt) = str2num(valTmp);
    end
    vec(nCom) = str2num(valStr);
    parvalStr = ['( ' num2str(prod(vec)) ' )'];
end
