function [input_plus, input_minus, y_plus_aux, y_minus_aux] = ...
   middleconv(ldisminus1, A, B, y_plus_aux, y_minus_aux, C_plus, C_minus, ...
   input_plus, input_minus, output_plus, output_minus);
% NOTE (#64): no longer used. Since November 2026 the tube model (ctim2)
% calculates the conical segments with coneprepare.m and conestep.m:
% plane waves at the tube ends, finite kernels over the round trip of
% every cone and a stable recursion (method M2, docs/conical-tubes.md).
% This file belongs to the former multiconvolution formulation, which
% grew without limit; it is kept for reference.
% application of matrices to the discontinuities
% convoluciodiscontinuitat[i_] := Block[{aux}
for i=2:ldisminus1
   maxdim = size(A(i).value,1);
   y_plus_aux(i,1:maxdim)  = (A(i).value *  y_plus_aux(i,1:maxdim)')'  ...
      + (B(i).value * output_plus(i,1:2)')';
   y_minus_aux(i,1:maxdim) = (A(i).value * y_minus_aux(i,1:maxdim)')' ...
      + (B(i).value *     output_minus(i-1,1:2)')';
   aux = (C_plus(i).value  *  y_plus_aux(i,1:maxdim)')' ...
      + (C_minus(i).value * y_minus_aux(i,1:maxdim)')';
   input_plus(i-1) = aux + output_plus(i,1);
   input_minus(i)  = aux + output_minus(i-1,1);
end;
% corrected