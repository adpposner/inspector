%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_T1T2_DataResort
%%
%%  Resort T1/T2 experiment delays to ascending order.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile t1t2

FCTNAME = 'SP2_T1T2_DataResort';


%--- init read flag ---
f_succ = 0;

%--- data resorting ---
[t1t2.delays,resortInd] = sort(t1t2.delays);
t1t2.fid     = t1t2.fid(:,resortInd);
t1t2.fidOrig = t1t2.fid;

%--- info printout ---
fprintf('Resorting delays to ascending order completed:\n');
fprintf('%ss\n\n',SP2_Vec2PrintStr(t1t2.delays,3));

%--- update read flag ---
f_succ = 1;
