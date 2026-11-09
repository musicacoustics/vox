function vox(action, var)
% This function creates a graphic environment for input and output of
% simulation data of the human vocal tract and vocal fold.
%
% Inputs:
%    action - handle or action to do
%    var -
%
% Outputs:
%    none
%
% Example:
%    vox('initialze') - initializes the application
%
% Other m-files required: todo
% Subfunctions: todo
% MAT-files required: todo
%
% Author: Malte Kob, et al
% RWTH Aachen, Department of Phoniatrics, Pedaudiology and Communications Disorder
% email address: mkob@ukaachen.de
% Copyright (c) 1999-2001 Malte Kob
% $Revision: 1.98 $  $Date: 2001/07/10 12:11:25 $

global Fs rho c TMAX XI Xi0 CALC t      % general calc. constants
global Infold PARFOLD glotareadefault MAXM MAXMdefault MODAL HEAD FALSETT MODFOLD GRONF SURFS MOV VIBRO filename % fold calc.
global PARTRACT rvocdefault rtrachdefault MODTRACT TRACTDISP PARNOISE DAMPDB % tract calc.
global GRONT MAXSEGMENTS   MAXDEVLIMIT radimproutine       % tract calc.
global BATCH IMPORT TRACH FOLD TRACT NOISE QUIT BRK PARA PROFILE noisemovflag  % combi calc.
global S SD_NAMES SD_DISP SD_PLOTCMD BG fgstyle bgstyle % GUI
global FMAX GRON inx Hndl LASTPATH WORKDIR COF% GUI
global figdata%mo:Data crucial for (re)creating figures

if nargin < 1
    action = 'initialize';
end;

% show whats done for basti:
action;


