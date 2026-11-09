% main call for external force integration
% global Infold Hndl

% vox('extforce') runs this script only to open or close the window; the
% force computation below needs the glottal area (sum_amin) of a running
% fold calculation (siggi)
calledFromGui      = ~exist('sum_amin', 'var');
radio              = get(Hndl.extforce, 'Value');  % is radio button on main vox gui on?
guiname            = 'external_forces_gui';        % name of this gui
% find out if gui is open
[isda] = voxfigflag(guiname, 1);

% gui stuff
if radio == 1 && isda == 0
    Hndl.efgui     = openfig(guiname, 'reuse');
    handles        = guihandles(Hndl.efgui);
    % set pos of window
    dockwindowPosSize = get(Hndl.figureNumber, 'Position');
    try
        if ~isempty(Hndl.efgui)
            dockwindowPosSize = get(Hndl.plotmassfig, 'Position');
        end
    end
    aktposSize        = get(Hndl.efgui, 'Position'); % position normalized
    set(Hndl.efgui, 'Units', 'pixels');
    pixPosSize        = get(Hndl.efgui, 'Position'); % position in pixels
    set(Hndl.efgui, 'Units', 'normalized');
    minPixSize        = [0 0 290 500]; % minimum size of window
    relFac            = minPixSize ./ pixPosSize;
    aktposSize        = relFac .* aktposSize;

    newPosSize        = [dockwindowPosSize(1)+dockwindowPosSize(3)+0.005, dockwindowPosSize(2), aktposSize(3), dockwindowPosSize(4)];
    set(Hndl.efgui, 'Position', newPosSize);

    % fill gui with actual vector data - only once!
    Infold.extForceFac = ones(1,MAXM);
    setStr = '';
    for i=1:MAXM-1
        setStr = [setStr sprintf('%1.0f', Infold.extForceFac(i)) ';'];
    end
    setStr = [setStr sprintf('%1.0f', Infold.extForceFac(MAXM))];
    set(handles.forcefactor, 'String', setStr);

    sum_amin = 0;

elseif radio == 0 && isda == 1
    close(Hndl.efgui);
    Hndl.extforcesgui = -1;
    sum_amin = 0;
else
    try
        handles = guihandles(Hndl.efgui);
    end
end

if calledFromGui
    return   % window opened or closed; no calculation running
end


% do this once....
if Infold.k == 1
    % init vars
    Infold.extForceF0inSamples = 0; % store f0s here
    Infold.glottalarea         = 0; % store last glottalareas here to mean them
    Infold.last3areavalues     = 0; % store last 3 f0s
    Infold.ef_lastmax          = 0; % last sample step where f0 trigger was
    Infold.lastF0type          = 0; % use this to store which kind of extremum last f0 trigger was: min=-1 none=0 max=1
    Infold.completeareafunction = 0;
end
    
    
% check if we have to set force to zero...
zerome = true;


% search of fundamental frequency
meanrange                     = 5;
Infold.glottalarea            = circshift(Infold.glottalarea, [0 -1]);
Infold.glottalarea(meanrange) = sum_amin;
Infold.completeareafunction(Infold.k) = sum_amin;
Infold.last3areavalues        = circshift(Infold.last3areavalues, [0 -1]);
Infold.last3areavalues(3)     = mean(Infold.glottalarea);
any_a = Infold.last3areavalues(1);
any_b = Infold.last3areavalues(2);
any_c = Infold.last3areavalues(3);

% debug
%dfsdd = Infold.glottalarea;
%lkjsd = Infold.last3areavalues;


% check actual values for minumum/maximum in glottalarea as points of
% f0
gotF0 = 0;
if (Infold.lastF0type == 0 && (sum(Infold.last3areavalues)>0)) % we had some zeroes before, but now we are opening again: so trigger
    Infold.lastF0type = -1;
    gotF0 = 1;
elseif (Infold.lastF0type > -1 && (sum(Infold.last3areavalues)==0)) % we are in closed state, this can take some time so dont trigger
    Infold.lastF0type = 0;
elseif any_a>any_b && any_c>any_b % a normal minimum in glottalarea: so trigger
    %display('min');
    Infold.lastF0type = -1;
    gotF0 = 1;
elseif (any_a<any_b && any_c<any_b) % a normal maximum in glottal area, for now not used...
    %display('max');

    % to activate double trigger set gotF0 to 1.
    % for now trigger only if area is very small!!!
    Infold.lastF0type = 1;
    gotF0 = 0;
