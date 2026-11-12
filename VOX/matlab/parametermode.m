function parametermode(callback, var)
% functions for the parametermode
%
% The parameter mode (button Para) keeps a list of profiles, each a
% complete set of VOX settings (voxprofile), in a parameter file
% para*.mat (variable datas) and calculates one combi result per profile.
% A profile may name a control file, which varies the subglottal pressure,
% the vocal fold tension, the mouth opening or the positions of the vocal
% folds during the calculation (voxcontrolread; e.g. a vibrato).
%
%   parametermode                 open the window
%   parametermode('new')          new parameter file (dialog)
%   parametermode('load')         open a parameter file, or choose a
%                                 control file (*.txt) for the next profile
%   parametermode('save')         add the current settings as a profile
%   parametermode('refresh')      set VOX to the profile chosen in the window
%   parametermode('start')        calculate all profiles of the file
%   parametermode('run', FILE)    the same for FILE, without dialogs (for
%                                 scripts and other programs)
%   parametermode('close')        close the window
%
% Every result is saved as out/para_<file>_<n>.mat (n = number of the
% profile) with the profile in data.profile. Before #74 "save" also
% calculated and stayed switched on for every later Combicalc, "start"
% calculated nothing for an ordinary parameter file, and the results of
% the profiles overwrote each other (docs/parametermode.md).

global profilenum filename parapath datas Hndl numstr PARA QUIT %#ok<GVMIS>

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
      parapath = voxoutdir;   % parameters.mat goes into out/ (#29)
      set(handles.ed_filepath,'String',parapath);
      filename = 'parameters.mat';
      datas = voxprofile();   % template for the structure (parameters.mat is not in the repository)


   case 'save'
      %===========================================================================================================================
      % store the current settings as the next profile; no calculation
      % (was: PROFILE = 1 and vox('combicalc'), which calculated and then
      % added a profile at every later Combicalc as well, #74)
      parametermode('getdata', voxprofile());



   case 'getdata'
      %===========================================================================================================================

      % the profile var into the parameter file

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
      [datas, var] = samefields(datas, var);   % profiles of older versions lack fields (control)
      datas(profilenum) = var;
      save(paramfile,'datas');
      numstr            = [numstr,profilenum];
      set(handles.pop_profilenum, 'string', numstr);
      set(handles.pop_profilenum, 'Value', profilenum);
      fprintf('parameter mode: profile %d stored in %s\n', profilenum, paramfile);

   case 'new'
      %===========================================================================================================================

      [newname, newpath] = uiputfile(voxoutdir('para*.mat'),['Welches mat-File soll es sein?']);   % starts in out/ (#29)
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

      [loadname, loadpath] = uigetfile({'*.mat;*.txt', 'parameter files (*.mat), control files (*.txt)'}, ...
         ['Welches mat-File soll es sein?'], voxoutdir);
      if isequal(loadname, 0)
         return   % cancelled
      end

      [~, ~, ext] = fileparts(loadname);
      if strcmpi(ext, '.txt')
         % a control file (old FE*.txt or with column names): choose it in
         % the main window; "save settings" then stores it with the next
         % profile (was: samplepara.mat from the folder of the file as the
         % only profile, #74)
         vox('setcontrol', fullfile(loadpath, loadname));
         fprintf('parameter mode: control file %s chosen; "save settings" adds it to the next profile\n', loadname);
         return
      end
      filename = loadname;
      parapath = loadpath;
      set(handles.ed_filename,'String',filename);
      set(handles.ed_filepath,'String',parapath);
      load(fullfile(parapath,filename), 'datas');
      dim = size(datas,2);
      numstr = 1:dim;
      set(handles.pop_profilenum,'String',numstr);
      set(handles.pop_profilenum,'Value',1);
      profilenum = 1;
      set(handles.bt_save,'enable','on');
      set(handles.pop_profilenum,'enable','on');
      set(handles.bt_start,'Enable','on');
      parametermode('refresh');


   case 'refresh'
      %===========================================================================================================================
      % set VOX to the chosen profile (all settings, voxapplyprofile)

      profilenum = get(handles.pop_profilenum, 'Value');
      if profilenum <= numel(datas)
         voxapplyprofile(datas(profilenum));
      end


   case {'start', 'run'}
      %===========================================================================================================================
      % calculate every profile and keep every result (#74)
      if strcmp(callback, 'run') && nargin >= 2 && ~isempty(var)
         [p, n, e] = fileparts(var);
         if isempty(p)
            p = pwd;
         end
         parapath = p;
         filename = [n e];
         set(handles.ed_filename,'String',filename);
         set(handles.ed_filepath,'String',parapath);
      else
         filename = get(handles.ed_filename,'String');
      end
      paramfile = fullfile(parapath, filename);
      S = load(paramfile, 'datas');
      datas = S.datas;
      [~, base] = fileparts(filename);
      results = {};
      PARA = 1;   % a series is running
      for i = 1:numel(datas)
         fprintf('parameter mode: profile %d of %d (%s)\n', i, numel(datas), filename);
         voxapplyprofile(datas(i));
         vox('combicalc');
         if QUIT
            disp('parameter mode: stopped (Quit)');
            break
         end
         data = get(Hndl.figureNumber, 'UserData');   % the result, shown by vox('input')
         data.profile  = datas(i);
         data.filename = sprintf('para_%s_%03d', base, i);
         save(voxoutdir(data.filename), 'data');
         results{end+1} = data.filename; %#ok<AGROW>
      end
      PARA = 0;
      fprintf('parameter mode: %d result(s) in %s: %s\n', numel(results), voxoutdir, strjoin(results, ', '));
      numstr = 1:numel(datas);
      set(handles.pop_profilenum,'String',numstr);


   case 'close'
      %===========================================================================================================================

      delete(paramfig);

end
end

function [a, b] = samefields(a, b)
% both structs with the union of their fields (missing ones empty), in the
% same order, so that b can be added to the struct array a
f = union(fieldnames(a), fieldnames(b), 'stable');
for k = 1:numel(f)
   if ~isfield(a, f{k})
      [a.(f{k})] = deal([]);
   end
   if ~isfield(b, f{k})
      b.(f{k}) = [];
   end
end
a = orderfields(a, f);
b = orderfields(b, f);
end
