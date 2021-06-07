% Evaluate cardinal spline at N+1 values for given four points and tesion.
% Uniform parameterization is used.

% P0,P1,P2 and P3 are given four points.
% T is tension.
% N is number of intervals (spline is evaluted at N+1 values).


function [xvec,yvec]=EvaluateCardinal2DAtNplusOneValues(P0,P1,P2,P3,T,N)

xvec=[]; yvec=[];

% u vareis b/w 0 and 1.
% at u=0 cardinal spline reduces to P1.
% at u=1 cardinal spline reduces to P2.

u=0;
[xvec(1),yvec(1)] =EvaluateCardinal2D(P0,P1,P2,P3,T,u);
du=1/N;
for k=1:N
    u=k*du;
    [xvec(k+1),yvec(k+1)] =EvaluateCardinal2D(P0,P1,P2,P3,T,u);
end


% % % --------------------------------
% % % Author: Dr. Murtaza Khan
% % % Email : drkhanmurtaza@gmail.com
% % % --------------------------------
