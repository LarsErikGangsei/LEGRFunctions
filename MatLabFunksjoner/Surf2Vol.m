%% --------------------------------------------------------------------- %%
% Function to delete faces in Meshes
%
% Author: Lars Erik Gangsei
% Date: 11th of May 2020
%
% Innput:
%       - SurfStr: a structure with "mesh fields" as given by matlab's function isosurface
%       - SFields (optional) the fields to use.
%       - Vscale (optional): How to scale vertices.
%     
%
% Output:
%       - VV: The volume defined by the mesh input

function VV = Surf2Vol(SurfStr,SFields,Vscale,Vadjust,Vdim)

if~exist('SFields','var');SFields=fieldnames(SurfStr);end
if~exist('Vscale','var');Vscale = 1;end
if~exist('Vadjust','var');Vadjust = [0 0 0];end


mm = length(SFields);

SS = fieldnames(SurfStr);
for ii = 1:length(SS)
    ss = SS{ii};
    if sum(strcmp(ss,SFields))==0
        SurfStr = rmfield(SurfStr,ss);
    else
        SurfStr.(ss).vertices = (SurfStr.(ss).vertices+...
            ones(size(SurfStr.(ss).vertices))*diag(Vadjust))/Vscale;
    end
end

if~exist('Vdim','var')
vvmin = min(cell2mat(struct2cell(structfun(@(x) min(x.vertices),...
    SurfStr,'UniformOutput',false))));
vvmax = max(cell2mat(struct2cell(structfun(@(x) max(x.vertices),...
    SurfStr,'UniformOutput',false)))) + [1 1 1];
Vdim = ceil(vvmax-vvmin);
end
VV = zeros(Vdim);

for ii = 1:mm
    %SurfStr.(SFields{ii}).vertices = (SurfStr.(SFields{ii}).vertices/Vscale-...
    %    ones(size(SurfStr.(SFields{ii}).vertices))*diag(vvmin));
    
    
    BB_box = [floor(min(SurfStr.(SFields{ii}).vertices))' ceil(max(SurfStr.(SFields{ii}).vertices))'];
    VVD = VOXELISE(BB_box(1,2)-BB_box(1,1),BB_box(2,2)-BB_box(2,1),...
    BB_box(3,2)-BB_box(3,1),SurfStr.(SFields{ii}));

    idxVVD = find(VVD==1);
    VVD = VV((BB_box(1,1)+1):BB_box(1,2),(BB_box(2,1)+1):BB_box(2,2),...
    (BB_box(3,1)+1):BB_box(3,2));
    VVD(idxVVD)=ii;
    VV((BB_box(1,1)+1):BB_box(1,2),(BB_box(2,1)+1):BB_box(2,2),...
    (BB_box(3,1)+1):BB_box(3,2)) = VVD;

    
end


end