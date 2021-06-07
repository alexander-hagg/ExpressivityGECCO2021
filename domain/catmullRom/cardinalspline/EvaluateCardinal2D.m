% Evaluates 2D Cardinal Spline at parameter value u

% INPUT
% P0,P1,P2,P3  are given four points. Each have x and y values.
% P1 and P2 are endpoints of curve.
% P0 and P3 are used to calculate the slope of the endpoints (i.e slope of P1 and
% P2).
% T is tension (T=0 for Catmull-Rom type)
% u is parameter at which spline is evaluated


% OUTPUT
% cardinal spline evaluated values xt,yt,zt at parameter value u

function [xt,yt] =EvaluateCardinal2D(P0,P1,P2,P3,T,u)

s= (1-T)./2;

% MC is cardinal matrix
MC=[-s     2-s   s-2        s;
    2.*s   s-3   3-(2.*s)   -s;
    -s     0     s          0;
    0      1     0          0];

GHx=[P0(1);   P1(1);   P2(1);   P3(1)];
GHy=[P0(2);   P1(2);   P2(2);   P3(2)];

U=[u.^3    u.^2    u    1];


xt=U*MC*GHx;
yt=U*MC*GHy;


% % % --------------------------------
% % % Author: Dr. Murtaza Khan
% % % Email : drkhanmurtaza@gmail.com
% % % --------------------------------