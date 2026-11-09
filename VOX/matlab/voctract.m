function [Fs, y, z, out] = voctract(Fs_vox, TMAX, Xi0)
% before: "SIMP_16.M"
% May 1999 by Ulrich Reiter
% last modified 29.06.2000 - 19.11.2000 by Malte Kob

global Hndl BRK c rho GRONT


data = get(Hndl.figureNumber, 'UserData');

% system parameters
numcyl=length(data.radius);                % number of cylinders constituting the VT model
lastj=numcyl+1;                                % index of last junction (=output end)
dirac=1;                                                        % amplitude of dirac function

% air properties
c0 = c;                                                                % sound speed in air [m/s], GLOBAL!

Fs = round(c0/data.spacing);        % sampling frequency
%Fs = Fs_vox;        % sampling frequency
loop= ceil(TMAX/1000*Fs);                        % number of loops to be calculated

% derived parameters
dx=c0/Fs;                                                        % path increment [m]
dt=1/Fs;                                                        % time increment [s]

%Xi0=0.005135;                                        % constant for damping...
damp=1-Xi0;
nuem=zeros(1,numcyl-1);                % reflection coefficient
nuep=zeros(1,numcyl-1);                % refl. coeff. for backwards travelling waves


% cylindrical segments of the VT model

% length of cylinders from left to right [m]
lcyld=ones(1,numcyl);
lcyl=lcyld*data.spacing;
lsum=sum(lcyl);                                        % total length of vocal tract
n=round(lsum/dx);                                % total number of samples
nspc=round(lcyl*n/lsum);                % number of samplepoints within each cylinder

% radius of cylinders from left to right: rl=left radius; rr=right radius [m]
rl=data.radius;
rr=rl;

for i=2:numcyl
   Bm(i)=(rr(i-1)/rl(i))^2;
end
Bm(1)=1;        % dummy value for division in next line
Bp=1./Bm;

if data.properties.radimp == 1
   % reflection at cylindrical open output end - old routine
   a=-c0/(2*rr(numcyl));
   a32=a;
   b3=a;

   Teta32=[exp(b3*dt)];                        % matrix Teta for output end
   TT21=((b3*dt-1)+exp(-b3*dt))/(dt*b3^2);        % 2nd row, 1st col.
   TT22=(1-(1+b3*dt)*exp(-b3*dt))/(dt*b3^2);
   TetaT32=[TT21 TT22];                        % matrix        TetaTilde for output end
   %TetaT32=[TT21 TT22]/dt;        % matrix        TetaTilde for output end corrected 17.8.2000
   A32=Teta32*TetaT32;                                % matrix A (1 row, 2 columns) for output end

elseif data.properties.radimp == 2
   % reflection at cylindrical open output end - new routine
   ord         = 8;
   d     = 2*data.radius(end);
   fmax  = round(Fs/2);
   x     = 0:100:fmax;
   ord         = length(x);
   k     = 2*pi*x/c;
   warning off
   f     = 1 -  2*besselj(1,k*d)./(k*d) + j*2*mstruv(k*d) ./(k*d).^2;
   %  f_r   = real(f);
   %  f_i   = imag(f);
   %  save z_03_unmod x f_r f_i
   warning on
   f(isnan(f))=0;
   fy    = x/fmax;
   Rm.f         = ((f - 1)./(f + 1));
   mirror = fliplr(Rm.f);
   Rm.f2 = [Rm.f, mirror];
   Rm.h = real(ifft(Rm.f2));
   Rm.h = Rm.h(1:end/2);
   Rm.b = Rm.h(1:length(Rm.h));
   Rm.a = [1 zeros(1,length(Rm.h)-1)];
   %        [Rm.b,Rm.a] = invfreqs(Rm.f,x/fmax*pi,ord,ord)
   %        [Rm.b,Rm.a] = yulewalk(ord,fy,Rm.f);
   [Rm.A,Rm.B,Rm.C,Rm.D] = tf2ss(Rm.b,Rm.a);
   Tm.f         = (2*f./(f + 1));
   %        [Tm.b,Tm.a] = invfreqs(Tm.f,x/fmax*pi,ord,ord)
   %        [Tm.b,Tm.a] = yulewalk(ord,fy,Tm.f);
   mirror = fliplr(Tm.f);
   Tm.f2 = [Tm.f, mirror];
   Tm.h = real(ifft(Tm.f2));
   Tm.h = Tm.h(1:end/2);
   Tm.b = Tm.h(1:length(Tm.h));
   Tm.a = [1 zeros(1,length(Tm.h)-1)];
   [Tm.A,Tm.B,Tm.C,Tm.D] = tf2ss(Tm.b,Tm.a);
   Rm.state = zeros(length(Rm.h)-1,2);
   Tm.state = zeros(length(Rm.h)-1,2);

   [hRm,w] = freqz(Rm.b,Rm.a,128);
   [hTm,w] = freqz(Tm.b,Tm.a,128);
   figure(734)
   plot(x,abs(f),'k-', w/pi*fmax,abs(hRm),'r-', w/pi*fmax,abs(hTm),'b-', ...
      x,real(f),'k:', w/pi*fmax,real(hRm),'r:', w/pi*fmax,real(hTm),'b:', ...
      x,imag(f),'k--', w/pi*fmax,imag(hRm),'r--', w/pi*fmax,imag(hTm),'b--');
   legend('|Z|',' R ',' T ',4)
   grid on

