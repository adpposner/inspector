%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [f_err,msg] = SP2_Data_ProcparConsistency(meth1,meth2)
%%
%%  function [f_err,msg] = SP2_Data_ProcparConsistency(meth1,meth2)
%%  compares struct arrays meth1 and meth2 and returns an error flag f_err 
%%  and an error message msg, when a conflict is detected. Checked are the
%%  size, the field names and the entries at the corresponding field
%%  positions for meth1 and meth2.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Data_ProcparConsistency';

[f_err,msg] = SP2_Data_ConsistencyChecker(FCTNAME,meth1,meth2);

% f_err = 0;
% msg   = '';

% meth1Names = fieldnames(meth1);
% meth1No    = length(meth1Names);
% meth2Names = fieldnames(meth2);
% meth2No    = length(meth2Names);

% if meth1No==meth2No         % struct sizes are the same
%     % check field names to be the same
%     pattVec = strcmp(meth1Names,meth2Names);
%     pattInd = find(pattVec==0);
%     pattNo  = length(pattInd);
%     if pattNo==0            % struct fields are same
%         for icnt = 1:meth1No
%             par1 = getfield(meth1,char(meth1Names(icnt)));
%             par2 = getfield(meth2,char(meth2Names(icnt)));
%             if isnumeric(par1)
%                 if isnumeric(par2)
%                     if ndims(par1)==ndims(par2)
%                         if ~any(size(par1)~=size(par2))
%                             if par1~=par2
%                                 if ~strcmp('sfrq',char(meth1Names(icnt))) && ~strcmp('tof',char(meth1Names(icnt)))
%                                     msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                                     f_err = 1;
%                                 end
%                             end
%                         else
%                             f_err = 1;
%                             msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                         end
%                     else
%                         f_err = 1;
%                         msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                     end
%                 else
%                     f_err = 1;
%                     msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                 end
%             elseif isstruct(par1)
%                 if isstruct(par2)
%                     [f_err,msg] = SP2_Data_ProcparConsistency(par1,par2);       %...
%                 else
%                     f_err = 1;
%                     msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                 end
%             else
%                 if ~strcmp(par1,par2)
%                     msg = sprintf('%s%s is not consistent\n',msg,char(meth1Names(icnt)));
%                     f_err = 1;
%                 end
%             end
%         end
%     else                    % struct fields differ
%         f_err = 1;
%         msg = sprintf('%s -> %.0f method struct fields differ:\n',FCTNAME,pattNo);
%         for icnt = 1:pattNo
%             str1tmp = sprintf('meth1.%s=%s',char(meth1Names(pattInd(icnt))),getfield(meth1,char(meth1Names(pattInd(icnt)))));
%             str2tmp = sprintf('meth2.%s=%s',char(meth2Names(pattInd(icnt))),getfield(meth2,char(meth2Names(pattInd(icnt)))));
%             msg = [msg sprintf('%s %s\n',str1tmp,str2tmp)];
%         end
%     end
% else                        % struct sizes differ
%     f_err = 1;
%     msg = sprintf('%s -> struct sizes differ (%.0f/%.0f)\n',FCTNAME,meth1No,meth2No);
% end

end
