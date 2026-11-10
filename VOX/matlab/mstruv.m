function fout = mstruv(z)
%MSTRUV Struve function H1 of order 1.
%   FOUT = MSTRUV(Z) returns the Struve function H1(Z) for real Z, from
%   its integral representation
%
%       H1(z) = 2z/pi * integral_0^(pi/2) sin(z cos(x)) sin(x)^2 dx.
%
%   It is used for the radiation impedance of a piston (Rad.-Imp. "all f"
%   in the vocal tract editor). VOX called mstruv from the old itatools
%   (mstruv.m/mstruvarg.m with quad), which are not in the repository, so
%   that setting failed. Same definition, computed with integral.
%
%   See also integral, besselj.

fout = zeros(size(z));
for i = 1:numel(z)
    fout(i) = integral(@(x) 2*z(i)/pi*sin(z(i)*cos(x)).*sin(x).^2, 0, pi/2);
end
end
