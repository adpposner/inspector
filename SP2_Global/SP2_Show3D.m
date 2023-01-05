%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Show3D(dat3D, varargin)
%% 
%%  3D visualization of arbitrary 3D map
%%  
%%  Note:
%%  Colors shown on cutaway surfaces correspond to the real B0 values at
%%  those points.
%%  Colors shown on the outside surface of an object are not the real outside
%%  border B0 values. Instead the colors shown are from one pixel further
%%  inside the volume.
%%
%%  03-2007, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global pars exm syn impt ana reg flag

FCTNAME = 'SP2_Show3D';


%--- init success flag ---
f_succ = 0;

%--- function argument handling ---
narg = nargin;
if narg==2
    nameCell  = SP2_Check4CellR(varargin{1});
elseif narg==3
    nameCell  = SP2_Check4CellR(varargin{1});
    titleCell = SP2_Check4CellR(varargin{2});       % not yet used
elseif narg~=1
    fprintf('%s -> sorry, only 1..3 input arguments are supported!',FCTNAME);
    return
end

%--- transformation to RGB value range [0 1] ---
switch flag.fmWin
    case 3  % ROI
        Btmp = SP2_ConvertGray2RGB(dat3D.*exm.roiComb);
    case 4  % synthesis
        Btmp = SP2_ConvertGray2RGB(dat3D.*syn.roi);
    case 7  % import
        Btmp = SP2_ConvertGray2RGB(dat3D.*impt.roi);
    case 8  % analysis
        Btmp = SP2_ConvertGray2RGB(dat3D.*ana.roi);
    case 9  % region
        Btmp = SP2_ConvertGray2RGB(dat3D.*reg.roi);
    otherwise
        fprintf('%s -> flag.fmWin=%i is not supported\n',FCTNAME,flag.fmWin);
        return
end
B = squeeze(Btmp(:,:,:,1));
fprintf('%s -> color limits: %sHz\n',FCTNAME,SP2_Vec2PrintStr(pars.colLims,0));

%--- labeling of non-contributing voxels ---
switch flag.fmWin
    case 3  % ROI
        coords = find(exm.roiComb==0);
    case 4  % synthesis
        coords = find(syn.roi==0);
    case 7  % import
        coords = find(impt.roi==0);
    case 8  % analysis
        coords = find(ana.roi==0);
    case 9  % region
        coords = find(reg.roi==0);
end
B(coords)=-2;                                   % Points outside the ROI are set to -2

%--- (cuboid) volume extraction ---
switch flag.fmWin
    case 3  % ROI
        [limX limY limZ] = limDeterm(exm.roiComb);
        x = exm.posX3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        y = exm.posY3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        z = exm.posZ3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
    case 4  % synthesis
        [limX limY limZ] = limDeterm(syn.roi);
        x = syn.posX3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        y = syn.posY3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        z = syn.posZ3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
    case 7  % import
        [limX limY limZ] = limDeterm(impt.roi);
        [posX3D,posY3D,posZ3D] = ndgrid(impt.posX1D,impt.posY1D,impt.posZ1D);
        x = posX3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        y = posY3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        z = posZ3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        clear posX3D posY3D posZ3D
    case 8  % analysis
        [limX limY limZ] = limDeterm(ana.roi);
        x = ana.posX3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        y = ana.posY3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        z = ana.posZ3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
    case 9  % region
        [limX limY limZ] = limDeterm(reg.roi);
        x = reg.posX3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        y = reg.posY3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
        z = reg.posZ3D(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));
end
B = B(limX(1):limX(2),limY(1):limY(2),limZ(1):limZ(2));


%--- determination of the 3D shaped surface values ---
% The colorvalues are taken from one layer of points outside the ROI- 
% this circshifts the whole volume in 3D in all directions by 2 points: one
% because the colormap values for the outside surface are taken from a shell
% of points one outside the outer boundary, and the 2nd shifted point
% because of the effect of trying to calculate B0 at the partial volume
% border on the outside of the volume.

