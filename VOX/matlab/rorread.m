function [importradius,importspacing,TMAX,Fs,phonsamples] = rorread(filename)



% extract phonationmoments
filename2 = [filename(1:end-3), 'fri'];
vector2 = textread(filename2,'%f');
for i = 1:length(vector2)
   samples(i) = vector2(2*i-1);
   areas(i) = vector2(2*i);
   if (2*i) == length(vector2)
      break;
   end
end
phonsamples = samples(find(areas <= 5));

vector = textread(filename,'%f');
blocks = floor(size(vector,1)/22);
data = vector(1:22)';
for n = 1:blocks-1
   %	data(n+1,:) = vector(1+n*2*22:(n*2+1)*22)';
   data(n+1,:) = vector(n*22+1:(n+1)*22)';
end
samples = data(:,1);
data(:,1:4) = [];
importradius = [];
importradius(:,1:18) = sqrt(data(:,1:18)/pi)/1e3;
importradius(find(importradius == 0)) = 0.00000000000001;
importspacing = 0.857e-2;
TMAX = samples(end)/20;
Fs = 20000;

for n = 1:18
   %   x = (1:size(importradius,1))';
   xi = (1:samples(end))';
   r(:,n) = interp1(samples,importradius(:,n),xi,'cubic');
end
importradius = r;
% generated array: importradius(blocks,radius)

% samples beziehen sich auf 20 kHz !!!!!!!
% Fläche in mm²
% spacing 0.875 cm
