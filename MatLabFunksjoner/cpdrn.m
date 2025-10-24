
%% --------------------------------------------------------------------- %%
% Code for _C_oherent _P_oint _D_rift _R_otation _N_ormals (cpdrn).
%
% See Gangsei & Nordbø (2019) for detail. 
% Based basically on: 
% - Myronenko, A., & Song, X. (2010). Point set registration: Coherent 
%       point drift. IEEE transactions on pattern analysis and machine 
%       intelligence, 32(12), 2262-2275.
% - Challis, J. H. (1995). A procedure for determining rigid body   %%
%       transformation parameters. Journal of biomechanics, 28(6),      %%
%       733-737.               
%
% - Lars Erik Gangsei and Øyvind Nordbø, April 2019.
% - lars.erik.gangsei@animalia.no, +47 95061231
% - oyvind.nordbo@norsvin.no, +47 91344102

%% - Input ------------------------------------------------------------- %%
% - YY, XX: Two matrices of size 2n1 x 3 and 2n2 x 3, where n1>n2. The
% first half of rows represent euclidian posision of points in point cloud
% and the second half represents isonormals (i.e. to an object for which
% the pointcloud represents surface points). I.e. row i and row i+n
% represents the same point, posision and normal rspectively.
% - Options: Structure defining the options, having fields:
%            - omega: vector of length n2 representing probabilities that
%            points in X are not represented in Y. If set as a scalar, the 
%            same probability is allocated to all points.
%            - omega_r: vector of length n2 representing probabilities that
%            normals of points in X are not represented in normals of Y. 
%            If set as a scalar, the same probability is allocated to all points.
%            - sim: maximum numer of simultations.
%            - stopcrit: Criteria for stopping



%% - Output ------------------------------------------------------------ %%
% - PP: matrix of size n2 x n1 maximum likelihood estimates for the 
% chances of correspondance between XX and YY. 
% - Beta: maximum likelihood estimate for Beta (transformation + rotation)
% - Sigma: Mximum likelihood estimate for sigma.


function [PP,Beta,Sigma] = cpdrn(XX,YY,Options)
warning('off')
%% 1) Matrice sizes based on input and put "intercept on XX"
% Size of matrices.
nn2 = size(XX,1)/2;
pp = size(XX,2);
nn1 = size(YY,1)/2;
XX = [[ones(nn2,1);zeros(nn2,1)] XX];

%% 2) Options
if ~exist('Options','var')
    Options.sim = 100;
end

if ~isfield(Options,'stopcrit')
    Options.stopcrit = 2*eps;
end

if ~isfield(Options,'sim')
    Options.sim = 100;
end

if ~isfield(Options,'omega')
    Options.omega = 0;
end

if length(Options.omega)~=nn2
    Options.omega = Options.omega(1)*ones(nn2,1);
end

if size(Options.omega,1)==1
    Options.omega = Options.omega';
end

if ~isfield(Options,'omega_r')
    Options.omega_r = 0;
end

if length(Options.omega_r)~=nn2
    Options.omega_r = Options.omega_r(1)*ones(nn2,1);
end

if size(Options.omega_r,1)==1
    Options.omega_r = Options.omega_r';
end


%% 3) Initiate Beta and Sigma
Beta = [mean(YY(1:nn1,:))-mean(XX(1:nn2,2:end));eye(size(YY,2))];
sigma_p = (nn1*trace(XX(1:nn2,2:end)'*XX(1:nn2,2:end))+nn2*trace(YY(1:nn1,:)'*YY(1:nn1,:))...
    -2*sum(XX(1:nn2,2:end))*sum(YY(1:nn1,:))')/(nn1*pp*nn2);
sigma_r = (nn1*trace(XX((nn2+1):end,2:end)'*XX((nn2+1):end,2:end))+nn2*trace(YY((nn1+1):end,:)'*YY((nn1+1):end,:))...
    -2*sum(XX((nn2+1):end,2:end))*sum(YY((nn1+1):end,:))')/(nn1*pp*nn2);
Sigma =[sigma_p 0;0 sigma_r];

%% 4) Start looping and updating
for ii=1:Options.sim

%% 5) Find distances and update PP
Pdist_Pos = pdist2(XX(1:nn2,:)*Beta,YY(1:nn1,:));
Pdist_Rot = pdist2(XX((nn2+1):end,:)*Beta,YY((nn1+1):end,:));

log_p = -3*log(2*pi)-3*sqrt(Sigma(1,1))/2-3*sqrt(Sigma(2,2))/2-...
    0.5*(Pdist_Pos.^2/Sigma(1,1) + Pdist_Rot.^2/Sigma(2,2));

nom_PP = exp(log_p);
dnom_PP = (sum(nom_PP,2).*(1-Options.omega) + Options.omega/nn1)*ones(1,nn1);

PP = nom_PP./dnom_PP;
PP_r = PP.*((1-Options.omega_r)*ones(1,nn1));

%% 6) Update Sigma
Err_p_sq = (PP*YY(1:nn1,:)-XX(1:nn2,:)*Beta).^2; 
sigma_p = sum(Err_p_sq(:))/(nn2*pp);

Err_r_sq = (PP_r*YY((nn1+1):end,:)-XX((nn2+1):end,:)*Beta).^2; 
sigma_r = sum(Err_r_sq(:))/(nn2*pp);
Sigma =[sigma_p 0;0 sigma_r];

 %   sigma_sq = (trace((YY.*(sum(PP,2)*ones(1,pp)))'*YY)-...
 %       trace(YY'*PP*Phi*Beta))/(NN_p*pp);
   

%% 7) Update Beta based on Challis rotation
ww = kron([1/sqrt(Sigma(1,1));1/sqrt(Sigma(2,2))],ones(nn2,1));
ww = ww/max(ww(:));
Beta = Challis_rot_Norm([PP zeros(nn2,nn1);zeros(nn2,nn1) PP_r]*YY,XX(:,2:end),ww);



  
end


% [corr,~] = ind2sub(size(PP),find(Eps == (ones(NN,1)*min(Eps))));
% 
% 
%     function log_p = log_like
%         log_p = -0.5*(NN_p*pp*log(sigma_sq) + trace(Eps'*PP*PP'*Eps)/sigma_sq);
%     end


function Beta = Challis_rot_Norm(YYc,XXc,ww);
 nn = size(YYc,1);
 WW_sq = (ww*ones(1,3)).^2;
 YY_m = (ww*ones(1,3)).*(YYc - ones(nn,1)*(sum(WW_sq.*YYc)./sum(WW_sq)));
 XX_m = (ww*ones(1,3)).*(XXc - ones(nn,1)*(sum(WW_sq.*XXc)./sum(WW_sq)));
 CC = (YY_m'*XX_m)/sum(WW_sq(:,1));
 
 [UU SS VV] = svd(CC);
 
 RR = UU*[1 0 0;0 1 0;0 0 det(UU*VV')]*VV';
 dd = mean(YYc(1:(nn/2),:)) - (RR*mean(XXc(1:(nn/2),:))')';
 Beta = [dd;RR];
 
end



warning('on')
end