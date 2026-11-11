% Plot der Massen in der Draufsicht und im Schnitt durch die Massen

global inx

finx =  1; % index of folds for single display (sectional and 3D view)
xmax =  3;
xmin = -3;
zmax =  4;
zmin = -2;
NoColIndx = 1; %last Timestep without Collision
if (voxfigflag('Deflection of masses',1) == 1)&(size(Hndl.plotmassrec11,2) == MAXM)
    set(0,'CurrentFigure',Hndl.plotmassfig)
    plotedit(Hndl.plotmassfig,'off');
    plotedit(Hndl.plotmassfig,'hidetoolsmenu');

    % update side view
    for i= 1:MAXM
        subplot(Hndl.plotmassax1);
        set(Hndl.plotmassrec11(i), 'Position', 1000*[(i-1)*a, zv(finx,i)-thv/2, ...
            a, thv]);
        set(Hndl.plotmassrec12(i), 'Position', 1000*[(i-1)*a, zm(finx,i)-thm/2, ...
            a, thm]);
    end

    refresh = 1;
    testfill(xv, zv, dv, thv, xm, zm, dm, thm, a, MAXM, refresh, zmax, zmin,Infold);

    % update top view and change color if external force influences folds
    vocalisColor = [0.5 0.5 0.5];
    mucosaColor  = [0.7 0.7 0.7];
    if sum(sum(fextxv)) > 0
        vocalisColor = [0.6 0 0];
    elseif sum(sum(fextxv)) < 0
        vocalisColor = [0 0.6 0];
    end
    if sum(sum(fextxm)) > 0
        mucosaColor  = [0.8 0 0];
    elseif sum(sum(fextxm))  < 0
        mucosaColor  = [0 0.8 0];
    end

    for i= 1:MAXM
        subplot(Hndl.plotmassax3);
        set(Hndl.plotmassrec31a(2,i), 'Position',1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), (i-1)*a, dv+(Infold.rvoffset(i)/10000), a], 'FaceColor', vocalisColor);
        set(Hndl.plotmassrec31b(1,i), 'Position',1000*[-xv(1,i)-dv/2, (i-1)*a, dv+(Infold.lvoffset(i)/10000), a], 'FaceColor', vocalisColor);
        set(Hndl.plotmassrec32a(2,i), 'Position',1000*[ xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), (i-1)*a, dm+(Infold.rmoffset(i)/10000), a], 'FaceColor', mucosaColor);
        set(Hndl.plotmassrec32b(1,i), 'Position',1000*[-xm(1,i)-dm/2, (i-1)*a, dm+(Infold.lmoffset(i)/10000), a], 'FaceColor', mucosaColor);
        %edgeline
        if xv(2,i)<xm(2,i)
            set(Hndl.plotmassrec31c(2,i), 'XData', 1000*[ xv(2,i)-dv/2, xv(2,i)-dv/2], 'YData', 1000*[(i-1)*a, i*a],'Visible','on');
        else
            set(Hndl.plotmassrec31c(2,i), 'Visible','off');
        end
        set(Hndl.plotmassrec32c(2,i), 'XData', 1000*[ xm(2,i)-dm/2, xm(2,i)-dm/2], 'YData', 1000*[(i-1)*a, i*a]);
        %mo: rechts
        if xv(2,i)<xm(2,i)
            set(Hndl.plotmassrec31d(2,i), 'XData', 1000*[ xv(2,i)-dv/2, xv(2,i)+dv/2], 'YData', 1000*[(i-1)*a, i*a],'Visible','on');
        else
            set(Hndl.plotmassrec31d(2,i), 'Visible','off');
        end
        set(Hndl.plotmassrec32d(2,i), 'XData', 1000*[ xm(2,i)-dm/2, xm(2,i)-dm/2], 'YData', 1000*[(i-1)*a, i*a]);
        %links
        if xv(1,i)<xm(1,i)
            set(Hndl.plotmassrec31e(1,i), 'XData', 1000*[ xv(1,i)-dv/2, xv(1,i)-dv/2], 'YData', 1000*[(i-1)*a, i*a],'Visible','on');
        else
            set(Hndl.plotmassrec31e(1,i), 'Visible','off');
        end
        set(Hndl.plotmassrec32e(1,i), 'XData', 1000*[ -xm(1,i)+dm/2, -xm(1,i)+dm/2], 'YData', 1000*[(i-1)*a, i*a],'Visible','on');

        %opening
        if xm(1,i) -dm/2 < xv(1,i) -dv/2
            if xm(1,i)-dm/2 > 0
                set(Hndl.plotmassrec32f(2,i), 'Position',1000*[ 0, (i-1)*a, xm(1,i)-dm/2-(Infold.rmoffset(i)/10000), a], 'FaceColor', [1 0 0]);
            end
            if xm(1,i)-dm/2 < 0
               set(Hndl.plotmassrec32f(2,i), 'Position',1000*[ xm(1,i)-dm/2-(Infold.rmoffset(i)/10000), (i-1)*a, abs(xm(1,i)-dm/2-(Infold.rmoffset(i)/10000)), a], 'FaceColor', [0 0 1]);
            end            
            VibroGramm(MassTimeStep, i) = xm(1,i)-dm/2-(Infold.rmoffset(i)/10000);
        else
            if xv(1,i)-dv/2 > 0
                set(Hndl.plotmassrec32f(2,i), 'Position',1000*[ 0, (i-1)*a, xv(1,i)-dv/2-(Infold.rvoffset(i)/10000), a], 'FaceColor', [0 1 0]);
            end
            if xv(1,i)-dv/2 < 0
               set(Hndl.plotmassrec32f(2,i), 'Position',1000*[ xv(1,i)-dv/2+(Infold.rvoffset(i)/10000), (i-1)*a, abs(xv(1,i)-dv/2+(Infold.rvoffset(i)/10000)), a], 'FaceColor', [0 1 1]);               
            end
            VibroGramm(MassTimeStep, i) = xv(1,i)-dv/2-(Infold.rvoffset(i)/10000);
        end
        if xm(2,i) -dm/2 < xv(2,i)-dv/2            
             if xm(2,i)-dm/2 > 0
                set(Hndl.plotmassrec32g(2,i), 'Position',1000*[ 0, (i+MAXM-1)*a, xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), a], 'FaceColor', [1 0 0]);                
             end
             if xm(2,i)-dm/2 < 0
               set(Hndl.plotmassrec32g(2,i), 'Position',1000*[ xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), (i+MAXM-1)*a, abs(xm(2,i)-dm/2-(Infold.rmoffset(i)/10000)), a], 'FaceColor', [0 0 1]);               
             end
             VibroGramm(MassTimeStep, 2*MAXM-i+1) = xm(2,i)-dm/2-(Infold.rmoffset(i)/10000);
        else
             if xv(2,i)-dv/2 > 0
                set(Hndl.plotmassrec32g(2,i), 'Position',1000*[ 0, (i+MAXM-1)*a, xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), a], 'FaceColor', [0 1 0]);                
             end
             if xv(2,i)-dv/2 < 0
               set(Hndl.plotmassrec32g(2,i), 'Position',1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), (i+MAXM-1)*a, abs(xv(2,i)-dv/2-(Infold.rvoffset(i)/10000)), a], 'FaceColor', [0 1 1]);               
             end
             VibroGramm(MassTimeStep, 2*MAXM-i+1) = xv(2,i)-dv/2-(Infold.rvoffset(i)/10000);
        end
        
        if VibroGramm(MassTimeStep, i) + VibroGramm(MassTimeStep, 2*MAXM-i+1) < 0
            DeltaVib=VibroGramm(MassTimeStep, i) + VibroGramm(MassTimeStep, 2*MAXM-i+1);
            VibroGramm(MassTimeStep, i) = VibroGramm(MassTimeStep, i)- DeltaVib/2;
            VibroGramm(MassTimeStep, 2*MAXM-i+1) = VibroGramm(MassTimeStep, 2*MAXM-i+1) - DeltaVib/2;
        end
    end

    % update frequency txt
    if Infold.extForceF0inSamples(size(Infold.extForceF0inSamples, 2)) > 0
        ef_f0_Hz = Fs/Infold.extForceF0inSamples(size(Infold.extForceF0inSamples, 2));
        my_f0 = ['f0: ' sprintf('%5.1f', ef_f0_Hz) ' Hz'];
        set(Hndl.ef_f0_txt, 'String', my_f0);
    end

    % makin movie
    if GRONF & MOV & Hndl.movisgood > 0
        % at first get size from figure...
        set(Hndl.plotmassfig, 'units', 'pixels');
        posnsize = get(Hndl.plotmassfig, 'Position');
        set(Hndl.plotmassfig, 'units', 'normalized');
        sizex = posnsize(3)-(mod(posnsize(3), 4)); % make multiple of 4 because of indeo5 codec
        sizey = posnsize(4)-(mod(posnsize(4), 4)); % make multiple of 4 because of indeo5 codec
        % origin 0, not 1: [1 1 w h] reaches 1 pixel outside the figure,
        % which getframe now rejects
        grabposnsize = [0 0 sizex sizey];
        try
            grabframe    = getframe(Hndl.plotmassfig, grabposnsize);
            writeVideo(Hndl.mov, grabframe);   % addframe has been removed
        catch err   % e.g. window resized: frame size must stay constant
            close(Hndl.mov);
            Hndl.movisgood = -1;
            warning('Movie stopped after a frame could not be written: %s', err.message);
        end
    end

