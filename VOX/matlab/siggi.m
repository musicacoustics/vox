% This program calculates stepwise the glottal flow through the glottis
% and then the resulting new positions of the n masses.
% The m-files used in this program are explained below:
%
%        inifold        -        initialisation of vocal fold constants
%        press          -        calculate the pressuredrops in the glottis from
%                                        the flow u
%        flow           -        one-step-calculation of the glottal flow u and its
%                                        derivative du (= du/dt) from equivalent curcuit
%                                        elements
%        aerforc        -        aerodynamic forces on the masses, calculated from
%                                        glottal pressures
%        cplforc        -        coupling forces between neighbour masses, vocalis-
%                                        and mucosa-masses and coupling to the boundary
%        dampforc       -        damping forces, calculated from tension between
%                                        neighbour masses and spring-constants
%        contforc       -        contact forces, if the glottis is closed
%        deq16m         -        one-step-calculation of the new masspositions,
%                                        that result from the forces acting on the 16 masses
%        glotpar        -        calculation of glottal widths an glottal areas
%
%
% The graphic output routines require the following files
%
%----------------------------------------------------------------------

global figdata;%mo

%MOV   = 0;
xlim  = 30.1;
ALONE = Infold.flags.ALONE;

% create waitbar ------------------------------------------------------
if ALONE
    h1 = waitbar(0, 'Generating vocal fold signal...');
end

% initialisation ------------------------------------------------------
BRK = 0;

foldcons;

iscombi = Infold.combicalc; % flag for combimode

if Infold.k == 1        % first call: initialization
    params;
    inifold;

else
    xv     = Parfold.var.masspos.xv_pos;
    xm     = Parfold.var.masspos.xm_pos;
    zv     = Parfold.var.masspos.zv_pos;
    zm     = Parfold.var.masspos.zm_pos;
    x_1    = Parfold.var.masspos.x_oldpos;
    z_1    = Parfold.var.masspos.z_oldpos;
    num_it = Parfold.const.num_it;
    T      = Parfold.const.timestep;

    params;
end

% time initialisation ---------------------------------------------------

T = 1/Fs;        %s
if ALONE
    num_it = floor(Infold.calctime*Fs);
else
    num_it = 1;
end
MassTimeStep=1;

% fill parfold struct with constants ------------------------------------

if ~ALONE
    Parfold.const.timestep = T;
    Parfold.const.num_it = num_it;
end

