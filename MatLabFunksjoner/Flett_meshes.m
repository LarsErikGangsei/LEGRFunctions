%% --------------------------------------------------------------------- %%
% Function to fit two meshes too each other
%
% Author: Lars Erik Gangsei
% Date: 23th of June 2020
%
% Innput:
%       - FV1 and FV2: mesh as given by matlab's function isosurface
%       - ind1 and Ind2: Index of vertices that are merged together.
%
% Output:
%       - FV1_out and FV2_out: Two meshes with connected vertices

function [FV1_out,FV2_out] = Flett_meshes(FV1,FV2,ind1,ind2)
FF1 = FV1.faces;
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