end

if Infold.k>3 && gotF0
    ef_pos     = size(Infold.extForceF0inSamples, 2);
    ef_f0      = Infold.k - Infold.ef_lastmax;
    Infold.extForceF0inSamples(ef_pos+1) = ef_f0;
    Infold.ef_lastmax = Infold.k;

    % for debugging
    ef_f0_Hz = Fs/ef_f0;
    disp(['fo[' sprintf('%3.0f', ef_pos+1)  ']: ' sprintf('%5.2f', ef_f0_Hz) ' : Hz  : ' sprintf('%g',Infold.k) ])
    %hsuehsz    = [any_a, any_b, any_c];
    %iuienkds   = Infold.extForceF0inSamples;
end

% the actual calculation part
if radio == 1 && isda == 1
    if size(Infold.extForceF0inSamples, 2) > 1 % wait for first f0 calc
        % now we have the fundamental frequency, now produce a vector with a
        % stepper function, to rise the force smooth

        ef_actstep = Infold.k - Infold.ef_lastmax; % actual step in the actual period
        ef_actf0   = Infold.extForceF0inSamples(size(Infold.extForceF0inSamples, 2));

        % read the values from gui - every time!
        getStr = get(handles.forcefactor, 'String'); % the factor vector
        Infold.extForceFac = str2num(getStr);


        ef_force    = get(handles.forceslider,     'Value') / 100; % get value of force

        % take duration into account
        ef_duration        = get(handles.durationslider,  'Value'); % get value of duration in percent of f0
        ef_durationInSteps = round(ef_duration*ef_actf0);  % calc stepcount that should be influenced


        % take phase shiftslider into account
        phaseslider       = get(handles.phaseslider, 'Value')*360-180;
        phasestartstep    = round((ef_actf0/360)*phaseslider);

        % decide if we have to influence
        doinfluence = ef_actstep > phasestartstep && ef_actstep <= phasestartstep+ef_durationInSteps;

        % check if we have a force and a length given, otherwise do
        % nothing..
        if ef_force > 0 && ef_durationInSteps > 0
            if doinfluence % is the actual step one we need to influence?
                %display(['influence: ' sprintf('%4.5f', ef_force)]);
                % on which masses do have to add the force
                if get(handles.both , 'Value') == 1
                    for j = 1:2
                        for i = 1:MAXM
                            fextxv(j,i) = ef_force * Infold.extForceFac(i);
                            fextxm(j,i) = ef_force * Infold.extForceFac(i);
                        end
                    end
                    % dont zero vectors...
                    zerome = false;
                elseif get(handles.vocalis , 'Value') == 1
                    for j = 1:2
                        for i = 1:MAXM
                            fextxv(j,i) = ef_force * Infold.extForceFac(i);
                        end
                        fextxm = zeros(MAXM); % fill other vector with zeros
                    end
                    % dont zero vectors...
                    zerome = false;
                elseif get(handles.mucosa , 'Value') == 1
                    for j = 1:2
                        for i = 1:MAXM
                            fextxm(j,i) = ef_force * Infold.extForceFac(i);
                        end
                        fextxv = zeros(MAXM); % fill other vector with zeros
                    end
                    % dont zero vectors...
                    zerome = false;
                end
            end
        end
    else
        % check if someone changed the count of masses
        getStr = get(handles.forcefactor, 'String'); % the factor vector
        Infold.extForceFac = str2num(getStr);
        oldsize = size(Infold.extForceFac);
        if (oldsize~=MAXM)
            % calc new vector
            newvec = ones(MAXM);
            for i=1:min(MAXM, oldsize)
                newvec(i) = Infold.extForceFac(i);
            end
            Infold.extForceFac = newvec;
            % set display
            setStr = '';
            for i=1:MAXM-1
                setStr = [setStr sprintf('%1.0f', Infold.extForceFac(i)) ';'];
            end
            setStr = [setStr sprintf('%1.0f', Infold.extForceFac(MAXM))];
            set(handles.forcefactor, 'String', setStr);
            disp('number of masses was changed...bad boy');
        end
    end
end

if zerome
    % init vectors if extforce isnt used....
    fextxv = zeros(MAXM);
    fextxm = zeros(MAXM);
end