end

% initialization of structs for pressure calculus inside the waveguide
% smallest index for time indicates latest incoming value
for i=1:numcyl
   pmr1.junction(i).time=zeros(1,2);
   ppl1.junction(i+1).time=zeros(1,2);
   lastp2(i)=1+lcyld(i);
   pmr2.junction(i).time=zeros(1,lastp2(i));
   ppl2.junction(i+1).time=zeros(1,lastp2(i));
   lastp(i)=lastp2(i)+1;
   pml.junction(i+1).time=zeros(1,lastp(i));
   ppr.junction(i).time=zeros(1,lastp(i));
   pmR.junction(i+1).time=zeros(1,1);
   pmT.junction(i+1).time=zeros(1,1);
   ppR.junction(i).time=zeros(1,1);
   ppT.junction(i).time=zeros(1,1);
end
zmR.time=zeros(1,2);
zmT.time=zeros(1,2);

pmr2.junction(1).time(1)=dirac;

% start of calculus loop

Hndl.voctractwaitbar = waitbar(0,'Calculating impulse response...');

BRK = 0;

for z=1:loop

%   waitbar(z/loop,Hndl.voctractwaitbar)
    waitbar(z/loop)

   if BRK, break,        end

   t(z)=z*dt;        % time vector

   if data.properties.radimp == 1
      h_calc_out(z) ...
         = pmR.junction(lastj).time(1) ...
         + pmr2.junction(lastj-1).time(1);
   elseif data.properties.radimp == 2
      Tm.state(:,2) ...
         = Tm.A * Tm.state(:,1) ...
         + Tm.B * pmr2.junction(lastj-1).time(1);
      h_calc_out(z) ...
         = Tm.C * Tm.state(:,1) ...
         + pmR.junction(lastj).time(1) ...
         + Tm.D * pmr2.junction(lastj-1).time(1);
      Tm.state(:,1) = Tm.state(:,2);
   end

   z_calc_out(z) ...
      = pmR.junction(2).time(1) ...
      + pmr2.junction(1).time(1);

   for i=1:numcyl;
      h_calc_all(i,z) = ...
         pmr2.junction(i).time(1)...
         + ppl2.junction(i+1).time(1);
      h_calc_all(lastj,z) = h_calc_out(z);
   end

   if GRONT
      if voxfigflag('Wave propagation in the vocal tract',1) == 1
         set(0,'CurrentFigure',Hndl.voctractfig)
         set(Hndl.voctractfig,'CurrentAxes',Hndl.voctractfigplot)
         waterfall(t(1:z), 1:lastj, h_calc_all);
         view(0,85)
         grid off
      else        % create figure
         Hndl.voctractfig = figure('visible','on','NumberTitle','off', ...
            'Name','Wave propagation in the vocal tract','Units','normalized',...
            'Position',[.5 .05 .5 .4]);
         set(Hndl.voctractfig,'MenuBar', 'none');
         Hndl.voctractfigplot = axes;
         waterfall(t(1:z), 1:lastj, h_calc_all);
         view(0,85)
         grid off
      end
   end;


   % reflection and transmission of outgoing wave at intermediate segments
   for i=2:numcyl
      pmR.junction(i).time(1) ...
         = pmr2.junction(i-1).time(1) * (Bm(i)-1)/(Bm(i)+1);
      pmT.junction(i).time(1) ...
         = pmR.junction(i).time(1) ...
         + pmr2.junction(i-1).time(1);
   end

   % reflection of outgoing wave at output end
   if data.properties.radimp == 1
      % zmR is calculated "in advance" (ec.(8): z(t+dt)=...); therefore
      % pmR(t) must use element zmR(t)=zmR(t+dt-dt)=zmR.junction.time(2)
      % and not zmR.junction.time(1)=zmR(t+dt)
      zmR.time(1) ...
         = zmR.time(2)*Teta32 ...
         + A32(1)*pmr2.junction(numcyl).time(2) ...
         + A32(2)*pmr2.junction(numcyl).time(1);
      pmR.junction(lastj).time(1) ...
         = a32*zmR.time(1);
      %  h_calc_out(z) = pmR.junction(lastj).time(1);
      %         h_calc_out(z) ...
      %           = pmR.junction(lastj).time(1); ...
      %           + pmr2.junction(lastj-1).time(1);
   elseif data.properties.radimp == 2
      Rm.state(:,2) ...
         = Rm.A*Rm.state(:,1) ...
         + Rm.B*pmr2.junction(numcyl).time(1);
      pmR.junction(lastj).time(1) ...
         = Rm.C*Rm.state(:,1) ...
         + Rm.D*pmr2.junction(numcyl).time(1);
      Rm.state(:,1) = Rm.state(:,2);
      %                p_out_mouth ...
      %                = pmR.junction(lastj).time(1)...
      %                        + pmr2.junction(lastj-1).time(1);
   end

   % reflection and transmission of ingoing wave
   for i=numcyl:-1:2
      ppR.junction(i).time(1) ...
         = ppl2.junction(i+1).time(1) * (Bp(i)-1)/(Bp(i)+1);
      ppT.junction(i).time(1) ...
         = ppR.junction(i).time(1) ...
         + ppl2.junction(i+1).time(1);
   end
   % reflection of ingoing wave at input end
   ppR.junction(1).time(1) = ppl2.junction(2).time(1)*(+1);        % no impedance jump at glottis!
   %%%  pmT.junction(1).time(1) = a32*(1-zmR.time(1));
   %%%  z_calc_out(z) = pmT.junction(1).time(1);

   %        z_calc_out(z) = 2 * ppl2.junction(2).time(1);
   %        z_calc_out(z) =   pmr2.junction(1).time(1)

   % timeshift of outgoing and ingoing waves
   for i=1:numcyl
      pmr2.junction(i).time(2:lastp2(i)) ...
         = pmr2.junction(i).time(1:lastp2(i)-1);
      ppl2.junction(i+1).time(2:lastp2(i)) ...
         = ppl2.junction(i+1).time(1:lastp2(i)-1);
   end
   zmR.time(2)=zmR.time(1);
   % end of timeshift

   % newest element of outgoing wave
   for i=2:numcyl
      pmr2.junction(i).time(1) ...
         = ppR.junction(i).time(1) ...
         + pmT.junction(i).time(1);
      pmr2.junction(i).time(1) ...
         = damp*pmr2.junction(i).time(1);
   end
   pmr2.junction(1).time(1) = ppR.junction(1).time(1);
   pmr2.junction(1).time(1) = damp*pmr2.junction(1).time(1);

   % newest element of ingoing wave
   ppl2.junction(lastj).time(1) = pmR.junction(lastj).time(1);
   for i = numcyl:-1:2
      ppl2.junction(i).time(1) ...
         = pmR.junction(i).time(1) ...
         + ppT.junction(i).time(1);
      ppl2.junction(i).time(1) ...
         = damp*ppl2.junction(i).time(1);
   end

end

BRK = 0;

out.t         = t;
out.segments  = 1:lastj;
out.h                = h_calc_all;
y             = h_calc_out;
z             = z_calc_out;
if ishghandle(Hndl.voctractwaitbar)   % vox('break') may have closed it already
   close(Hndl.voctractwaitbar)
end