else	% create figure
    try
        set(0,'CurrentFigure',Hndl.plotmassfig)
        if size(Hndl.plotmassrec11,2) ~= MAXM
            clear Hndl.plotmassfig
            Hndl.plotmassrec11 = [];
            Hndl.plotmassrec12 = [];
            clf
        end
    catch
        Scrsize   = get(0,'Screensize');
        Scrwidth  = Scrsize(3);
        Scrheight = Scrsize(4);

        Hndl.plotmassfig = figure('visible', 'on', ...
            'NumberTitle','off', ...
            'Name','Deflection of masses', ...
            'Units','Normalized', ...
            'MenuBar', 'none',  ...
            'Position',[Scrwidth-0.5 Scrheight-0.5 0.25 0.5]);
        % (DoubleBuffer removed: no effect since R2014b graphics)

        % set pos of window
        dockwindowPosSize = get(Hndl.figureNumber, 'Position');
        try
            if ~isempty(Hndl.efgui)
                dockwindowPosSize = get(Hndl.efgui, 'Position');
            end
        end
        plotMassPosSize   = get(Hndl.plotmassfig, 'Position');
        newPMPosSize      = [dockwindowPosSize(1)+dockwindowPosSize(3)+0.005, dockwindowPosSize(2), plotMassPosSize(3), dockwindowPosSize(4)];
        set(Hndl.plotmassfig, 'Position', newPMPosSize);
    end;

    Hndl.plotmassax1 = subplot(4,1,2);

    % side view
