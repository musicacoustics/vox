% extract the combicalc stuff for better readability

if PROFILE ==  1
    data     = get(Hndl.figureNumber, 'UserData');
    iniinput = get(Hndl.INPUT,'Value');
    vowel    = get(Hndl.VOWEL,'Value');
    TVAKT    = get(Hndl.tvakt,'Value');
    PTG      = get(Hndl.ptg,'Value');
    datas    = struct('data',data,'Infold',Infold,'MODFOLD',MODFOLD,'PARA',PARA,'BATCH',BATCH,'TRACH',TRACH,'FOLD',FOLD, ...
        'TRACT',TRACT,'NOISE',NOISE,'vowel',vowel,'iniinput',iniinput,'TVAKT',TVAKT,'PTG',PTG, ...
        'TMAX',TMAX,'Fs',Fs,'MAXSEGMENTS',MAXSEGMENTS,'MAXDEVLIMIT',MAXDEVLIMIT,'XI',XI,'Xi0',Xi0,...
        'MAXM',MAXM,'GRON',GRON);
    parametermode('getdata',datas);
    %    break;
end

CALC = 1;
setenable(CALC)

% is FE mode activated...
isfe = get(Hndl.FE, 'Value');

Infold.combicalc = 1;

% FE mode init
if isfe
    if ischar(filename) && contains(filename,'FE')
        PARAMANZ = 14;
        fnam = filename;
        fid  = fopen(filename);
        if fid == -1
            [errmsg, errnum] = ferror(fid);
            if errnum ~= 0
                disp(['1: ' errmsg]);
            end
        else
            fid  = fopen(fnam);
            if fid>0
                [errmsg, errnum] = ferror(fid);
                if errnum ~= 0
                    disp(['2: ' errmsg]);
                else
                    % dont know why i did this (basti)
                   % display([filename ' not found. so use: ' fnam]);
                end
            else
                errnum = -1;
            end
        end
        if errnum == 0
            disp(['using ' fnam ' as FE input file'])
            a    = fscanf(fid,'%f',[PARAMANZ inf]);
            fclose(fid);
            b    = a';
            time = max(b(:,1));
            TMAX = time;
        else
            disp('FE input file not found');
            isfe = 0;
        end
    else
        isfe = 0;
    end
end

% combicalc loop init
n_samples = ceil(TMAX/1000*Fs);%mo: /1000 für ms
t         = [0:n_samples-1]/Fs;   % time beam for graphic display
kk        = 1;
ik        = 1; % index of timestep in fe vector

if n_samples > 0
    % combicalc loop
    for ii = 1:n_samples
        % read FE file stuff in
        if isfe
%             display('femode');
            time = b(ik,1);
            time;
            if t(ii) ==  TMAX
                return % stop execution
            else
                % basti (FE mode):
                % is there a timestep where we have to change the parameters?
                % do we need to interpolate here?

                % read parameters from vector
%                 ik
                time            = b(ik,1);
                refactor        = 1000; % this is cause later it is divided trough refactor, so we need to correct it here
                Infold.wmaxla   = b(ik,2:4).*refactor;   % xyz-positions of vocalfolds left  anterior  (ary)
%                 lllmaxX         = Infold.wmaxla(1)
                Infold.w0lp     = b(ik,5:7).*refactor;   % xyz-positions of vocalfolds right posterior (thyr)
                Infold.wmaxra   = b(ik,8:10).*refactor;  % xyz-positions of vocalfolds left  anterior  (ary)
