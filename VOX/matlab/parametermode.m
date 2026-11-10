function parametermode(callback, var)
% functions for the parametermode
global PROFILE profilenum filename parapath datas Hndl numstr WORKDIR

if nargin < 1
   callback = 'initialize';
end;

openfig('parametermode_gui','reuse');
paramfig      = findobj('Name','Parametermode');
voxcolor(paramfig, 'light');   % the .fig stores light colours
Hndl.paramfig = paramfig;
handles       = guihandles(paramfig);



switch callback

   case 'initialize'
      %===========================================================================================================================

      openfig('parametermode_gui','reuse');
      set(paramfig,'Visible','on');
      paramfig      = findobj('Name','Parametermode');
      Hndl.paramfig = paramfig;
      handles       = guihandles(paramfig);
      profilenum    = 1;
      numstr        = [];
      set(handles.bt_start,'Enable','off');
      set(handles.pop_profilenum,'string','0');
      set(handles.pop_profilenum,'Value',profilenum);
      parapath = WORKDIR;
      set(handles.ed_filepath,'String',parapath);
      filename = 'parameters.mat';
      datas = voxprofile();   % template for the structure (parameters.mat is not in the repository)


   case 'save'
      %===========================================================================================================================
      PROFILE = 1;    % enable Profile Mode
      % call vox at line 1428 to get values
      
      % basti: is this right??? to start calc if save is pressed?
      vox('combicalc');



   case 'getdata'
      %===========================================================================================================================

      % called by vox

      if ~isempty(numstr)
         profilenum = numstr(end) + 1;
      else
         profilenum = 1;
      end
      paramfile = fullfile(parapath, filename);   % parapath may lack a trailing separator
      if isfile(paramfile)
         load(paramfile, 'datas');
      else
         datas = var([]);   % first profile of a new file: empty struct with the same fields
      end
      datas(profilenum) = var;
      save(paramfile,'datas');
      numstr            = [numstr,profilenum];
      set(handles.pop_profilenum, 'string', numstr);
      set(handles.pop_profilenum, 'Value', profilenum);

   case 'new'
      %===========================================================================================================================

      [newname, newpath] = uiputfile('para*.mat',['Welches mat-File soll es sein?']);
      if isequal(newname, 0)
         return   % cancelled: keep the current file (it was overwritten with the template before)
      end
      filename = newname;
      parapath = newpath;
      set(handles.ed_filename,'String',filename);
      set(handles.ed_filepath,'String',parapath);
      profilenum = 1;
      numstr     = [];
      set(handles.pop_profilenum,'String','0');
      set(handles.pop_profilenum,'Value',1);
      datas = voxprofile();   % template for the structure (was parameters.mat, not in the repository)
      save(fullfile(parapath,filename),'datas');   % delete datas
      set(handles.bt_save,'enable','on');
      set(handles.pop_profilenum,'enable','on');
      set(handles.bt_start,'Enable','on');

   case 'load'
      %===========================================================================================================================

      [loadname, loadpath] = uigetfile({'*.mat;*.txt', 'parameter files (*.mat, FE *.txt)'},['Welches mat-File soll es sein?']);
      if isequal(loadname, 0)
         return   % cancelled
      end
      filename = loadname;
      parapath = loadpath;
      set(handles.ed_filename,'String',filename);
      set(handles.ed_filepath,'String',parapath);
      
      if ischar(filename) && contains(filename,'FE')
         %       [time,w0lp(1),w0lp(2),w0lp(3)] = textread(filename,'%f %f %f %f',1,'k','whitespace','\r');
         %       [time,w0rp(1),w0rp(2),w0rp(3)] = textread(filename,'%f %f %f %f',1,'whitespace','\r');
         %       [time,wmaxla(1),wmaxla(2),wmaxla(3)] = textread(filename,'%f %f %f %f',1,'whitespace','\r');
         %       [time,wmaxra(1),wmaxra(2),wmaxra(3)] = textread(filename,'%f %f %f %f',1);

         %  [time,w0lp(1),w0lp(2),w0lp(3)...
         %      ,w0rp(1),w0rp(2),w0rp(3)...
         %  ,wmaxla(1),wmaxla(2),wmaxla(3)...
         %      ,wmaxra(1),wmaxra(2),wmaxra(3)] = textread(filename,'%f %f %f %f %f %f %f %f %f %f %f %f %f',1);


         load(fullfile(parapath,'samplepara.mat'));
         dim = size(datas,2);
         numstr = [];
         for i = 1:dim
            numstr = [numstr,i];
         end
         set(handles.pop_profilenum,'String',numstr);
         set(handles.pop_profilenum,'Value',1);
         profilenum = 1;
         set(handles.bt_save,'enable','on');
         set(handles.pop_profilenum,'enable','on');
         set(handles.bt_start,'Enable','on');
         parametermode('refresh');

      else
         load(fullfile(parapath,filename));
         dim = size(datas,2);
         numstr = [];
         for i = 1:dim
            numstr = [numstr,i];
         end
         set(handles.pop_profilenum,'String',numstr);
         set(handles.pop_profilenum,'Value',1);
         profilenum = 1;
         set(handles.bt_save,'enable','on');
         set(handles.pop_profilenum,'enable','on');
         set(handles.bt_start,'Enable','on');
         parametermode('refresh');
      end


   case 'refresh'
      %===========================================================================================================================

      profilenum = get(handles.pop_profilenum, 'Value');

      value = datas(profilenum).TMAX;
      set(Hndl.DurationStr, 'String', num2str(value));
      set(Hndl.Duration, 'value', value);

      value = datas(profilenum).Fs;
      set(Hndl.FsStr, 'String', num2str(value));
      set(Hndl.Fs, 'value', value);

      value = datas(profilenum).PTG;
      set(Hndl.ptgStr, 'String', num2str(value));
      set(Hndl.ptg, 'value', value);

      value = datas(profilenum).TVAKT;
      set(Hndl.tvaktStr, 'String', num2str(value));
      set(Hndl.tvakt, 'value', value);


      switch datas(profilenum).Infold.register
         case 0
         case 1
            set(Hndl.modal, 'value', 1);
            set(Hndl.head, 'value', 0);
            set(Hndl.falsett, 'value', 0);
            %		set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold, 'enable', 'on');
         case 2
            set(Hndl.modal, 'value', 0);
            set(Hndl.head, 'value', 1);
            set(Hndl.falsett, 'value', 0);
            %		set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold, 'enable', 'on');
         case 3
            set(Hndl.modal, 'value', 0);
            set(Hndl.head, 'value', 0);
            set(Hndl.falsett, 'value', 1);
            %		set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold, 'enable', 'on');
      end

      set(Hndl.ModFold,'Value',datas(profilenum).MODFOLD);
      if datas(profilenum).MODFOLD
         foldmod('initialize');
      else
         try
            close(Hndl.ModFoldFig);
         end
      end;

      % set(Hndl.gronf,'Value',datas.gronf);
      set(Hndl.VOWEL,'Value',datas(profilenum).vowel);
      set(Hndl.INPUT,'Value',datas(profilenum).iniinput);
      set(Hndl.VOWEL,'Value',datas(profilenum).vowel);
      set(Hndl.TractCalcMode,'Value',datas(profilenum).data.properties.mode);
      set(Hndl.trach,'Value',datas(profilenum).TRACH);
      set(Hndl.fold,'Value',datas(profilenum).FOLD);
      set(Hndl.tract,'Value',datas(profilenum).TRACT);
      set(Hndl.noise,'Value',datas(profilenum).NOISE);
      set(Hndl.batch,'Value',datas(profilenum).BATCH);

      set(Hndl.figureNumber,'UserData',datas(profilenum).data);
      if datas(profilenum).BATCH == 1
         controlfile('refresh');
      end


   case 'start'
      %===========================================================================================================================
      filename = get(handles.ed_filename,'String');
      clear datas;

      if ischar(filename) && contains(filename,'FE')
         load(fullfile(parapath,'samplepara.mat'));
      else
         load(fullfile(parapath,filename));
      end;

      dim = size(datas,2);
      set(paramfig,'Visible','off');
      Hndlold = Hndl;
      for i = 1:dim
         set(paramfig,'UserData',i)
         vox('initialize','parameterfile_var');
         %     try
         %        delete(Hndl.figureNumber);
         %     end
      end
      Hndl = Hndlold;
      set(paramfig,'Visible','on');


   case 'close'
      %===========================================================================================================================

      delete(paramfig);
      PARA = 0;

end