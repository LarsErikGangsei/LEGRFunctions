%% --------------------------------------------------------------------- %%
%
% Function for returning a model matrix based on B-splines
%
% Lars Erik Gangsei
% 3th of August 2018
%
%% --------------------------------------------------------------------- %%
%
% Input:
%       - XX:  A matrix of size n x p (p = 2 or 3)
%       - Theta: An array of size 5 x p x q, where q defines the number of
%       extra colums added to the model matrix.
%       - Psi: (optional). A binary matrix of size n x q defining if the
%       B-spline in output should be used for the row in XX in question.
%       - Knots: (Optional). Cell with p elements defining knot sequenses.
%       Overwrites Theta. All elements of minimum length 5.
%
% Output:
%       - Mod_mat = [1 XX Phi], where Phi is a n x q matrix based on
%       B-splines
%       - Theta might also be returned if Knots are used.

function [Mod_mat, Theta]= B_spline_Evaluate(XX,Theta,Psi,Knots);
[nn,pp] = size(XX);

if exist('Knots','var')
    switch pp
        case 2
            mm_1 = (length(Knots{1})-4);
            mm_2 = (length(Knots{2})-4);
            qq = mm_1*mm_2;
        case 3
            mm_1 = (length(Knots{1})-4);
            mm_2 = (length(Knots{2})-4);
            mm_3 = (length(Knots{3})-4);
            qq = mm_1*mm_2*mm_3;
    end
    Theta = zeros(5,pp,qq);
    for ii = 1:mm_1
        for jj = 1:mm_2;
            switch pp
                case 2
                    Theta(:,1,(ii-1)*mm_2+jj)=Knots{1}(jj:(jj+4));
                    Theta(:,2,(ii-1)*mm_2+jj)=Knots{2}(ii:(ii+4));
                case 3
                    for kk = 1:mm_3;
                        Theta(:,1,(ii-1)*(mm_2*mm_3)+(jj-1)*mm_3+kk)=Knots{1}(ii:(ii+4));
                        Theta(:,2,(ii-1)*(mm_2*mm_3)+(jj-1)*mm_3+kk)=Knots{2}(jj:(jj+4));
                        Theta(:,3,(ii-1)*(mm_2*mm_3)+(jj-1)*mm_3+kk)=Knots{3}(kk:(kk+4));
                    end
            end
        end
    end 
else
    qq = size(Theta,3);
end

Phi = zeros(nn,qq);
for jj = 1:qq;
    QQ = cell(pp,1);
    for ll = 1:pp;
        %BB = spmak(squeeze(Theta(:,ll,jj)),1);
        %QQ{ll} = fnval(BB,XX(:,ll));
        t_ind = find(((XX(:,ll)>Theta(1,ll,jj))+(XX(:,ll)>Theta(1,ll,jj)))==2);
        QQ{ll} = zeros(nn,1);
        QQ{ll}(t_ind,:) = Basic_cubic(XX(t_ind,ll),squeeze(Theta(:,ll,jj)));
    end
    switch pp
        case 2
            Phi(:,jj) = QQ{1}.*QQ{2};
        case 3
            
            Phi(:,jj) = QQ{1}.*QQ{2}.*QQ{3};
    end
end

if exist('Psi','var')
    if isempty(Psi)
        Psi = ones(nn,qq);
    end
    Phi = Phi.*Psi;
end

Mod_mat = [ones(nn,1) XX Phi];

end



