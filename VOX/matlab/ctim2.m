function [y_out, z_out, PARCTIM] ...
   = ctim2(tubes, tmax, xi, ii, PARCTIM, inputpressure, PARNOISE)

% function ctim2 calculates pressure signals within a cylinder model of the vocal tract.
% input: tubes (matrice of

global Fs c rho BRK GRONT Hndl

GRON2=0; 			% graphics flag

if isempty(Fs)
   Fs=44100;			% sample rate [Hz]
end;
deltat = 1/Fs;	% time increment
if isempty(c)
   c = 350;			% speed of sound [m/s]
end;
if isempty(rho)
   rho = 1.21; 	% air density [kg/m^3]
end;
%ndis	 = 1;			% discontinuity where pressure is calculated
ndis	 = size(tubes,1);			% discontinuity where pressure is calculated

if nargin < 5
   PARCTIM = [];	% stand alone calculation
end;
if nargin < 4
   ii = 0;	% stand alone calculation
   ntmax = ceil(tmax*1e-3/deltat);	% calculate ntmax samples
else
   ntmax = 1;
end;
if nargin < 3
   xi 		 = 0.135;	% damping constant
   %	xi 		 = 5.0*0.135;	% damping constant
end;
if nargin < 2
   tmax = 20;
end;

if ii < 2	% initialization of tubes etc.
   Hndl.waitfigure = voxwaitbar(0,'Calculating tract signal...');
   t = [0:ntmax-1]/Fs*1000;	% time beam for graphic display
   if nargin == 0	% for test
      lcyl	= [0.05,   0.05];	% test
      rl		= [0.005, 0.01];
      rr		= [0.01,  0.005];
      holes 		= [];
      fingering = [];
      tubes = [lcyl;2*rl;2*rr]';
      diracamp = 1/deltat;	% amplitude Dirac input org:1/deltat
   else
      tubes(:,2:3) = tubes(:,2:3)*2;
      holes 		= [];
      fingering = [];
      diracamp 	= 1;			% amplitude Dirac input org:1/deltat
   end;
   % calculpressio[ndis_, tfinal_] := Block[{t,i,n,m,infinal,cabalactual}
   BRK  = 0;
   QUIT = 0;
   PARCTIM = preparation(tubes, holes, fingering, xi, c);


   %inicipressio;	%
   PARCTIM.pressure_plus		= zeros(PARCTIM.ldis-1,max(PARCTIM.msup)+PARCTIM.degree);
   PARCTIM.pressure_minus	= zeros(PARCTIM.ldis-1,max(PARCTIM.msup)+PARCTIM.degree);
   PARCTIM.output_plus			= zeros(PARCTIM.ldis  ,PARCTIM.degree+1);
   PARCTIM.output_minus		= zeros(PARCTIM.ldis-1,PARCTIM.degree+1);
   PARCTIM.input_plus  		= zeros(1,PARCTIM.ldis-1);
   PARCTIM.input_minus			= zeros(1,PARCTIM.ldis-1);
   PARCTIM.y_plus_aux			= zeros(PARCTIM.ldis, 3);	% max. value for dimension('eo')=3
   PARCTIM.y_minus_aux			= zeros(PARCTIM.ldis, 3);
   PARCTIM.flowinput				= zeros(1,PARCTIM.degree+1);
   PARCTIM.inputaux				= zeros(1,2);
end;	% of initialization
if ii == 0	% stand alone calculation
   inputflow = zeros(ntmax,1);
   inputflow(1) = diracamp/(rho*c);;
   %	  disp('preparation...');
else
   inputflow = inputpressure/(rho*c);
end;

for n = 1:ntmax
   if BRK, break, end  % makes it possible to end calculation
   if ii == 0	% stand alone calculation
%      Hndl.waitfigure=waitbar(n/ntmax,Hndl.waitfigure);
      Hndl.waitfigure=voxwaitbar(n/ntmax);
      inputflow = zeros(ntmax,1);
      inputflow(1) = diracamp/(rho*c);;
      %	  disp('preparation...');
      %    Hndl.waitfigure = waitbar(0,'Calculating tract signal...');
   else
      inputflow = inputpressure/(rho*c);
   end;

   [PARCTIM.pressure_plus, PARCTIM.pressure_minus, PARCTIM.output_plus, PARCTIM.output_minus] ...
      = propagator(PARCTIM.ldis-1, PARCTIM.pressure_plus, PARCTIM.pressure_minus, ...
      PARCTIM.output_plus, PARCTIM.output_minus, PARCTIM.input_plus, ...
      PARCTIM.input_minus, PARCTIM.b, PARCTIM.alfa1, PARCTIM.alfa2, ...
      PARCTIM.minf, PARCTIM.msup);

   actualflow = inputflow(n);

   [PARCTIM.input_minus, PARCTIM.flowinput, PARCTIM.y_plus_aux, PARCTIM.inputaux] ...
      = inputconv(actualflow, PARCTIM.flowinput, PARCTIM.A, PARCTIM.B, ...
      PARCTIM.y_plus_aux, PARCTIM.output_plus, PARCTIM.input_minus, PARCTIM.Ainput, ...
      PARCTIM.inputaux, PARCTIM.Binput, PARCTIM.Cinput, PARCTIM.C_plus);

   [PARCTIM.input_plus, PARCTIM.input_minus, PARCTIM.y_plus_aux, PARCTIM.y_minus_aux] ...
      = middleconv(PARCTIM.ldis-1, PARCTIM.A, PARCTIM.B, PARCTIM.y_plus_aux, ...
      PARCTIM.y_minus_aux, PARCTIM.C_plus, PARCTIM.C_minus, PARCTIM.input_plus, ...
      PARCTIM.input_minus, PARCTIM.output_plus, PARCTIM.output_minus);

   [PARCTIM.input_plus, PARCTIM.y_minus_aux] ...
      = outputconv(PARCTIM.ldis, PARCTIM.A, PARCTIM.B, PARCTIM.y_minus_aux, ...
      PARCTIM.output_minus, PARCTIM.C_minus, PARCTIM.input_plus);

   y_out(n) = PARCTIM.output_plus(ndis,1) + PARCTIM.input_minus(ndis);
   z_out(n) = PARCTIM.output_plus(1,1) + PARCTIM.input_minus(1);
   y_out_all(:,n) = PARCTIM.output_plus(1:ndis,1) + PARCTIM.input_minus(:);

   if ((GRONT == 1) | (GRONT == 3))  & (ii == 0)	% waterfall if graphics on and standalone calc.
      if voxfigflag('Wave propagation in the vocal tract',1) == 1
         set(0,'CurrentFigure',Hndl.voctractfig)
         set(Hndl.voctractfig,'CurrentAxes',Hndl.voctractfigplot)
         waterfall(t(1:n), 1:ndis, y_out_all);
         view(0,85)
         grid off
      else	% create figure
         Hndl.voctractfig = figure('visible','on','NumberTitle','off', ...
            'Name','Wave propagation in the vocal tract','Units','normalized',...
            'Position',[.5 .05 .5 .4]);
         set(Hndl.voctractfig,'MenuBar', 'none');
         Hndl.voctractfigplot = axes;
         waterfall(t(1:n), 1:ndis, y_out_all);
         view(0,85)
         grid off
      end
   end;
   if (GRONT == 2) | (GRONT == 3)	% graphics on
      for segment=1:ndis;
         dudu1(segment) = PARCTIM.output_minus(segment);		% wave runs downstream
         dudu2(segment) = PARCTIM.output_plus(segment+1);	% wave runs upstream
         p_out_mouth(segment) = ...
            dudu1(segment)+dudu2(segment);
      end
      mdudu=max(max(abs([dudu1;dudu2;p_out_mouth(1:ndis)])));
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
end
if ii == 0 % stand alone calculation
   PARCTIM.out.t = t(1:n);
   PARCTIM.out.segments = 1:ndis;
   PARCTIM.out.y	= y_out_all;
end;
%toc;
if ii == 0	% stand alone calculation
   if ishghandle(Hndl.waitfigure)   % vox('break') may have closed it already
      close(Hndl.waitfigure);  % close waitbar
   end
end