%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DataResort
%%
%%  Resort saturation-recovery experiment to ascending delays.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm

FCTNAME = 'SP2_MM_DataResort';


%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if ~isfield(mm,'fid')
    if ~SP2_MM_DataLoad
        return
    end
end

%--- data resorting ---
[mm.satRecDelays,resortInd] = sort(mm.satRecDelays);
mm.fid = mm.fid(:,resortInd);
mm.fidOrig = mm.fid;

%--- info printout ---
fprintf('Resorting to ascending saturation-delays completed:\n');
fprintf('%ss\n\n',SP2_Vec2PrintStr(mm.satRecDelays,3));

% %--- data export ---
% mm.expt = mm;
% if isfield(mm.expt,'spec')
%     mm.expt = rmfield(mm.expt,'spec');
% end
% mm.expt.fid = mm.fidOrig;

%--- update read flag ---
f_succ = 1;
