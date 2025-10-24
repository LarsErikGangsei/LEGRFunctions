%% --------------------------------------------------------------------- %%
% Function add normals to vertices in a mesh
%
% Author: Lars Erik Gangsei
% Date: 15th of February 2021
%
% Innput:
%       - FV a mesh as given by matlab's function isosurface
%
% Output:
%       - FV_out: A mesh where normals are added for the innput mesh

function FV_out = Add_mesh_normals(FV)
FV_out = FV;
BBox = [round(min(FV.vertices))-1;round(max(FV.vertices))+1];

FV.vertices = FV.vertices-ones(size(FV.vertices))*diag(min(FV.vertices)-1);

VV = VOXELISE(diff(BBox(:,1)),diff(BBox(:,2)),diff(BBox(:,3)),FV);
VV = smooth3(VV);

%imagesc(squeeze(sum(VV,2)))

FV_out.normals = isonormals(VV,FV.vertices(:,[2 1 3]));

FV_out.normals = FV_out.normals(:,[2 1 3])
FV_out.normals = FV_out.normals./vecnormals(FV_out.normals')'*ones(1,3);
end