%                 rrrmaxX         = Infold.wmaxra(1)
                Infold.w0rp     = b(ik,11:13).*refactor; % xyz-positions of vocalfolds right posterior (thyr)


                Infold.k1     = 2;
                Infold.k2     = 4.5;

                % read active stress if not null
                hastvakt = 0;
                if (b(ik,14)>0)
                    Infold.tvakt  = b(ik,14);
                    hastvakt = 1;
                    %display('found active stress in parameter file, so i use it...');
                end


                % set values to modfold-gui
                if get(Hndl.ModFold, 'value') ==  1;
                    MODFOLD = 1;
                    foldmod('initialize');
                    foldmod('refreshwmax','strsli');
                    foldmod('refreshw0','strsli');
                else
                    MODFOLD = 0;
                    try
                        close(Hndl.ModFoldFig);
                    end
                end;
                % set value to main gui
                if hastvakt
                    set(Hndl.tvaktStr, 'String', sprintf('%10.6f', Infold.tvakt)); % set text of slider
                    vox('refreshtvakt','string'); % set slider to text value
                end
                if t(ii) >=  time
                    ik  = ik + 1;
                    disp(['use fe step: ' sprintf('%4d', ik)]);
                end;              
            end;
        end;

        data = get(Hndl.figureNumber, 'UserData');
        % do it only once...combicalc init
        if ii ==  1
            %display('eins');
            % same name as vox('input') looks for (was built separately there)
            combi_filename = [voxcombiname() '  '];
            control_init; % call script for initial parameter definitions
            timeindex = 1;  % initialize timeindex for batch
            if BATCH % called only once
                modvar.actstr = Infold.tvakt;
                modvar.subpre = Infold.ptg;
                modvar.radius = data.radius;
                [control1, control2, control3, timevector] = controlfile('call',n_samples,'',Fs,modvar);  % call function for parameter definition
            end;
            if Infold.register ==  0   % loaded fold file
                value = 1;
                % Load file, if available. Otherwise, give empty plot and message in title
                file = SD_NAMES(value,:);
                if file(9) ==  '0'
                    file = 'out_vf_n00000';
                end
                file(file ==  ' ') = []; % get rid of extra blanks in filename
                try
                    foldfile  = load(file);   % hier werden y, filename etc überschrieben!
                    if foldfile.data.Fs ==  Fs    % file Fs = global Fs -> do nothing
                    elseif foldfile.data.Fs > Fs
                        disp('decimate vocal fold signal...');
                        foldfile.data.y = decimate(foldfile.data.y,round(foldfile.data.Fs/Fs));
                        if rem(foldfile.data.Fs,Fs) ~=  0
                            warning('sample rate of fold file is not integer*Fs!');
                        end;
                        data.Fs = Fs;
                    else
                        disp('interpolate vocal fold signal...');
                        foldfile.data.y = interp(foldfile.data.y,round(Fs/foldfile.data.Fs));
                        if rem(foldfile.data.Fs,Fs) ~=  0
                            warning('sample rate of fold file is not Fs/integer!');
                        end;
                        data.Fs = Fs;
                    end;
                    fileout = foldfile.data.y;
                catch
                    error('vocal fold file not present!');
                end; % of try - catch
                out_vf_trach = 0;
                minarea      = glotareadefault;
            end;  % of if Infold.register ==  0

            % video stuff
            if noisemovflag
                % avifile has been removed: VideoWriter (find a free file name)
                noisenum = voxnextnum(fullfile(WORKDIR, 'out'), 'noisemov_');   % counting could pick a number in use
                Hndl.noisemov = VideoWriter(fullfile(WORKDIR, 'out', ['noisemov_' noisenum '.avi']), 'Motion JPEG AVI');
                Hndl.noisemov.FrameRate = 20;
                Hndl.noisemov.Quality   = 100;
                open(Hndl.noisemov);
            end

            % initiate movie file
            Hndl.movisgood  = -1;
            Hndl.foldmovfig = '';
            if GRONF & MOV
                % find free filename (above the highest combimov_*.avi/.fig;
                % counting the files could pick a number in use)
                movnum     = voxnextnum(fullfile(WORKDIR, 'out'), 'combimov_');   % was named datetime (hides the function)
                movfilename = fullfile(WORKDIR, 'out', ['combimov_' movnum '.avi']);
                % make movie file (avifile has been removed: VideoWriter);
                % this created Hndl.noisemov before, so no frames were written
                try
                    Hndl.mov = VideoWriter(movfilename, 'Motion JPEG AVI');
                    Hndl.mov.FrameRate = 20;
                    Hndl.mov.Quality   = 100;
                    open(Hndl.mov);
                    disp(['initialized movie file: ' movfilename]);
                    Hndl.movisgood = 1;
                catch err
                    disp(['could not init movie file: ' err.message]);
                end
                Hndl.foldmovfig = fullfile(WORKDIR, 'out', ['combimov_' movnum '.fig']);
            end

            Hndl.mainwaitfigure = voxwaitbar(0, 'Calculating combined fold/tract signal...');

            % why is this:
            BRK      = 0;
            QUIT     = 0;
            glotarea = 0;
        end   % of if combicalc init

