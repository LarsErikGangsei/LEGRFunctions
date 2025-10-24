
%% --------------------------------------------------------------------- %%
% Function doing a djicastra segmentation.

% - Lars Erik Gangsei 03.11.2015. 
% - lars.erik.gangsei@animalia.no, +47 95061231

%% - Input ------------------------------------------------------------- %%
% - Img: A 2d image in cortesian coordinates binary or grayscale.
% - overlap: The length of points that may overlap from row til row.
% - punish: vector of length overlap. Desides the degree of punishment when
%           "changing" direction.


%% - Output ------------------------------------------------------------ %%
% - ROI: A image of same size as "Img". "2"-s in left, "1"-s in limit
%        and 0 on right.
% - cum_cost: A matrix of same size as "Img" containing the cumulative
% cost.

function [ROI cum_cost] = Djikastra_expanded(Img,overlap,punish)

if ~exist('overlap','var');
    overlap=3;
end

if ~exist('punish','var');
    punish=zeros(1,overlap);
end

if size(punish,1)~=size(Img,1);
    punish = ones(size(Img,1),1)*punish;
end

ROI=zeros(size(Img));

cum_cost=zeros(size(Img));

cum_cost(1,:)=Img(1,:);

for ii=2:size(Img,1);
    h_mat=inf*ones(overlap,size(Img,2)+overlap-1);
    for jj=1:overlap;
        h_mat(jj,jj:(jj+size(Img,2)-1))=squeeze(cum_cost(ii-1,:))+punish(ii,jj);
    end
    h_mat=h_mat(:,(overlap/2+0.5):(size(Img,2)+overlap/2-0.5));
    cum_cost(ii,:)=min(h_mat,[],1)+Img(ii,:);
end

for ii=size(Img,1):-1:1;
        if ii==size(Img,1);
            j_ind=find(cum_cost(ii,:)==min(cum_cost(ii,:)));
        else
            pos_ind=max([1 j_ind-overlap/2+0.5]):...
                min([j_ind+overlap/2-0.5 size(Img,2)]);
            h_vec=inf*ones(1,size(Img,2));
            h_vec(pos_ind)=cum_cost(ii,pos_ind);
            j_ind=find(h_vec==min(h_vec));
        end
            
        j_ind=j_ind(round(length(j_ind)/2));
        ROI(ii,1:max([1 j_ind-1]))=2;
        ROI(ii,min([size(Img,2) j_ind+1]))=0;
        ROI(ii,j_ind)=1;      
end
end
        
