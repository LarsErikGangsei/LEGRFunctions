
%% --------------------------------------------------------------------- %%
% Function for getting image moment invariants.
% - Lars Erik Gangsei 23.11.2015.
% - lars.erik.gangsei@animalia.no, +47 95061231

%% - Input ------------------------------------------------------------- %%
% - xyz: Coordinates corresponding to the full size of input.
% - unit_inp: The unit of the input array.
% - dim_out: The dimention of the output image.
% - pixcel_weights: Help for orientating the bone.
% - return_plot: logical. Set to 1 if a plot (matrix) shuld be returned.
% - dir_points: Pixcellist with 3 points defining directions

%% - Output ------------------------------------------------------------ %%
% A structure with the following elements
% - ZZ: Coordinates of theoutput bone correspondingto the size given by dim_out.
% - RR: Eigen vectors for the bone
% - com: The center of mass for inp (not affected by pixcelweights)
% - vv: The volume of the bone.
% - ll: The lengt along the dominating dimention (1. dimention).


function [com RR vv ll ZZ com_out rp] =...
    Get_moments_invariants(xyz,unit_inp,dim_out,...
    pixcel_weights,return_plot,dir_points);

if (~exist('unit_inp','var')||isempty(unit_inp))
    unit_inp=ones(1,3);
end

if (~exist('dim_out','var')||isempty(dim_out))
    dim_out=round(max(xyz))+1;
end

if (~exist('pixcel_weights','var')||isempty(pixcel_weights))
    pixcel_weights=ones(size(xyz,1),1);
end

if (~exist('return_plot','var')||isempty(return_plot))
    return_plot=0;
end

xyz=xyz*diag(unit_inp);
com_ind=mean(xyz);
xyz = xyz-ones(size(xyz,1),1)*com_ind;

%DD=xyz-ones(size(xyz,1),1)*com_ind;

%Sigma=(repmat(pixcel_weights,1,3).*DD)'*DD/sum(pixcel_weights);
Sigma=(repmat(pixcel_weights,1,3).*xyz)'*xyz/sum(pixcel_weights);
[Eig_vecs,Eig_vals] = eig(Sigma);

[~,ind_sort]=sort(sum(Eig_vals),'descend');

Eig_vecs=Eig_vecs(:,ind_sort);

%   for jj=1:3;
%        if (Eig_vecs(find(abs(Eig_vecs(:,jj))==max(abs(Eig_vecs(:,jj)))),jj))<0;
%           Eig_vecs(:,jj)=-Eig_vecs(:,jj);
%        end
%   end

xyz_rot=xyz*Eig_vecs;
%com_out=com_ind*Eig_vecs;
%com_out=com_out-min(xyz_rot,[],1);
%xyz_rot=xyz_rot-ones(size(xyz,1),1)*min(xyz_rot,[],1);

%Test eigenvectors.
if exist('dir_points','var')
    for jj=1:3;
        Tv=xyz_rot(dir_points(jj),jj);
        if Tv<mean(xyz_rot(:,jj));
            Eig_vecs(:,jj)=-Eig_vecs(:,jj);
            xyz_rot=xyz*Eig_vecs;
            %com_out=com_ind*Eig_vecs;
            %com_out=com_out-min(xyz_rot,[],1);
            %xyz_rot=xyz_rot-ones(size(xyz,1),1)*min(xyz_rot,[],1);
        end
    end
end

com_out=min(xyz_rot,[],1);
xyz_rot = xyz_rot - ones(size(xyz_rot,1),3)*diag(com_out);

length_out=max(xyz_rot(:,1));

scal_fac=length_out/dim_out(1);

com_out=com_out/scal_fac;
x_ind=round(xyz_rot(:,1)/scal_fac);x_ind(x_ind<1)=1;
x_ind(x_ind>dim_out(1))=dim_out(1);

y_ind=xyz_rot(:,2)/scal_fac;
y_mean=mean(y_ind);
y_ind=y_ind-y_mean+dim_out(2)/2;

y_ind=round(y_ind);
y_ind(y_ind<1)=1;
y_ind(y_ind>dim_out(2))=dim_out(2);

z_ind=xyz_rot(:,3)/scal_fac;
z_mean=mean(z_ind);
z_ind=z_ind-z_mean+dim_out(3)/2;

z_ind=round(z_ind);
z_ind(z_ind<1)=1;
z_ind(z_ind>dim_out(3))=dim_out(3);

ZZ=[x_ind y_ind z_ind];

RR=Eig_vecs;
com=com_ind;
ll=length_out;
vv=size(xyz,1)*prod(unit_inp);

if return_plot>0;
    figure();
    p_list=sub2ind(dim_out,x_ind(pixcel_weights==1),...
        y_ind(pixcel_weights==1),...
        z_ind(pixcel_weights==1));
    TT=zeros(dim_out);
    TT(p_list)=1;
    TT=TT(2:return_plot:size(TT,1),2:return_plot:size(TT,2),2:return_plot:size(TT,3));
    TT=convn(TT,ones(3,3,3),'same');
    
    TT=TT>(max(TT(:))/5);
    hiso=patch(isosurface(TT,0.5),'FaceColor',[0.8 0.6 0.2],'EdgeColor','none','FaceAlpha',1);
    norm=isonormals(TT,hiso);
    hiso_patch=patch(isocaps(TT,0.5),'FaceColor','interp','EdgeColor','none');
    
    p_list=sub2ind(dim_out,x_ind(pixcel_weights~=1),...
        y_ind(pixcel_weights~=1),...
        z_ind(pixcel_weights~=1));
    TT=zeros(dim_out);
    TT(p_list)=1;
    TT=TT(2:return_plot:size(TT,1),2:return_plot:size(TT,2),2:return_plot:size(TT,3));
    TT=convn(TT,ones(3,3,3),'same');
    
    TT=TT>(max(TT(:))/5);
    hiso=patch(isosurface(TT,0.5),'FaceColor',[1 0 0],'EdgeColor','none','FaceAlpha',1);
    norm=isonormals(TT,hiso);
    hiso_patch=patch(isocaps(TT,0.5),'FaceColor','interp','EdgeColor','none');
    
    daspect([1 1 1]);
    view(90,70)
    axis 'off'
    %mArrow3([size(TT,2) 0 0],[size(TT,2) size(TT,1) 0],'color','red');
    mArrow3([size(TT,2) 0 size(TT,3)],[size(TT,2) size(TT,1) size(TT,3)],'color','blue');
    mArrow3([size(TT,2) 0 size(TT,3)],[size(TT,2) 0 0],'color','black');
    mArrow3([size(TT,2) 0 size(TT,3)],[0 0 size(TT,3)],'color','green');
    
    rp = print('-RGBImage');
    close();
else
    rp=[];
end

end