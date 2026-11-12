function [pressure_plus, pressure_minus, output_plus, output_minus] ...
   = propagator(ldisminus1, pressure_plus, pressure_minus, ...
   output_plus, output_minus, input_plus, input_minus, b, ...
   alfa1, alfa2, minf, msup)
% NOTE (#64): no longer used. Since November 2026 the tube model (ctim2)
% calculates the conical segments with coneprepare.m and conestep.m:
% plane waves at the tube ends, finite kernels over the round trip of
% every cone and a stable recursion (method M2, docs/conical-tubes.md).
% This file belongs to the former multiconvolution formulation, which
% grew without limit; it is kept for reference.
% applicationi of linear propagation for segment i
% propagador[i_] := Block[{}
for i = 1:ldisminus1
   pressure_plus(i,1)	= input_plus(i)./b(i);
%   pressure_plus(i,:)	= rotateright(pressure_plus(i,:));
%   pressure_plus(i,:)	= bitror(pressure_plus(i,:));
   pressure_plus(i,:)	= bitshift(pressure_plus(i,:),-1);
   pressure_plus(i,1)	= 2*pressure_plus(i,2)-pressure_plus(i,3);

   pressure_minus(i,1) = input_minus(i).*b(i);
%   pressure_minus(i,:) = rotateright(pressure_minus(i,:));
   pressure_minus(i,:) = bitshift(pressure_minus(i,:),-1);
   pressure_minus(i,1) = 2*pressure_minus(i,2)-pressure_minus(i,3);

%   output_plus(i,:) = rotateright(output_plus(i,:));
   output_plus(i,:) = bitshift(output_plus(i,:),-1);
   output_plus(i,1) ...
      = (alfa1(i).value * pressure_plus(i,minf(i)  :msup(i))')' ...
      + (alfa2(i).value * pressure_plus(i,minf(i)+1:msup(i)+1)')';

%   output_minus(i,:) = rotateright(output_minus(i,:));
   output_minus(i,:) = bitshift(output_minus(i,:),-1);
   output_minus(i,1) ...
      = (alfa1(i).value * pressure_minus(i,minf(i)  :msup(i))')' ...
      + (alfa2(i).value * pressure_minus(i,minf(i)+1:msup(i)+1)')';
end;