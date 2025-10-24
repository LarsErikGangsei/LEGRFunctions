%% --------------------------------------------------------------------- %%
%
% Function wvaluating Cubic (cardinal) B spline values of vector xx with
% knot sequense kk (length 5)
%
% Lars Erik Gangsei
% 13th of September 2018
%


function Bas_val = Basic_cubic(xx,kk)
if length(kk)~=5
    warning('Wrong knot sequense')
end
    k_diff = ((kk(5)-kk(1))/4);
    pp_mat = zeros(length(xx),4);
    for rr = 1:4
        pp_mat(:,rr) = xx>kk(rr);
        pp_mat(xx>kk(rr+1),rr) = 0;
    end
    %pp_mat = double(pp_mat);
    vals = zeros(length(xx),4);
    uu = (xx-kk(1))/k_diff;
    vals(:,1) = (uu.^3)/6;
    uu = (xx-kk(2))/k_diff;
    vals(:,2) = (-3*uu.^3 + 3*uu.^2+3*uu+1)/6;
    uu = (xx-kk(3))/k_diff;
    vals(:,3) = (3*uu.^3 - 6*uu.^2+4)/6;
    uu = (xx-kk(4))/k_diff;
    vals(:,4) = (-uu.^3 + 3*uu.^2-3*uu+1)/6;
    
    
    Bas_val = sum(vals.*pp_mat,2);
    
end