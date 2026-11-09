% this does something for parametermode...
function [control1, control2, control3, timevector] = controlfile(callback, n_samples, var, Fs, modvar);

global Hndl PARA TMAX


if nargin < 1
   callback = 'initialize';
end;


controlfig      = openfig('control_file_gui','reuse');
Hndl.controlfig = controlfig;
handles         = guihandles(controlfig);
% unused GUIDE leftover "Edit Text": its callback calls control_file_gui.m,
% which does not exist, so any input there raised an error
set(handles.edit1, 'Callback', '', 'Visible', 'off');
weg = 0;


switch callback

   case 'initialize'
      %===========================================================================================================================

      set(controlfig,'visible','on');
      openfig('control_file_gui','reuse');
      controlfile('refresh');

      
      % set pos of window
      dockwindowPosSize = get(Hndl.figureNumber, 'Position');
      aktPosSize        = get(Hndl.controlfig, 'Position');
      newPosSize        = [dockwindowPosSize(1)+dockwindowPosSize(3)+0.005, dockwindowPosSize(2), aktPosSize(3), dockwindowPosSize(4)];
      set(Hndl.controlfig, 'Position', newPosSize);
   case 'refresh'
      %===========================================================================================================================

      data = get(Hndl.figureNumber,'UserData');
      batch = data.batch;
      try
         if batch.periodic == 1
            set(handles.rb_periodic,'Value',1);
            controlfile('periodic');
            set(handles.sl_freq,'Value',batch.modFreq);
            controlfile('sl_freq');
            set(handles.sl_depth,'Value',batch.modDepth);
            controlfile('sl_depth');
            set(handles.sl_seg1,'Value',batch.seg1);
            controlfile('sl_seg1');
         end
      end
      try
         if batch.linramp == 1
            set(handles.rb_linramp,'Value',1);
            controlfile('linramp');
            set(handles.sl_start,'Value',batch.start);
            controlfile('sl_start');
            set(handles.sl_stop,'Value',batch.stop);
            controlfile('sl_stop');
            set(handles.sl_seg2,'Value',batch.seg2);
            controlfile('sl_seg2');
         end
      end
      if batch.periodic == 0 & batch.linramp == 0
         set(handles.rb_linramp,'Value',0);
         controlfile('linramp');
         set(handles.rb_periodic,'Value',0);
         controlfile('periodic');
      end
      if batch.actstr == 1
         set(handles.rb_actstr,'Value',1);
      end
      if batch.subpre == 1
         set(handles.rb_subpre,'Value',1);
      end
      try
         if batch.shift == 1
            set(handles.rb_shift,'value',1);
            set(findobj(controlfig,'UserData',76),'enable','on');
            set(handles.sl_shift,'Value',batch.shiftvalue);
            controlfile('sl_shift');
         end
      end


   case 'sl_freq'
      %===========================================================================================================================
      value = get(handles.sl_freq,'Value');
      set(handles.ed_freq,'String',value);

   case 'sl_depth'
      %===========================================================================================================================
      value = get(handles.sl_depth,'Value');
      set(handles.ed_depth,'String',value);

   case 'sl_seg1'
      %===========================================================================================================================
      value = get(handles.sl_seg1,'Value');
      set(handles.ed_seg1,'String',value);

   case 'ed_freq'
      %===========================================================================================================================
      value = get(handles.ed_freq,'String');
      set(handles.sl_freq,'Value',str2num(value));

   case 'ed_depth'
      %===========================================================================================================================
      value = get(handles.ed_depth,'String');
      set(handles.sl_depth,'Value',str2num(value));

   case 'ed_seg1'
      %===========================================================================================================================
      value = get(handles.ed_seg1,'String');
      set(handles.sl_seg1,'Value',str2num(value));



   case 'sl_start'
      %===========================================================================================================================
      value = get(handles.sl_start,'Value');
      set(handles.ed_start,'String',value);

   case 'sl_stop'
      %===========================================================================================================================
      value = get(handles.sl_stop,'Value');
      set(handles.ed_stop,'String',value);

   case 'sl_seg2'
      %===========================================================================================================================
      value = get(handles.sl_seg2,'Value');
      set(handles.ed_seg2,'String',value);

   case 'ed_start'
      %===========================================================================================================================
      value = get(handles.ed_start,'String');
      set(handles.sl_start,'Value',str2num(value));

   case 'ed_stop'
      %===========================================================================================================================
      value = get(handles.ed_stop,'String');
      set(handles.sl_stop,'Value',str2num(value));

   case 'ed_seg2'
      %===========================================================================================================================
      value = get(handles.ed_seg2,'String');
      set(handles.sl_seg2,'Value',str2num(value));



   case 'sl_shift'
      %===========================================================================================================================
      value = get(handles.sl_shift,'Value');
      set(handles.ed_shift,'String',value);

   case 'ed_shift'
      %===========================================================================================================================
      value = get(handles.ed_shift,'String');
      set(handles.sl_shift,'Value',str2num(value));


   case 'shift'
      %===========================================================================================================================

      shift = get(handles.rb_shift,'Value');
      if shift
         set(findobj(controlfig,'UserData',76),'enable','on');
      elseif get(handles.rb_periodic,'Value') | get(handles.rb_linramp,'Value')
         set(findobj(controlfig,'UserData',76),'enable','off');
      else
         set(handles.rb_shift,'Value',1);
         set(findobj(controlfig,'UserData',76),'enable','on');
      end



   case 'periodic'
      %===========================================================================================================================


      value = get(handles.rb_periodic,'Value');
      if value == 1
         set(findobj(controlfig,'UserData',1),'enable','on');
         set(handles.rb_linramp,'Value',0);
         set(findobj(controlfig,'UserData',2),'enable','off');
      elseif value == 0
         set(findobj(controlfig,'UserData',1),'enable','off');
         if get(handles.rb_periodic,'Value') == 0
            set(handles.rb_shift,'Value',1);
            set(findobj(controlfig,'UserData',76),'enable','on');
         end
      end


   case 'linramp'
      %===========================================================================================================================

      value = get(handles.rb_linramp,'Value');
      if value == 1
         set(findobj(controlfig,'UserData',2),'enable','on');
         set(handles.rb_periodic,'Value',0);
         set(findobj(controlfig,'UserData',1),'enable','off');
      elseif value == 0
         set(findobj(controlfig,'UserData',2),'enable','off');
         if get(handles.rb_periodic,'Value') == 0
            set(handles.rb_shift,'Value',1);
            set(findobj(controlfig,'UserData',76),'enable','on');
         end
      end



   case 'close'
      %===========================================================================================================================
      delete(controlfig);
      weg = 1;


   case 'call'
      %===========================================================================================================================

      data     = [];
      data     = get(Hndl.figureNumber,'UserData');
      batch    = data.batch;
      actstr   = batch.actstr;
      subpre   = batch.subpre;
      trac     = batch.trac;
      import   = batch.import;
      areadata = batch.areadata;


      periodic = batch.periodic;
      linramp  = batch.linramp;
      segments = 0;

      if actstr == 1
         oldStr1      = 'Infold.tvakt';
         modfunction1 = ['vox(''refreshtvakt'',''strsli'');'];	% function to be modified (Graphic)
         oldValue1	  = modvar.actstr;
      end

      if subpre == 1
         oldStr2      = 'Infold.ptg';
         modfunction2 = ['vox(''refreshptg'',''strsli'');'];	% function to be modified ( graphic)
         oldValue2	  = modvar.subpre;
      end

      if trac == 1
         oldStr3   = 'data.radius';
         oldValue3 = modvar.radius(1:10);
         if import == 1
            oldStr3    = 'areadata';
         end
      end

      if periodic == 1
         modFreq = batch.modFreq;
         modDepth = batch.modDepth;
         segments = ceil(modFreq*batch.seg1*n_samples/Fs);
         % preparation of function vectors
      end

      if linramp == 1
         start = batch.start;
         stop = batch.stop;
         segments = batch.seg2;
         % preparation of function vectors
      end

      if linramp == 0 & periodic == 0
         segments = TMAX/2;
      end

      %	generates time vector with equally spaced segments from t=0 to t=Duration [ms]
      %    timevector=linspace(0, n_samples/Fs*1000, segments+1);
      timevector = linspace(0, n_samples/Fs*1000, segments);
      shift      = get(handles.rb_shift,'Value');
      shiftvalue = str2num(get(handles.ed_shift,'string'))/100;
      offset1    = 0;
      offset2    = 0;
      offset3    = 0;

      control1		=	'';
      control2		=	'';
      control3		=	'';

      modDepth1 = batch.modDepth;
      modFreq1  = batch.modFreq;
      modDepth2 = batch.modDepth;
      modFreq2  = batch.modFreq;
      modDepth3 = batch.modDepth;
      modFreq3  = batch.modFreq;

      for localIndex=1:segments
         if periodic == 1
            % sine-like variation of value
            if actstr == 1
               % random shift
               if shift
                  % modDepth
                  randnum1    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modDepth1 - modDepth1*(1+randnum1*shiftvalue);
                  modDepth1   = modDepth1 + shiftradius;
                  %Frequenz
                  randnum2    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modFreq1 - modFreq1*(1+randnum2*shiftvalue/10);
                  modFreq1    = modFreq1 + shiftradius;
                  %offset
                  randnum3 = rand(1,1)*(-1)^round(rand(1,1)*10);
                  offset1  = offset1 + randnum3*shiftvalue/15;
               end
               newValue1(localIndex) 	=  offset1 + oldValue1*(1+modDepth1/100*sin(2*pi*modFreq1*timevector(localIndex)/1000));

               if newValue1(localIndex) < 0
                  newValue1(localIndex) = 0;
               end
               %controlstring
               control1 = strvcat(control1, [oldStr1 '=' num2str(newValue1(localIndex)) ';' modfunction1]);
            else
               control1 = strvcat(control1, '0;');
            end
            if subpre == 1
               %random shift
               if shift
                  %moddepth
                  randnum1    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modDepth2 - modDepth2*(1+randnum1*shiftvalue);
                  modDepth2   = modDepth2 + shiftradius;
                  %Frequenz
                  randnum2    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modFreq2 - modFreq2*(1+randnum2*shiftvalue/10);
                  modFreq2    = modFreq2 + shiftradius;
                  %offset
                  randnum3 = rand(1,1)*(-1)^round(rand(1,1)*10);
                  offset2  = offset2 + randnum3*shiftvalue/15;
               end
               newValue2(localIndex) 	= offset2 + oldValue2*(1+modDepth2/100*sin(2*pi*modFreq2*timevector(localIndex)/1000));
               if newValue2(localIndex) < 0
                  newValue2(localIndex) = 0;
               end
               %controlstring
               control2 = strvcat(control2, [oldStr2 '=' num2str(newValue2(localIndex)) ';' modfunction2]);
            else
               control2 = strvcat(control2, '0;');
            end
            if trac == 1
               %random shift
               if shift
                  %modDepth
                  randnum1    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modDepth3 - modDepth3*(1+randnum1*shiftvalue);
                  modDepth3   = modDepth3 + shiftradius;
                  %Frequenz
                  randnum2    = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = modFreq3 - modFreq3*(1+randnum2*shiftvalue/10);
                  modFreq3    = modFreq3 + shiftradius;
                  %offset
                  randnum3 = rand(1,1)*(-1)^round(rand(1,1)*10);
                  offset3  = offset3 + randnum3*shiftvalue/10;
               end
               for i = 1:10
                  newValue3(localIndex,i) 	= oldValue3(i)*(1+modDepth3/100*sin(2*pi*modFreq3*timevector(localIndex)/1000));
                  if newValue3(localIndex,i) < 0
                     newValue3(localIndex,i) = 0.00001;
                  end
               end
               %controlstring
               for j = 11:(length(modvar.radius))
                  newValue3(localIndex,j) = modvar.radius(j);
               end
               control3 = strvcat(control3, [oldStr3 '=[' num2str(newValue3(localIndex,1:size(newValue3,2))) '];']);
            else
               control3 = strvcat(control3, '0;');
            end  %elseif
         end  %if periodic


         if linramp == 1
            % linear increase of value
            if actstr == 1
               newValue1(localIndex) 	= oldValue1*(1*start/100+(stop - start)/100*timevector(localIndex)/max(timevector));
               % random shift
               if shift
                  randnum = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = oldValue1 - oldValue1*(1+randnum*shiftvalue);
                  newValue1(localIndex) = newValue1(localIndex) + shiftradius;
               end
               if newValue1(localIndex) < 0
                  newValue1(localIndex) = 0;
               end
               %controlstring
               control1 = strvcat(control1, [oldStr1 '=' num2str(newValue1(localIndex)) ';' modfunction1]);
            else
               control1 = strvcat(control1, '0;');
            end
            if subpre == 1
               newValue2(localIndex) 	= oldValue2*(1*start/100+(stop - start)/100*timevector(localIndex)/max(timevector));
               %random shift
               if shift
                  randnum     = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = oldValue2 - oldValue2*(1+randnum*shiftvalue);
                  newValue2(localIndex) = newValue2(localIndex) + shiftradius;
               end
               if newValue2(localIndex) < 0
                  newValue2(localIndex) = 0;
               end
               %controlstring
               control2 = strvcat(control2, [oldStr2 '=' num2str(newValue2(localIndex)) ';' modfunction2]);
            else
               control2 = strvcat(control2, '0;');
            end
            if trac == 1
               for i = 1:10
                  newValue3(localIndex,i) 	= oldValue3(i)*(1*start/100+(stop - start)/100*timevector(localIndex)/max(timevector));
               end
               %random shift
               if shift
                  randnum     = rand(1,1)*(-1)^round(rand(1,1)*10);
                  shiftradius = oldValue3 - oldValue3*(1+randnum*shiftvalue);
                  newValue3(localIndex) = newValue3(localIndex) + shiftradius;
               end
               if newValue3(localIndex) < 0
                  newValue3(localIndex) = 0;
               end
               %controlstring
               for j = 11:(length(modvar.radius))
                  newValue3(localIndex,j) = modvar.radius(j);
               end
               control3 = strvcat(control3, [oldStr3 '=[' num2str(newValue3(localIndex,1:size(newValue3,2))) '];']);
            else
               control3 = strvcat(control3, '0;');
            end
         end  % if linramp


         if periodic == 0 & linramp == 0 & shift == 1
            if actstr
               newValue1(localIndex) = oldValue1;
               randnum1    = rand(1,1)*(-1)^round(rand(1,1)*10);
               shiftradius = oldValue1 - oldValue1*(1+randnum1*shiftvalue);
               newValue1(localIndex) = newValue1(localIndex) + shiftradius;
               if newValue1(localIndex) < 0
                  newValue1(localIndex) = 0;
               end
            end
            if subpre
               newValue2(localIndex) = oldValue2;
               randnum2    = rand(1,1)*(-1)^round(rand(1,1)*10);
               shiftradius = oldValue2 - oldValue2*(1+randnum2*shiftvalue);
               newValue2(localIndex) = newValue2(localIndex) + shiftradius;
               if newValue1(localIndex) < 0
                  newValue1(localIndex) = 0;
               end
            end
            if trac
               randnum3 = rand(1,1)*(-1)^round(rand(1,1)*10);
               for i = 1:10
                  newValue3(localIndex,i) 	= oldValue3(i);
                  shiftradius(i)            = oldValue3(i) - oldValue3(i)*(1+randnum3*shiftvalue);
                  newValue3(localIndex,i)   = newValue3(localIndex,i) + shiftradius(i);
               end
            end
         end
      end   %for segments

      if periodic == 0 & linramp == 0 & shift == 1
         if actstr
            newValue1(101:end+100) = newValue1(1:end);
            newValue1(1:100) = oldValue1;
            %lowpass
            newValue1 = filtern(newValue1,4,0,2,segments/(TMAX/1000),'low');
            newValue1(1:end-100)  = newValue1(101:end);
            newValue1(end-99:end) = '';
         end
         if subpre
            newValue2(101:end+100) = newValue2(1:end);
            newValue2(1:100)       = oldValue2;
            %lowpass
            newValue2 = filtern(newValue2,4,0,2,segments/(TMAX/1000),'low');
            newValue2(1:end-100)  = newValue2(101:end);
            newValue2(end-99:end) = '';
         end
         if trac
            for i = 1:10
               newValue3(101:size(newValue3,1)+100,i) = newValue3(1:size(newValue3,1),i);
               newValue3(1:100,i) = oldValue3(i);
               %lowpass
               newValue3(1:end,i) = filtern(newValue3(1:end,i),3,0,2,segments/(TMAX/1000),'low');
               newValue3(1:size(newValue3,1)-100,i) = newValue3(101:size(newValue3,1),i);
               for j = size(newValue3,1):-1:size(newValue3,1)-99
                  newValue3(j,:) = [];
               end
            end
         end

         for localIndex=1:segments
            for j = 11:(length(modvar.radius))
               newValue3(localIndex,j) = modvar.radius(j);
            end
            if actstr
               %controlstring
               control1 = strvcat(control1, [oldStr1 '=' num2str(newValue1(localIndex)) ';' modfunction1]);
            else
               control1 = strvcat(control1, '0;');
            end
            if subpre
               %controlstring
               control2 = strvcat(control2, [oldStr2 '=' num2str(newValue2(localIndex)) ';' modfunction2]);
            else
               control2 = strvcat(control2, '0;');
            end
            if trac
               %controlstring
               control3 = strvcat(control3, [oldStr3 '=[' num2str(newValue3(localIndex,1:size(newValue3,2))) '];']);
            else
               control3 = strvcat(control3, '0;');
            end
         end %for segments
      end

      %=======================================================================
      % imported radiusdata

      if import == 1
         oldstr3  = 'data.radius';
         control3 = strvcat(control3, '0;');;
      end


      %  plot changes
      if actstr
         figure(612);
         stairs(timevector(1:length(timevector)), newValue1);
         grid on; xlabel('Time [ms]');ylabel(oldStr1);
      end
      %  plot changes
      if subpre
         figure(613);
         stairs(timevector(1:length(timevector)), newValue2);
         grid on; xlabel('Time [ms]');ylabel(oldStr2);
      end
      %  plot changes
      if trac & import == 0
         figure(614);
         stairs(timevector(1:length(timevector)), newValue3(1:end,1:10));
         grid on; xlabel('Time [ms]');ylabel(oldStr3);
      end
