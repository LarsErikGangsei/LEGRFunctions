
%% --------------------------------------------------------------------- %%
% Own code for cohernt poiunt drift.
%
% See Myrenenko & Song (2009) for details
%
% - Lars Erik Gangsei 12.05.2018.
% - lars.erik.gangsei@animalia.no, +47 95061231

%% - Input ------------------------------------------------------------- %%
% - YY, XX: Two matrices of size N x p and n x p, where N>n.
% - Options: Structure defining the options, having fields:
%            - Transformation ('rotation' (default), 'affine', 'non_rigid')
%            - Sim: maximum numer of simultations.
%            - Stopcrit: Criteria for stopping
%
% - Theta: Structure with prior parameters.
%            - P_0
%            - omega



%% - Output ------------------------------------------------------------ %%
% - PP: maximum likelihood estimates for the chances of correspondance


function [PP,Beta,corr] = Coherent_point_drift_adjusted_code(XX,YY,Options,Theta)
warning('off')

%% 1) Matrice sizes based on input
% Size of matrices.
[nn, pp] = size(XX);
[NN,~] = size(YY);

%% 2) Initiate parameters
switch Options.Transformation
    case 'rotation'
        Phi = [ones(nn,1) XX];
    case 'affine'
        Phi = [ones(nn,1) XX];
    case 'non_rigid'
        Phi = Theta.Phi;
end

Beta = [mean(YY)-mean(XX);eye(size(XX,2));zeros(size(Phi,2)-size(XX,2)-1,size(XX,2))];
sigma_sq=(NN*trace(XX'*XX)+nn*trace(YY'*YY)-2*sum(XX)*sum(YY)')/(nn*pp*NN);

O_mat = (Theta.omega/((1-Theta.omega)*NN))*ones(NN,nn);

log_n = NaN;

for ii=1:Options.Sim
    ii;
    % Calculate PP
    Eps = pdist2(YY,Phi*Beta);
    
    Pi_log = -0.5*(pp*log(2*pi*sigma_sq) + Eps.^2/sigma_sq);
    %Pi_log = -0.5*Eps.^2/sigma_sq;
    
    PP_nom = exp(Pi_log).*Theta.P_0;
    
    PP_denom = sum(PP_nom + O_mat,2)*ones(1,nn);
    %PP_denom = ones(NN,1)*sum(PP_nom + O_mat);
    if min(PP_denom(:))>0;
    PP = (NN/nn)*PP_nom./PP_denom;
    %else
    %    Theta.break_v = Inf;
    %end
    PP(isnan(PP)) = 0;
    PP(PP==Inf) = 0;
    end
    %toc
    
    % Update Beta
    NN_p = sum(PP(:));
    
    switch Options.Transformation
        case 'rotation'
            mu_y = (1/NN_p)*(YY'*PP*ones(nn,1))';
            YY_m = YY - ones(NN,1)*mu_y;
            mu_x = (1/NN_p)*(XX'*PP'*ones(NN,1))';
            XX_m = XX - ones(nn,1)*mu_x;
            AA = YY_m'*PP*XX_m;
            [UU,SS,VV] = svd(AA);
            CC = [1 0 0;0 1 0;0 0 det(UU*VV')];
            RR = UU*CC*VV';
            ss = trace(SS*CC)/(sum(sum(XX.^2.*(sum(PP)'*ones(1,pp))))-...
                NN_p*(mu_x*mu_x'));
            if isfield(Options,'scale_lim')
               ss = min([max([ss Options.scale_lim(1)]) Options.scale_lim(2)]);
            end
            Beta = [mu_y-ss*mu_x*RR';ss*RR'];
        otherwise
            Beta = ((Phi.*(sum(PP)'*ones(1,size(Phi,2))))'*Phi)\...
                Phi'*PP'*YY;
    end
    
    %sigma_sq = (trace((YY_m.*(sum(PP,2)*ones(1,pp)))'*YY_m)-ss*trace(SS*CC))/(NN_p*pp)
    %sigma_sq = (trace((YY_m.*(sum(PP,2)*ones(1,pp)))'*YY_m)-...
    %    trace(YY_m'*PP*Phi*Beta))/(NN_p*pp)
    
    sigma_sq = (trace((YY.*(sum(PP,2)*ones(1,pp)))'*YY)-...
        trace(YY'*PP*Phi*Beta))/(NN_p*pp);
   
    
%     log_tn = log_like;
%     
%     if ((log_tn-log_n)/log_n)< Theta.break_v
%         if (ii>10)
%             break
%         else
%             log_n = log_tn;
%         end
%         
%     else
%         log_n = log_tn;
%     end
    ii;
  
end

%imagesc(PP == (ones(NN,1)*max(PP)))
%[corr,~] = ind2sub(size(PP),find(PP == (ones(NN,1)*max(PP))));
[corr,~] = ind2sub(size(PP),find(Eps == (ones(NN,1)*min(Eps))));
%[corr,~] = ind2sub(size(PP),find(PP == (max(PP,[],2)*ones(1,nn))));

    function log_p = log_like
        log_p = -0.5*(NN_p*pp*log(sigma_sq) + trace(Eps'*PP*PP'*Eps)/sigma_sq);
    end

warning('on')
end