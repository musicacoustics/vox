function PARNOISE = noisesig(PARNOISE, actflow, glotarea, ...
   radius, spacing, ii)
% synthesize noise component in VOX

global Fs rho Hndl GRON noisemovflag

noisemovflag = 0;

% initialization of parameters
vortices = PARNOISE.vortices;
shedtimer = PARNOISE.shedtimer;
if glotarea > 0
   flowvelocity = actflow/(glotarea*1.1);  % Hirschberg
else
   flowvelocity = 0;
end
St = 1;    % Strouhal number
shedtimer = shedtimer+1;  % count time after last shedding
actflow;
glotarea;

% kill vortex with deadmark (velocity == 0)
vortex = 1;
while vortex <= size(vortices,2)  % vortex counter
   vortex;
   if vortices(vortex).velocity == 0;
      vortices(vortex) = [];
   else
      vortex = vortex+1;
   end;
end

% main routine
[vortices, Tshed, shedtimer] = vortexgenerator(vortices, ...
   flowvelocity, glotarea, ii, spacing, radius, St, shedtimer);

if noisemovflag
   writeVideo(Hndl.noisemov, getframe(Hndl.noisefig));   % addframe has been removed
end

[PARNOISE.out, vortices] = vortexnoise(vortices, radius, ...
   flowvelocity, St, Tshed, PARNOISE.dampdB);

% write vortices back to PARNOISE
PARNOISE.vortices = vortices;
PARNOISE.shedtimer = shedtimer;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vortices, Tshed, shedtimer] = vortexgenerator(vortices, ...
   flowvelocity, glotarea, ii, spacing, radius, St, shedtimer)
% creates, moves and deletes vortices in segments

global Fs Hndl GRON noisemovflag

% calculate shedding interval
if (ii > 1) & (size(vortices,2)>0) & (flowvelocity>0)
   Tshed = 2*rand*(vortices(size(vortices,2)).diameter/ ...
      (St*flowvelocity));
else
   Tshed = 0;
end

% create new vortex after shedding interval
if (shedtimer/Fs > Tshed) & (flowvelocity ~= 0)
   vortex = size(vortices,2)+1;
   vortices(vortex).diameter = sqrt(glotarea*4.4/pi);  % Hirschberg
   vortices(vortex).position = 0;  	  % spatial offset?
   vortices(vortex).velocity = 0.5*max(0,flowvelocity);      % Sinder
   vortices(vortex).segment  = 1;
   vortices(vortex).newnoise = 0;
   shedtimer = 0;
end


sizevortices = size(vortices,2);
if GRON & (voxfigflag('Vortex generation',1) == 1) & (sizevortices>0)
   set(0,'CurrentFigure',Hndl.noisefig)
   set(Hndl.noisefig,'CurrentAxes',Hndl.noisefigplot)
   cla;
   hold on
   x0 = -spacing*1000;
   y0 = sqrt(glotarea/pi);
   if size(spacing) == 1	% stairs
      x = [0:length(radius)-1]*spacing*1000;
      stairs([x0 x],  [y0; radius(1:length(x))]*1000)
      stairs([x0 x], -[y0; radius(1:length(x))]*1000)
   end;
   axis([-5 30 -5 5])
   hold off
end;

