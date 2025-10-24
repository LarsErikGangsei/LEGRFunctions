%% --------------------------------------------------------------------- %%
% Function to reduce the vertice part of surface to just be the faces.
%
% Author: Lars Erik Gangsei
% Date: 13th of May 2020
%
% Innput:
%       - Surf: a structure with "mesh fields" as given by matlab's function isosurface
%       - Ind: an index of which faces to keep
%
% Output:
%       - A surface with reduced matrices for vertices and faces

function SurfRed = MeshReduce(Surf,Ind)

SurfRed.faces = Surf.faces(Ind,:);
ff = unique(Surf.faces(Ind,:));
nn = size(Surf.vertices,1);
SurfRed.vertices = Surf.vertices;
for ii = nn:-1:1
    if ~ismember(ii,ff)
        SurfRed.vertices(ii,:) = [];
        SurfRed.faces(SurfRed.faces>=ii) = SurfRed.faces(SurfRed.faces>=ii)-1;
    end
end



end