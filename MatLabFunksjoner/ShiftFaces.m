%% --------------------------------------------------------------------- %%
% Function to move face from one surface to another
%
% Author: Lars Erik Gangsei
% Date: 14th of May 2020
%
% Innput:
%       - Surf1 and Surf2: two structures with "mesh fields" as given by matlab's function isosurface
%
% Output:
%       - Surf1 and Surf1: Indexes for which faces are considered common

function [Surf1,Surf2] = ShiftFaces(Surf1,Surf2)
h = figure();
  axis image
    hold on
    

MP1 = FaceMP(Surf1);
MP2 = FaceMP(Surf2);

    P1 = patch(Surf1,'FaceColor','b','FaceAlpha',0.5,'EdgeColor','k','PickableParts','none');
    P2 = patch(Surf2,'FaceColor','r','FaceAlpha',0.5,'EdgeColor','k','PickableParts','none');
  
  
    pl1 = plot3(MP1(:,1),MP1(:,2),MP1(:,3), 'MarkerFaceColor','b',...
        'MarkerEdgeColor','k','LineStyle','none','Marker','o','MarkerSize',5);
    
    pl2 = plot3(MP2(:,1),MP2(:,2),MP2(:,3), 'MarkerFaceColor','r',...
        'MarkerEdgeColor','k','LineStyle','none','Marker','o','MarkerSize',5);
    
    % set the callback, pass pointCloud to the callback function
set(h, 'WindowButtonDownFcn', {@callbackClickA3DPoint}); 
   V1 = Surf1.vertices;
    V2 = Surf2.vertices;
    
     F1 = Surf1.faces;
    F2 = Surf2.faces;
waitfor(h)
  Surf1.vertices = V1;
    Surf2.vertices= V2;
    
     Surf1.faces = F1;
    Surf2.faces = F2;
    
  function callbackClickA3DPoint(src, eventData)
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Babak Taati - May 4, 2005
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009

pointCloud = [MP1' MP2'];

point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the nearest neighbour to the clicked point 
[pI,dist] = dsearchn(rotatedPointCloud(1:2,:)', ... 
    rotatedPointFront(1:2))

if dist<2
if pI>size(MP1,1)
    ind2 = pI-size(MP1,1);
    Surf1.vertices = [Surf1.vertices;Surf2.vertices(Surf2.faces(ind2,:),:)];
    Surf1.faces = [Surf1.faces;[size(Surf1.vertices,1)-2 ...
        size(Surf1.vertices,1)-1 size(Surf1.vertices,1)]];
    
    MP1 = [MP1;MP2(ind2,:)];
    indV2 = 1:size(MP2,1);
    MP2(ind2,:) = [];
    
    indV2(ind2)=[];
    Surf2 = MeshReduce(Surf2,indV2);    
else
        ind1 = pI;
    Surf2.vertices = [Surf2.vertices;Surf1.vertices(Surf1.faces(ind1,:),:)];
    Surf2.faces = [Surf2.faces;[size(Surf2.vertices,1)-2 ...
        size(Surf2.vertices,1)-1 size(Surf2.vertices,1)]];
    
    MP2 = [MP2;MP1(ind1,:)];
    indV1 = 1:size(MP1,1);
    MP1(ind1,:) = [];
    
    indV1(ind1)=[];
    Surf1 = MeshReduce(Surf1,indV1);    
end

  P1.Faces = Surf1.faces;
    P1.Vertices = Surf1.vertices;
    
    V1 = Surf1.vertices;
    V2 = Surf2.vertices;
    
     F1 = Surf1.faces;
    F2 = Surf2.faces;
    
    pl1.XData = MP1(:,1);
    pl1.YData = MP1(:,2);
    pl1.ZData = MP1(:,3);
    
    P2.Faces = Surf2.faces;
    P2.Vertices = Surf2.vertices;
    
    pl2.XData = MP2(:,1);
    pl2.YData = MP2(:,2);
    pl2.ZData = MP2(:,3);
    
clear 'pI'

    
% h = findobj(gca,'Tag','pt'); % try to find the old point
% selectedPoint = pointCloud(:, pointCloudIndex); 
% 
% if isempty(h) % if it's the first click (i.e. no previous point to delete)
%     
%     % highlight the selected point
%     h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
%         selectedPoint(3,:), 'r.', 'MarkerSize', 20); 
%     set(h,'Tag','pt'); % set its Tag property for later use   
% 
% else % if it is not the first click
% 
%     delete(h); % delete the previously selected point
%     
%     % highlight the newly selected point
%     h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
%         selectedPoint(3,:), 'r.', 'MarkerSize', 20);  
%     set(h,'Tag','pt');  % set its Tag property for later use
% 
% end
   end

%fprintf('you clicked on point number %d\n', pointCloudIndex);
  end
end