% track existing vortices
for vortex = 1:sizevortices   % vortex counter

   % set up parameters
   diameter = vortices(vortex).diameter;
   position = vortices(vortex).position;
   segment = vortices(vortex).segment;
   velocity = vortices(vortex).velocity;
   newnoise = vortices(vortex).newnoise;
   % mark old vortex dead
   if (position > 4*diameter)|(velocity < 1)
      velocity = 0;
   end

   % move existing vortices
   position = position + velocity/Fs;

   % calculate segment in which vortex lives and its parameters
   if size(spacing) == 1	% stairs
      segment = ceil((position+.0001)/spacing);
      inpos = (segment-1)*spacing;  % inlet position
      outpos = inpos + spacing;     % segment outlet position
      if segment > 1
         inradius = radius(segment-1); % inlet radius
         outradius = radius(segment);  % outlet radius
      else
         inradius = radius(segment);
         outradius = inradius;
      end
      if inradius == outradius
         outradius = inradius+1e-5;
      end
      ductarea = pi*(outradius^2);  % segment cross section area
   else	 % tubes
      seg = find(spacing <= position);
      segment = seg(length(seg))+1;
      inpos = spacing(segment-1);
      outpos = spacing(segment);
      inradius = radius(segment);
      if segment > 2
         outradius = radius(segment+1);
      else
         outradius = radius(segment)+1e-10;
      end
      actradius = position*(outradius-inradius)/ ...
         (outpos-inpos) + inradius;
      % ductradius at vortex position
      ductarea = pi*(actradius)^2;
   end

   % calculate anglefactor for each vortex
   focuspoint = inpos - inradius*((outpos-inpos)/(outradius-inradius));
   % focus point position of mainflow streamlines
   anglefactor = 0.5*diameter	/(position - focuspoint);

   if GRON
      if voxfigflag('Vortex generation',1) == 1
         set(0,'CurrentFigure',Hndl.noisefig)
         set(Hndl.noisefig,'CurrentAxes',Hndl.noisefigplot)
         if velocity == 0
            lstyle = ':';
         else
            lstyle = '-';
            %				text(position*1000,-3,num2str(vortex), ...
            %					'HorizontalAlignment', 'center');
         end
         maxnoise = 0.1;
         bgcolor  = 0.15;
         vortexcolor = bgcolor+abs(newnoise/maxnoise);
         if (abs(newnoise) > maxnoise)|(vortexcolor > 1)
            lcolor = 1; % make sure that maxcolor = 1
         else
            lcolor = vortexcolor;
         end
         hold on
         line([position*1000 position*1000], ... % draw vortex
            [-diameter*1000/2 diameter*1000/2], ...
            'LineStyle', lstyle, ...
            'Color', [1-lcolor, 1-lcolor, 1-lcolor]);
         hold off
      else	% create figure
         if GRON
            Scrsize   = get(0,'Screensize');
            Scrwidth  = Scrsize(3);
            Scrheight = Scrsize(4);
            Hndl.noisefig = figure('visible','on','NumberTitle','off', ...
               'Name','Vortex generation','Units','Pixels',...
               'Position',[660 260 250 330]);
            set(Hndl.noisefig,'DoubleBuffer','on');
            set(Hndl.noisefig,'MenuBar', 'none');
            Hndl.noisefigplot = axes;
            xlabel('Distance from glottis [mm]');
            ylabel('Vocal tract section [mm]');
         end
      end
   end % if GRON
   % write back parameters to vortices
   vortices(vortex).diameter 		= diameter;
   vortices(vortex).position 		= position;
   vortices(vortex).segment 			= segment;
   vortices(vortex).velocity 		= velocity;
   vortices(vortex).anglefactor 	= anglefactor;
   vortices(vortex).ductarea 		= ductarea;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, vortices] = vortexnoise(vortices, radius, ...
   flowvelocity, St, Tshed, dampdB)
% generates and sums noise pressure for each vortex in each segment

global rho;

out	= zeros(length(radius),1); % no noise
for vortex = 1:size(vortices,2)
   %  dissfac = 1-vortices(vortex).position/(4*vortices(vortex).diameter)
   %  vortices(vortex).position
   m = dampdB/10/(4*vortices(vortex).diameter);
   dissfac = 10^(-m*vortices(vortex).position);
   vortices(vortex).newnoise = ...
      -pi*rho*Tshed/2 * flowvelocity^2 ... % /500 ...% *1e7 ...
      / vortices(vortex).ductarea ...
      * (vortices(vortex).diameter) ...
      * vortices(vortex).velocity ...
      * vortices(vortex).anglefactor ...
      * dissfac;
   %	nn = vortices(vortex).newnoise
   out(vortices(vortex).segment) ...
      = out(vortices(vortex).segment) ...
      + vortices(vortex).newnoise;
end;
