%% --------------------------------------------------------------------- %%
% Function to delete faces in Meshes
%
% Author: Lars Erik Gangsei
% Date: 1th of April 2020
%
% Innput:
%       - FV: a mesh as given by matlab's function isosurface
%       - indx: Index of which faces to delete.
%
% Output:
%       - FV_out: The mesh with deleted faces

function FV_out = Delete_Faces(FV,indx)

FF = FV.faces;
Vert_indx = unique(FF(indx,:));
if size(Vert_indx,2)==1;Vert_indx = Vert_indx';end
Vert_indx = sort(Vert_indx,'descend');

FF(indx,:)=[];
VV = FV.vertices;

 for ii =  Vert_indx
    if ~ismember(ii,unique(FF))
        VV(ii,:)=[];
        FF(FF>ii) = FF(FF>ii)-1;
    end
 end
FV_out.vertices = VV;
FV_out.faces = FF;
end