% this loop is not used when called from combicalc. it has its own loop
for n = 1 : 1 : num_it

    % when not called from combicalc set Infold.k
    if num_it>1
        Infold.k = n;      % parameter for foldsig
    end

    % dont know who breaks here....
    if BRK == 1
        display('stopping');
        break
    end

    params;

    % rising of transglottal pressure --------------------------
    if ALONE
        ps0 = ptg*(1+tanh((n-30)/10))/2;
    else
        ps0 = ptg*(1+tanh((k-30)/10))/2;
    end

    % calculate the glottal widths and areas --------------------
    glotpar;

    % calculate flow and resulting pressures -------------------
    flow;
    press;

    % calculate forces on the masses ---------------------------
    aerforc;
    cplforc;
    contforc;
    dampforc;
    external_forces; % adds an amount to dampforces (basti)
    
    
    %writing the contactforce for each vocal folds in matrics
    writecontforc;


    
    % solve differential equation of movement ------------------

    % set x((n-1)T) and x((n-2)T) for calculation of x(nT)
    xvor1 = [xv, xm];
    zvor1 = [zv, zm];

    % differential equation
    [xv,xm,zv,zm] = deq16m(T, fxv, fxm, fzv, fzm, ...
        fexv, fexm, fezv, fezm, ...
        fcxv, fcxm, fczv, fczm, ...
        fdxv, fdxm, fdzv, fdzm, ...
        fextxv, fextxm, ...
        [xv xm], x_1, [zv zm], z_1, lmv, rmv, lmm, rmm);

    x_1 = xvor1;
    z_1 = zvor1;
    
    
    
    % calculation of velocity and impuls of the vocalis folds and 
    % writing the impulse for each vocal folds in matrics    -------------
    [ velocity_vx, velocity_vz, velocity_mx, velocity_mz ] = velocity(T, xv, xm, zv, zm, x_1, z_1 );
    [ impulse_vx, impulse_vz, impulse_mx, impulse_mz ] = impuls( lmv, lmm, rmv, rmm, velocity_vx, velocity_vz, velocity_mx, velocity_mz );
    writeimpulse;
    
    

    % graphic stuff ----------------------------------------------------
    if GRONF && PMON
        plotmass;
        drawnow;
        MassTimeStep = MassTimeStep+1;
    end;
    if ALONE
        y(n)    = pinak;
        ysub(n) = ps;
        ys0(n)  = ps0;
        minareamm(n)  = sum_amin*1e6;
        rvocmm(n)     = pi*Infold.rvoc^2*1e6;
        rtrachmm(n)   = pi*Infold.rtrach^2*1e6;
        sum_uccm(n)   = sum_u*1e6;
        %=====================================================
        % Graphic output of intermediate signals
        if GRON
            [isfig,figh]=figflag('Sound pressure during calculation',1);
            if (isfig == 1)	% figure exists
                set(0,'CurrentFigure', figh)
            end
            time     = [1:n]/Fs*1000;
            Vektor1  = [rvocmm;rtrachmm;minareamm];
            Vektor2  = [y;ysub;ys0];
            Vektor6  = [sum_uccm;gradient(sum_uccm)];
            Vektor31 = [max(testfexv1,[],2)';max(testfexm1,[],2)';max(testfezv1,[],2)';max(testfezm1,[],2)'];
            Vektor32 = [max(testfexv2,[],2)';max(testfexm2,[],2)';max(testfezv2,[],2)';max(testfezm2,[],2)'];
            Vektor41 = [max(testfyxv1,[],2)';max(testfyxm1,[],2)';max(testfyzv1,[],2)';max(testfyzm1,[],2)'];
            Vektor42 = [max(testfyxv2,[],2)';max(testfyxm2,[],2)';max(testfyzv2,[],2)';max(testfyzm2,[],2)'];
            Vektor51 = [max(testfdxv1,[],2)';max(testfdxm1,[],2)';max(testfdzv1,[],2)';max(testfdzm1,[],2)'];
            Vektor52 = [max(testfdxv2,[],2)';max(testfdxm2,[],2)';max(testfdzv2,[],2)';max(testfdzm2,[],2)'];
            if (isfig == 1)&(n>1)	% figure exists and >1 sample plotted
                yaxe11 = Hndl.infofig.yaxe11;
                yaxe12 = Hndl.infofig.yaxe12;
                yaxe13 = Hndl.infofig.yaxe13;
                yaxe21 = Hndl.infofig.yaxe21;
                yaxe22 = Hndl.infofig.yaxe22;
                yaxe31 = Hndl.infofig.yaxe31;
                yaxe32 = Hndl.infofig.yaxe32;
                yaxe41 = Hndl.infofig.yaxe41;
                yaxe42 = Hndl.infofig.yaxe42;
                sig1   = Hndl.infofig.sig1;
                sig2   = Hndl.infofig.sig2;
                sig6   = Hndl.infofig.sig6;
                sig31  = Hndl.infofig.sig31;
                sig41  = Hndl.infofig.sig41;
                sig51  = Hndl.infofig.sig51;
                sig32  = Hndl.infofig.sig32;
                sig42  = Hndl.infofig.sig42;
                sig52  = Hndl.infofig.sig52;

                for ii = 1:size(sig1,1)
                    set(sig1(ii),'XData',time, 'YData',Vektor1(ii,:));
                end;
                for ii = 1:size(sig2,1)
                    set(sig2(ii),'XData',time, 'YData',Vektor2(ii,:));
                end;
                for ii = 1:size(sig6,1)
                    set(sig6(ii),'XData',time, 'YData',Vektor6(ii,:));
                end;
                for ii = 1:size(sig31,1)
                    set(sig31(ii),'XData',time, 'YData',Vektor31(ii,:));
                end;
                for ii = 1:size(sig32,1)
                    set(sig32(ii),'XData',time, 'YData',Vektor32(ii,:));
                end;
                for ii = 1:size(sig41,1)
                    set(sig41(ii),'XData',time, 'YData',Vektor41(ii,:));
                end;
                for ii = 1:size(sig42,1)
                    set(sig42(ii),'XData',time, 'YData',Vektor42(ii,:));
                end;
                for ii = 1:size(sig51,1)
                    set(sig51(ii),'XData',time, 'YData',Vektor51(ii,:));
                end;
                for ii = 1:size(sig52,1)
                    set(sig52(ii),'XData',time, 'YData',Vektor52(ii,:));
                end;
                set(yaxe11,'XLim', [max(time)-xlim max(time)]);
                set(yaxe12,'XLim', [max(time)-xlim max(time)]);
                set(yaxe13,'XLim', [max(time)-xlim max(time)]);
                set(yaxe21,'XLim', [max(time)-xlim max(time)]);
                set(yaxe22,'XLim', [max(time)-xlim max(time)]);
                set(yaxe31,'XLim', [max(time)-xlim max(time)]);
                set(yaxe32,'XLim', [max(time)-xlim max(time)]);
                set(yaxe41,'XLim', [max(time)-xlim max(time)]);
                set(yaxe42,'XLim', [max(time)-xlim max(time)]);

            else	% initialize output
                if (isfig == 1)&(n==1)
                    clf(gcf);
                else
                    Hndl.infofigure = figure('visible','on','NumberTitle','off', ...
                        'Name','Sound pressure during calculation','Units','normalized',...
                        'Position',[.55 .55 .45 .4]);
                    set(Hndl.infofigure,'DoubleBuffer','on');
                end

                Hndl.infofig.yaxe11 = subplot(3,3,1);
                [Hndl.infofig.sig1] = plot(time,Vektor1);
                yaxe11 = Hndl.infofig.yaxe11;
                sig1 = Hndl.infofig.sig1;
                set(sig1,'LineStyle','-')
                set(sig1(1),'Color','g')
                set(sig1(2),'Color','b')
                set(sig1(3),'Color','k')
                set(yaxe11,'XLim', [max(time)-10 max(time)]);
                set(yaxe11,'YLimMode', 'auto');
                set(yaxe11,'YTickMode', 'auto');
                set(get(yaxe11,'YLabel'),'String','A^g (g), A_g (b), A_{min} (k) [mm^2]');
                grid on

                Hndl.infofig.yaxe12 = subplot(3,3,4);
                [Hndl.infofig.sig2] = plot(time,Vektor2);
                yaxe12 = Hndl.infofig.yaxe12;
                sig2   = Hndl.infofig.sig2;
                set(sig2,'LineStyle','-')
                set(sig2(1),'Color','b')
                set(sig2(2),'Color','g')
                set(sig2(3),'Color','k')
                set(yaxe12,'XLim', [max(time)-10 max(time)]);
                set(yaxe12,'YLimMode', 'auto');
                set(yaxe12,'YTickMode', 'auto');
                set(get(yaxe12,'Ylabel'),'String','p^{g} (b), p_{g} (g), p_{s0} (k) [Pa]');
                grid on

                Hndl.infofig.yaxe13 = subplot(3,3,7);
                [Hndl.infofig.sig6] = plot(time,Vektor6);
                yaxe13 = Hndl.infofig.yaxe13;
                sig6 = Hndl.infofig.sig6;
                set(sig6,'LineStyle','-')
                set(sig6(1),'Color','b')
                set(sig6(2),'Color','r')
                set(yaxe13,'XLim', [max(time)-xlim max(time)]);
                set(yaxe13,'YLimMode', 'auto');
                set(yaxe13,'YTickMode', 'auto');
                set(get(yaxe13,'Ylabel'),'String','u (b) [cm^3/s,], du/dt (r) [cm^3/s^2]' );
                xlabel('Time [ms]');
                grid on

                Hndl.infofig.yaxe21 = subplot(3,3,2);
                [Hndl.infofig.sig31] = plot(time,Vektor31);
                yaxe21 = Hndl.infofig.yaxe21;
                sig31 = Hndl.infofig.sig31;
                set(sig31(1),'Color','r')
                set(sig31(2),'Color','g')
                set(sig31(3),'Color','b')
                set(sig31(4),'Color','k')
                set(yaxe21,'XLim', [max(time)-xlim max(time)]);
                set(yaxe21,'YLimMode', 'auto');
                set(yaxe21,'YTickMode', 'auto');
                set(get(yaxe21,'Ylabel'),'String','F_{aerod.,max} [N]');
                grid on

                Hndl.infofig.yaxe22 = subplot(3,3,3);
                [Hndl.infofig.sig32] = plot(time,Vektor32);
                yaxe22 = Hndl.infofig.yaxe22;
                sig32 = Hndl.infofig.sig32;
                set(sig32(1),'Color','r')
                set(sig32(2),'Color','g')
                set(sig32(3),'Color','b')
                set(sig32(4),'Color','k')
                set(yaxe22,'XLim', [max(time)-xlim max(time)]);
                set(yaxe22,'YLimMode', 'auto');
                set(yaxe22,'YTickMode', 'auto');
                set(get(yaxe22,'Ylabel'),'String','F_{aerod.,max} [N]');
                grid on

                Hndl.infofig.yaxe31 = subplot(3,3,5);
                [Hndl.infofig.sig41] = plot(time,Vektor41);
                yaxe31 = Hndl.infofig.yaxe31;
                sig41 = Hndl.infofig.sig41;
                set(sig41(1),'Color','r')
                set(sig41(2),'Color','g')
                set(sig41(3),'Color','b')
                set(sig41(4),'Color','k')
                set(yaxe31,'XLim', [max(time)-xlim max(time)]);
                set(yaxe31,'YLimMode', 'auto');
                set(yaxe31,'YTickMode', 'auto');
                set(get(yaxe31,'Ylabel'),'String','F_{coupl.,max} [N]');
                grid on

                Hndl.infofig.yaxe32 = subplot(3,3,6);
                [Hndl.infofig.sig42] = plot(time,Vektor42);
                yaxe32 = Hndl.infofig.yaxe32;
                sig42 = Hndl.infofig.sig42;
                set(sig42(1),'Color','r')
                set(sig42(2),'Color','g')
                set(sig42(3),'Color','b')
                set(sig42(4),'Color','k')
                set(yaxe32,'XLim', [max(time)-xlim max(time)]);
                set(yaxe32,'YLimMode', 'auto');
                set(yaxe32,'YTickMode', 'auto');
                set(get(yaxe32,'Ylabel'),'String','F_{coupl.,max} [N]');
                grid on

                Hndl.infofig.yaxe41 = subplot(3,3,8);
                [Hndl.infofig.sig51] = plot(time,Vektor51);
                yaxe41 = Hndl.infofig.yaxe41;
                sig51 = Hndl.infofig.sig51;
                set(sig51(1),'Color','r')
                set(sig51(2),'Color','g')
                set(sig51(3),'Color','b')
                set(sig51(4),'Color','k')
                set(yaxe41,'XLim', [max(time)-xlim max(time)]);
                set(yaxe41,'YLimMode', 'auto');
                set(yaxe41,'YTickMode', 'auto');
                set(get(yaxe41,'Ylabel'),'String','F_{damp.,max} [N]');
                set(get(yaxe41,'Xlabel'),'String','voc._x (r)  muc._x (g)  voc._z (b)  muc._z (k)');
                grid on

                Hndl.infofig.yaxe42 = subplot(3,3,9);
                [Hndl.infofig.sig52] = plot(time,Vektor52);
                yaxe42 = Hndl.infofig.yaxe42;
                sig52 = Hndl.infofig.sig52;
                set(sig52(1),'Color','r')
                set(sig52(2),'Color','g')
                set(sig52(3),'Color','b')
                set(sig52(4),'Color','k')
                set(yaxe42,'XLim', [max(time)-xlim max(time)]);
                set(yaxe42,'YLimMode', 'auto');
                set(yaxe42,'YTickMode', 'auto');
                set(get(yaxe42,'Ylabel'),'String','F_{damp.,max} [N]');
                set(get(yaxe42,'Xlabel'),'String','voc._x (r)  muc._x (g)  voc._z (b)  muc._z (k)');
                grid on
            end
        end; % of GRONs
    end


    % waitbar step -----------------------------------------------------
    if ALONE
        try
            waitbar(n/num_it)
        end
    end
