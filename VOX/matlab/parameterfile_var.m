function [data,Infold,PARA,BATCH,FOLD,TRACH,TRACT,NOISE,vowel, ...
   iniinput,TVAKT,PTG,TMAX,Fs,...
   MAXSEGMENTS,MAXDEVLIMIT,XI,Xi0,MAXM,GRON] ...
   = parameterfile1 ...
   (PARA,BATCH,FOLD,TRACH,TRACT,NOISE,vowel,iniinput,TVAKT,PTG, ...
   TMAX,Fs,MAXSEGMENTS,MAXDEVLIMIT,XI,Xi0,MAXM,GRON,datas,num)

global filename time
% switches
PARA      = 1;
BATCH     = datas.BATCH;
FOLD      = datas.FOLD;
TRACH     = datas.TRACH;
TRACT     = datas.TRACT;
NOISE     = datas.NOISE;


% select
vowel     = datas.vowel;         % 6 = o, 3= a
iniinput  = datas.iniinput;      % 4 = combicalc

% values
TVAKT     = datas.TVAKT;     % activ stress
PTG       = datas.PTG;       % lounge pressure
if ischar(filename) && (contains(filename,'FE') || contains(filename,'ip'))
   fid = fopen(filename,'r');
   a = fscanf(fid,'%f',[13 inf]);
   fclose(fid);
   b=a';
   TMAX     = max(b(:,1));    % length of signal
else
   TMAX    = datas.TMAX;
end;
Fs        = datas.Fs;

% suffix of outfile
if ischar(filename) && contains(filename,'FE')
   suffix = ['fem',num2str(num)];
else
   suffix = ['para',num2str(num)];
end;

% infold settings
% ==========================================================================================

Infold.k   	   = 1;
Infold.lmvfac  = ones(1,MAXM);;
Infold.lmmfac  = ones(1,MAXM);;
Infold.rmvfac  = ones(1,MAXM);;
Infold.rmmfac  = ones(1,MAXM);;


% if no interaction:
Infold.rvoc   		= datas.Infold.rvoc;         % default:0.0089, input radius of vocal tract
Infold.rtrach 		= datas.Infold.rtrach;	     % default: 0.009, input radius of trachea
Infold.flags.VOC	= datas.Infold.flags.VOC;    % to be CHANGED?
Infold.flags.SUB 	= datas.Infold.flags.SUB;
Infold.pin_gl_ac 	= datas.Infold.pin_gl_ac;    % "Load" of vocal folds by vocal tract, see above.
Infold.ps_gl_ac  	= datas.Infold.ps_gl_ac;     % "Load" of vocal folds by lung
Infold.pin          = datas.Infold.pin;
Infold.ps           = datas.Infold.ps;

% set Graphicflags ----------
Infold.flags.GRON  = datas.Infold.flags.GRON;
Infold.flags.PMON  = datas.Infold.flags.PMON;

% set registerflag ----------
Infold.register     = datas.Infold.register;		% 1: Modal, 2: Head, 3: Falsett
Infold.flags.ALONE  = datas.Infold.flags.ALONE;   % 1: standalone execution of loop
Infold.calctime 	= datas.TMAX/1000;

if ischar(filename) && contains(filename,'FE')

   % [time,Infold.w0lp(1),Infold.w0lp(2),Infold.w0lp(3)...
   %      ,Infold.w0rp(1),Infold.w0rp(2),Infold.w0rp(3)...
   %  ,Infold.wmaxla(1),Infold.wmaxla(2),Infold.wmaxla(3)...
   %      ,Infold.wmaxra(1),Infold.wmaxra(2),Infold.wmaxra(3)] = textread(filename,'%f %f %f %f %f %f %f %f %f %f %f %f %f',1);
   %     Infold.k1    = 2;
   %     Infold.k2    = 3;    	% default 3, MIN 0, MAX 8 [N/m]
   fid = fopen(filename,'r');
   a   = fscanf(fid,'%f',[13 1]);
   fclose(fid);
   b = a';

   time = b(1,1);
   Infold.w0lp   = b(1,2:4);
   Infold.w0rp   = b(1,5:7);
   Infold.wmaxla = b(1,8:10);
   Infold.wmaxra = b(1,11:13);

   Infold.k1    = 2;
   Infold.k2    = 4.5;