B1 = B;
B2 = B1;
B2 = circshift(B2,[0 -2 0]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B2 = B1;
B2 = circshift(B2,[0 2 0]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B2 = B1;
B2 = circshift(B2,[0 0 2]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B2 = B1;
B2 = circshift(B2,[0 0 -2]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B2 = B1;
B2 = circshift(B2,[2 0 0]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B2 = B1;
B2 = circshift(B2,[-2 0 0]);
coords2 = find((B1==-2 & B2>=0));
B1(coords2)=B2(coords2);

B1 = smooth3(B1);                       % so outside doesnt appear jagged
clear B2

%--- image dimension scaling ---
switch flag.fmWin
    case 3  % ROI
        if flag.plotOrient==1               % sagittal
            scaleVec = [exm.res(3) exm.res(2) exm.res(1)];
        elseif flag.plotOrient==2           % coronal
            % x and y are exchanged, when they are plotted
            scaleVec = [exm.res(3) exm.res(1) exm.res(2)];     
        else                                % axial
            scaleVec = [exm.res(2) exm.res(1) exm.res(3)];
        end
    case 4  % synthesis
        if flag.plotOrient==1               % sagittal
            scaleVec = [syn.res(3) syn.res(2) syn.res(1)];
        elseif flag.plotOrient==2           % coronal
            % x and y are exchanged, when they are plotted
            scaleVec = [syn.res(3) syn.res(1) syn.res(2)];     
        else                                % axial
            scaleVec = [syn.res(2) syn.res(1) syn.res(3)];
        end
    case 7  % import
        if flag.plotOrient==1               % sagittal
            scaleVec = [impt.res(3) impt.res(2) impt.res(1)];
        elseif flag.plotOrient==2           % coronal
            % x and y are exchanged, when they are plotted
            scaleVec = [impt.res(3) impt.res(1) impt.res(2)];     
        else                                % axial
            scaleVec = [impt.res(2) impt.res(1) impt.res(3)];
        end
    case 8  % analysis
        if flag.plotOrient==1               % sagittal
            scaleVec = [ana.res(3) ana.res(2) ana.res(1)];
        elseif flag.plotOrient==2           % coronal
            % x and y are exchanged, when they are plotted
            scaleVec = [ana.res(3) ana.res(1) ana.res(2)];     
        else                                % axial
            scaleVec = [ana.res(2) ana.res(1) ana.res(3)];
        end
    case 9  % region
        if flag.plotOrient==1               % sagittal
            scaleVec = [reg.res(3) reg.res(2) reg.res(1)];
        elseif flag.plotOrient==1           % coronal
            % x and y are exchanged, when they are plotted
            scaleVec = [reg.res(3) reg.res(1) reg.res(2)];     
        else                                % axial
            scaleVec = [reg.res(2) reg.res(1) reg.res(3)];
        end
end


%--- plot 3D shape ---
% Plots outside surface of B with the colors taken from dataset B1 (outside
% surface shown is really one point inside the real dataset's outside
% surface.
fh_3D = figure;
if narg>1
    set(fh_3D,'Name',nameCell{1})
end
set(fh_3D,'NumberTitle','off','Color',[1 1 1]);
[faces,verts,colors] = isosurface(x,y,z,B,-1,B1); 
p1 = patch('Vertices',verts,'Faces',faces,'FaceVertexCData',colors, ... 
           'FaceColor','interp','edgecolor','interp');

%--- add colorbar ---
if flag.plotColorBar
    fh_tmp = figure;
    set(fh_tmp,'Position',[440 378 813 418])
    fake2plot = repmat(pars.colLims,2,1);
    imagesc(fake2plot)
    cb_tmp = colorbar;
    cb = copyobj(cb_tmp,fh_tmp);
    copyobj(cb,fh_3D)
    delete(fh_tmp)
end       

caxis([0 1])
set(p1,'FaceColor','interp')
     
%--- plots caps on cutaway surfaces ---
% p2 = patch(isocaps(x,y,z,B,-0.5),'FaceColor','interp','EdgeColor','none');

%--- adjusts viewing angle, aspect ratios ---
set(gca,'DataAspectRatioMode','Manual')
set(gca,'DataAspectRatio',scaleVec)
set(gca,'XDir','reverse')
grid on
shading flat
xlabel('L/R [mm]')
ylabel('P/A [mm]')
zlabel('F/H [mm]')
view(3)

%--- update success flag ---
f_succ = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%      L O C A L     F U N C T I O N                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determination of cartesian min/max limits for 3D ROI
function [limX limY limZ] = limDeterm(roiPatt)
    
roiNX   = squeeze(sum(sum(roiPatt,2),3))';      % number of contributing voxels: x-projection
roiNY   = squeeze(sum(sum(roiPatt,1),3));       % number of contributing voxels: y-projection
roiNZ   = squeeze(sum(sum(roiPatt,1),2))';      % number of contributing voxels: z-projection
roiIndX = find(roiNX);                          % index vector of contributing slices: x-projection
roiIndY = find(roiNY);                          % index vector of contributing slices: y-projection
roiIndZ = find(roiNZ);                          % index vector of contributing slices: z-projection
limX    = [roiIndX(1) roiIndX(end)];            % ROI slice limits [min max]: x-projection
limY    = [roiIndY(1) roiIndY(end)];            % ROI slice limits [min max]: y-projection
limZ    = [roiIndZ(1) roiIndZ(end)];            % ROI slice limits [min max]: z-projection
