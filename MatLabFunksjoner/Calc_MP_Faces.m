%% --------------------------------------------------------------------- %%
% Function to calculate midpoints in faces in mesh
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

function MP = Calc_MP_Faces(FV)
FF = FV.faces;
VV = FV.vertices;
        MP = zeros(size(FF));
        for ll = 1:size(FF,1)
            MP(ll,:) = mean(VV(FF(ll,:),:));
        end
    end

   