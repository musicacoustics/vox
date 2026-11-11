function [y_out, z_out, PARCTIM] ...
   = ctim2(tubes, tmax, xi, ii, PARCTIM, inputpressure, PARNOISE, glotarea, radimp) %#ok<INUSD>

% function ctim2 calculates pressure signals within a cylinder model of the vocal tract.
% input: tubes (matrice of
%
% Conical tubes in the time domain (#64, method M2), see coneprepare.m:
% plane pressure waves at the tube ends, spherical waves inside the cones;
% the growing parts of the cone reflections cancel within the round trip of
% every cone, what remains are finite kernels and a stable recursion. The
% former conical formulation (preparation, propagator, inputconv,
% middleconv, outputconv) grew without limit; #45 had replaced the cones by
% a staircase of cylinders.
% Input, glottis end, radiation and output as in the stairs model
% (voctract, tractsig):
%
% Stand alone (nargin < 4): impulse response of tmax ms, calculated and
%    returned with the internal sampling rate PARCTIM.out.Fs; pressure wave
%    impulse of amplitude 1 into the first tube, closed glottis end
%    y_out: pressure at the mouth end, z_out: pressure at the glottis end
% Combi (ii >= 1): one sample at the sampling rate Fs per call, input
%    inputpressure (fold signal out_vf_voc); ii = 1 initializes PARCTIM.
%    As in tractsig the wave 2*Ag/(Ag+Av)*out_vf_voc enters the first tube
%    (Ag = glotarea, Av area of the first tube; without glotarea the factor
%    is 1), and z_out is pin_gl_ac of tractsig, out_vf_voc*(Ag-Av)/(Ag+Av).
% xi: viscothermal constant (data.properties.damping), 0: no wall losses
% radimp: radiation at the mouth as in the stairs model (1, default, or 2)
%
% The internal sampling rate is an integer multiple of Fs, at least
% 88200 Hz and high enough for the shortest tube and the steepest cone.

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

if nargin < 9 || isempty(radimp)
   radimp = 1;	% radiation as radimproutine 1 of the stairs model
end
if nargin < 8
   glotarea = [];	% no glottal area: the fold signal enters unchanged
end
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
   end;
   M = internalfactor(tubes, Fs, c);
   PARCTIM = coneprepare(tubes, xi, c, 1/(M*Fs), radimp);
   while ~PARCTIM.stable	% very steep cone: shorter time step
      M = M + 1;
      if M > 64
         error('ctim2: a cone is too steep for the calculation');
      end
      PARCTIM = coneprepare(tubes, xi, c, 1/(M*Fs), radimp);
   end
   PARCTIM.M = M;
end;	% of initialization
M  = PARCTIM.M;
nt = PARCTIM.nt;	% number of tubes

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
      [PARCTIM, y_out(n), z_out(n), y_out_all(:,n), fw, bw] ...
         = conestep(PARCTIM, double(n == 1));	% impulse as in voctract
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
   % coupling at the glottis as in tractsig
   if isempty(glotarea)
      T1m = 1;  z_out = 0;
   else
      vocarea = pi*tubes(1,2)^2;
      T1m   = 2*glotarea/(vocarea + glotarea);
      z_out = inputpressure*(glotarea - vocarea)/(glotarea + vocarea);	% pin_gl_ac
   end
   y_out = 0;  p_all = zeros(nt+1,1);
   for m = 1:M
      [PARCTIM, y, ~, p] = conestep(PARCTIM, inputpressure*T1m);
      y_out = y_out + y/M;
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
      voxcolor(Hndl.tractsigfigplot);   % black line readable in a dark theme
   else
      Hndl.tractsigfig = figure('visible','on','NumberTitle','off', ...
         'Name','Sound pressure in the vocal tract','Units','normalized',...
         'Position',[.5 .05 .5 .4]);
      set(Hndl.tractsigfig,'MenuBar', 'none');
      Hndl.tractsigfigplot = axes;
      plot(1:ndis, [dudu1], 'r-', ...
         1:ndis, [dudu2],    		'b-', ...
         1:ndis, p_out_mouth,		'k-')
      voxcolor(Hndl.tractsigfigplot);
   end
end;
