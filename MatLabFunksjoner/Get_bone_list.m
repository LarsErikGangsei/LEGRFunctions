%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions for getting bone structure from carcass           %%
function [Ind_bone_list Centroids_list numpix] = Get_bone_list(Carc,thr,ncomp,connect)

    if ~exist('connect','var')
    connect=26;
    end

    Ind_bone=logical(Carc>thr);

    for ii = 1:size(Ind_bone,3);
        Ind_bone(:,:,ii) = imfill(Ind_bone(:,:,ii),4,'holes');
    end

    Bone_comp=bwconncomp(Ind_bone,connect);
    numPixels = cellfun(@numel,Bone_comp.PixelIdxList);
    Centroids=regionprops(Bone_comp,'Centroid');
    
    s_numPixels=sort(numPixels);
    II_dd=[];
    for ii =size(numPixels,2):-1:1;
      II_dd=[II_dd, find(numPixels==s_numPixels(ii),1)];
    end
   
    ncomp = min([ncomp length(numPixels)]);
    
    Ind_bone_list=cell(1,ncomp);
    Centroids_list=cell(1,ncomp);
    for jj=1:ncomp;
        Ind_bone_list{jj}=Bone_comp.PixelIdxList{II_dd(jj)};
        Centroids_list{jj}=Centroids(II_dd(jj)).Centroid;
    end
    
    numpix=numPixels(II_dd(1:ncomp));
end