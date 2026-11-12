function [input_minus, flowinput, y_plus_aux, inputaux] ...
   = inputconv(actualflow, flowinput, A, B, y_plus_aux, output_plus, ...
   input_minus, Ainput, inputaux, Binput, Cinput, C_plus)
% NOTE (#64): no longer used. Since November 2026 the tube model (ctim2)
% calculates the conical segments with coneprepare.m and conestep.m:
% plane waves at the tube ends, finite kernels over the round trip of
% every cone and a stable recursion (method M2, docs/conical-tubes.md).
% This file belongs to the former multiconvolution formulation, which
% grew without limit; it is kept for reference.
% application of matrices at the discontinuity of the entry
% convolucioentrada[cabalactual_] := Block[{}
%flowinput 	 = rotateright(flowinput);
flowinput 	 = bitshift(flowinput,-1);
flowinput(1) = actualflow;
maxdim = size(A(1).value,1);
y_plus_aux(1,1:maxdim) ...
   = (A(1).value *  y_plus_aux(1,1:maxdim)')' ...
   + (B(1).value * output_plus(1,1:maxdim)')';
inputaux = (Ainput *  inputaux')' ...	% transpose Ainput? No!
   + (Binput * flowinput')';		% transpose Binput? No!
maxdim = size(C_plus(1).value,2);
input_minus(1)  ...
   = (C_plus(1).value * y_plus_aux(1,1:maxdim)')' ...
   + (Cinput					 *               inputaux')';
% corrected(2)