switch action
    % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
    % initialize
    case 'initialize'

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Set all the initial variables values
        Fs        = 22050;% Sampling rate
        rho       = 1.293;% [kg/m^2] at 20°C
        c         = 350;  % [m/s] at 25°C
        TMAX      = 5000;    % Duration of signal [ms]
        XI        = 0.135;% Damping of wave propagation in ctim2
        Xi0       = 0.005135;   % constant for damping in tractsig
        GRONF     = 1;      % Flag for graphic display of fold results
        SURFS     = 1;      % Flag for Surf-Plot Creation
        MOV       = 0;      % Flag for movie generation (when GRONF == 1)
        VIBRO     = 0;      % Flag for Phonovibrogrammm
        MAXMdefault = 11;      % Maximum number of masses
        MODAL     = 1;    % Flag 1: switch to Modal register
        HEAD      = 0;    % Flag 1: switch to Head register
        FALSETT   = 0;     % Flag 1: switch to Falsetto register
        MODFOLD   = 0;     % Flag 1: switch to interactive VF design
        MODTRACT  = 0;     % Flag 1: switch to interactive VT design
        TRACH     = 0;    % Flag 0: without consideration of Trachaea pressure, 1: with
        FOLD      = 0;    % Flag 0: without consideration of Vocal Fold pressure, 1: with
        TRACT     = 0;    % Flag 0: without consideration of Vocal Tract pressure, 1: with
        NOISE     = 0;    % Flag 0: without consideration of Pulse Noise, 1: with
        noisemovflag = 0;% make noise movie
        DAMPDB   = 40;   % damping factor for exp. decay of noise
        CALC     = 0;      % Flag 1: calculation is running
        QUIT     = 0;    % Flag 1: exit from loops, do not save results
        BRK      = 0;    % Flag 1: exit from loops, save results
        GRON     = 0;    % Flag for graphic display of calculational results
        inx      = 1000; % index used for increment filename
        BG       = 0;     % Flag 1: load and display background data
        fgstyle  = 'k-';   % line style for foreground plot
        bgstyle  = 'g-';   % line style for background plot
        FMAX     = 5000; % floor(Fs/2);   % maximum for frequency representation
        BATCH    = 0;      % batch mode on (1) or off (0)
        PTG      = 800;  % initial subglottal pressure
        TVAKT    = 30;   % activ stress on vocalis
        PARA     = 0;    % parameter flag
        FEswitch = 0;
        IMPORT  = 0;    % imported vocaltract areadata flag
        PROFILE = 0;    % flag for parametermode
        glotareadefault = 3e-6; % 14 mm x .2 mm [m^2]; if NOT FOLD , this value is taken, otherwise minarea
        rvocdefault     = 4;  % VT entrance radius [mm]
        rtrachdefault   = 3;  % Trachea entrance radius [mm]
        GRONT      = 0;      % Flag for graphic display of tract results
        initractcalcmode = 1;   % default vocal tract calculation mode, 1:segments, 2:tubes
        radimproutine   = 1;  % old routine:1, piston routine:2
        TRACTDISP = 1;   % default vocal tract diplay mode, 1:transfer function, 2:input impedance
        popupStr = char('/ii/ (heed)','/_u/ (who)',...
            '/_a/ (hod)','/ea/ (head)','/ae/ (had)','/_o/ (hoe)',...
            '/uu/ (hood)','/aa/ (ton)' ,'/_i/ (hid)','/ao/ (paw)',...
            '/o1/ (oF6)' ,'/o2/ (oG6)','/o3/ (oA6)','/o4/ (oC7)',...
            '/i_/ (BJK)' ,'/e_/ (BJK)','/ä_/ (BJK)','/a_/ (BJK)',...
            '/o_/ (BJK)','/u_/ (BJK)','/cy/ (10mm)');
        vowel       = 3;      % default start vowel 3:/_a/, 8:/aa/
        filevalue   = 1;
        filename    = [];
        MAXSEGMENTS = 2;% default number of tube segments
        MAXDEVLIMIT = 0;% default number of tube segments
        iniinput    = 1;   % default input file 1: fold, 2: tract, 3: conv., 4: combi
        SD_NAMES    = [
            'out_vf_n10000  '
            'out_tt_a       '
            'out_ft_a10000  '
            'out_cs__10000  '
            'filename_mat   '
            'filename_wav   '
            'filename_dat   '
            'last_filename  '];
        SD_DISP    = 1;   % default displaymode 1:s(t),S(f), 2:Spectrogram, 3:P(t),S(f)
        SD_PLOTCMD = char(['plot_tuf'],['plot_spec'],['plot_puf']);

        % check working directory
        WORKDIR = fileparts(mfilename('fullpath')); % folder of vox.m (replaces voxpath.mat, works on every computer)
        cd(WORKDIR);
        if ~isfolder(fullfile(WORKDIR, 'out'))
            [state, msg] = mkdir(fullfile(WORKDIR, 'out')); % create subdirectory "out"
            if ~state
                error('Could not create subdirectory ''out'': %s', msg);
            end
        end
        % stay in WORKDIR: VOX is not on the MATLAB path and finds its
        % functions only from here
        LASTPATH = fullfile(WORKDIR, 'out');

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % for external forces
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =

        Infold.extForceF0inSamples = 0;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % für Parameterbetrieb
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        try
            if strcmp(var(1:4),'para')
                paramfig = findobj('Name','Parametermode');
                handles  = guihandles(paramfig);
                filename = get(handles.ed_filename,'String');
                parapath = get(handles.ed_filepath,'String');

                if findstr(filename,'FE') > 0  & filename ~=  0
                    parapath = pwd;
                    load([parapath,'\samplepara.mat']);
                else
                    load([parapath,filename]);
                end;
                i = get(paramfig,'Userdata');
                [data,Infold,PARA,BATCH,FOLD,TRACH,TRACT,NOISE,vowel,iniinput,TVAKT,PTG,TMAX,Fs,MAXSEGMENTS,...
                    MAXDEVLIMIT,XI,Xi0,MAXM,GRON] ...
                    = eval([var '(PARA,BATCH,FOLD,TRACH,TRACT,NOISE,vowel,iniinput,TVAKT,PTG,TMAX,Fs,' ...
                    'MAXSEGMENTS,MAXDEVLIMIT,XI,Xi0,MAXM,GRON,datas(i),i);']);
            end
        end

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % Initialize DATA
        if PARA
            PARA = 1;
        else
            Hndl = voxgui(Fs,TMAX,PTG,TVAKT,MODAL,HEAD,FALSETT,MODFOLD,MODTRACT,TRACH,FOLD, ...
                TRACT,NOISE,GRONF,SURFS,GRONT,popupStr,BG,FMAX,BATCH,initractcalcmode,TRACTDISP,vowel,filevalue,iniinput, ...
                SD_NAMES,SD_DISP,SD_PLOTCMD,GRON,FEswitch,MOV,VIBRO);
        end;

        if PARA
            set(Hndl.figureNumber,'Userdata',data);
        end
        if ~PARA
            iniinfold;   % Initialization of vocal fold paramter struct Infold.xxx
            %  data = [];
            %  [data.radius, data.spacing] = areadata(vowel);
            datainit(MAXSEGMENTS,MAXDEVLIMIT, ...
                XI,Xi0,radimproutine);   % initialize data struct
        end
        vox('refreshPopup')   % update vowel list and display data
        set(Hndl.figureNumber,'pointer','arrow');

        % END of INITIALIZE section
        if PARA
            vox('combicalc');
        end

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % LEFT FUNCTION CALLS
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =

        % RefreshDuration callback.
    case 'refreshDuration'
        if var == 'string'
            value = str2num(get(Hndl.DurationStr, 'string'));
            set(Hndl.Duration, 'value', value);
            TMAX = value;
        elseif var == 'slider'
            value = get(Hndl.Duration, 'value');
            set(Hndl.DurationStr, 'String', num2str(value));
            TMAX = value;
        elseif var == 'strsli'
            value = TMAX;
            set(Hndl.DurationStr, 'String', num2str(value));
            set(Hndl.Duration, 'value', value);
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % RefreshFs callback.
    case 'refreshFs'
        if var == 'string'
            value = str2num(get(Hndl.FsStr, 'string'));
            set(Hndl.Fs, 'value', value);
            Fs = value;
        elseif var == 'slider'
            value = get(Hndl.Fs, 'value');
            set(Hndl.FsStr, 'String', num2str(value));
            Fs = value;
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Refreshptg callback.
    case 'refreshptg'
        if var == 'string'
            value = str2num(get(Hndl.ptgStr, 'string'));
            set(Hndl.ptg, 'value', value);
            Infold.ptg = value;
        elseif var == 'slider'
            value = get(Hndl.ptg, 'value');
            set(Hndl.ptgStr, 'String', num2str(value));
            Infold.ptg = value;
        elseif var == 'strsli'
            value = Infold.ptg;
            set(Hndl.ptgStr, 'String', num2str(value));
            set(Hndl.ptg, 'value', value);
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Refreshtvakt callback.
    case 'refreshtvakt'
        if var == 'string'
            value = str2num(get(Hndl.tvaktStr, 'string'));
            set(Hndl.tvakt, 'value', value);
            Infold.tvakt = value;
        elseif var == 'slider'
            value = get(Hndl.tvakt, 'value');
            set(Hndl.tvaktStr, 'String', num2str(value));
            Infold.tvakt = value;
        elseif var == 'strsli'
            value = Infold.tvakt;
            set(Hndl.tvaktStr, 'String', num2str(value));
            set(Hndl.tvakt, 'value', value);
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Modal register callback.
    case 'modal'
        if get(Hndl.modal, 'value') ==  1;
            Infold.register = 1;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.head,     'value', 0);
            set(Hndl.falsett,  'value', 0);
            set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold,  'enable', 'on');
        else
            Infold.register = 0;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.head,     'value', 0);
            set(Hndl.falsett,  'value', 0);
            set(Hndl.FoldCalc, 'enable', 'off');
            set(Hndl.ModFold,  'enable', 'off');
        end;
        SD_NAMES(1,9) = num2str(Infold.register);
        if get(Hndl.INPUT,     'value') ==  3
            set(Hndl.INPUT,    'value', 3);
        elseif get(Hndl.INPUT, 'value') ==  4
            set(Hndl.INPUT,    'value', 4);
        else
            set(Hndl.INPUT,    'value', 1);
        end;
        if ~CALC
            vox('input');
        end
        % END of Modal callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Head register callback.
    case 'head'
        if get(Hndl.head, 'value') ==  1;
            set(Hndl.modal, 'value', 0);
            set(Hndl.falsett, 'value', 0);
            Infold.register = 2;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold, 'enable', 'on');
        else
            set(Hndl.modal, 'value', 0);
            set(Hndl.falsett, 'value', 0);
            Infold.register = 0;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.FoldCalc, 'enable', 'off');
            set(Hndl.ModFold, 'enable', 'off');
        end;
        SD_NAMES(1,9) = num2str(Infold.register);
        if get(Hndl.INPUT, 'value') ==  3
            set(Hndl.INPUT, 'value', 3);
        elseif get(Hndl.INPUT, 'value') ==  4
            set(Hndl.INPUT, 'value', 4);
        else
            set(Hndl.INPUT, 'value', 1);
        end;
        if ~CALC
            vox('input');
        end
        % END of head callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Falsetto register callback.
    case 'falsett'
        if get(Hndl.falsett, 'value') ==  1;
            set(Hndl.modal, 'value', 0);
            set(Hndl.head, 'value', 0);
            Infold.register = 3;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.FoldCalc, 'enable', 'on');
            set(Hndl.ModFold, 'enable', 'on');
        else
            set(Hndl.modal, 'value', 0);
            set(Hndl.head, 'value', 0);
            set(Hndl.falsett, 'value', 0);
            Infold.register = 0;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.FoldCalc, 'enable', 'off');
            set(Hndl.ModFold, 'enable', 'off');
        end;
        SD_NAMES(1,9) = num2str(Infold.register);
        if get(Hndl.INPUT, 'value') ==  3
            set(Hndl.INPUT, 'value', 3);
        elseif get(Hndl.INPUT, 'value') ==  4
            set(Hndl.INPUT, 'value', 4);
        else
            set(Hndl.INPUT, 'value', 1);
        end;
        if ~CALC
            vox('input');
        end
        % END of Modal callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % ModFold callback.
    case 'modfold'
        if get(Hndl.ModFold, 'value') ==  1;
            MODFOLD = 1;
            %    Hndl.ModFoldFig = figure('Units','normalized',...
            %      'Position',[.52 .38 .48 .55]);
            foldmod('initialize');
        else
            MODFOLD = 0;
            try
                close(Hndl.ModFoldFig);
            end
        end;
        % END of ModFold callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % FOLDLOAD callback.
    case 'foldload'
        %[filename, pathname] = uigetfile('out_vf*.mat', 'choose input fold file');
        [filename, pathname] = uigetfile('*.mat', 'choose input fold file');%mo
        if filename ~=  0
            value = 1;
            Infold.register = 0;      % 1: Modal, 2: Head, 3: Falsett
            set(Hndl.modal,   'value', 0);
            set(Hndl.head,    'value', 0);
            set(Hndl.falsett, 'value', 0);
            filename = filename(1:(length(filename)-4));
            load([pathname filename]);
            try
                data.y  = y(:)';
                data.Fs = Fs;
            end;
            try
                TMAX = data.Tmax;
                vox('refreshDuration','strsli');
            end
            data.filename = filename;
            data.pathname = pathname;
            Infold = data.Infold;%mo
            try
                figdata = data.figdata;%mo
                figdata.OldData = 1;
                displaycontforc;
                displayimpuls;
                set(Hndl.surfs,       'Enable', 'on')
                %figdata.OldData = 0;
            catch
                display('No figure data in file');
                try
                    close figure 60;
                end
                try
                    close figure 61;
                end
                try
                    close figure 80;
                end
                try
                    close figure 81;
                end
                figdata.OldData = 2;%mo: No data available
                 set(Hndl.surfs,       'Enable', 'off')
            end
            MAXM = Infold.maxm;%mo
            SD_NAMES(value,:) = ['out_vf_n00000  '];
            save('out_vf_n00000','data');
            set(Hndl.FoldCalc, 'enable', 'off');
            set(Hndl.INPUT, 'value', 1);
            vox('input');
            filename = ['out_vf_n' num2str(Infold.register) ...
                num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE)];
            save(filename, 'data');
            SD_NAMES(1,:) = [filename '  '];
            if get(Hndl.INPUT, 'value') ~=  3 % if not conv. view
                set(Hndl.INPUT, 'value', 1); % switch to fold view
            end;
           vox('input');
        end;
        % END of FOLDLOAD callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % FOLDSAVE callback.
    case 'foldsave'
        value = 1;
        MODAL = 0; HEAD = 0; FALSETT = 0;
        set(Hndl.modal,   'value', 0);
        set(Hndl.head,    'value', 0);
        set(Hndl.falsett, 'value', 0);
        initfilename = ['out_vf*.mat'];
        [filename, pathname] = uiputfile(initfilename, 'choose output fold file');
        if filename ~=  0
            data = get(Hndl.figureNumber,'UserData');
            data.filename = filename;
            data.pathname = pathname;
            data.figdata  = figdata;
            save([pathname filename], 'data')
            SD_NAMES(value,:) = ['out_vf_n00000  '];
            save('out_vf_n00000','data');
            set(Hndl.FoldCalc, 'enable', 'off');
            %    vox('input');
        end;
        % END of FOLDSAVE callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % FoldCalc callback.
    case 'foldcalc'
        CALC = 1;
        setenable(CALC)
        PARFOLD = [];
        Infold.calctime = TMAX/1000;
        Infold.k        = 1;
        Infold.maxm     = MAXM;
        Infold.asym     = 1; % indicate asymmetric model
        TRACT = 0;
        set(Hndl.tract, 'value', 0);
        Infold.flags.VOC = 0; % to be CHANGED?
        TRACH = 0;
        set(Hndl.trach, 'value', 0);
        Infold.flags.SUB = 0;
        Infold.pin_gl_ac = 0;    % "Load" of vocal folds by vocal tract, see above.
        Infold.ps_gl_ac  = 0;    % "Load" of vocal folds by lung

        % set Graphicflags ----------
        Infold.flags.GRON    = GRONF;
        Infold.flags.PMON    = 1;
        Infold.flags.ALONE   = 1;   % 1: standalone execution of loop

        % remember we are not in combimode
        Infold.combicalc = 0;

        % init movie for fold mode, combimovie shouldnt be inited here...
        if GRONF & MOV
            %dialog + set filename and pathname
            [fileName, pathName] = uiputfile('*.avi','Save .avi file');
            %avifiles   = dir('out/foldmov_*.avi');
            Hndl.movisgood  = -1;
            Hndl.foldmovfig = '';
            if ~ischar(fileName)
                %avi file creation canceled by user
                disp('movie file creation cancelled');
            else
                % no cd(pathName): VOX finds its functions only in WORKDIR
                avifiles   = dir(fullfile(pathName, 'foldmov_*.fig'));   % was dir('pathName'), always empty
                fanz       = size(avifiles, 1)+1;
                movnum     = sprintf('%03d', fanz);   % was named datetime, which hid the datetime function in vox
                %movfilenam = ['out/foldmov_' datetime '.avi'];
                movfilename = fullfile(pathName, fileName);
                % make movie file (avifile/addframe have been removed: VideoWriter)
                try
                    Hndl.mov = VideoWriter(movfilename, 'Motion JPEG AVI');
                    Hndl.mov.FrameRate = 20;
                    Hndl.mov.Quality   = 100;
                    open(Hndl.mov);
                    Hndl.movisgood = 1;
                catch err
                    disp(['could not init movie file: ' err.message]);
                end
                Hndl.foldmovfig = fullfile(pathName, ['foldmov_' movnum '.fig']);
            end
        end

        % (no access to the parameters from outside the function)
        QUIT = 0;
        [out_vf_voc, out_vf_trach, minarea, PARFOLD, figdata] = foldsig(PARFOLD);
        if QUIT ==  0
            filename = ['out_vf_n' num2str(Infold.register) ...
                num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE)];
            data.Fs       = Fs;
            data.Tmax     = size(out_vf_voc,2)*1000/Fs;
            data.y        = out_vf_voc;
            data.Infold   = Infold;
            data.figdata  = figdata;%mo
            data.filename = filename;
            save(filename, 'data');
            SD_NAMES(1,:) = [filename '  '];
            if get(Hndl.INPUT, 'value') ~=  3 % if not conv. view
                set(Hndl.INPUT, 'value', 1); % switch to fold view
            end;
            vox('input');%mo
        end;
        figdata.OldData = 1;
        CALC = 0;
        setenable(CALC)
        % END of FoldCalc callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % FOLDGRON callback.
    case 'gronf'
        if get(Hndl.gronf,'value') ==  0
            GRONF = 0;
            set( Hndl.makemovie, 'Enable','off')
            try
                %close(Hndl.ModFoldFig);
            end
        else
            GRONF = 1;
            set( Hndl.makemovie, 'Enable','on')
            % remember
        end


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % RefreshPopup callback.
    case 'refreshPopup'
        SD_NAMES(2,9:end) = ' ';
        vowel = get(Hndl.VOWEL,'value');
        data  = get(Hndl.figureNumber, 'UserData');
        vowelstring = get(Hndl.VOWEL, 'string');
        vowelname   = vowelstring(vowel, 2:3);
        [data.radius, data.spacing] = areadata(vowel);
        set(Hndl.figureNumber, 'UserData',data);
        if get(Hndl.ModTract,'value') ==  1
            data = get(Hndl.figureNumber, 'UserData');
            ModTractstr = vowelstring;
            data.properties.name = vowelname;
            data.properties.value = vowel;
            set(Hndl.figureNumber, 'UserData',data);
            areas3('refresh');
        end;
        set(Hndl.TractCalc, 'enable', 'on');
        SD_NAMES(2,7:8) = vowelname;
        if get(Hndl.ModTract,'value') ==  1         % modification on
            if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                SD_NAMES(2,1:6) = 'out_ms';                        % modified stairs
            elseif get(Hndl.TractCalcMode,'value') ==  2   % Tube segments
                SD_NAMES(2,1:6) = 'out_mt';                        % modified tubes
            elseif get(Hndl.TractCalcMode,'value') ==  3 % File
                if get(Hndl.TractDispMode,'value') ==  1   % mouth
                    modechar = 'fm';
                elseif get(Hndl.TractDispMode,'value') ==  2   % glottis
                    modechar = 'fg';
                end;
            end;
        else                                                      % modification off
            if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                SD_NAMES(2,1:6) = 'out_st';                     % stairs tract
            elseif get(Hndl.TractCalcMode,'value') ==  2   % Tube segments
                SD_NAMES(2,1:6) = 'out_tt';                        % modified tubes
            elseif get(Hndl.TractCalcMode,'value') ==  3 % File
                if get(Hndl.TractDispMode,'value') ==  1   % mouth
                    modechar = 'fm';
                elseif get(Hndl.TractDispMode,'value') ==  2   % glottis
                    modechar = 'fg';
                end;
            end;
        end

        value = get(Hndl.INPUT, 'value');
        if (value ~=  1)&(value ~=  2)&(value ~=  3)&(value ~=  4) % input = fold, tract, convoluted or combi?
            set(Hndl.INPUT, 'value', 2);                  % set to tract
        end;
        if ~CALC
            vox('input');
        end
        % END of RefreshPopup section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Modtract callback.
    case 'modtract'
        if get(Hndl.ModTract,'value') ==  1   % modification on
            MODTRACT = 1;
            data = get(Hndl.figureNumber, 'UserData');
            vowel = get(Hndl.VOWEL,'value');

            if voxfigflag('Design of VT area function',1) ==  0
                Scrsize   = get(0,'Screensize');
                Scrwidth  = Scrsize(3);
                Scrheight = Scrsize(4);
                Hndl.ModTractFig = figure('visible','on',...
                    'NumberTitle','off', ...
                    'Name','Design of VT area function',...
                    'Units','Normalized',...
                    'MenuBar', 'none', ...
                    'Position',[0 0 0.4 0.4]);
                %        'MenuBar', 'none', 'Position',[Scrwidth-420530 634 420 360]);
                areas3;   % initialize figure

                % set pos of window
                dockwindowPosSize = get(Hndl.figureNumber, 'Position');
                aktPosSize        = get(Hndl.ModTractFig, 'Position');
                newPMPosSize      = [dockwindowPosSize(1)+dockwindowPosSize(3)+0.005, dockwindowPosSize(2)-aktPosSize(4)-0.025, aktPosSize(3), aktPosSize(4)];
                set(Hndl.ModTractFig, 'Position', newPMPosSize);
            end
            if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                SD_NAMES(2,1:6) = 'out_ms';                     % modified stairs
                SD_NAMES(4,1:6) = 'outmcs';                     % modified calc
            elseif get(Hndl.TractCalcMode,'value') ==  2   % Tube segments
                SD_NAMES(2,1:6) = 'out_mt';                     % modified tubes
                SD_NAMES(4,1:6) = 'outmct';                     % modified calc
            elseif get(Hndl.TractCalcMode,'value') ==  3 % File
                if get(Hndl.TractDispMode,'value') ==  1   % mouth
                    modechar = 'fm';
                elseif get(Hndl.TractDispMode,'value') ==  2   % glottis
                    modechar = 'fg';
                end;
            end;
        else   % modification off
            MODTRACT = 0;
            if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                SD_NAMES(2,1:6) = 'out_st';                     % stairs tract
                SD_NAMES(4,1:6) = 'out_cs';                     % modified calc
            elseif get(Hndl.TractCalcMode,'value') ==  2   % Tube segments
                SD_NAMES(2,1:6) = 'out_tt';                     % modified tubes
                SD_NAMES(4,1:6) = 'out_ct';                     % modified calc
            elseif get(Hndl.TractCalcMode,'value') ==  3 % File
                if get(Hndl.TractDispMode,'value') ==  1   % mouth
                    modechar = 'fm';
                elseif get(Hndl.TractDispMode,'value') ==  2   % glottis
                    modechar = 'fg';
                end;
            end;
            if isfield(Hndl, 'ModTractFig') && ishghandle(Hndl.ModTractFig)   % window may have been closed by the user
                close(Hndl.ModTractFig);
            end
        end;
        if ~CALC
            vox('input');
        end


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Tract Calc Mode callback.
    case 'tractcalcmode'
        if get(Hndl.TractCalcMode,'value') < 3  % not File and not import
            SD_NAMES(2,9:end) = ' ';
            vowel = get(Hndl.VOWEL,'value');
            vowelstring = get(Hndl.VOWEL, 'string');
            vowelname = vowelstring(vowel, 2:3);
            SD_NAMES(2,7:8) = vowelname;
        end
        data = get(Hndl.figureNumber, 'UserData');
        if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
            data.properties.mode = 1;
            if get(Hndl.ModTract,'value') ==  1       % modified vowel
                SD_NAMES(2,1:6) = 'out_ms';                     % modified stairs
            else
                SD_NAMES(2,1:6) = 'out_st';                     % stairs tract
            end
            SD_NAMES(4,6) = 's';                           % mark stairs in combi calc
            try % if modtract window is open, refresh it
                set(Hndl.TractMod.Mode, ...
                    'Value', data.properties.mode);
                areas3('refresh');
            end;
            set(Hndl.TractDispMode,'String',char('FRF','Imp-m','Imp-g'));
            % 3 entries here, 4 in File mode: keep the selected display valid
            if TRACTDISP ==  2, TRACTDISP = 1; end   % FRF-glottis exists only in File mode
            dispentry = [1 1 2 3];                    % TRACTDISP -> entry
            set(Hndl.TractDispMode,'Value',dispentry(TRACTDISP));
        elseif get(Hndl.TractCalcMode,'value') ==  2 % Tube segments
            data.properties.mode = 2;
            if get(Hndl.ModTract,'value') ==  1       % modified vowel
                SD_NAMES(2,1:6) = 'out_mt';                     % modified tubes
            else
                SD_NAMES(2,1:6) = 'out_tt';                     % tube tract
            end
            SD_NAMES(4,6) = 't';                           % mark tubes in combi calc
            try % if modtract window is open, refresh it
                set(Hndl.TractMod.Mode, ...
                    'Value', data.properties.mode);
                areas3('refresh');
            end;
            set(Hndl.TractDispMode,'String',char('FRF  ','Imp-m','Imp-g'));
            % 3 entries here, 4 in File mode: keep the selected display valid
            if TRACTDISP ==  2, TRACTDISP = 1; end   % FRF-glottis exists only in File mode
            dispentry = [1 1 2 3];                    % TRACTDISP -> entry
            set(Hndl.TractDispMode,'Value',dispentry(TRACTDISP));

        elseif get(Hndl.TractCalcMode,'value') ==  3 % File
            data.properties.mode = 3;
            % 4 entries in File mode, entry = TRACTDISP (set before reading the value)
            set(Hndl.TractDispMode,'String',char('FRF-m','FRF-g','Imp-m','Imp-g'), ...
                'Value',TRACTDISP);
            if get(Hndl.TractDispMode,'value') ==  1   % FRF-mouth
                SD_NAMES(2,1:6) = 'out_fm';
            elseif get(Hndl.TractDispMode,'value') ==  2   % FRF-glottis
                SD_NAMES(2,1:6) = 'out_fg';
            end;
            if get(Hndl.TractDispMode,'value') ==  3   % Imp-mouth
                SD_NAMES(2,1:6) = 'outzfm';
            elseif get(Hndl.TractDispMode,'value') ==  4   % Imp-glottis
                SD_NAMES(2,1:6) = 'outzfg';
            end;
        elseif get(Hndl.TractCalcMode,'value') ==  4 % import
            data.properties.mode = 4;
            SD_NAMES(2,1:6) = 'out_im';
            set(Hndl.VOWEL,'Enable','off');
        end;
        set(Hndl.figureNumber, 'UserData',data);
        value = get(Hndl.INPUT, 'value');
        if (value ~=  2)&(value ~=  3)&(value ~=  4) % input = tract, convoluted or combi?
            set(Hndl.INPUT, 'value', 2);                  % set to tract
        end;
        vox('input');


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Tract Disp Mode callback.
    case 'tractdispmode'
        if get(Hndl.TractCalcMode,'value') ~=  3  % File
            SD_NAMES(2,9:end) = ' ';
            vowel = get(Hndl.VOWEL,'value');
            vowelstring = get(Hndl.VOWEL, 'string');
            vowelname = vowelstring(vowel, 2:3);
            SD_NAMES(2,7:8) = vowelname;
        end
        if get(Hndl.TractCalcMode,'value') ==  3  % File
            if get(Hndl.TractDispMode,'value') ==  1      % FRF-mouth
                TRACTDISP = 1;
                SD_NAMES(2,1:6) = 'out_fm';
            elseif get(Hndl.TractDispMode,'value') ==  2  % FRF-glottis
                TRACTDISP = 2;
                SD_NAMES(2,1:6) = 'out_fg';
            elseif get(Hndl.TractDispMode,'value') ==  3  % Imp-mouth
                TRACTDISP = 3;
                SD_NAMES(2,1:6) = 'outzfm';
            elseif get(Hndl.TractDispMode,'value') ==  4  % Imp-glottis
                TRACTDISP = 4;
                SD_NAMES(2,1:6) = 'outzfg';
            end
        else    % stairs or tubes
            if get(Hndl.TractDispMode,'value') ==  1      % FRF
                TRACTDISP = 1;
            elseif get(Hndl.TractDispMode,'value') ==  2  % Imp-mouth
                TRACTDISP = 3;
            elseif get(Hndl.TractDispMode,'value') ==  3  % Imp-glottis
                TRACTDISP = 4;
            end
        end
        vox('input');


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % TRACTLOAD callback.
    case 'tractload'
        data = get(Hndl.figureNumber, 'UserData');
        if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
            modechar = 'st';
        elseif get(Hndl.TractCalcMode,'value') ==  2 % Tubes
            modechar = 'tt';
        elseif get(Hndl.TractCalcMode,'value') ==  3 % File
            if TRACTDISP ==  1   % FRF-mouth
                modechar = '_fm';
            elseif TRACTDISP ==  2   % FRF-glottis
                modechar = '_fg';
            elseif TRACTDISP ==  3   % Imp-mouth
                modechar = 'zfm';
            elseif TRACTDISP ==  4   % Imp-glottis
                modechar = 'zfg';
            end;
        end;
        %cd('d:\projects\vox\out\');
        % do not change the working folder (VOX finds its functions only in
        % WORKDIR); start the dialog in out/ instead
        [filename, pathname] = uigetfile(fullfile(WORKDIR, 'out', ['out' modechar '*.mat']), 'choose input tract file');
        if ischar(filename)
            value = 2; % set 2 entry as file entry
            set(Hndl.TractCalcMode, 'Value', 3);
            filename = filename(1:(length(filename)-4));
            load(fullfile(pathname, filename));
            while length(filename) < 16
                filename(end+1) = ' ';
            end
            SD_NAMES(value,:) = [filename(1:15)];
            % vox('input') loads SD_NAMES(value,:) from the working folder
            save(deblank(SD_NAMES(value,:)), 'data');
            data.filename = filename;
            data.pathname = pathname;
            try
                TMAX = data.Tmax;
                vox('refreshDuration','strsli');
            end
            save(['out_' modechar 'fi'],'data');
            set(Hndl.TractCalc, 'enable', 'off');
            set(Hndl.INPUT, 'value', 2);
            vox('input');
        end;
        % END of TRACTLOAD callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % TRACTSAVE callback.
    case 'tractsave'
        %  value = 2;
        %  data = get(Hndl.figureNumber, 'UserData');
        %  set(Hndl.VOWEL, 'Value', 12);
        stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));   % datetime is a function, not text
        if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
            initfile = ['out_st' stamp '.mat'];
        else
            initfile = ['out_tt' stamp '.mat'];
        end;
        [filename, pathname] = uiputfile(initfile, 'choose output tract file');
        if filename ~=  0
            data = get(Hndl.figureNumber,'UserData');
            data.filename = filename;
            data.pathname = pathname;
            save([pathname filename], 'data')
            %    SD_NAMES(value,:) = ['out_vtfi' blanks(7)];
            %    save('out_vtfi','data');
            %    set(Hndl.TractCalc, 'enable', 'off');
            %    vox('input');
        end;
        % END of TRACTSAVE callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % TractCalc callback.
    case 'tractcalc'
        CALC = 1;
        setenable(CALC)
        ALONE = 1;
        QUIT = 0;
        data = get(Hndl.figureNumber, 'UserData');
        if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
            [data.Fs, data.y, data.z, data.out] = voctract(Fs, TMAX, data.properties.damping);
            data.Tmax = max(data.out.t)*1000;
        else
            areas3('tubecalc');
            data = get(Hndl.figureNumber, 'UserData');
            [data.y, data.z, PARCTIM] = ctim2(data.tubes, TMAX, data.properties.damping);
            data.out.t = PARCTIM.out.t;
            data.out.segments = PARCTIM.out.segments;
            data.out.h = PARCTIM.out.y;
            data.Fs = Fs;
            data.Tmax = max(data.out.t);
        end;
        if QUIT ==  0
            filename = get(Hndl.VOWEL, 'string');
            if get(Hndl.ModTract,'value') ==  1
                if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                    filename = ['out_ms', filename(get(Hndl.VOWEL, 'value'), 2:3)];
                else
                    filename = ['out_mt', filename(get(Hndl.VOWEL, 'value'), 2:3)];
                end
            else
                if get(Hndl.TractCalcMode,'value') ==  1   % Stair segments
                    filename = ['out_st', filename(get(Hndl.VOWEL, 'value'), 2:3)];
                else
                    filename = ['out_tt', filename(get(Hndl.VOWEL, 'value'), 2:3)];
                end;
            end;
            data.filename = filename;
            save(filename, 'data');
            SD_NAMES(2,:) = [filename blanks(7)];
            if get(Hndl.INPUT, 'value') ==  3
                set(Hndl.INPUT, 'value', 3);
            else
                set(Hndl.INPUT, 'value', 2);
            end;
            vox('input');
        end;
        CALC = 0;
        setenable(CALC)
        % END of tractcalc callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % TRACTGRON callback.
    case 'gront'   % 0: no graphics, 1: waterfall, 2: pressure vs tractlength
        GRONT = get(Hndl.gront,'value')-1;
        data  = get(Hndl.figureNumber, 'UserData');
        if GRONT ==  1
            try
                a = data.out;   % check if data.out exists
                Hndl.tractGrontFig = figure('Name', 'Waterfall',...
                    'Units', 'Normalized',...
                    'Position', [0.51 0.5 0.48 0.48]);
                waterfall(data.out.t, data.out.segments, data.out.h);
            catch
                warning('No graphics data available!')
            end
        elseif GRONT ==  2 % nothing?
        elseif GRONT ==  0 % close graphics window
            try
                close(Hndl.tractGrontFig);
            end
        end

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % RIGHT FUNCTION CALLS
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % Toback callback.
    case 'toback'
        if get(Hndl.toback, 'value') ==  1;
            BG = 1;
            bg = get(Hndl.figureNumber,'UserData');
            save('background', 'bg');
        else
            BG = 0;
            if ~CALC
                vox('input');
            end
        end;
        % END of toback callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % INPUT callback.
    case 'input'
        popStr    = get(Hndl.INPUT, 'String');
        value     = get(Hndl.INPUT, 'Value');
        selectStr = deblank(popStr(value,:));
        nfiles    = size(SD_NAMES,1);
        set(Hndl.figureNumber,'pointer','watch');
        data      = get(Hndl.figureNumber,'UserData');
        if value ==  1   % fold signal
            TRACH = 0; set(Hndl.trach,  'Value', 0)
            FOLD  = 0; set(Hndl.fold,   'Value', 0)
            TRACT = 0; set(Hndl.tract,   'Value', 0)
            NOISE = 0; set(Hndl.noise,   'Value', 0)
            SD_NAMES(value,:) = ['out_vf_n' num2str(Infold.register) ...
                num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) '  '];
            set(Hndl.FoldCalc,   'Enable', 'on')
            set(Hndl.TractCalc,  'Enable', 'off')
            set(Hndl.combi,      'Enable', 'off')
            set(Hndl.ctrl,       'Enable', 'off')
            set(Hndl.FE,         'Enable', 'off')
            set(Hndl.combiload,  'Enable', 'off')
            if voxfigflag('Design of VT area function',1)
                popupStr = char('stairs','tubes');
                set(Hndl.TractMod.Mode,'String',popupStr);
            end
        elseif value ==  2   % tract signal
            set(Hndl.FoldCalc,    'Enable', 'off')
            set(Hndl.TractCalc,   'Enable', 'on')
            set(Hndl.combi,       'Enable', 'off')
            set(Hndl.ctrl,        'Enable', 'off')
            set(Hndl.FE,          'Enable', 'off')
            set(Hndl.combiload,   'Enable', 'off')
            if voxfigflag('Design of VT area function',1)
                popupStr = char('stairs','tubes');
                set(Hndl.TractMod.Mode,'String',popupStr);
            end
        elseif value ==  3   % convoluted signal
            TRACH = 0; set(Hndl.trach,   'Value', 0)
            FOLD  = 0; set(Hndl.fold,    'Value', 0)
            TRACT = 0; set(Hndl.tract,   'Value', 0)
            NOISE = 0; set(Hndl.noise,   'Value', 0)
            set(Hndl.FoldCalc,    'Enable', 'on')
            set(Hndl.TractCalc,   'Enable', 'on')
            set(Hndl.combi,       'Enable', 'on')
            set(Hndl.ctrl,        'Enable', 'off')
            set(Hndl.FE,          'Enable', 'off')
            set(Hndl.combiload,   'Enable', 'off')
            if voxfigflag('Design of VT area function',1)
                popupStr = char('stairs','tubes');
                set(Hndl.TractMod.Mode,'String',popupStr);
            end
        elseif value ==  4   % combi signal
            if get(Hndl.FE, 'value') ==  1;
                SD_NAMES(value,5:15) = ['c' 'F' SD_NAMES(2,7:8) num2str(Infold.register) ...
                    num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) '  '];
            else
                if filename ~=  0
                    SD_NAMES(2,7:8) = filename(7:8);
                end
                SD_NAMES(value,5:15) = ['c' 's' SD_NAMES(2,7:8) num2str(Infold.register) ...
                    num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) '  '];
            end;
            set(Hndl.FoldCalc,    'Enable', 'off')
            set(Hndl.TractCalc,   'Enable', 'off')
            set(Hndl.combi,       'Enable', 'on')
            set(Hndl.ctrl,        'Enable', 'on')
            set(Hndl.FE,          'Enable', 'on')
            set(Hndl.combiload,   'Enable', 'on')

            if voxfigflag('Design of VT area function',1)
                popupStr = char('stairs','tubes','import');
                set(Hndl.TractMod.Mode,'String',popupStr);
            end
        else
            set(Hndl.FoldCalc,    'Enable', 'off')
            set(Hndl.TractCalc,   'Enable', 'off')
            set(Hndl.combi,       'Enable', 'off')
            set(Hndl.ctrl,        'Enable', 'off')
            if voxfigflag('Design of VT area function',1)
                popupStr = char('stairs','tubes');
                set(Hndl.TractMod.Mode,'String',popupStr);
            end
        end;

        % check for FE mode
        if findstr(filename,'FE') > 0 & filename ~=  0
            PARA = 1;
        elseif findstr(filename,'out_cF') > 0 & filename ~=  0
            PARA = 1;
        else
            PARA = 0;
        end;


        if ((value == 1)|(value == 2)|(value == 4))& ~PARA & ~IMPORT    % fold, tract or combi signal (only when PARA = 0)
            % Load file, if available. Otherwise, give empty plot and message in title
            if COF ==  1
                file = filename;
            else
                file = SD_NAMES(value,:);
                file(file ==  ' ') = []; % get rid of extra blanks in filename
            end;
            try
                Infile = load(file);
                try   % no data struct in file? (old data format)
                    data.Fs = Infile.Fs;
                    data.y  = Infile.y(:)';
                    disp('Old data format!');
                catch   % generate data struct
                    if (value ==  2)|(value ==  4)   % tract or combi file
                        data = Infile.data;
                    end
                    if get(Hndl.TractCalcMode,'value') ==  3 % File
                        % save the file with the standart name
                        if TRACTDISP ==  1   % FRF-mouth
                            modechar = '_fm';
                        elseif TRACTDISP ==  2   % FRF-glottis
                            modechar = '_fg';
                        elseif TRACTDISP ==  3   % Imp-mouth
                            modechar = 'zfm';
                        elseif TRACTDISP ==  4   % Imp-glottis
                            modechar = 'zfg';
                        end;
                        vowel = get(Hndl.VOWEL,'value');
                        vowelstring = get(Hndl.VOWEL, 'string');
                        vowelname = vowelstring(vowel, 2:3);
                        data.filename = ['out',modechar,vowelname];
                        path = [WORKDIR,'\out'];
                        save([path,'out',modechar,vowelname],'data');
                    end
                    if (value ==  1)|(value ==  4)   % fold or combi file
                        try
                            data.Infold = Infile.data.Infold;
                            data.filename = Infile.data.filename;
                        end
                    end;

                    try
                        data.batch = Infile.data.batch;
                    catch
                        if ~PARA
                            data = databatchinit(data);
                        end
                    end

                    data.Fs = Infile.data.Fs;
                    try
                        data.y  = Infile.data.y(:)';
                    end
                end
                try
                    data.properties.radimp = Infile.data.properties.radimp;
                catch
                    data.properties.radimp = radimproutine;
                end

                try
                    data.t = (0:length(data.y)-1)/data.Fs;
                end
                try
                    TMAX = data.Tmax;
                catch
                    try
                        data.Tmax = max(data.t)*1000;
                        TMAX = data.Tmax;
                    end
                end
                vox('refreshDuration','strsli');%mo
                if (get(Hndl.TractCalcMode,'value') ==  3)  % file
                    if (TRACTDISP ==  1 | TRACTDISP ==  2) % FRF - mouth
                        data.z = 0;    % only the y-vector is usefull
                    else
                        data.y = 0; % only the z-vector is usefull
                        data.t = (0:length(data.z)-1)/data.Fs;
                        data.Tmax = max(data.t)*1000;
                        TMAX = data.Tmax;
                    end
                end
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);  % call to plot_tuf,plot_puf or plot_spec
                try
                    title(['"', strrep(data.filename, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
                catch
                    title(['"', strrep(file, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
                end;
            catch % import did not workedit
                data.y = [-1 1 0 -1 0 1 -1];
                data.Fs = 1;
                data.z = [-1 1 0 -1 0 1 -1];
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                if ~PARA & ~IMPORT
                    datainit(MAXSEGMENTS,MAXDEVLIMIT, XI, Xi0,radimproutine);
                end
                data = get(Hndl.figureNumber,'UserData');
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['"' ,strrep(file, '_', '\_') '" not present - calc it?!']);
                COF = 0;
            end; % of try - catch
        elseif PARA
            if findstr(filename,'out_cF') > 0 & filename ~=  0
                file = filename;
            elseif get(Hndl.FE, 'value') ==  1;
                file = SD_NAMES(value,:);
                file(14) = '_';
                file(15:17) = filename(3:5);
                file(file ==  ' ') = []; % get rid of extra blanks in filename
            elseif findstr(filename,'FE') > 0 & filename ~=  0
                file = filename;
            end;
            try
                Infile = load(file);
                try   % no data struct in file? (old data format)
                    data.Fs = Infile.Fs;
                    data.y  = Infile.y(:)';
                    disp('Old data format!');
                catch   % generate data struct
                    if (value ==  2)|(value ==  4)   % tract or combi file
                        data = Infile.data;
                    end
                    if (value ==  1)|(value ==  4)   % fold or combi file
                        try
                            data.Infold = Infile.data.Infold;
                            data.filename = Infile.data.filename;
                        end
                    end;

                    try
                        data.batch = Infile.data.batch;
                    end
                    data.Fs = Infile.data.Fs;
                    try
                        data.y  = Infile.data.y(:)';
                    end
                end
                try
                    data.properties.radimp = Infile.data.properties.radimp;
                catch
                    data.properties.radimp = radimproutine;
                end

                try
                    data.t = (0:length(data.y)-1)/data.Fs;
                end
                try
                    TMAX = data.Tmax;
                catch
                    try
                        data.Tmax = max(data.t)*1000;
                        TMAX = data.Tmax;
                    end
                end
                vox('refreshDuration','strsli');%mo
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);  % call to plot_tuf,plot_puf or plot_spec
                try
                    title(['"', strrep(data.filename, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
                catch
                    title(['"', strrep(file, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
                end;


            catch % import did not workedit
                data.y = [-1 1 0 -1 0 1 -1];
                data.Fs = 1;
                data.z = [-1 1 0 -1 0 1 -1];
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                data = get(Hndl.figureNumber,'UserData');
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['"' strrep(file, '_', '\_') '" not present - calc it?!']);
                COF = 0;
            end; % of try - catch
            %     data.suffix = suffix;
            %     data.y = [-1 1 0 -1 0 1 -1];
            %     data.Fs = 1;
            %     data.t = (0:length(data.y)-1)/data.Fs;
            %     n = SD_DISP;
            %     eval([SD_PLOTCMD(n,:)]);
            %     !title('Parametermode!!');

        elseif IMPORT
            %data = get(Hndl.figureNumber,'UserData');
            data.y = [-1 1 0 -1 0 1 -1];
            data.Fs = 1;
            data.t = (0:length(data.y)-1)/data.Fs;
            n = SD_DISP;
            eval([SD_PLOTCMD(n,:)]);
            title('Imported Tract!!');
        end;

        if value ==  3 % calculate convoluted signal
            %      data = get(Hndl.figureNumber, 'UserData');
            % load vectors and sampling rates from mat-files
            SD_NAMES(1,:) = ['out_vf_n' num2str(Infold.register) ...
                num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) '  '];
            try % check sampling rates and decimate signal, if necessary.
                S_vf = load(deblank(SD_NAMES(1,:)));
                warning off
                try % test if data struct exists in Fold file
                    S_vf.y  = S_vf.data.y;
                    S_vf.Fs = S_vf.data.Fs;
                end
                S_vt = load(deblank(SD_NAMES(2,:)));
                try % test if data struct exists in Tract file
                    S_vt.y  = S_vt.data.y;
                    S_vt.Fs = S_vt.data.Fs;
                    data = S_vt.data;
                end
                try % try to get Infold data from Fold file
                    data.Infold = S_vf.data.Infold;
                catch
                    data.Infold = [];
                end;
                try
                    data.properties.radimp = Infile.data.properties.radimp;
                catch
                    data.properties.radimp = radimproutine;
                end
                warning on
                % go on if everything's fine

                if S_vf.Fs ==  S_vt.Fs
                    S_ft.Fs = S_vf.Fs;
                    data.Fs = S_vt.Fs;
                elseif S_vf.Fs > S_vt.Fs
                    if rem(S_vf.Fs,S_vt.Fs) ==  0
                        disp('decimate vocal fold signal...');
                        S_vf.y = decimate(S_vf.y,round(S_vf.Fs/S_vt.Fs));
                    else
                        warning('S_vf.Fs is not integer*S_vt.Fs!');
                        disp('resample vocal fold signal...');
                        d = gcd(S_vt.Fs,S_vf.Fs);
                        try
                            S_vf.y = resample(S_vf.y,S_vt.Fs/d,S_vf.Fs/d);
                        catch
                            warning('Resampling failed!');
                        end;
                    end;
                    data.Fs = S_vt.Fs;
                else
                    if rem(S_vt.Fs,S_vf.Fs) ==  0
                        disp('decimate vocal tract signal...');
                        S_vt.y = decimate(S_vt.y,round(S_vt.Fs/S_vf.Fs));
                    else
                        warning('S_vt.Fs is not integer*S_vf.Fs!');
                        disp('resample vocal tract signal...');
                        d = gcd(S_vt.Fs,S_vf.Fs);
                        try
                            S_vt.y = resample(S_vt.y,S_vf.Fs/d,S_vt.Fs/d);
                        catch
                            warning('Resampling failed!');
                        end;
                    end;
                    data.Fs = S_vf.Fs;
                end;
                % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ===
                %   S_vf.y = diff(S_vf.y)/data.Fs;    % differentiation!!!
                % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ===
                data.y = fftfilt(S_vt.y,S_vf.y);   % convolution
                if get(Hndl.ModTract, 'value') ==  1   % stairs calc.
                    fname = 'fs';
                else
                    fname = 'ft';
                end;
                file =  ['out_' fname SD_NAMES(2,7:8) ...
                    num2str(Infold.register) ...
                    num2str(TRACH) num2str(FOLD) num2str(TRACT) num2str(NOISE) '  '];
                SD_NAMES(value,:) = file;
                file(file ==  ' ') = []; % get rid of extra blanks in filename
                %      save(file, 'data')
                data.t = (0:length(data.y)-1)/data.Fs;
                try
                    TMAX = data.Tmax;
                catch
                    data.Tmax = max(data.t)*1000;
                    TMAX = data.Tmax;
                end
                vox('refreshDuration','strsli');%mo
                set(Hndl.figureNumber,'UserData', data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['"', strrep(file, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
            catch   % if one of the operations above fails
                datainit(MAXSEGMENTS,MAXDEVLIMIT, XI, Xi0,radimproutine);
                data = get(Hndl.figureNumber,'UserData');
                data.y = [-1 1 0 -1 0 1 -1];
                data.Fs = 1;
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['one of the files is not present - calc it?!']);
            end; % of try - catch
        end;

        if value ==  5   % load matlab variable with Fs and y or data.Fs/data.y
%            cd(LASTPATH)
            [filename, pathname] = uigetfile('*.mat', 'choose input file');
            if filename ~=  0
                LASTPATH = pathname;
                filename = filename(1:(length(filename)-4));
                S = load([pathname filename]);
                if length(filename)>15
                    filename = [filename(1:12) '...'];
                end;
                if isfield(S,'data')
                    data = S.data;
                else
                    data.Fs = S.Fs;
                    data.y  = S.y(:)';
                end;
                data.pathname = pathname;
                data.filename = filename;
                cd(WORKDIR)
                save('last_filename','data');   % save as 'last_filename'
                set(Hndl.INPUT, 'value', 8);
                vox('input');
            end;
        end;

        if value ==  6   % load microsoft wav file
%            cd(LASTPATH)
            [filename, pathname] = uigetfile('*.wav', 'choose input file');
            if filename ~=  0
                %      LASTPATH = data.pathname;
                [data.y, data.Fs] = audioread(fullfile(pathname, filename));   % wavread has been removed
                numch = size(data.y,2);
                if numch > 1
                    ButtonName = questdlg('Which channel?', ...
                        ['The file "' filename '" contains ' num2str(numch) ' channels.'], ...
                        'Channel 1', ...
                        'Channel 2', ...
                        'Channel 1');
                    switch ButtonName,
                        case 'Channel 1',
                            data.y = data.y(:,1);
                        case 'Channel 2',
                            data.y = data.y(:,2);
                    end % switch
                end;
                data.y = data.y';
                filename = filename(1:(length(filename)-4));
                if length(filename)>15
                    filename = [filename(1:12) '...'];
                end;
                SD_NAMES(value,:) = [filename blanks(15-length(filename))];
                data.filename = filename;
                data.pathname = pathname;
                save('last_filename','data');
                set(Hndl.INPUT, 'value', 8);
                vox('input');
            end;
            cd(WORKDIR)
        end;

        if value ==  7   % load Monkey forest dat file
            startdir = LASTPATH;   % start the dialog there, do not cd
            if isempty(startdir) || ~isfolder(startdir)
                startdir = WORKDIR;
            end
            [data.filename, data.pathname] = uigetfile(fullfile(startdir, '*.dat'), 'choose input file');
            if ischar(data.filename)
                LASTPATH = data.pathname;
                [data.Fs, data.y] = read_dat([data.pathname data.filename]);
                numch = size(data.y,1);
                if numch > 1
                    ButtonName = questdlg('Which channel?', ...
                        ['The file "' data.filename '" contains ' num2str(numch) ' channels.'], ...
                        'Channel 1', ...
                        'Channel 2', ...
                        'Channel 1');
                    switch ButtonName,
                        case 'Channel 1',
                            data.y = data.y(1,:);
                        case 'Channel 2',
                            data.y = data.y(2,:);
                    end % switch
                end;
                data.filename = data.filename(1:(length(data.filename)-4));
                if length(data.filename)>15
                    data.filename = [data.filename(1:12) '...'];
                end;
                SD_NAMES(value,:) = [data.filename blanks(15-length(data.filename))];
                save('last_filename', 'data');
                set(Hndl.INPUT, 'value', 8);
                vox('input');
            end;
            cd(WORKDIR)
        end;

        if value ==  8   % load last filename

            if isfile(fullfile(WORKDIR, 'last_filename.mat'))
                L = load(fullfile(WORKDIR, 'last_filename.mat'), 'data');
                data = L.data;
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['"', strrep(data.filename, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
            else   % nothing loaded yet: empty plot with a message, as for missing calc files
                data = get(Hndl.figureNumber,'UserData');
                data.y = [-1 1 0 -1 0 1 -1];
                data.Fs = 1;
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title('no file loaded yet - choose *.mat, *.wav or *.dat');
            end
        end;

        if value ==  9   % load last recorded signal
            if isfile(fullfile(WORKDIR, 'recorded.mat'))
                L = load(fullfile(WORKDIR, 'recorded.mat'), 'data');
                data = L.data;
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title(['"', strrep(data.filename, '_', '\_'), '", Fs = ', num2str(data.Fs) 'Hz']);
            else   % nothing recorded yet
                data = get(Hndl.figureNumber,'UserData');
                data.y = [-1 1 0 -1 0 1 -1];
                data.Fs = 1;
                data.t = (0:length(data.y)-1)/data.Fs;
                set(Hndl.figureNumber,'UserData',data);
                n = SD_DISP;
                eval([SD_PLOTCMD(n,:)]);
                title('nothing recorded yet - press REC');
            end
        end;

        Fs = get(Hndl.Fs, 'value');
        set(Hndl.figureNumber,'pointer','arrow');

        if ((value == 1)|(value == 3)|(value == 4)) & ~PARA   % fold, tract or combi signal
            try   % refresh Subglot. Pressure and Active Stress
                Infold.ptg = data.Infold.ptg;
                vox('refreshptg','strsli')
                Infold.tvakt = data.Infold.tvakt;
                vox('refreshtvakt','strsli')
                Infold.maxm          = data.Infold.maxm;
                %MAXM                    = data.Infold.maxm;mo
                Infold.k1         = data.Infold.k1;
                Infold.k2         = data.Infold.k2;       % default 3, MIN 0, MAX 8 [N/m]
                if ~isempty(data.Infold.asym)
                    Infold.w0       = data.Infold.w0;   % vocal fold distance [um]
                    Infold.wmax     = data.Infold.wmax;
                    Infold.lmmfac      = data.Infold.lmmfac;
                    Infold.rmmfac      = data.Infold.rmmfac;
                    Infold.lmvfac      = data.Infold.lmvfac;
                    Infold.rmvfac      = data.Infold.rmvfac;
                else
                    Infold.w0(1)    = data.Infold.w0;   % vocal fold distance [um]
                    Infold.w0(2)    = data.Infold.w0;   % vocal fold distance [um]
                    Infold.wmax(1)  = data.Infold.wmax;
                    Infold.wmax(2)  = data.Infold.wmax;
                end;
            catch
                %foldmod('defaults');%mo
            end
        end;

        try   % refresh ModTract window
            get(Hndl.ModTractFig, 'UserData');
            areas3('refresh');
        end

        try   % refresh ModFold window
            %%      get(Hndl.ModFoldFig, 'UserData'); % test if ModFold window is open
            if MODFOLD
                foldmod('initialize');
            end
            %%      MAXM = Infold.maxm;
            %%    foldmod('refreshMAXM','strsli');
        catch
            %% %      MAXM = Infold.maxm;
        end

        switch Infold.register
            case 0
            case 1
                set(Hndl.modal, 'value', 1);
                set(Hndl.head, 'value', 0);
                set(Hndl.falsett, 'value', 0);
                %      set(Hndl.FoldCalc, 'enable', 'on');
                set(Hndl.ModFold, 'enable', 'on');
            case 2
                set(Hndl.modal, 'value', 0);
                set(Hndl.head, 'value', 1);
                set(Hndl.falsett, 'value', 0);
                %      set(Hndl.FoldCalc, 'enable', 'on');
                set(Hndl.ModFold, 'enable', 'on');
            case 3
                set(Hndl.modal, 'value', 0);
                set(Hndl.head, 'value', 0);
                set(Hndl.falsett, 'value', 1);
                %      set(Hndl.FoldCalc, 'enable', 'on');
                set(Hndl.ModFold, 'enable', 'on');
        end

        % refresh Controlfile window
        if voxfigflag('controlfile',1) ==  1   %
           % data = get(Hndl.figureNumber, 'UserData');
            try
                controlfile('refresh');
            catch
                if ~PARA | ~IMPORT
                    data = databatchinit(data);
                  %  controlfile('refresh');
                end
            end
        end

        % plot output data if GRON is on
        if get(Hndl.gron, 'value') ==  1;
            vox('gron');
        end;



        % END of INPUT callback section
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==

        % data display callback.
    case 'datadisplay'
        data = get(Hndl.figureNumber,'UserData');
        Mode = data.properties.mode;
        if get(Hndl.ModFold, 'value') ==  1;
            % modify foldmod display
        end;
        if exist('Hndl.figureNumber')
            set(findobj('Tag','maxdevlimit'),'Enable','off');
            set(findobj('Tag','maxsegments'),'Enable','off');
            set(findobj('Tag','devlimit'),'Enable','off');
            set(findobj('Tag','segments'),'Enable','off');
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Display callback.
    case 'display'
        popStr       = get(Hndl.DISPLAY, 'String');
        SD_DISP    = get(Hndl.DISPLAY,'Value');
        data = get(Hndl.figureNumber,'UserData');
        set(Hndl.figureNumber,'pointer','watch');
        titl = get(get(gca,'title'),'String');
        eval([SD_PLOTCMD(SD_DISP,:)]);
        set(Hndl.figureNumber,'pointer','arrow');
        title(titl);
        % END of Display callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
    case 'paradisplay'
        if get(Hndl.FE, 'value') ==  1;
            outfilename = get(Hndl.PARAM,'String');
            filevalue   = get(Hndl.PARAM,'Value');
            name        = char(outfilename(filevalue));
            COF = 1;
            if findstr(name,'FE') > 0 & name ~=  0
                filename = name;
                PARA     = 1;
                count    = 1;
            else
                filename = name;
            end;

            vox('input');
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % setFMAX callback.
    case 'setFMAX'
        FMAX = str2num(get(Hndl.FMAXstr,'String'));
        vox('display');
        % END of setFMAX callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Play callback.
    case 'play'
        set(Hndl.figureNumber,'pointer','watch');
        data = get(Hndl.figureNumber,'UserData');
        y = data.y./max(abs(data.y));
        y = y';
        try
            maxindex = size(y,1);lastindex = maxindex;oldindex = maxindex;
 %mo???           while ((abs(y(lastindex))<= abs(y(oldindex))) | (abs((y(lastindex)-y(oldindex))/y(lastindex))<0.1))
 %               oldindex = lastindex;
 %               lastindex = lastindex-1;
 %           end;
            y = y(1:lastindex);
            y(lastindex) = 0;
            %    sound(y*get(Hndl.SD_VOLUME,'value'),data.Fs, 16);
            sound(y, data.Fs, 16);
        catch
            warning('Can''t play sound file!');
        end
        set(Hndl.figureNumber,'pointer','arrow');
        % END of Play callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Record callback.
    case 'record'
        set(Hndl.figureNumber,'pointer','watch');
        try,
            N = ceil(get(Hndl.Duration, 'value')/1000*Fs);
            % wavrecord(N, Fs, 1, 'double') has been removed: record mono, 16 bit
            rec = audiorecorder(Fs, 16, 1);
            recordblocking(rec, N/Fs);
            y = getaudiodata(rec, 'double');
            y = [y(1:min(N, end)); zeros(N - min(N, numel(y)), 1)];   % exactly N samples, as before
            y = y';
            t = (0:length(y)-1)/Fs;
            data.y = y;
            data.t = t;
            data.Fs =  Fs;
            data.filename = 'recorded';
            save('recorded', 'data');
            %    set(Hndl.figureNumber,'UserData',data);
            %    n = SD_DISP;
            %    eval([SD_PLOTCMD(n,:)]);
            %    title(['"' data.filename '", n = ', int2str(length(data.y)), ...
            %        'Fs = ', num2str(data.Fs) 'Hz']);
            set(Hndl.INPUT, 'value', 9);
            vox('input');
        catch err
            warning('Recording failed: %s', err.message);   % was silently ignored
        end
        set(Hndl.figureNumber,'pointer','arrow');
        % END of Record callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Trach callback.
    case 'trach'
        if get(Hndl.trach, 'value') ==  1;
            TRACH = 1;
            Infold.flags.SUB = 1;
        else
            TRACH = 0;
            Infold.flags.SUB = 0;
        end;
        set(Hndl.INPUT, 'value', 4);
        if ~CALC
            vox('input');
        end
        % END of Trach callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
    case 'FEchange'
        if get(Hndl.FE, 'value') ==  1;
            found       = false;
            FEswitch    = 1;
            files       = dir;
            [reng, col] = size(files);
            ii = 1;
            for r = 1:numel(files)   % 1:size(files) is an error for a size vector
                list(r,1) = {files(r).name};
                list1(r,1:length(list{r})) = list{r};
                if r >=  3
                    fnam = files(r).name;
                    if startsWith(fnam, 'FE')   % fnam(1:2) failed for names shorter than 2
                        list3(1, ii) = {fnam};
                        ii = ii + 1;
                        found = true;
                    end
                end
            end

            if (found)
                set(findobj('Tag','popup' ),'String',list3)
                set(Hndl.PARAM, 'String', list3);

                outfilename = get(Hndl.PARAM,'String');
                filevalue   = get(Hndl.PARAM,'Value');
                fnnn        = outfilename(filevalue);
                filename    = char(fnnn);
            else
                display('no FE files found.');
            end
        else
            FEswitch = 0;
            set(Hndl.PARAM, 'Value', 2);
            list3 = char(' ',' ');
            set(findobj('Tag','popup' ),'String',list3)
            set(Hndl.PARAM, 'String', list3);
            filename = [];
        end;
        if ~CALC
            vox('input');
        end

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
    case 'combiload'
        [loadname, pathname] = uigetfile('****c*.mat', 'choose combi input file');
        if ischar(loadname)   % dialog not cancelled
            filename = loadname;
            vox('input');
        end
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Fold callback.
    case 'fold'
        if get(Hndl.fold, 'value') ==  1;
            FOLD = 1;
        else
            FOLD = 0;
        end;
        set(Hndl.INPUT, 'value', 4);
        if ~CALC
            vox('input');
        end
        % END of Trach callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Tract callback.
    case 'tract'
        if get(Hndl.tract, 'value') ==  1;
            TRACT = 1;
            Infold.flags.VOC = 1;
        else
            TRACT = 0;
            Infold.flags.VOC = 0;
        end;
        set(Hndl.INPUT, 'value', 4);
        if ~CALC
            vox('input');
        end
        % END of Trach callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Noise callback.
    case 'noise'
        if get(Hndl.noise, 'value') ==  1;
            NOISE = 1;
        else
            NOISE = 0;
        end;
        if ~CALC
            vox('input');
        end
        % END of Noise callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % COMBICALC callback.
    case 'combicalc'

        combicalc;
        % END of CombiCalc callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % GRON callback.
    case 'gron'
        if get(Hndl.gron, 'value') ==  1;
            GRON = 1;
            if ~CALC
                if voxfigflag('Sound pressure during calculation',1) ==  1   %
                    set(0,'CurrentFigure',Hndl.infofigure)
                else   % initialize output
                    Scrsize   = get(0,'Screensize');
                    Scrwidth  = Scrsize(3);
                    Scrheight = Scrsize(4);

                    Hndl.infofigure = figure('visible','on',...
                        'NumberTitle','off', ...
                        'Name','Sound pressure during calculation',...
                        'Units','Normalized',...
                        'Position',[0 0 0.5 0.3]);

                    % set pos of window
                    dockwindowPosSize = get(Hndl.figureNumber, 'Position');
                    aktposSize        = get(Hndl.infofigure, 'Position');
                    newPosSize        = [dockwindowPosSize(1), dockwindowPosSize(2)-aktposSize(4)-0.07, aktposSize(3), aktposSize(4)];
                    set(Hndl.infofigure, 'Position', newPosSize);
                end
                data = get(Hndl.figureNumber, 'Userdata');
                time = data.t;
                try
                    combi_filename = data.filename;
                    clf
                    plot(time, data.y, ...
                        time, data.out.out_vf_voc_vek, ...
                        time, data.out.out_vf_trach_vek, ...
                        time, data.out.glotnoise_vek, ...
                        time, data.out.pin_gl_ac_vek);

                    legendtext = [...
                        'p tract -> mouth'; ...
                        'p glot. -> tract'; ...
                        'p glot. -> trach'; ...
                        'p noise @glottis'; ...
                        'p tract->glottis'];
                    titlestring = strrep(combi_filename, '_', '\_');
                    title(titlestring);



                catch
                    plot(1,1)
                    titlestring = 'No output data available!';
                    title(titlestring);
                end
            end
        else
            GRON = 0;
            try
                close(Hndl.infofigure);
            end
        end;
        % END of GRON callback section

         % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % SURFS callback.
    case 'surfs'
       if SURFS == 1
           SURFS = 0;
           try
               close figure 60;
           end
           try
               close figure 61;
           end
           try
               close figure 80;
           end
           try
               close figure 81;
           end
       else
           SURFS = 1;
           try figdata.time;
               displaycontforc;
               displayimpuls;
           catch
               display('No figure data present (old file format)');
               set(Hndl.surfs,       'Enable', 'off')
           end
       end
    case 'vibro'
        if VIBRO == 1
            VIBRO = 0;
            try
                close Phonovibrogramm;
            end
        else
            VIBRO=1;
            try
                VibroHndl = figure('name','Phonovibrogramm','NumberTitle','off');
                surf(figdata.vibro', 'linestyle', 'none');
                axis([1 length(figdata.vibro) 1 size(figdata.vibro,2)])
                %Calculations for Colormap
                cMap=zeros(100,3);   % n x 3 in both cases (was 100 x 1 without negative values)
                if min(min(figdata.vibro)) < 0 %negative values exist
                    per=(max(max(figdata.vibro))+abs(min(min(figdata.vibro))))/100;
                    upper=round(max(max(figdata.vibro))/per);
                    lower=max(round(abs(min(min(figdata.vibro))/per)), 1);   % index, at least 1
                    cMap(lower:lower+upper,1) = linspace(0,1,upper+1);
                    cMap(1:lower,3) = linspace(min(lower/30,1),0,lower);       % colormap values <= 1
                else  %no negative values
                    cMap(1:100,1) = linspace(0,1,100);
                end
                colormap(cMap);
                colorbar;
                view(0, -90);
            catch err
                close Phonovibrogramm;
                disp(['No vibrogram shown: ' err.message]);
            end

        end
        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Batch callback.
        % case 'batch'
        %   if get(Hndl.batch, 'value') ==  1;
        %     BATCH = 1;
        %     SD_NAMES(4,5) = 'B';
        %   else
        %     BATCH = 0;
        %     SD_NAMES(4,5) = 'c';
        %   end;
        %   if get(Hndl.INPUT, 'value') ==  4
        %     vox('input');
        %   end
        % END of Batch callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % BatchEdit callback.
    case 'batchedit'
        if get(Hndl.batch, 'value') ==  1;
            BATCH = 1;
            SD_NAMES(4,5) = 'B';
            controlfile('initialize');
        else
            BATCH = 0;
            SD_NAMES(4,5) = 'c';
            try
                controlfile('close');
            end
        end;
        if get(Hndl.INPUT, 'value') ==  4
            vox('input');
        end


        % END of BatchEdit callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % makemovie callback.
    case 'makemovie'
        MOV = get(Hndl.makemovie, 'Value');

        % END of makemovie callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % BatchEdit callback.
    case 'Parametermode'
        parametermode;

        % END of BatchEdit callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % Info callback.
    case 'info'
        helpwin('vox')
        % END of Info callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % extforce callback.
    case 'extforce'
        external_forces;
        % END of extforce callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % WAV callback.
    case 'wav'
        value = get(Hndl.INPUT, 'Value');
        file = SD_NAMES(value,:);
        file(file ==  ' ') = []; % get rid of extra blanks in filename
        path      = '';
        filename  = file;
        extension = '';
        %  filestring = [path filename extension];
        data = get(Hndl.figureNumber,'UserData');
        s = data.y./max(abs(data.y));
        %  s = load(filestring);
        maxy = max(s);
        miny = min(s);
        s = (2*s./(maxy-miny)-(maxy+miny)/(maxy-miny))./1.0001;
        figure(372);plot([1:length(s)]./Fs, s);
        [~, filename] = fileparts(filename);   % 'a.wav' -> 'a', avoids 'a.wav.wav'
        audiowrite([path filename '.wav'], s, data.Fs);
        sound(s, data.Fs);
        %mo
        initfilename = ['out_*.wav'];
        [filename, pathname] = uiputfile(initfilename, 'choose output wav file');
        if ischar(filename)   % dialog not cancelled
            [~, filename] = fileparts(filename);   % uiputfile already adds .wav
            try
                audiowrite(fullfile(pathname, [filename '.wav']), s, data.Fs);
            catch err
                warning('Could not write the WAV file: %s', err.message);
            end
        end
        % END of WAV callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % QUIT callback.
    case 'quit'
        set(gcf,'Pointer','arrow')
        BRK  = 1;
        QUIT = 1;
        CALC = 0;
        setenable(CALC)
        f = findobj(allchild(0),'flat','Tag','TMWWaitbar');
        if ~isempty(f)
            close(f)
        end
        %mycalc = CALC
        %mybrk = BRK
        % END of QUIT callback section


        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % BREAK callback.
    case 'break'
        set(gcf,'Pointer','arrow')
        BRK = 1;
        CALC = 0;
        setenable(CALC)
        f = findobj(allchild(0),'flat','Tag','TMWWaitbar');
        if ~isempty(f)
            close(f)
        end
        % END of BREAK callback section

        % == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        % QUIT callback.

    case 'closevox'
        close all;
    otherwise
        display('couldnt find some for this action:');action

end;    % switch action case...
