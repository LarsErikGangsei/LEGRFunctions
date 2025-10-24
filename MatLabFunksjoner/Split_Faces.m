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

function FV_out = Split_Faces(FV,d_lim)

FF = FV.faces;
VV = FV.vertices;

 for ii =  size(FF,1):-1:1
     d_mat = pdist(VV(FF(ii,:),:));
    if max(d_mat)>d_lim
        comb = find(d_mat == max(d_mat));
        switch comb(1)
            case 1
                comb_vec = [1 2]; 
                ff_n = 3;
            case 2
                comb_vec = [1 3]; 
                ff_n = 2;
            case 3
                comb_vec = [2 3]; 
                ff_n = 1;
        end
        VV = [VV;mean(VV(FF(ii,comb_vec),:))];
        FF = [FF;[size(VV,1) FF(ii,[comb_vec(2) ff_n])]];    
        FF(ii,:) = [size(VV,1) FF(ii,[comb_vec(1) ff_n])];
    end
 end
FV_out.vertices = VV;
FV_out.faces = FF;
end