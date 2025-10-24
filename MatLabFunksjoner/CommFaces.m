%% --------------------------------------------------------------------- %%
% Function to move face from one surface to another
%
% Author: Lars Erik Gangsei
% Date: 14th of May 2020
%
% Innput:
%       - Surf1 and Surf2: two structures with "mesh fields" as given by matlab's function isosurface
%       - dlim: limiting distance for when two faces are considered common.
%       - showfig: logical. If figure is to be shown.
%       - direct (optional): If not given not used 'trans','sag','cor'
%                            '-trans','-sag','-cor'
%
% Output:
%       - Int1 and Int2: Indexes for which faces are considered common

function [Int1,Int2,Surf1Red,Surf2Red] = CommFaces(Surf1,Surf2,dlim,showfig,direct)

MP1 = FaceMP(Surf1);
MP2 = FaceMP(Surf2);

D_mat = pdist2(MP1,MP2);
[Int1,Int2] = ind2sub(size(D_mat),find(D_mat<dlim));
Int1 = unique(Int1);
Int2 = unique(Int2);

if exist('direct','var')    
    CP1 = CrossNorms(Surf1,Int1);
    CP2 = CrossNorms(Surf2,Int2);
    switch direct
        case 'trans'
            Int1(CP1(:,3)<(1/sqrt(2))) = [];
            Int2(CP2(:,3)<(1/sqrt(2))) = [];
        case '-trans'
            Int1(CP1(:,3)>(1/sqrt(2))) = [];
            Int2(CP2(:,3)>(1/sqrt(2))) = [];
        case 'sag'
            Int1(CP1(:,1)<(1/sqrt(2))) = [];
            Int2(CP2(:,1)<(1/sqrt(2))) = [];
        case '-sag'
            Int1(CP1(:,1)>(1/sqrt(2))) = [];
            Int2(CP2(:,1)>(1/sqrt(2))) = [];
        case 'cor'
             Int1(CP1(:,2)<(1/sqrt(2))) = [];
            Int2(CP2(:,2)<(1/sqrt(2))) = [];
        case '-cor'
             Int1(CP1(:,2)>(1/sqrt(2))) = [];
            Int2(CP2(:,2)>(1/sqrt(2))) = [];
        otherwise
end
end

Surf1Red = MeshReduce(Surf1,Int1);
Surf2Red = MeshReduce(Surf2,Int2);

if showfig==1
    patch(Surf1,'FaceColor','b','FaceAlpha',0.2,'EdgeColor','none')
    patch(Surf2,'FaceColor','r','FaceAlpha',0.2,'EdgeColor','none')
    patch(Surf1Red,'FaceColor','b','FaceAlpha',1,'EdgeColor','k')
    patch(Surf2Red,'FaceColor','r','FaceAlpha',1,'EdgeColor','k')
    axis image
end

    function CP = CrossNorms(Surf,Int)
        CPA = Surf.vertices(Surf.faces(Int,2),:)-Surf.vertices(Surf.faces(Int,1),:);
        CPB = Surf.vertices(Surf.faces(Int,3),:)-Surf.vertices(Surf.faces(Int,1),:);
        CP = cross(CPA,CPB,2);
        CP = abs(CP./(vecnorm(CP')'*ones(1,3)));
    end


end