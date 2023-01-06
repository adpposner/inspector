%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function bestFit = SP2_BestApprox(varargin)
%%
%%  function SP2_BestApprox(varargin)
%%  determines the (double precision) index of xVector to fit value
%%  vAlue on yVector. The subpoint accuracy is achieved by linear interpolation.
%%  parameter assignment:
%%  1) 2 args: 1 vector, value -> the best index is returned (in double precision)
%%  2) 3 args: x vector, y vector, y value -> the best x-value is determined and returned
%%  
%%  02-2005, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_BestApprox';


%--- init result ---
bestFit = 0;

%--- parameter handling ---
if nargin==2
    yVec    = SP2_Check4RowVecR( varargin{1} );
    xVec    = 1:length(yVec);
    appVal  = SP2_Check4NumR( varargin{2} );
elseif nargin==3
    xVec    = SP2_Check4RowVecR( varargin{1} );
    yVec    = SP2_Check4RowVecR( varargin{2} );
    if length(xVec)~=length(yVec)
        fprintf('%s -> x- and y-vector must of the same size, length(x/y)=%i/%i\n\n',FCTNAME,length(xVec),length(yVec));
        return
    end
    appVal  = SP2_Check4NumR( varargin{3} );
else
    fprintf('%s -> number of arguments must be two or three, but is %i\n\n',FCTNAME,nargin);
    return
end

%--- consistency check ---
if isempty(appVal)
    fprintf('%s ->\nEmpty value to be approximated. Program aborted.\n',FCTNAME);
    return
end

%--- best approximation analysis ---
if appVal==yVec(1)
    bestFit = xVec(1);
elseif appVal==yVec(end)
    bestFit = xVec(end);
elseif ~isempty(find(appVal<yVec)) && ~isempty(find(appVal>yVec))
	[val,ind]=sort(abs(yVec-appVal));
	indNear = ind(1);      % nearest neighbour determination
% 	if indNear==1 && indNear==length(xVec)
%         fprintf('%s -> best approximation value is found around the vector limit and not reliable...\n\n',FCTNAME);
%         return
% 	end
	% simple consideration of the global 2nd nearest neighbour can fail if there is another local
	% amplitude value in that range somewhere else. Therefore a localized search is required:
    if indNear==1                   % value lies between first two points
        ind1 = 1;
        ind2 = 2;
    elseif indNear==length(yVec);   % value lies between last two points
        ind1 = length(yVec)-1;
        ind2 = length(yVec);
    else
        A = yVec(indNear-1);        % value before the closest
        B = yVec(indNear);          % nearest value
        if B>A && appVal>B          % positive slope && to the right, ie. after
            ind1 = indNear;
            ind2 = indNear+1;
        elseif B>A && appVal<=B      % positive slope && to the left, ie. before
            ind1 = indNear-1;
            ind2 = indNear;
        elseif B<A && appVal>B      % negative slope && to the left, ie. before
            ind1 = indNear-1;
            ind2 = indNear;
        elseif B<A && appVal<=B      % negative slope && to the right, ie. after
            ind1 = indNear;
            ind2 = indNear+1;
        end    
    end
	
	%--- linear data interpolation ---
	% y = m*x + b
	m = ( yVec(ind1) - yVec(ind2) )/( xVec(ind1) - xVec(ind2));     % slope
	b = yVec(ind1) - m*xVec(ind1);                                  % Achsenabschnitt
	bestFit = (appVal-b)/m;
else
    fprintf('%s -> the value to be approximated (%d) is outside the\nrange of the assigned data vector (%d..%d)!!!\n\n',...
            FCTNAME,appVal,min(yVec),max(yVec))
    return
end

end
