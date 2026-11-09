% areas3 interactive shaping of the vocal tract
%====================================================
%= function areas3.m V 0.5                          =
%= input: array of vocaltract radius data (1,i)     =
%= output: array of modified vocaltract data (1,i)  =
%=                                                  =
%= written 12-08-1999 Daniel Riemann                =
%= modified by Malte Kob                            =
%====================================================

function [] = areas3(action);
%function [newfii] = areas3(fii,action);

global AREA_DAT Hndl XI Xi0 MAXSEGMENTS MAXDEVLIMIT TMAX radimproutine IMPORT BATCH Hndl

if nargin > 1
   error('Wrong number of input arguments');
elseif nargin == 0
   action = 'initialize';
end;

maxradius = 40;	% maximum radius in mm

switch action

   case 'initialize'

      %  oldFigNumber = watchon;
      S =  brighten([[zeros(8,2) (3:10)'/10]; prism(56)],1/3);
      if (get(0,'ScreenDepth') == 1)
         S = gray(64);
      end
      labelColor		= 192/255*[1 1 1];

      set(0,'CurrentFigure',Hndl.ModTractFig)
      clf
      %   set (Hndl.ModTractFig,'Units','normalized','Name','Design of VT area Function',...
      %     'NumberTitle','off');
      Hndl.TractMod.areafunc = axes('Position',[.09 .35 .86 .58]);
      data = get(Hndl.figureNumber, 'UserData');
      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      %  data.properties.maxdevlimit = 3;
      %  data.properties.maxsegments = 3;
      %  data.properties.color = 1;
      %  data.properties.damping = XI; % default 0.135;

      [data.newradius,data.newradiusintpol,data.properties.outsegments,...
         data.properties.outdevlimit] = areaintpol(data.radius,data.properties.maxsegments,...
         data.properties.maxdevlimit);
      [tubes] = radiusconvert(data.radius,data.spacing,data.newradius);
      data.tubes = tubes;
      data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
      x_vector = [0:1:length(data.radius)-1]*data.spacing;
      [xb,yb] = stairs(x_vector,data.radius);
      data.radius = data.radius(1:length(data.radius) - 1);
      CurrentRadius = data.radius(1);
      CurrentDisc = 1;
      data.properties.currentdisc = CurrentDisc;
      length_fii = length(data.radius);
      Area = pi*(CurrentRadius^2);
      linehandle = plot(xb,yb);

      lowerframe = uicontrol('Style','frame',...
         'Units','normalized',...
         'Position',[.07 .05 .86 .19],...
         'BackgroundColor',labelColor);

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.09 .18 .09 .05],...
         'BackgroundColor',labelColor,...
         'String','Radius');

      radius = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.18 .18 .11 .05],...
         'Tag','radius',...
         'Callback','areas3(''radius'');',...
         'String',num2str(CurrentRadius));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.3 .18 .1 .05],...
         'String','Area',...
         'BackgroundColor',labelColor);

      area = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Tag','area',...
         'Position',[.4 .18 .1 .05],...
         'Callback','areas3(''area'');',...
         'String',num2str(Area));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.52 .18 .12 .05],...
         'String','Disc',...
         'BackgroundColor',labelColor);

      disc = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Tag','disc',...
         'Position',[.64 .18 .1 .05],...
         'Callback','areas3(''disc'');',...
         'String',num2str(CurrentDisc));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.09 .12 .09 .05],...
         'String','Mode',...
         'BackgroundColor',labelColor);

      if get(Hndl.INPUT,'Value') == 4
         popupStr = str2mat('stairs','tubes','import');
         popmode = 3;
      else
         popupStr = str2mat('stairs','tubes');
         popmode = 2;
      end

      Hndl.TractMod.Mode = uicontrol('Style','popup',...
         'Units','normalized', ...
         'Position',[.18 .12 .11 .05], ...
         'String',popupStr, ...
         'Value', popmode, ...
         'Callback','areas3(''mode'')');

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.09 .063 .09 .04],...
         'String','Damping',...
         'BackgroundColor',labelColor);

      Damping = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.18 .06 .11 .05],...
         'String',num2str(data.properties.damping),...
         'Tag','Damping',...
         'Callback','areas3(''damping'')');

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.3 .06 .1 .05],...
         'String','MaxDev',...
         'BackgroundColor',labelColor);

      maxdevlimit = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.4 .06 .1 .05],...
         'Tag','maxdevlimit',...
         'Enable','off',...
         'Callback','areas3(''maxdevlimit'')',...
         'String',num2str(data.properties.maxdevlimit));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.3 .12 .1 .05],...
         'String','AreaDev',...
         'BackgroundColor',labelColor);

      devlimit = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.4 .12 .1 .05],...
         'Enable','off',...
         'BackgroundColor',labelColor,...
         'Tag','devlimit',...
         'String',num2str(data.properties.maxdevlimit));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.52 .06 .12 .05],...
         'String','Maxsegments',...
         'BackgroundColor',labelColor);

      maxsegments = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.64 .06 .1 .05],...
         'Tag','maxsegments',...
         'Enable','off',...
         'Callback','areas3(''maxsegments'')',...
         'String',num2str(data.properties.maxsegments));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.52 .12 .12 .05],...
         'String','Segments',...
         'BackgroundColor',labelColor);

      segments = uicontrol('Style','Edit',...
         'Units','normalized',...
         'Position',[.64 .12 .1 .05],...
         'Enable','off',...
         'BackgroundColor',labelColor,...
         'Tag','segments',...
         'String',num2str(data.properties.maxsegments));

      uicontrol('Style','text',...
         'Units','normalized',...
         'Position',[.8 .18 .11 .05],...
         'String','Rad.-Imp.',...
         'BackgroundColor',labelColor);

      popupStr = str2mat('low f','all f');

      radimp = uicontrol('Style','Popup',...
         'Units','normalized',...
         'Position',[.8 .12 .1 .05],...
         'Tag','radimp',...
         'Enable','on',...
         'String',popupStr,...
         'Callback','areas3(''radimp'')',...
         'Value',data.properties.radimp);

      defaults = uicontrol('Style','Pushbutton',...
         'Units','normalized',...
         'Position',[.8 .06 .1 .05],...
         'Tag','defaults',...
         'Enable','on',...
         'Callback','areas3(''defaults'')',...
         'String','defaults');

      set(linehandle,'ButtonDownfcn','areas3(''down'');');
      set(linehandle,'UserData',data.radius);
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);

      vowelname = get(Hndl.VOWEL, 'string');
      index = get(Hndl.VOWEL, 'value');
      if index == 11
         %        set(get(Hndl.TractMod.areafunc, 'Title'),'String', '');
         vowelname = vowelname(get(Hndl.VOWEL, 'value'), 8:9);
      else
         %        set(get(Hndl.TractMod.areafunc, 'Title'),'String', '');
         vowelname = vowelname(get(Hndl.VOWEL, 'value'), 2:3);
      end;
      TitleStr = ['Vocal tract for vowel ' strrep(vowelname, '_', '\_')];
      set(get(Hndl.TractMod.areafunc, 'Title'),'String', TitleStr);
      xlabel('Distance from glottis [mm]');
      ylabel('Radius [mm]');
      AREA_DAT = [ linehandle ; 0 ; 0 ];

      %  watchoff(oldFigNumber);


      %=====================================================================================================
      % down callback
   case 'down'

      point=get(Hndl.TractMod.areafunc,'currentpoint');
      x = point(1,1);
      y = point(1,2);

      linehandle = AREA_DAT(1);
      line_x=get(linehandle,'XData');
      line_y=get(linehandle,'YData');
      dist=(line_x-x).^2 + (line_y-y).^2;
      [temp,i]=min(dist);
      fixedx=line_x(i);
      fixedy=line_y(i);

      set(linehandle,'LineStyle',':');
      set(Hndl.TractMod.areafunc,'YLimMode','manual');
      drawnow;

      AREA_DAT(2) = fixedx;
      AREA_DAT(3) = fixedy;

      set(gcf,'WindowButtonMotionFcn', 'areas3(''move'');');
      set(gcf,'WindowButtonUpFcn', 'areas3(''up'');');


      %===========================================================================
      % move callback
   case 'move'
      data = get(Hndl.figureNumber, 'UserData');
      if size(data.radius,1) == 1
         data.radius = data.radius';
      end;

      %CurrentRadius = AREA_DAT(1);
      %CurrentDisc = AREA_DAT(2);
      linehandle = AREA_DAT(1);
      %Radius = findobj('Tag','radius');
      %Area = findobj('Tag','area');
      %Disc = findobj('Tag','disc');
      fixedx = AREA_DAT(2);
      fixedy = AREA_DAT(3);
      length_fii = size(data.radius,1);
      YData = get(linehandle,'YData');


      point=get(Hndl.TractMod.areafunc,'currentpoint');
      x=point(1,1);
      y=point(1,2);


      %data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;

      if ceil(x/data.spacing) > length_fii
         x = length_fii*data.spacing;
      elseif round(x) < data.spacing
         x = data.spacing;
      end;
      if y < 0
         y = 0;
      elseif y > maxradius
         y = maxradius;
      end;
      %AREA_DAT(1) = y;
      data.properties.currentdisc = round(x/data.spacing);
      data.radius(data.properties.currentdisc) = y;
      %AREA_DAT(2) = CurrentDisc;
      temparea = pi*(y^2);
      data.radius(length(data.radius) + 1) = data.radius(length(data.radius));

      x_vector = [0:1:length(data.radius)-1].*data.spacing;
      [xb,yb] = stairs(x_vector,data.radius);
      data.radius = data.radius(1:length(data.radius) - 1);

      xb(length(xb)+1) = xb(length(xb));
      yb(length(yb)+1) = yb(length(yb));


      %  newfii = data;
      set(findobj('Tag','radius'),'String',num2str(y));
      set(findobj('Tag','area'),'String',num2str(temparea));
      set(findobj('Tag','disc'),'String',num2str(data.properties.currentdisc));
      set(linehandle,'YData',yb);
      set(linehandle,'XData',xb);
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);


      %===========================================================================
      % up callback
   case 'up'

      set(AREA_DAT(1),'LineStyle','-');

      linehandle = AREA_DAT(1);
      YData = get(linehandle,'YData');
      set(Hndl.TractMod.areafunc, 'YLim', [0 max(YData)+1]);
      set(gcf,'WindowButtonMotionFcn','');
      set(gcf,'WindowButtonUpFcn','');

      areas3('redraw');

      %===========================================================================
      % redraw callback
   case 'redraw'
      areas3('refresh');
      data=get(Hndl.figureNumber, 'UserData');
      %CurrentRadius = AREA_DAT(1);
      %CurrentDisc = AREA_DAT(2);
      linehandle = AREA_DAT(1);
      %Radius = findobj('Tag','radius');
      %Area = findobj('Tag','area');
      %Disc = findobj('Tag','disc');
      fixedx = AREA_DAT(2);
      fixedy = AREA_DAT(3);
      length_fii = size(data.radius,1);
      YData = get(linehandle,'YData');

      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;
      data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
      x_vector = [0:1:length(data.radius)-1]*data.spacing;
      [xb,yb] = stairs(x_vector,data.radius);
      data.radius = data.radius(1:length(data.radius) - 1);

      xb(length(xb)+1) = xb(length(xb));
      yb(length(yb)+1) = yb(length(yb));

      set(AREA_DAT(1),'YData',yb);
      set(AREA_DAT(1),'XData',xb);

      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);

      linehandle = AREA_DAT(1);
      YData = get(linehandle,'YData');
      set(Hndl.TractMod.areafunc, 'YLim', [0 max(YData)+1]);
      %  drawnow;


      %===========================================================================
      % disc callback
   case 'disc'
      data = get(Hndl.figureNumber, 'UserData');
      if size(data.radius,1) == 1
         data.radius = data.radius';
      end;

      CurrentDisc = round(str2num(get(findobj('Tag','disc'),'String')));

      if CurrentDisc < 1
         CurrentDisc = 1;
      elseif CurrentDisc > size(data.radius,1)
         CurrentDisc = size(data.radius,1);
      end;

      %AREA_DAT(2) = CurrentDisc;
      linehandle = AREA_DAT(1);
      %radius = findobj('Tag','radius');
      %area = findobj('Tag','area');
      %disc = findobj('Tag','disc');
      length_fii = size(data.radius,1);
      YData = get(linehandle,'YData');

      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;

      %CurrentRadius = data.radius(CurrentDisc);
      %AREA_DAT(1) = CurrentRadius;
      Area = pi*(data.radius(data.properties.currentdisc)^2);

      set(findobj('Tag','disc'),'String',num2str(CurrentDisc));
      set(findobj('Tag','radius'),'String',num2str(data.radius(CurrentDisc)));
      set(findobj('Tag','area'),'String',num2str(Area));

      data.properties.currentdisc = CurrentDisc;
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);


      %===============================================================================
      % radius callback
   case 'radius'

      data=get(Hndl.figureNumber, 'UserData');
      if size(data.radius,1) == 1
         data.radius = data.radius';
      end;

      CurrentRadius = str2num(get(findobj('Tag','radius'),'String'));

      if CurrentRadius < 0
         CurrentRadius = 0;
      elseif CurrentRadius > maxradius
         CurrentRadius = maxradius;
      end;

      %AREA_DAT(1) = CurrentRadius;
      %CurrentDisc = AREA_DAT(2);
      linehandle = AREA_DAT(1);
      %radius = findobj('Tag','radius');
      %area = findobj('Tag','area');
      length_fii = size(data.radius,1);
      YData = get(linehandle,'YData');
      Area = pi*(CurrentRadius^2);

      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;

      data.radius(data.properties.currentdisc) = CurrentRadius;
      data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
      x_vector = [0:1:length(data.radius)-1]*data.spacing*100;
      [xb,yb] = stairs(x_vector,data.radius);
      data.radius = data.radius(1:length(data.radius) - 1);

      set(findobj('Tag','radius'),'String',num2str(CurrentRadius));
      set(findobj('Tag','area'),'String',num2str(Area));
      set(linehandle,'YData',yb);
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);
      drawnow;


      %====================================================================================
      % area callback
   case 'area'
      data=get(Hndl.figureNumber, 'UserData');
      if size(data.radius,1) == 1
         data.radius = data.radius';
      end;
      Area = str2num(get(gcbo,'String'));
      if Area < 0
         Area = 0;
      elseif Area > pi*maxradius^2
         Area = pi*maxradius^2;
      end;

      CurrentRadius = sqrt(Area/pi);
      %AREA_DAT(1) = CurrentRadius;
      %CurrentDisc = AREA_DAT(2);
      linehandle = AREA_DAT(1);
      radius = findobj('Tag','radius');
      area = findobj('Tag','area');
      length_fii = size(data.radius,1);
      YData = get(linehandle,'YData');
      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;

      data.radius(data.properties.currentdisc) = CurrentRadius;
      data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
      x_vector = [0:1:length(data.radius)-1]*data.spacing;
      [xb,yb] = stairs(x_vector,data.radius);
      data.radius = data.radius(1:length(data.radius) - 1);

      set(findobj('Tag','area'),'String',num2str(Area));
      set(findobj('Tag','radius'),'String',num2str(CurrentRadius));
      set(linehandle,'YData',yb);
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);
      drawnow;


      %====================================================================================
      % mode callback
   case 'mode'
      data = get(Hndl.figureNumber, 'UserData');
      data.properties.mode = get(Hndl.TractMod.Mode,'Value');
      set(Hndl.TractCalcMode,'value',data.properties.mode);
      set(Hndl.figureNumber, 'UserData',data);
      if data.properties.mode == 3  % import
         set(Hndl.TractCalcMode,'value',4);
         data.properties.mode = 4;
         areas3('import');
      else
         data = get(Hndl.figureNumber,'Userdata');
         data.batch.import = 0;
         data.batch.trac = 0;
         IMPORT = 0;
         set(Hndl.figureNumber, 'UserData',data);
         set(Hndl.batch,'enable','on');
         set(Hndl.Duration','Enable','on');
         set(Hndl.DurationStr','Enable','on');
         try
            set(findobj(Hndl.controlfig,'Tag','rb_trac'),'enable','on');
            set(findobj(Hndl.controlfig,'Tag','rb_trac'),'Value',0);
         end
         set(Hndl.VOWEL,'Enable','on');
      end
      vox('tractcalcmode');
      %   areas3('refresh');



      %====================================================================================
      % tubecalc callback
   case 'tubecalc'
      data = get(Hndl.figureNumber, 'UserData');
      [data.newradius, data.newradiusintpol, ...
         data.properties.outsegments, data.properties.outdevlimit] ...
         = areaintpol(data.radius, data.properties.maxsegments, ...
         data.properties.maxdevlimit);
      data.tubes = radiusconvert(data.radius,data.spacing,data.newradius);
      set(Hndl.figureNumber, 'UserData',data);


      %====================================================================================
      % refresh callback
   case 'refresh'
      set(0,'CurrentFigure',Hndl.ModTractFig)
      data = get(Hndl.figureNumber, 'UserData');
      data.properties.mode = get(Hndl.TractMod.Mode,'Value');	% tract or stairs
      if IMPORT
         data.properties.mode = 4;
      end
      Mode = data.properties.mode;
      % CurrentRadius = AREA_DAT(1);
      % CurrentDisc = AREA_DAT(2);
      linehandle = AREA_DAT(1);
      radius = findobj('Tag','radius');
      area = findobj('Tag','area');
      disc = findobj('Tag','disc');
      fixedx = AREA_DAT(2);
      fixedy = AREA_DAT(3);
      length_fii = size(data.radius,1);

      vowelname = get(Hndl.VOWEL, 'string');
      vowelname = vowelname(get(Hndl.VOWEL, 'value'), 2:3);
      if Mode ~= 4
         if get(Hndl.ModTract,'value') == 1 		% modified vowel
            TitleStr = ['Vocal tract for modified vowel ' strrep(vowelname, '_', '\_')];
         else
            TitleStr = ['Vocal tract for vowel ' strrep(vowelname, '_', '\_')];
         end
      end
      if Mode == 1	| Mode == 4 % stairs or import
         set(findobj('Tag','radius'),'Enable','on');
         set(findobj('Tag','area'),'Enable','on');
         set(findobj('Tag','disc'),'Enable','on');
         set(findobj('Tag','Damping'),'String',num2str(data.properties.damping));
         set(findobj('Tag','maxdevlimit'),'Enable','off');
         set(findobj('Tag','maxsegments'),'Enable','off');
         set(findobj('Tag','devlimit'),'Enable','off');
         set(findobj('Tag','segments'),'Enable','off');
         %tempcolormap = [.49,1,.83 ; 1,0,0 ; 0,1,0 ; 1,1,0 ; 1,0,1 ; 0,1,1];
         data.radius = data.radius*1000;
         data.spacing = data.spacing*1000;
         %delete(findobj('linestyle',':'));
         delete(findobj('Tag','tube'));
         legend('off');
         data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
         x_vector = [0:1:length(data.radius)-1]*data.spacing;
         [xb,yb] = stairs(x_vector,data.radius);
         data.radius = data.radius(1:length(data.radius) - 1);

         xb(length(xb)+1) = xb(length(xb));
         yb(length(yb)+1) = yb(length(yb));

         data.properties.currentdisc = 1;
         set(findobj('Tag','radius'),'String',num2str(data.radius(data.properties.currentdisc)));
         Disc_area = pi*(data.radius(data.properties.currentdisc))^2;
         set(findobj('Tag','area'),'String',num2str(Disc_area));
         set(findobj('Tag','disc'),'String',num2str(data.properties.currentdisc));
         set(findobj('Tag','radimp'),'Value',data.properties.radimp);
         set(linehandle,'XData',xb);
         set(linehandle,'YData',yb);
         %   vowelname = get(Hndl.VOWEL, 'string');
         %   index = get(Hndl.VOWEL, 'value');
         %   if index == 11
         %      %        set(get(Hndl.TractMod.areafunc, 'Title'),'String', '');
         %      vowelname = vowelname(get(Hndl.VOWEL, 'value'), 8:9);
         %    else
         %      %        set(get(Hndl.TractMod.areafunc, 'Title'),'String', '');
         %      vowelname = vowelname(get(Hndl.VOWEL, 'value'), 2:3);
         %    end;
         %    TitleStr = ['Vocal tract for vowel ' strrep(vowelname, '_', '\_')];
         %    set(get(Hndl.TractMod.areafunc, 'Title'),'String', TitleStr);
         %    figure(Hndl.ModTractFig)
         %    Title(TitleStr);
         data.radius = data.radius/1000;
         data.spacing = data.spacing/1000;
         set(Hndl.figureNumber, 'UserData',data);
         drawnow;
      else
         if Mode == 2
            set(findobj('Tag','radius'),'Enable','off');
            set(findobj('Tag','area'),'Enable','off');
            set(findobj('Tag','disc'),'Enable','off');
            set(findobj('Tag','Damping'),'String',num2str(data.properties.damping));
            set(findobj('Tag','maxdevlimit'),'Enable','on');
            set(findobj('Tag','maxsegments'),'Enable','on');
            set(findobj('Tag','devlimit'),'Enable','inactive');
            set(findobj('Tag','maxdevlimit'),'String',num2str(data.properties.maxdevlimit));
            set(findobj('Tag','segments'),'Enable','inactive');
            set(findobj('Tag','maxsegments'),'String',num2str(data.properties.maxsegments));
            %tempcolormap = [.49,1,.83 ; 1,0,0 ; 0,1,0 ; 1,1,0 ; 1,0,1 ; 0,1,1];
            areas3('tubecalc');
            data = get(Hndl.figureNumber, 'UserData');

            data.properties.currentdisc = 1;
            data.radius = data.radius*1000;
            data.spacing = data.spacing*1000;
            data.radius(length(data.radius) + 1) = data.radius(length(data.radius));
            x_vector = [0:1:length(data.radius)-1]*data.spacing;
            [xb,yb] = stairs(x_vector,data.radius);
            data.radius = data.radius(1:length(data.radius) - 1);

            set(findobj('Tag','radius'),'String',num2str(data.radius(data.properties.currentdisc)));
            Disc_area = pi*(data.radius(data.properties.currentdisc))^2;
            set(findobj('Tag','area'),'String',num2str(Disc_area));
            set(findobj('Tag','disc'),'String',num2str(data.properties.currentdisc));
            set(linehandle,'XData',xb);
            set(linehandle,'YData',yb);
            data.radius = data.radius/1000;
            data.spacing = data.spacing/1000;

            delete(findobj('linestyle',':'));
            set(findobj('Tag','tube'),'linestyle',':');
            if data.properties.color == 1
               linecolor = 'g';
               data.properties.color = 2;
            elseif data.properties.color == 2
               linecolor = 'r';
               data.properties.color = 1;
            end;

            set(findobj('Tag','devlimit'),'String',num2str(data.properties.outdevlimit));
            set(findobj('Tag','segments'),'String',num2str(data.properties.outsegments));
            set(findobj('Tag','radimp'),'Value',data.properties.radimp);
            data.tubes = 1000 * data.tubes;
            X1 = 0;
            for i = 1: size(data.tubes,1)
               X2 = X1 + data.tubes(i,1);
               line_handle = line([X1,X2],[data.tubes(i,2),data.tubes(i,3)],'Color',linecolor);
               set(line_handle,'Tag','tube');
               set(line_handle,'HitTest','off');
               X1 = X2;
            end;
            legend(line_handle,'last','Location','northwest');   % numeric location 2 is an error now
            set(Hndl.figureNumber, 'UserData',data);
         end;
      end;  % of Mode callback
      YData = get(linehandle,'YData');
      XData = get(linehandle,'XData');   % xb is not computed in File mode
      set(Hndl.TractMod.areafunc, 'YLim', [0 max(YData)+1]);
      set(Hndl.TractMod.areafunc, 'XLim', [0 max(XData)]);
      if Mode ~= 4
         set(get(Hndl.TractMod.areafunc, 'Title'),'String', TitleStr);
      end


      %=========================================================================
      % Maxdevlimit callback
   case 'maxdevlimit'
      data = get(Hndl.figureNumber, 'Userdata');
      data.properties.maxdevlimit = str2num(get(gcbo,'String'));
      set(Hndl.figureNumber, 'Userdata',data);
      areas3('refresh');


      %========================================================================
      % Maxsegments callback
   case 'maxsegments'
      data = get(Hndl.figureNumber, 'Userdata');
      data.properties.maxsegments = str2num(get(gcbo,'String'));
      set(Hndl.figureNumber, 'Userdata',data);
      areas3('refresh');


      %==========================================================================
      % Damping Callback
   case 'damping'
      data = get(Hndl.figureNumber, 'UserData');
      data.properties.damping = str2num(get(gcbo,'String'));
      set(Hndl.figureNumber, 'UserData',data);
      % END of Damping Callback


      %==========================================================================
      % Radiation impedance Callback
   case 'radimp'
      data=get(Hndl.figureNumber, 'UserData');
      data.properties.radimp = get(gcbo,'Value');
      set(Hndl.figureNumber, 'Userdata',data);
      areas3('refresh');
      % END of radimp Callback
      %==========================================================================


      %==========================================================================
      % Import Callback
   case 'import'
      % no fixed start folder (was cd('c:\bcd'), which exists on no current machine)
      [filename, filepath] = uigetfile('*.ror',['choose an area-data-file?']);
      if ischar(filename)
         BATCH = 1;
         set(Hndl.batch,'Value',1);
         set(Hndl.batch,'enable','off');
         controlfig = openfig('control_file_gui','reuse');
         Hndl.controlfig = controlfig;
         rb_trac = findobj(Hndl.controlfig,'Tag','rb_trac');
         set(rb_trac,'Enable','off');
         set(rb_trac,'Value',1);
         set(get(Hndl.TractMod.areafunc, 'Title'),'String',strrep(['imported radius-data from:' filename],'_','\_'));
         data   = get(Hndl.figureNumber,'UserData');
         IMPORT = 1;
         batch  = data.batch;
         batch.import = 1;
         batch.tract  = 0;
         batch.subpre = 0;
         batch.actstr = 0;
         data.Fs = get(Hndl.Fs,'Value');
         TMAX    = get(Hndl.Duration,'Value');
         [data.importradius,data.importspacing,TMAX,data.Fs,phonsamples] = rorread([filepath,filename]);
         set(Hndl.Fs,'Value',data.Fs);
         set(Hndl.FsStr,'String',num2str(data.Fs));
         set(Hndl.Duration','Value',TMAX);
         set(Hndl.DurationStr','String',num2str(TMAX));
         set(Hndl.Duration','Enable','off');
         set(Hndl.DurationStr','Enable','off');
         data.radius = data.importradius(1,:);
         data.batch = batch;
         data.phonsamples = phonsamples;
         set(Hndl.figureNumber,'UserData',data);
         controlfile('refresh');
      end



      % END of import callback
      %==========================================================================


      %==========================================================================
      % Defaults Callback
   case 'defaults'
      data=get(Hndl.figureNumber, 'UserData');
      datainit(MAXSEGMENTS,MAXDEVLIMIT, ...
         XI, Xi0, radimproutine);	% initialize data struct
      areas3('refresh');
      TMAX = 10;
      vox('refreshDuration','strsli');
      % END of Damping Callback


   case 'done'
      data=get(Hndl.figureNumber, 'UserData');
      length_fii = size(data.radius,1);
      linehandle = AREA_DAT(1);
      YData = get(linehandle,'YData');

      data.radius = data.radius*1000;
      data.spacing = data.spacing*1000;
      data.radius = zeros(length_fii,1);
      for i = 1:length_fii
         data.radius(i) = YData(2*i-1);
      end;

      %  newfii = data;
      %  set(Hndl.figureNumber, 'UserData',newfii);
      data.radius = data.radius/1000;
      data.spacing = data.spacing/1000;
      set(Hndl.figureNumber, 'UserData',data);
      close(Hndl.ModTractFig);
end;