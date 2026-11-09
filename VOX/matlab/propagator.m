function [pressure_plus, pressure_minus, output_plus, output_minus] ...
   = propagator(ldisminus1, pressure_plus, pressure_minus, ...
   output_plus, output_minus, input_plus, input_minus, b, ...
   alfa1, alfa2, minf, msup)
% applicationi of linear propagation for segment i
% propagador[i_] := Block[{}
for i = 1:ldisminus1
   pressure_plus(i,1)	= input_plus(i)./b(i);
%   pressure_plus(i,:)	= rotateright(pressure_plus(i,:));
%   pressure_plus(i,:)	= bitror(pressure_plus(i,:));
   pressure_plus(i,2:end)	= pressure_plus(i,1:end-1);   % delay line: shift by one sample (bitshift shifted the bits of the values)
   pressure_plus(i,1)	= 2*pressure_plus(i,2)-pressure_plus(i,3);

   pressure_minus(i,1) = input_minus(i).*b(i);
%   pressure_minus(i,:) = rotateright(pressure_minus(i,:));
   pressure_minus(i,2:end) = pressure_minus(i,1:end-1);   % delay line: shift by one sample (bitshift shifted the bits of the values)
   pressure_minus(i,1) = 2*pressure_minus(i,2)-pressure_minus(i,3);

%   output_plus(i,:) = rotateright(output_plus(i,:));
   output_plus(i,2:end) = output_plus(i,1:end-1);   % delay line: shift by one sample (bitshift shifted the bits of the values)
   output_plus(i,1) ...
      = (alfa1(i).value * pressure_plus(i,minf(i)  :msup(i))')' ...
      + (alfa2(i).value * pressure_plus(i,minf(i)+1:msup(i)+1)')';

%   output_minus(i,:) = rotateright(output_minus(i,:));
   output_minus(i,2:end) = output_minus(i,1:end-1);   % delay line: shift by one sample (bitshift shifted the bits of the values)
   output_minus(i,1) ...
      = (alfa1(i).value * pressure_minus(i,minf(i)  :msup(i))')' ...
      + (alfa2(i).value * pressure_minus(i,minf(i)+1:msup(i)+1)')';
end;