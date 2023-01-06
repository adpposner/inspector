%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpatialZF(datStruct)
%%
%%  Spatial zero-filling.
%% 
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi

FCTNAME = 'SP2_MRSI_SpatialZF';


%--- init success flag ---
f_succ = 0;

%--- consistency check ---
if mrsi.spatZF<datStruct.nEncR
    fprintf('Spatial ZF < original matrix size (%.0f<%.0f). Nothing applied.\n',...
            mrsi.spatZF,datStruct.nEncR)
    return
end

%--- matrix creation ---
fidKSpNew = complex(zeros(datStruct.nspecC,mrsi.spatZF,mrsi.spatZF,datStruct.nRcvrs));

%--- index selection ---
if mod(datStruct.nEncR,2)==1 && mod(mrsi.spatZF,2)==1      % datStruct.nEncR and mrsi.spatZF odd
    MinIndUD = (mrsi.spatZF-datStruct.nEncR)/2+1;
    MaxIndUD = MinIndUD+datStruct.nEncR-1;
elseif mod(datStruct.nEncR,2)==0 && mod(mrsi.spatZF,2)==0  % datStruct.nEncR and mrsi.spatZF even
    MinIndUD = (mrsi.spatZF-datStruct.nEncR)/2+1;
    MaxIndUD = MinIndUD+datStruct.nEncR-1;
elseif mod(datStruct.nEncR,2)==1 && mod(mrsi.spatZF,2)==0  % datStruct.nEncR odd, mrsi.spatZF even
    fprintf('%s -> don''t know how to do this: datStruct.nEncR is odd, mrsi.spatZF is even',FCTNAME);
    return
else        % mod(datStruct.nEncR,2)==0 && mod(mrsi.spatZF,2)==1  % datStruct.nEncR even, mrsi.spatZF odd
    fprintf('%s -> don''t know how to do this: datStruct.nEncR is even, mrsi.spatZF is odd',FCTNAME);
    return
end
if mod(datStruct.nEncP,2)==1 && mod(mrsi.spatZF,2)==1      % datStruct.nEncP and mrsi.spatZF odd
    MinIndLR = (mrsi.spatZF-datStruct.nEncP)/2+1;
    MaxIndLR = MinIndLR+datStruct.nEncP-1;
elseif mod(datStruct.nEncP,2)==0 && mod(mrsi.spatZF,2)==0  % datStruct.nEncP and mrsi.spatZF even
    MinIndLR = (mrsi.spatZF-datStruct.nEncP)/2+1;
    MaxIndLR = MinIndLR+datStruct.nEncP-1;
elseif mod(datStruct.nEncP,2)==1 && mod(mrsi.spatZF,2)==0  % datStruct.nEncP odd, mrsi.spatZF even
    fprintf('%s -> don''t know how to do this: datStruct.nEncP is odd, mrsi.spatZF is even',FCTNAME);
    return
else        % mod(datStruct.nEncP,2)==0 && mod(mrsi.spatZF,2)==1  % datStruct.nEncP even, mrsi.spatZF odd
    fprintf('%s -> don''t know how to do this: datStruct.nEncP is even, mrsi.spatZF is odd',FCTNAME);
    return
end    

%--- data assignment ---
fidKSpNew(:,MinIndUD:MaxIndUD,MinIndLR:MaxIndLR,:) = datStruct.fidksp;
datStruct.fidksp = fidKSpNew;
datStruct.nEncR  = mrsi.spatZF;
datStruct.nEncP  = mrsi.spatZF;

%--- info printout ---
fprintf('Spatial ZF to %.0fx%.0f applied (%s).\n',datStruct.nEncR,datStruct.nEncP,datStruct.name);

%--- update success flag ---
f_succ = 1;




end