end  %call callback
%===========================================================================================================================

if ~strcmp(callback,'call')&(~weg)

   % 'ok'
   %===========================================================================================================================

   data = get(Hndl.figureNumber,'UserData');
   batch = data.batch;

   if get(handles.rb_actstr,'Value') == 1
      %oldStr(1)  		= 'Infold.tvakt';	% varialble to be varied (activ Stress )
      batch.actstr = 1;
   else
      batch.actstr = 0;
   end

   if get(handles.rb_subpre,'Value') == 1
      %oldStr(2)  	= 'Infold.ptg';	% variable to be varied ( subgl. pressure )
      batch.subpre = 1;
   else
      batch.subpre = 0;
   end

   if get(handles.rb_trac,'Value') == 1
      %oldStr(3)  		= 'data.radius';	% variable to be varied ( radius )
      batch.trac   = 1;
   else
      batch.trac   = 0;
   end

   if get(handles.rb_periodic,'Value') == 1
      batch.periodic = 1;
      batch.modFreq = str2num(get(handles.ed_freq,'string'));
      batch.modDepth = str2num(get(handles.ed_depth,'string'));
      batch.seg1 = round(str2num(get(handles.ed_seg1,'string')));
   else
      batch.periodic = 0;
   end

   if get(handles.rb_linramp,'Value') == 1
      batch.linramp = 1;
      batch.start = str2num(get(handles.ed_start,'string'));
      batch.stop = str2num(get(handles.ed_stop,'string'));
      batch.seg2 = round(str2num(get(handles.ed_seg2,'string')));
   else
      batch.linramp = 0;
   end

   if get(handles.rb_periodic,'Value') == 0 & get(handles.rb_periodic,'Value') == 0
      batch.modDepth = 0;
      batch.modFreq = 0;
   end

   if get(handles.rb_shift,'Value') == 1
      batch.shift = 1;
      batch.shiftvalue = str2num(get(handles.ed_shift,'string'));
   else
      batch.shift = 0;
   end

   data.batch = batch;
   set(Hndl.figureNumber,'UserData',data);

end;