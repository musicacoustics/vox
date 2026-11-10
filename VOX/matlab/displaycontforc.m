
%displaycontforc, displays the contact forc for each vocal folds, vocalis,
%mucosa, x- and z-direction.  

if get(Hndl.surfs, 'value') ==  1 && figdata.OldData ~= 2;
    
    try 
        if figdata.OldData == 1;
            time = figdata.time;%mo:get Old Data
            massaxis = figdata.massaxis;
            fcxv_left = figdata.fcxv_left;
            fcxv_right = figdata.fcxv_right;
            fcxm_left = figdata.fcxm_left;
            fcxm_right = figdata.fcxm_right;

            fczv_left = figdata.fczv_left;
            fczv_right = figdata.fczv_right;
            fczm_left = figdata.fczm_left;
            fczm_right = figdata.fczm_right;
        end
    end
    
    figure(60)
    set(gcf, 'Renderer', 'opengl');   % zbuffer was removed with R2014b graphics
    subplot(2,2,1); 
    surfl(time, massaxis, fcxv_left); %the matrics time, massaxis, fcxv_left are computed in writecontforc.m
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Vocalis left x-axis')

    subplot(2,2,2);
    surfl(time, massaxis, fcxv_right);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Vocalis right x-axis')

    subplot(2,2,3);
    surfl(time, massaxis, fcxm_left);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Mucosa left x-axis')

    subplot(2,2,4);
    surfl(time, massaxis, fcxm_right);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Mucosa right x-axis')



    figure(61);
    set(gcf, 'Renderer', 'opengl');   % zbuffer was removed with R2014b graphics
    subplot(2,2,1);
    surfl(time, massaxis, fczv_left);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Vocalis left z-axis')

    subplot(2,2,2);
    surfl(time, massaxis, fczv_right);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Vocalis right z-axis')

    subplot(2,2,3);
    surfl(time, massaxis, fczm_left);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Mucosa left z-axis')


    subplot(2,2,4);
    surfl(time, massaxis, fczm_right);
    alpha(.4)
    xlabel('Time')
    ylabel('Mass')
    zlabel('Contact Force (N)')
    title('Mucosa right z-axis')
end