%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_KeepFigure(fHandle)
%%
%%  Protects a figure from being updated by copying all of its content to
%%  a newly created figure.
%%
%%  Christoph Juchem, 01-2012
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_KeepFigure';


%--- init success flag ---
f_done = 0;

%--- figure manipulation ---
fhName = ['fh_' datestr(now,30)];
eval([fhName ' = figure(''IntegerHandle'',''off'');'])
eval(['copyobj(get(fHandle,''children''),' fhName ');'])
eval(['set(' fhName ',''Name'',[get(fHandle,''Name'') '' (' datestr(now,0) ')''])'])
eval(['set(' fhName ',''NumberTitle'',get(fHandle,''NumberTitle''))'])
eval(['set(' fhName ',''Position'',get(fHandle,''Position''))'])
eval(['set(' fhName ',''Color'',get(fHandle,''Color''))'])
set(0,'CurrentFigure',fHandle)

% %--- figure manipulation ---
% fh_new  = figure;
% copyobj(get(fHandle,'children'),fh_new);
% set(fh_new,'Name',get(fHandle,'Name'))
% set(fh_new,'NumberTitle',get(fHandle,'NumberTitle'))
% set(fh_new,'Position',get(fHandle,'Position'))
% set(fh_new,'Color',get(fHandle,'Color'))
% set(0,'CurrentFigure',fHandle)

%--- update success flag ---
f_done = 1;



end
