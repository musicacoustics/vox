
%displayimpulse, displays the impulse for each vocal folds, vocalis,
%mucosa, x- and z-direction. 

if get(Hndl.surfs, 'value') ==  1 && figdata.OldData ~= 2;
    try 
        if figdata.OldData == 1;%Data importet from file
            time = figdata.time;
            massaxis = figdata.massaxis;
            impulse_vx_left = figdata.impulse_vx_left;
            impulse_vx_right = figdata.impulse_vx_right;
            impulse_mx_left = figdata.impulse_mx_left;
            impulse_mx_right = figdata.impulse_mx_right;

            impulse_vz_left = figdata.impulse_vz_left;
            impulse_vz_right = figdata.impulse_vz_right;
            impulse_mz_left = figdata.impulse_mz_left;
            impulse_mz_right = figdata.impulse_mz_right;
        end
    end

    figure(80);
    set(gcf, 'Renderer', 'opengl');   % zbuffer was removed with R2014b graphics
    subplot(2,2,1); 
    surfl(time, massaxis, impulse_vx_left); %the matrics time, massaxis, impulse_vx_left are computed in writecontforc.m
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Vocalis left x-axis')

    subplot(2,2,2); 
    surfl(time, massaxis, impulse_vx_right);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Vocalis right x-axis')

    subplot(2,2,3); 
    surfl(time, massaxis, impulse_mx_left);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Mucosa left x-axis')


    subplot(2,2,4); 
    surfl(time, massaxis, impulse_mx_right);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Mucosa right x-axis')



    figure(81)
    set(gcf, 'Renderer', 'opengl');   % zbuffer was removed with R2014b graphics
    subplot(2,2,1); 
    surfl(time, massaxis, impulse_vz_left);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Vocalis left z-axis')

    subplot(2,2,2); 
    surfl(time, massaxis, impulse_vz_right);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Vocalis right z-axis')


    subplot(2,2,3); 
    surfl(time, massaxis, impulse_mz_left);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Mucosa left z-axis')

    subplot(2,2,4); 
    surfl(time, massaxis, impulse_mz_right);
    colormap(pink(100))
    xlabel('Time')
    ylabel('Mass')
    zlabel('Impulse (p)')
    title('Impulse Mucosa right z-axis')
  
end