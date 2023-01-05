%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function SP2_LCM_BSpline(T,p,y,order)
    function yVal = SP2_LCM_BSpline(T,ampVec,xx,order)

%% Adapted from 
%% function val = DEBOOR(T,p,y,order)
%% by Jonas Ballani, 2007-11-27, TUM
%% 
%% INPUT:  T     St�tzstellen
%%         p     Kontrollpunkte (nx2-Matrix)
%%         y     Auswertungspunkte (Spaltenvektor)
%%         order Spline-Ordnung
%% 
%% OUTPUT: val   Werte des B-Splines an y (mx2-Matrix)
%%
%%  11-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


% 
%    lcm.anaSplIndPpm    = lcm.anaAllIndPpm(1:pointStep:end);            % sparse ppm vector for spline interpolation
%     lcm.anaSplIndPpmN   = length(lcm.anaSplIndPpm);                     % number of spline points
%     if flag.lcmRealComplex          % real part only
%         lcm.anaSplAmpReal = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
%     else                            % complex FID and fit
%         lcm.anaSplAmpReal = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
%         lcm.anaSplAmpImag = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
%     end


% order = 3;
% T = lcm.anaAllIndPpm(1):(lcm.anaAllIndPpm(end)-lcm.anaAllIndPpm(1))/(lcm.anaSplIndPpmN-1):lcm.anaAllIndPpm(end);
T(length(T)+1) = T(end) + (T(end)-T(end-1));
Torig = T;
% xx = lcm.anaAllIndPpm;
% ampVec = zeros(1,lcm.anaSplIndPpmN);
% ampVec = [0 1 1.9 3.1 4.3 4.6 6 7 9 11 8 6 3];
ampVec(length(ampVec)+1) = ampVec(end);
p = [T; ampVec]';


m = size(p,1);
n = length(xx);
X = zeros(order,order);
Y = zeros(order,order);
a = T(1);
b = T(end);
T = [ones(1,order-1)*a,T,ones(1,order-1)*b];



for l = 1:n
    t0 = xx(l);
    id = find(t0 >= T);
    k  = id(end);
		if (k > m)
            figure
            hold on
            plot(Torig,ampVec,'r*')
            plot(val(:,1),val(:,2),'g')
            plot(xx(1:end-1),val(:,2))
            hold off
            size(val)
            returnFake = 1;
            yVal = [val(:,2); val(end,2)];
			return
		end
    X(:,1) = p(k-order+1:k,1);
    Y(:,1) = p(k-order+1:k,2);

    for i = 2:order
        for j = i:order
            num = t0-T(k-order+j);
            if num == 0
                weight = 0;
            else
				s = T(k+j-i+1)-T(k-order+j);
                weight = num/s;
            end
            X(j,i) = (1-weight)*X(j-1,i-1) + weight*X(j,i-1);
            Y(j,i) = (1-weight)*Y(j-1,i-1) + weight*Y(j,i-1);
        end
    end
    val(l,1) = X(order,order);
    val(l,2) = Y(order,order);
end


fake = 1;



% 
% 
% 
% 
% % function spline(n,order)
% %
% % Plots the B-slpine-curve of n control-points.
% % The control points can be chosen by clicking
% % with the mouse on the figure.
% %
% % COMMAND:  spline(n,order)
% % INPUT:    n     Number of Control-Points
% %           order Order ob B-Splines
% %                 Argnument is arbitrary
% %                 default: order = 4
% %
% % Date:     2007-11-28
% % Author:   Stefan H�eber
% 
% 
% fake = 1;
% 
% 
% 
% close all;
% if (nargin ~= 2)
% 	order = 4;
% end
% nplot = 100;
% 
% if (n < order)
% 	display([' !!! Error: Choose n >= order=',num2str(order),' !!!']);
% 	return;
% end
% 
% figure(1);
% hold on; box on;
% set(gca,'Fontsize',16);
% 
% t = linspace(0,1,nplot);
% 
% for i = 1:n	
% 	title(['Choose ',num2str(i),' th. control point']);
% 	p(i,:) = ginput(1);
% 	hold off;
% 	plot(p(:,1),p(:,2),'k-','LineWidth',2);
% 	axis([0 1 0 1]);
% 	hold on; box on;
% 	if (i  >= order) 
% 		T = linspace(0,1,i-order+2);
% 		y = linspace(0,1,1000);
% 		p_spl = DEBOOR(T,p,y,order);
% 		plot(p_spl(:,1),p_spl(:,2),'b-','LineWidth',4);
% 	end
% 	plot(p(:,1),p(:,2),'ro','MarkerSize',10,'MarkerFaceColor','r');
% end
% 
% title(['B-Spline-curve with ',num2str(n),' control points of order ',num2str(order)]);