end % of loop
if ALONE
  BRK = 0;   % in combi mode keep BRK: combicalc checks it after this step
  if ishghandle(h1)   % vox('break') may have closed it already
    close(h1)
  end
end


time = timeA;%mo

%mo:preserve data for figure recreation without re-calculation
figdata.fcxv_left = fcxv_left;
figdata.fcxv_right = fcxv_right;
figdata.fcxm_left = fcxm_left;
figdata.fcxm_right = fcxm_right;

figdata.fczv_left = fczv_left;
figdata.fczv_right = fczv_right;
figdata.fczm_left = fczm_left;
figdata.fczm_right = fczm_right;

figdata.time = time;
figdata.massaxis = massaxis;
figdata.impulse_vx_left = impulse_vx_left;
figdata.impulse_vx_right = impulse_vx_right;
figdata.impulse_mx_left = impulse_mx_left;
figdata.impulse_mx_right = impulse_mx_right;

figdata.impulse_vz_left = impulse_vz_left;
figdata.impulse_vz_right = impulse_vz_right;
figdata.impulse_mz_left = impulse_mz_left;
figdata.impulse_mz_right = impulse_mz_right;

try
    figdata.vibro = VibroGramm;
end

figdata.OldData = 0;%mo: New data calculated

if ~iscombi
    %displays the contact force of each vocal folds in separate 3D grafics
    displaycontforc;
    %displays the impulse of each vocal folds in separate 3D grafics
    displayimpuls;
    if get(Hndl.vibro, 'value') == 1
        VibroHndl = figure('name','Phonovibrogramm','NumberTitle','off');
        surf(VibroGramm', 'linestyle', 'none');
        axis([1 MassTimeStep 1 2*MAXM])
        %Calculations for Colormap
        cMap=zeros(100,3);
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
    end 
    
    set(Hndl.surfs, 'enable','on')
    figdata.OldData = 1;%mo: Calculation excecuted
end

% close video file, otherwise we cannot open it
if GRONF & MOV & ~iscombi & Hndl.movisgood > 0
    display('saved avifile');
    Hndl.mov = close (Hndl.mov);
end

% save area function for later, when external forces is active
    guiname = 'external_forces_gui';        % name of gui
    [isda]  = figflag(guiname, 1);
    if isda
       Hndl.efgui     = openfig(guiname, 'reuse');
       handles        = guihandles(Hndl.efgui);
       ef_force       = get(handles.forceslider,     'Value'); % get value of force
       % take duration into account
       ef_duration    = get(handles.durationslider,  'Value')*100; % get value of duration in percent of f0
       if ef_force>0 && ef_duration>0
           areafilename   = ['externalforce_glottalarea_' sprintf('%g', ef_force*100) 'mN_'  sprintf('%g', ef_duration) 'percent.csv'];
           csvwrite(areafilename, Infold.completeareafunction);
           display(['wrote area function into file: ' areafilename]);
       end
    end

% what is this for?
if GRON & MOV
    saveas(Hndl.infofigure,Hndl.foldmovfig)
end

% close waitbar -------------------------------------------------------
if ALONE
    f = findobj(allchild(0),'flat','Tag','TMWWaitbar');
    if ~isempty(f)
        close(f)
    end
end

if ~ALONE
    Parfold.var.masspos.xv_pos = xv;
    Parfold.var.masspos.xm_pos = xm;
    Parfold.var.masspos.zv_pos = zv;
    Parfold.var.masspos.zm_pos = zm;
    Parfold.var.masspos.x_oldpos = x_1;
    Parfold.var.masspos.z_oldpos = z_1;
    Parfold.var.flow = sum_u;
end