%    set(gca,'DrawMode','fast')
    rectangle('Position',[-1/2*a*1000, zmin, ...
        1/2*a*1000, zmax-zmin], 'FaceColor', [0.4 0.4 0.4], ...
        'Parent', Hndl.plotmassax1);
    rectangle('Position',[MAXM*a*1000, zmin, ...
        1/2*a*1000, zmax-zmin], 'FaceColor', [0.4 0.4 0.4]);
    for i= 1:MAXM
        Hndl.plotmassrec11(i) = rectangle('Position',1000*[(i-1)*a, zv(1,i)-thv/2, ...
            a, thv], 'FaceColor', [0.5 0.5 0.5]);
        Hndl.plotmassrec12(i) = rectangle('Position',1000*[(i-1)*a, zm(1,i)-thm/2, ...
            a, thm], 'FaceColor' , [0.7 0.7 0.7]);
    end
    axis([-1/2*a*1000 (MAXM+1/2)*a*1000 zmin zmax]);
    line([0 MAXM*a*1000], [0 0], ...
        'Color','k', 'LineStyle',':')
    xlabel('One fold, side view, y [mm] -->');
    ylabel('z [mm] -->');

    % perspective plot on masses
    Hndl.plotmassax2 = subplot(4,1,1);
    set(gca,'NextPlot','add');%,'DrawMode','fast')
    refresh = 0;
    testfill(xv, zv, dv, thv, xm, zm, dm, thm, a, MAXM, refresh, zmax, zmin,Infold);

    % top plot on masses
    Hndl.plotmassax3 = subplot(4,1,3);
%    set(gca,'DrawMode','fast')
    rectangle('Position',[ xmin,   -a/2*1000, 2*(-xmin), a/2*1000], 'FaceColor', [0.4 0.4 0.4]);
    rectangle('Position',[ xmin, MAXM*a*1000, 2*(-xmin), a/2*1000], 'FaceColor',[0.4 0.4 0.4]);
    for i= 1:MAXM
        Hndl.plotmassrec31a(2,i) = rectangle('Position',1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), (i-1)*a, dv+(Infold.rvoffset(i)/10000), a], 'FaceColor', [0.5 0.5 0.5]);
        Hndl.plotmassrec31b(1,i) = rectangle('Position',1000*[-xv(1,i)-dv/2, (i-1)*a, dv+(Infold.lvoffset(i)/10000), a], 'FaceColor', [0.5 0.5 0.5]);
        Hndl.plotmassrec32a(2,i) = rectangle('Position',1000*[ xm(2,i)-dm/2, (i-1)*a, dm, a], 'FaceColor' , [0.7 0.7 0.7]);
        Hndl.plotmassrec32b(1,i) = rectangle('Position',1000*[-xm(1,i)-dm/2, (i-1)*a, dm, a], 'FaceColor' , [0.7 0.7 0.7]);
        % plot edgeline
        Hndl.plotmassrec31c(2,i) = line(1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), xv(2,i)-dv/2-(Infold.rvoffset(i)/10000)], 1000*[(i-1)*a, i*a], 'Color', 'black');
        Hndl.plotmassrec32c(2,i) = line(1000*[ xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), xm(2,i)-dm/2-(Infold.rmoffset(i)/10000)], 1000*[(i-1)*a, i*a], 'Color', 'black');
    end
    axis([-3 3 -1/2*a*1000 (MAXM+1/2)*a*1000]);
    line([0 0], [0 MAXM*a*1000], ...
        'Color','k', 'LineStyle',':')
    xlabel('Both folds, top view, x [mm] -->');
    ylabel('y [mm] -->');

    %mo: test
    Hndl.plotmassax4 = subplot(4,1,4);
