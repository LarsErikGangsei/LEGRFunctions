
%% --------------------------------------------------------------------- %%
%% - Funksjon for å implementere Challis tilpasning av rotasjon mm       %%
%%   Se: Challis, J. H. (1995). A procedure for determining rigid body   %%
%%       transformation parameters. Journal of biomechanics, 28(6),      %%
%%       733-737.                                                        %%
%%                                                                       %%
%% - Lars Erik Gangsei                                                   %%
%% - 08.01.2018                                                          %%
%% 
%% Input: - Two matrices XX and YY of size n x 3
%%        - calc_ss: (optional, default is 1). Logical if sscale parameter 
%%          is to be estimated.
%%
%% Output: A structure, "Trans" containing the following fields:
%%         - RR: The 3 x 3 rotation matrix
%%         - ss: The scaling factor (scalar)
%%         - dd: Displacement vector (1 x 3)
%% We have that predicted values for YY, ^YY = s*XX*RR' + 1*dd

function Trans = Challis_rot(YY,XX,calc_ss);
if~exist("calc_ss","var");calc_ss=1;end
nn = size(YY,1);
 YY_m = YY - ones(nn,1)*mean(YY);
 XX_m = XX - ones(nn,1)*mean(XX);
 CC = (YY_m'*XX_m)/nn;
 
 [UU SS VV] = svd(CC);
 
 Trans.RR = UU*[1 0 0;0 1 0;0 0 det(UU*VV')]*VV';
 sigma_xx = sum(sum(XX_m.*XX_m))/nn;
 if calc_ss==1
    Trans.ss = trace(Trans.RR'*CC)/sigma_xx;
 else
     Trans.ss = 1;
 end
 
 Trans.dd = mean(YY) - (Trans.ss*Trans.RR*mean(XX)')';
 
end


