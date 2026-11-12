function [input_plus, y_minus_aux] ...
   = outputconv(ldis, A, B, y_minus_aux, output_minus, C_minus, input_plus);
% NOTE (#64): no longer used. Since November 2026 the tube model (ctim2)
% calculates the conical segments with coneprepare.m and conestep.m:
% plane waves at the tube ends, finite kernels over the round trip of
% every cone and a stable recursion (method M2, docs/conical-tubes.md).
% This file belongs to the former multiconvolution formulation, which
% grew without limit; it is kept for reference.
% application of matrices at the discontinuity of the exit
% convoluciosortida := Block[{i=Length[Discontinuitats]}
maxdim = size(B(ldis).value,1);
y_minus_aux(ldis,1:maxdim) = (A(ldis).value * y_minus_aux(ldis,1:maxdim)')' ...
   + (B(ldis).value *     output_minus(ldis-1,:)')';
input_plus(ldis-1) =   (C_minus(ldis).value * y_minus_aux(ldis,1:maxdim)')';
% corrected