%    set(gca,'DrawMode','fast')
    rectangle('Position',[ xmin,   -a/2*1000, 2*(-xmin), a/2*1000], 'FaceColor', [0.4 0.4 0.4]);
    rectangle('Position',[ xmin, MAXM*a*1000, 2*(-xmin), a/2*1000], 'FaceColor',[0.4 0.4 0.4]);
    for i= 1:MAXM
        % plot edgeline right
        Hndl.plotmassrec31d(2,i) = line(1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), xv(2,i)-dv/2-(Infold.rvoffset(i)/10000)], 1000*[(i-1)*a, i*a], 'Color', 'black');
        Hndl.plotmassrec32d(2,i) = line(1000*[ xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), xm(2,i)-dm/2-(Infold.rmoffset(i)/10000)], 1000*[(i-1)*a, i*a], 'Color', 'black');
        %left
        Hndl.plotmassrec31e(1,i) = line(1000*[ xv(2,i)-dv/2-(Infold.rvoffset(i)/10000), xv(2,i)-dv/2-(Infold.rvoffset(i)/10000)], 1000*[(MAXM+i-1)*a, MAXM+i*a], 'Color', 'black');
        Hndl.plotmassrec32e(1,i) = line(1000*[ xm(2,i)-dm/2-(Infold.rmoffset(i)/10000), xm(2,i)-dm/2-(Infold.rmoffset(i)/10000)], 1000*[(MAXM+i-1)*a, MAXM+i*a], 'Color', 'black');
        %opening
        if xm(1,i) + xm(2,i)-dm > 0
            Hndl.plotmassrec32f(2,i) = rectangle('Position',1000*[0, (i-1)*a, xm(1,i), a], 'FaceColor' , [1 0 0]);
            Hndl.plotmassrec32g(2,i) = rectangle('Position',1000*[0, (i-1)*a, xm(2,i), a], 'FaceColor' , [1 0 0]);
        end
        if xm(1,i) + xm(2,i)-dm < 0
            Hndl.plotmassrec32f(2,i) = rectangle('Position',1000*[0, (i-1)*a, xm(1,i), a], 'FaceColor' , [0 1 1]);
            Hndl.plotmassrec32g(2,i) = rectangle('Position',1000*[0, (i-1)*a, xm(2,i), a], 'FaceColor' , [0 1 1]);
        end
        
    end
   
    axis([-1 1 -1/2*a*1000 (2*MAXM+1)*a*1000]);
    line([0 0], [0 MAXM*a*1000], ...
        'Color','k', 'LineStyle',':')
    xlabel('Both folds, top view, x [mm] -->');
    ylabel('y [mm] -->');

    % layout (#70): with subplot(4,1,k) the 3D view got a quarter of the
    % window height (about 100 pixels in a window of 720): squashed box,
    % overlapping labels. The 3D view gets the upper 28 %, the three 2D
    % panels share the rest.
    set(Hndl.plotmassax2, 'Position', [0.10 0.70 0.85 0.28]);
    set(Hndl.plotmassax1, 'Position', [0.13 0.52 0.775 0.12]);
    set(Hndl.plotmassax3, 'Position', [0.13 0.31 0.775 0.13]);
    set(Hndl.plotmassax4, 'Position', [0.13 0.10 0.775 0.13]);

    % make text for frequency
    btnPos = [0.35 0 0.40 0.030];
    Hndl.ef_f0_txt = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'HorizontalAlignment','center', ...
        'String','n/a');
    voxcolor(Hndl.plotmassfig);   % black edge and zero lines follow the theme
end
inx=inx+1;