%        Hndl.mainwaitfigure = waitbar(ii/n_samples, Hndl.mainwaitfigure);
        Hndl.mainwaitfigure = voxwaitbar(ii/n_samples);

        % makes it possible to end calculation
        if BRK
            disp('combibreak');
            break
        end
        Infold.k = ii;      % parameter for foldsig


        % batch mode stuff
        if BATCH
            % at each timesegment, the according control segment is executed
            if ii/Fs*1000 >=  timevector(timeindex)
                eval(eval('control1(timeindex,:);'));
                eval(eval('control2(timeindex,:);'));
                eval(eval('control3(timeindex,:);'));
                set(Hndl.figureNumber,'UserData',data);
                try
                    areas3('refresh');
                end
                timeindex = timeindex + 1;
            end;
            if IMPORT & (ii <=  size(data.importradius,1))
                data        = get(Hndl.figureNumber,'Userdata');
                data.radius = data.importradius(ii,:);
                if ii ==  1  % open glottis
                    Infold.wmaxold = Infold.wmax;
                    Infold.wmax    = Infold.xmax*1000;
                    flag = 0;
                end

                % smoothly closing glottis
                flag = flag +1;
                if flag ==  1
                    delta = floor((Infold.wmax-Infold.wmaxold)/200);
                end
                if (ii > data.phonsamples(1)-200) & (ii < data.phonsamples(1))
                    if Infold.wmax > Infold.wmaxold
                        Infold.wmax = Infold.wmax - delta;
                    end
                end
                if ii ==  data.phonsamples(1)
                    Infold.wmax = Infold.wmaxold;
                end
                % smoothly opening glottis
                if (ii > data.phonsamples(end)-200) & (ii < data.phonsamples(end))
                    if Infold.wmax < Infold.xmax*1000
                        Infold.wmax = Infold.wmax + delta;
                    end
                end
                if ii ==  data.phonsamples(end)
                    Infold.wmax = Infold.xmax*1000;
                end


                set(Hndl.figureNumber,'UserData',data);
                vox('refreshtvakt','strsli');
                try
                    areas3('refresh');
                end
                try
                    foldmod('refreshwmax','strsli');
                end
            end
        end;


        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % call Vocal Folds calculation program
        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        if Infold.register ==  0   % use sample from fold file
            out_vf_voc = fileout(ii);
        else
            [out_vf_voc, out_vf_trach, minarea, PARFOLD] ....
                = foldsig(PARFOLD);
        end;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % get glottal opening area (new value in foldsig->PARFOLD!
        if FOLD
            glotarea = minarea;   % vocal fold area [m^2]
        else
            glotarea = glotareadefault; %1 cm^2
        end;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % Add glottal noise pressure to the signal
        data = get(Hndl.figureNumber, 'UserData');
        if get(Hndl.TractCalcMode, 'value') ==  1   % stairs
            radius = data.radius(:);
            spacing = data.spacing;
        elseif   get(Hndl.TractCalcMode, 'value') ==  2      % tubes
            areas3('tubecalc');
            data    = get(Hndl.figureNumber, 'UserData');
            radius  = data.radius(data.newradius);
            spacing = data.spacing*(data.newradius-1);
        elseif   get(Hndl.TractCalcMode, 'value') ==  4      % import
            radius  = data.radius(:);
            spacing = data.spacing;
        end;
        if ii ==  1   % initialize PARNOISE
            PARNOISE.out = zeros(length(radius),1); % no noise
            PARNOISE.vortices   = []; % no vortices yet
            PARNOISE.shedtimer = 0;
            PARNOISE.dampdB = DAMPDB;
        end;
        if NOISE
            PARNOISE = noisesig(PARNOISE, PARFOLD.var.flow, ...
                glotarea, radius, spacing, ii);
            %  glotnoise = NoiseFactor*rand*PARFOLD.var.flow*glotarea;   % to be improved!
        end;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % call Vocal Tract calculation program
        % == == == == == == == == == == == == == == == == == == == == == == == == == == =

        if SD_NAMES(2,7:8) ==  'fi'   % no vocal tract;
            % replace vocaltract by transmission without delay
            p_out_mouth = out_vf_voc;
            pin_gl_ac = 0;
        else
            data = get(Hndl.figureNumber, 'UserData');
            if get(Hndl.TractCalcMode, 'Value') ==  1   % segment calc.
                % == == == == == == == == == == == == == == == == == == == == == == == == == == =
                % loop for calculation of countmax*tractsignal
                % == == == == == == == == == == == == == == == == == == == == == == == == == == =
                % test if sampling rate is appropriate
                vowel = get(Hndl.VOWEL,'value');
                if vowel < 11
                    FsRef = 88200;
                elseif vowel < 15
                    FsRef = 67803;
                else
                    FsRef = 117489;
                end
                if rem(FsRef, Fs) ~=  0  % test if n*Fs = 88200
                    error(['Fs must be ' num2str(FsRef) '/n, n = INT']);
                    %          close(Hndl.mainwaitfigure);  % close waitbar
                    %          vox('quit');
                else
                    countmax = FsRef/Fs;
                end;
                for count = 1:countmax
                    %          [p_out_all(ii,:), pin_gl_ac, PARTRACT] = tractsig(ii, ...
                    %            PARTRACT, vowelname, glotarea, out_vf_voc, PARNOISE);
                    [p_out_mouth, pin_gl_ac, PARTRACT] = tractsig(ii, ...
                        PARTRACT, glotarea, out_vf_voc, PARNOISE);
                end;
                Infold.pin_gl_ac = pin_gl_ac;
            elseif   get(Hndl.TractCalcMode, 'Value') ==  2 % tube calc.
                if BRK   % Break during the fold step: ctim2 would return
                    disp('combibreak');   % without assigning its outputs
                    break
                end
                areas3('tubecalc');
                sizetubes = size(data.tubes,1);
                [p_out_mouth, pin_gl_ac, PARCTIM] ...
                    = ctim2(data.tubes, 0, data.properties.damping, ii, PARCTIM, ...
                    out_vf_voc, PARNOISE);
                y_out_all(:,ii) = PARCTIM.p_boundaries;   % tube ends, glottis to mouth (sizetubes+1)
                if (GRONT ==  1) | (GRONT ==  4)
                    if voxfigflag('Wave propagation in the vocal tract',1) ==  1
                        set(0,'CurrentFigure',Hndl.voctractfig)
                        set(Hndl.voctractfig,'CurrentAxes',Hndl.voctractfigplot)
                        waterfall(t(1:ii), 1:sizetubes+1, y_out_all);
                        view(0,85)
                        grid off
                    else   % create figure
                        Hndl.voctractfig = figure('visible','on','NumberTitle','off', ...
                            'Name','Wave propagation in the vocal tract','Units','normalized',...
                            'Position',[.5 .05 .5 .4]);
                        set(Hndl.voctractfig,'MenuBar', 'none');
                        Hndl.voctractfigplot = axes;
                        waterfall(t(1:ii), 1:sizetubes+1, y_out_all);
                        view(0,85)
                        grid off
                    end
                end;
                % p_out_mouth from ctim2: pressure at the mouth end (was
                % y_out_all(sizetubes,ii), the left end of the last tube)
                data.out.t        = t(1:ii);
                data.out.segments = 1:sizetubes+1;
                data.out.h        = y_out_all;
            elseif   get(Hndl.TractCalcMode, 'Value') ==  4 % import
                [p_out_mouth, pin_gl_ac, PARTRACT] = tractsig(ii, ...
                    PARTRACT, glotarea, out_vf_voc, PARNOISE);
                Infold.pin_gl_ac = pin_gl_ac;
            end
        end;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % Generate Mouth signal
        sample(ii)           = ii;    % vector with sample indices
        out_y(ii)            = p_out_mouth;  % signal tract -> mouth
        out_vf_voc_vek(ii)   = out_vf_voc;   % signal glot. -> tract
        out_vf_trach_vek(ii) = out_vf_trach; % signal glot. -> trach
        time                 = sample/Fs*1000;
        glotnoise_vek(ii)    = sum(abs(PARNOISE.out)); % noise  @glottis
        pin_gl_ac_vek(ii)    = pin_gl_ac;    % signal tract -> glottis
        minareamm(ii)        = minarea*1e6;
        minareamm(ii)        = minarea*1e6;
        rvocmm(ii)           = pi*Infold.rvoc^2*1e6;
        ys0(ii)              = Infold.ptg;
        sum_uccm(ii)         = PARFOLD.var.flow*1e6;

        % == == == == == == == == == == == == == == == == == == == == == == == == == == =
        % Graphic output of intermediate signals
        if GRON
            time    = [1:ii]/Fs*1000;
            Vektor1 = [minareamm; rvocmm; out_y; glotnoise_vek; sum_uccm];
            Vektor2 = [out_vf_voc_vek; out_vf_trach_vek; pin_gl_ac_vek; ys0];
            Vector3 = Infold.w0lp(1);
            if (voxfigflag('Sound pressure during calculation',1) ==  1)&(ii>1)   %
                set(0,'CurrentFigure',Hndl.infofigure)
                yaxe = Hndl.infofig.yaxe;
                sig1 = Hndl.infofig.sig1;
                sig2 = Hndl.infofig.sig2;
                for ii = 1:size(sig1,1)
                    set(sig1(ii),'XData',time, 'YData',Vektor1(ii,:));
                end;
                for ii = 1:size(sig2,1)
                    set(sig2(ii),'XData',time, 'YData',Vektor2(ii,:));
                end;
                set(yaxe(1),'XLim', [max(time)-10 max(time)]);
                set(yaxe(2),'XLim', [max(time)-10 max(time)]);
                ylimit1 = get(yaxe(1),'YLim');
                ylimit2 = get(yaxe(2),'YLim');
                yinc1   = (ylimit1(2)-ylimit1(1))/5;
                yinc2   = (ylimit2(2)-ylimit2(1))/5;
                set(yaxe(1),'YTick',[ylimit1(1):yinc1:ylimit1(2)])
                set(yaxe(2),'YTick',[ylimit2(1):yinc2:ylimit2(2)])
%                 if time > 0.03
%                     display('hallo')
%                 end
                %label('p_{sup} (r), p_{sub} (g), p_{s0} (b) [Pa], A_{glot} [mm^2] (m)');
            else   % initialize output
                if (voxfigflag('Sound pressure during calculation',1) ==  1)
                    close(Hndl.infofigure);
                end
                Scrsize   = get(0,'Screensize');
                Scrwidth  = Scrsize(3);
                Scrheight = Scrsize(4);

                Hndl.infofigure = figure('visible','on','NumberTitle','off', ...
                    'Name','Sound pressure during calculation','Units','Pixels',...
                    'Position',[15 40 620 370]);
                [Hndl.infofig.yaxe,Hndl.infofig.sig1,Hndl.infofig.sig2] ...
                    = plotyy(time,Vektor1, time,Vektor2);

                yaxe = Hndl.infofig.yaxe;
                sig1 = Hndl.infofig.sig1;
                sig2 = Hndl.infofig.sig2;

                set(sig1,    'LineStyle',':')
                set(sig1(1), 'Color','k')
                set(sig1(2), 'Color','m')
                set(sig1(3), 'Color','b')
                set(sig1(4), 'Color','c')
                set(sig1(5), 'Color','r')
                set(sig2,    'LineStyle','-')
                set(sig2(1), 'Color','b')
                set(sig2(2), 'Color','g')
                set(sig2(3), 'Color','c')
                set(sig2(4), 'Color','k')
                set(yaxe(1), 'YLimMode', 'auto');
                set(yaxe(2), 'YLimMode', 'auto');
                xlabel('Time [ms]');
                set(get(yaxe(1),'Ylabel'),'String','A_{g} (k), A_{VT} (m) [mm^2], p_{m} (b), noise (c) [Pa], u (r) [mm^3/s]');
                set(get(yaxe(2),'Ylabel'),'String','p^{g} (b), p_{g} (g), p_{in} (c), p_{s0} (k) [Pa]');
            end
        end; % of GRONs
    end; % end combicalc main loop

    disp('loop end');
    
    if ishghandle(Hndl.mainwaitfigure)   % vox('break') may have closed it already
        close(Hndl.mainwaitfigure)
    end

    % finish stuff
    BRK = 0;
    f = findobj(allchild(0),'flat','Tag','TMWWaitbar');
    if ~isempty(f)
        close(f)
    end


        
    % video stuff
    if noisemovflag
        close(Hndl.noisemov);   % VideoWriter close returns nothing
    end

    % close video file, otherwise we cannot open it
    if GRONF & MOV & Hndl.movisgood > 0
        disp(['saved movie file: ' fullfile(Hndl.mov.Path, Hndl.mov.Filename)]);
        close(Hndl.mov);
    end
    
    % save area function for later, when external forces is active
    guiname = 'external_forces_gui';        % name of gui
    [isda]  = voxfigflag(guiname, 1);
    if isda
       Hndl.efgui     = openfig(guiname, 'reuse');
       handles        = guihandles(Hndl.efgui);
       ef_force       = get(handles.forceslider,     'Value'); % get value of force
       % take duration into account
       ef_duration    = get(handles.durationslider,  'Value')*100; % get value of duration in percent of f0
       if ef_force>0 && ef_duration>0
           areafilename   = ['externalforce_glottalarea_' sprintf('%g', ef_force*100) 'mN_'  sprintf('%g', ef_duration) 'percent.csv'];
           writematrix(Infold.completeareafunction, areafilename);   % csvwrite is not recommended
           disp(['wrote area function into file: ' areafilename]);
       end
    end
    
    
    if QUIT ==  0
        data.y                      = out_y;
        data.out.out_vf_voc_vek     = out_vf_voc_vek;
        data.out.out_vf_trach_vek   = out_vf_trach_vek;
        data.out.glotnoise_vek      = glotnoise_vek;
        data.out.pin_gl_ac_vek      = pin_gl_ac_vek;
        data.Fs                            = Fs;
        Infold.maxm                        = MAXM;
        Infold.asym               = 1;
        data.Infold                      = Infold;
        data.Tmax                         = max(time);
        combi_filename(combi_filename ==  ' ') = []; % get rid of extra blanks in filename
        if PARA
            %         if findstr(filename,'FE') > 0 & filename ~=  0
            %             suffix = ['fem',num2str(i)];
            %         else
            %             suffix = ['para',num2str(i)];
            %         end;
            %         data.suffix = suffix;
            %       combi_filename = [combi_filename data.suffix];
            if ischar(filename) && contains(filename,'FE')
                combi_filename(5) = 'c';
                combi_filename(6) = 'F';
                combi_filename(14) = '_';
                combi_filename(15:17) = filename(3:5);
            else
                combi_filename(5) = 'B';
            end;
        end
        data.filename                   = combi_filename;
        save(combi_filename, 'data');
        if ~PARA
            SD_NAMES(4,:) = [combi_filename '  '];
        end
        set(Hndl.INPUT, 'value', 4);
        vox('input');
    end;
else
    disp('there was a bug with samples calculation.');
end
CALC = 0;
setenable(CALC)