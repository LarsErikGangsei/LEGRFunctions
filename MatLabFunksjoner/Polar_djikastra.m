
%% --------------------------------------------------------------------- %%
% Function doing a djicastra segmentation based on a transformation to  
% polar coordinates.

% - Lars Erik Gangsei 03.11.2015. 
% - lars.erik.gangsei@animalia.no, +47 95061231

%% - Input ------------------------------------------------------------- %%
% - Img: A 2d image in cortesian coordinates which are to be segmented.
% - gradient: If gradient is to be used. -1 or 1 means gradient is used.
%             The sign show positive or negative. 0 (default) means no 
%             gradient is. 
% -com: The cartesian coordinatiates corresponding to distance = 0 in 
%       polar coordinates. If nor set image center is used
% -dist: (optional), minimum dist from center to segmented obj.
% -overlap: The structure for how overlapping in Djikastra is allowed.
% -dist_2: (optional), maximum dist from center to segmented obj.
% - roi_inp: (optional), region of interest limiting the segmentation.

%% - Output ------------------------------------------------------------ %%
% - ROI: A image of same size as "Img". "2"-s in center, "1"-s in limit
%        and 0 outside ROI.
% - pol_img: The input image in polar form


function [ROI,pol_img] = Polar_djikastra(Img,grad,com,dist,overlap,punish,dist_2,...
    roi_inp)

if ~exist('overlap','var');
    overlap=3;
end

if ~exist('dist','var');
    dist=0;
end

if ~exist('dist_2','var');
    dist_2=size(Img,1);
end

if ~exist('com','var')
    com=round([size(Img,1)/2 size(Img,2)/2]);
else
    if isempty(com)
        com=round([size(Img,1)/2 size(Img,2)/2]);
    end
end

if ~exist('grad','var')
    grad=0;
end

if ~exist('punish','var')
    punish=zeros(1,overlap);
end


[XX YY]=meshgrid(1:size(Img,2),1:size(Img,1));
XX=XX-com(1); YY=YY-com(2);
[theta, rho] = cart2pol(XX(:),YY(:));
pol_x=round((theta-min(theta))*(size(Img,2)/range(theta)))+1;
pol_y=round((rho-min(rho))*(size(Img,1)/range(rho)))+1;
pol_x(pol_x<1)=1;pol_x(pol_x>size(Img,2))=size(Img,2);
pol_y(pol_y<1)=1;pol_y(pol_y>size(Img,1))=size(Img,1);
   
pol_ind=sub2ind(size(Img),pol_y,pol_x);
pol_img=zeros(size(Img)); 
pol_img=pol_img./pol_img;
pol_img(pol_ind)=Img(:);

if abs(grad)==1;
    [~,pol_img]=gradient(pol_img);
    pol_img=grad*pol_img;
end

pol_img(isnan(pol_img(:)))=nanmean(pol_img(:));
if dist>0;pol_img(1:dist,:)=max(pol_img(:));end
pol_img(dist_2:end,:)=max(pol_img(:));

if exist('roi_inp','var')
    roi_inp_pol=zeros(size(Img));
    roi_inp_pol(pol_ind)=roi_inp(:);
    pol_img(roi_inp_pol==0)=max(pol_img(:));
end

 % imagesc(pol_img)
 % figure()
% pause(1)
 roi2d_pol=(Djikastra_expanded(pol_img',overlap,punish))';

 [tmp_x tmp_y]=ind2sub(size(roi2d_pol),find(roi2d_pol(:)==1));
% hold on
% plot(tmp_y,tmp_x,'r','LineWidth',4)
%figure()
%imagesc(roi2d_pol)

ROI=zeros(size(Img));
ROI(:)=roi2d_pol(pol_ind);
ROI=imfill(ROI,'holes');

end