elseif filename ~= 0

   switch datas.Infold.register
      case 1 % modal
         %     Infold.w0(1)    = 25;	% vocal fold distance [um]
         %     Infold.w0(2)    = 25;
         %     Infold.wmax(1)  = 25;
         %     Infold.wmax(2)  = 25;

         Infold.w0lp    = [25,0,0];
         Infold.w0rp    = [25,0,0];
         Infold.wmaxla  = Infold.w0lp;
         Infold.wmaxra  = Infold.w0rp;
         Infold.k1    = 2;
         Infold.k2    = 4.7;    	% default 3, MIN 0, MAX 8 [N/m]
      case 2 % head
         %     Infold.w0(1)    = 175;	% vocal fold distance [um]
         %     Infold.w0(2)    = 175;
         %     Infold.wmax(1)  = 175;
         %     Infold.wmax(2)  = 175;
         Infold.w0lp    = [175,0,0];
         Infold.w0rp    = [175,0,0];
         Infold.wmaxla  = Infold.w0lp;
         Infold.wmaxra  = Infold.w0rp;
         Infold.k1    = 2;
         Infold.k2    = 4.7;    	% default 3, MIN 0, MAX 8 [N/m]
      case 3 % falsetto
         %     Infold.w0(1)    = 1;	% vocal fold distance [um]
         %     Infold.w0(2)    = 1;
         %     Infold.wmax(1)  = 1;
         %     Infold.wmax(2)  = 1;

         Infold.w0lp    = [1,0,0];
         Infold.w0rp    = [1,0,0];
         Infold.wmaxla  = Infold.w0lp;
         Infold.wmaxra  = Infold.w0rp;
         Infold.k1    = 2;
         Infold.k2    = 4.7;    	% default 3, MIN 0, MAX 8 [N/m]
   end

end;

Infold.ptg    = datas.PTG;
Infold.tvakt  = datas.TVAKT;
% datainit
% ==========================================================================================


data.properties.value       = datas.vowel;
[data.radius, data.spacing] = areadata(data.properties.value);
data.properties.mode        = datas.data.properties.mode; % stairs
if data.properties.mode == 1
   data.properties.damping   = Xi0; % stairs
else
   data.properties.damping   = XI;  % tubes
end;
data.properties.maxdevlimit = MAXDEVLIMIT;
data.properties.maxsegments = MAXSEGMENTS;
data.properties.color       = datas.data.properties.color;


% databatchinit
% ==========================================================================================

data.batch.periodic   = datas.data.batch.periodic;	% flag periodic
data.batch.linramp    = datas.data.batch.linramp;		% flag linear
data.batch.shift      = datas.data.batch.shift;     % flag random shift

if data.batch.shift == 1
   data.batch.shiftvalue = datas.data.batch.shiftvalue; % range of random shift
end
if data.batch.periodic == 1
   data.batch.modFreq    = datas.data.batch.modFreq;	  % modulation frequency [Hz]
   data.batch.modDepth   = datas.data.batch.modDepth;	% modulation depth [%]
   data.batch.seg1       = datas.data.batch.seg1;		% number of segments per period
end
if data.batch.linramp == 1
   data.batch.start      = datas.data.batch.start;		% start of linear ramp [%]
   data.batch.stop       = datas.data.batch.stop;		% end of linear ramp [%]
   data.batch.seg2       = datas.data.batch.seg2;	  % number of linear segments
end

data.batch.actstr     = datas.data.batch.actstr;		% flag active stress
data.batch.subpre     = datas.data.batch.subpre;		% flag subglottal pressure
data.batch.trac       = datas.data.batch.trac;      % flag modulation of the first 10 radius segments

data.suffix = suffix;