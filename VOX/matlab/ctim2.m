function [y_out, z_out, PARCTIM] ...
   = ctim2(tubes, tmax, xi, ii, PARCTIM, inputpressure, PARNOISE) %#ok<INUSD>

% function ctim2 calculates pressure signals within a cylinder model of the vocal tract.
% input: tubes (matrice of
%
% Section-wise (tube by tube) wave calculation, see tubeprepare.m: every
% conical tube is divided into cylindrical sub-tubes of one time step, the
% propagation through a sub-tube uses the viscothermal kernel of the
% original method (tubekernel.m). The former conical formulation (preparation,
% propagator, inputconv, middleconv, outputconv) grew without limit.
%
% Stand alone (nargin < 4): impulse response of tmax ms, calculated and
%    returned with the internal sampling rate PARCTIM.out.Fs
%    y_out: pressure at the mouth end, z_out: pressure at the glottis end
% Combi (ii >= 1): one sample at the sampling rate Fs per call, input
%    inputpressure; ii = 1 initializes PARCTIM
%
% The internal sampling rate is an integer multiple of Fs, at least
% 88200 Hz (sub-tubes of about 4 mm) and high enough for the shortest tube.

global Fs c rho BRK Hndl

if isempty(Fs)
   Fs=44100;			% sample rate [Hz]
end;
if isempty(c)
   c = 350;			% speed of sound [m/s]
end;
if isempty(rho)
   rho = 1.21; 	% air density [kg/m^3]
end;
zcar = 412;			% wave impedence in air (as in the former preparation.m)

if nargin < 5
   PARCTIM = [];	% stand alone calculation
end;
if nargin < 4
   ii = 0;	% stand alone calculation
end;
if nargin < 3
   xi 		 = 0.135;	% damping constant
end;
if nargin < 2
   tmax = 20;
end;

if ii < 2	% initialization of tubes etc.
   if nargin == 0	% for test
      lcyl	= [0.05,   0.05];	% test
      rl		= [0.005, 0.01];
      rr		= [0.01,  0.005];
      tubes = [lcyl;rl;rr]';
      diracamp = 1/(Fs*internalfactor(tubes, Fs, c));	% amplitude Dirac input org:1/deltat
   else
      diracamp 	= 1;			% amplitude Dirac input org:1/deltat
   end;
   M = internalfactor(tubes, Fs, c);
   PARCTIM = tubeprepare(tubes, xi, c, 1/(M*Fs));
   PARCTIM.M = M;
   PARCTIM.diracamp = diracamp;
end;	% of initialization
M  = PARCTIM.M;
nt = numel(PARCTIM.first);	% number of tubes

if ii == 0	% stand alone calculation: impulse response
   BRK  = 0;
   ntmax = ceil(tmax*1e-3*M*Fs);	% number of internal samples
   t = (0:ntmax-1)/(M*Fs)*1000;	% time beam for graphic display [ms]
   Hndl.waitfigure = voxwaitbar(0,'Calculating tract signal...');
   y_out = zeros(1,ntmax);
   z_out = zeros(1,ntmax);
   y_out_all = zeros(nt+1,ntmax);
   nupdate = max(1, round(ntmax/100));	% waitbar and graphics every 1 percent
   for n = 1:ntmax
      if BRK, break, end  % makes it possible to end calculation
      inputflow = (n == 1)*PARCTIM.diracamp/(rho*c);
      [PARCTIM, y_out(n), z_out(n), y_out_all(:,n), fw, bw] ...
         = tubestep(PARCTIM, zcar*inputflow);
      if rem(n, nupdate) == 0 || n == ntmax
         Hndl.waitfigure=voxwaitbar(n/ntmax);
         plottract(t(1:n), y_out_all(:,1:n), fw, bw);
      end
   end
   PARCTIM.out.t = t(1:n);
   PARCTIM.out.segments = 1:nt+1;
   PARCTIM.out.y	= y_out_all(:,1:n);
   PARCTIM.out.Fs = M*Fs;
   y_out = y_out(1:n);
   z_out = z_out(1:n);
   if ishghandle(Hndl.waitfigure)   % vox('break') may have closed it already
      close(Hndl.waitfigure);  % close waitbar
   end
else	% combi: M internal samples with the same input, output = mean
   inputflow = inputpressure/(rho*c);
   y_out = 0;  z_out = 0;  p_all = zeros(nt+1,1);
   for m = 1:M
      [PARCTIM, y, z, p] = tubestep(PARCTIM, zcar*inputflow);
      y_out = y_out + y/M;
      z_out = z_out + z/M;
      p_all = p_all + p/M;
   end
   PARCTIM.p_boundaries = p_all;	% pressure at the tube ends, glottis to mouth
end


function M = internalfactor(tubes, Fs, c)
% factor between internal sampling rate and Fs
M = max(ceil(88200/Fs - 1e-9), ceil(c/(Fs*min(tubes(:,1))) - 1e-9));
M = max(M, 1);
if M > 64
   error('ctim2: tube of %.2f mm is too short for the calculation', 1e3*min(tubes(:,1)));
end


function [P, pmouth, pglot, pbound, fw, bw] = tubestep(P, psource)
% one time step of the sub-tube chain; psource enters at the glottis
fo = sum(P.fbuf .* P.H, 2);	% waves arriving at the right ends (towards the mouth)
bo = sum(P.bbuf .* P.H, 2);	% waves arriving at the left ends (towards the glottis)
r  = P.r;
fn = zeros(P.N,1);
bn = zeros(P.N,1);
% junctions between sub-tubes (pressure waves)
fn(2:end)   = (1+r).*fo(1:end-1) - r.*bo(2:end);
bn(1:end-1) = (1-r).*bo(2:end)   + r.*fo(1:end-1);
% glottis: closed end with source
fn(1) = bo(1) + psource;
% mouth: radiation filter
R  = P.rad;
x  = fo(end);
y2 = P.radstate(1);  y3 = P.radstate(2);  xp = P.radstate(3);
y3 = R.E*y3 + P.dt*R.E*y2 + R.k20*x + R.k21*xp;
y2 = R.E*y2 + R.k10*x + R.k11*xp;
P.radstate = [y2, y3, x];
bn(end) = -(R.nu^2)*y3;
% pressures
pmouth = fo(end) + bn(end);
pglot  = bo(1) + fn(1);
fw     = [fn(P.first); fo(end)];	% forward waves at the tube ends
bw     = [bo(P.first); bn(end)];	% backward waves at the tube ends
pbound = fw + bw;
% time shift of the wave buffers
P.fbuf = [fn, P.fbuf(:,1:end-1)];
P.bbuf = [bn, P.bbuf(:,1:end-1)];


function plottract(t, y_out_all, fw, bw)
% graphics of the stand alone calculation (see GRONT in vox.m)
global GRONT Hndl
ndis = size(y_out_all,1);
if ((GRONT == 1) | (GRONT == 3))	% waterfall if graphics on and standalone calc.
   if voxfigflag('Wave propagation in the vocal tract',1) == 1
      set(0,'CurrentFigure',Hndl.voctractfig)
      set(Hndl.voctractfig,'CurrentAxes',Hndl.voctractfigplot)
      waterfall(t, 1:ndis, y_out_all);
      view(0,85)
      grid off
   else	% create figure
      Hndl.voctractfig = figure('visible','on','NumberTitle','off', ...
         'Name','Wave propagation in the vocal tract','Units','normalized',...
         'Position',[.5 .05 .5 .4]);
      set(Hndl.voctractfig,'MenuBar', 'none');
      Hndl.voctractfigplot = axes;
      waterfall(t, 1:ndis, y_out_all);
      view(0,85)
      grid off
   end
end;
if (GRONT == 2) | (GRONT == 3)	% graphics on
   dudu1 = fw;	% wave runs downstream
   dudu2 = bw;	% wave runs upstream
   p_out_mouth = dudu1+dudu2;
   if voxfigflag('Sound pressure in the vocal tract',1) == 1
      plot(1:ndis, [dudu1], 'r-', ...
         1:ndis, [dudu2],    		'b-', ...
         1:ndis, p_out_mouth,		'k-', ...
         'Parent', Hndl.tractsigfigplot);
   else
      Hndl.tractsigfig = figure('visible','on','NumberTitle','off', ...
         'Name','Sound pressure in the vocal tract','Units','normalized',...
         'Position',[.5 .05 .5 .4]);
      set(Hndl.tractsigfig,'MenuBar', 'none');
      Hndl.tractsigfigplot = axes;
      plot(1:ndis, [dudu1], 'r-', ...
         1:ndis, [dudu2],    		'b-', ...
         1:ndis, p_out_mouth,		'k-')
   end
end;
