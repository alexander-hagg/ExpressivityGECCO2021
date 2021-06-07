Cardinal Spline (Catmull-Rom Spline)
-------------------------------------

EvaluateCardinal2D.m
Evaluates 2D Cardinal Spline at parameter value u

EvaluateCardinal2DAtNplusOneValues.m
Evaluate cardinal spline for given four points and
tesion at N+1 values of u (parameter u vareis b/w 0
and 1). Uniform parameterization is used.


TestEvaluateCardinal2D.m
A Simple Test program to evalute Cardinal Spline
for given set of data with Tension=0 (Catmull-Rom)
and Tension=0.5.

% % % --------------------------------
% % % Author: Dr. Murtaza Khan
% % % Email : drkhanmurtaza@gmail.com
% % % --------------------------------

Reference:
----------------
M. A.  Khan and Yoshio Ohno, "An Automated Video Data Compression Algorithm by Cardinal Spline Fitting". NICOGRAPH International Conference, Toyota, Japan, May 2007.

Bibtex entry

@inproceedings{KhanOhnoNICOGRAPH2007,
  author    = {M. A.  Khan and Yoshio Ohno},
  title     = {An Automated Video Data Compression Algorithm by Cardinal Spline Fitting},
  booktitle = {NICOGRAPH International Conference, Toyota, Japan},  
  year      = {2007},
  month = {May},  
}