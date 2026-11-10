function w0g = interpvf(w0,wmax,MAXM,a,lg,w0lp,wmaxla,w0rp,wmaxra);

% This function calculates the Restposition of the 
% Vocal folds in 3 different modes: Linear, und Polynomial
% for males and females.
% 
% Input:
%     - Distances of the vocal folds to Midline
%     - Event of Restpositions Pop-Up Menu (in Vocal Folds Mod)
% 
% Output:
%     - Interpolated polynoms.
%     - w0 (Restpositions)
%     
% Other .m files required:
% Inifold
% Params
%
% Author: Malte Kob, Edwin Calderón
% RWTH Aachen, Department of Phoniatrics, Pedaudiology and Communications Disorder
% email address: mkob@ukaachen.de, edwin.calderon@rwth-aachen.de
% Copyright (c) 2007-2008 Malte Kob
% $Revision: 1.98 $  $Date: 2008/17/03 16:44 $

global Infold male_dist female_dist male_dist_org female_dist_org male_dist_lin female_dist_lin;

% Messures of curved rest positions --------------------

%old male and female data
male_dist_org = [0.0 0.52 1.15 1.60 2.18 2.30 2.45 2.51]/1000;
female_dist_org = [0.0 0.80 1.38 1.73 1.95 2.10 2.20 2.40]/1000;

%new data
a_dist_org_new = [0.0 0.975 1.3 1.45 1.63 1.7 1.85 1.9]/1000;
b_dist_org_new = [0.0 1.0 1.4 1.7 1.95 2.0 2.23 2.35]/1000;
c_dist_org_new = [0.0 1.1 1.5 1.9 2.05 2.3 2.55 2.6]/1000;
d_dist_org_new = [0.0 1.0 1.3 1.65 1.8 1.85 2.0 2.2]/1000;

%linear data
male_dist_lin = [0:2.51/7:2.51]/1000;
female_dist_lin = [0:2.4/7:2.4]/1000;

a_dist_lin = [0:1.9/7:1.9]/1000;
b_dist_lin = [0:2.35/7:2.35]/1000;
c_dist_lin = [0:2.6/7:2.6]/1000;
d_dist_lin = [0:2.2/7:2.2]/1000;

%Output data
male_dist = male_dist_org - male_dist_lin;
female_dist = female_dist_org - female_dist_lin;

new_a_dist = a_dist_org_new - a_dist_lin;
new_b_dist = b_dist_org_new - b_dist_lin;
new_c_dist = c_dist_org_new - c_dist_lin;
new_d_dist = d_dist_org_new - d_dist_lin;

%Slider values for left and right folds
diffl = wmaxla(1) - w0lp(1);
diffr = wmaxra(1) - w0rp(1);

if (diffl==0) 
    %Parallel line to Midline
    dist_slider_left = ((ones(1,8)*(-25))+wmaxla(1))/1e6;
    linear_left = ([ones(1,MAXM)*(-25)]/1e6)+wmax(1,1);
elseif (diffl > 0) 
    %Line with positive gradient
    dist_slider_left = [w0lp(1):diffl/7:wmaxla(1)]/1e6;
    linear_left = [w0(1,1):(wmax(1,1)-w0(1,1))/(MAXM-1):wmax(1,1)]; 
elseif (diffl < 0) 
    %Line with negative gradient
    dist_slider_left = [w0lp(1):diffl/7:wmaxla(1)]/1e6;
    linear_left = [w0lp(1):diffl/(MAXM-1):wmaxla(1)]/1e6;
end

if (diffr==0)
    %Parallel line to Midline
    dist_slider_right = ((ones(1,8)*(-25))+wmaxra(1))/1e6; 
    linear_right = ([ones(1,MAXM)*(-25)]/1e6)+wmax(2,1);
elseif (diffr > 0)
    %Line with positive gradient
    dist_slider_right = [w0rp(1):diffr/7:wmaxra(1)]/1e6;
    linear_right = [w0(2,1):(wmax(2,1)-w0(2,1))/(MAXM-1):wmax(2,1)];
elseif (diffr < 0)
    %Line with negative gradient
    dist_slider_right = [w0rp(1):diffr/7:wmaxra(1)]/1e6;
    linear_right = [w0rp(1):diffr/(MAXM-1):wmaxra(1)]/1e6;
end

male_dist_left = male_dist + dist_slider_left;
male_dist_right = male_dist + dist_slider_right;
female_dist_left = female_dist + dist_slider_left;
female_dist_right = female_dist + dist_slider_right;

new_a_dist_left = new_a_dist + dist_slider_left;
new_a_dist_right = new_a_dist + dist_slider_right;
new_b_dist_left = new_b_dist + dist_slider_left;
new_b_dist_right = new_b_dist + dist_slider_right;
new_c_dist_left = new_c_dist + dist_slider_left;
new_c_dist_right = new_c_dist + dist_slider_right;
new_d_dist_left = new_d_dist + dist_slider_left;
new_d_dist_right = new_d_dist + dist_slider_right;

%Help variables ----------------------------------------
x = [0:2:14]/1000;
y = 0:a:lg;

%Polynoms  ---------------------------------------------
poly_male_left = pchip(x,male_dist_left,y);
poly_female_left = pchip(x,female_dist_left,y);
poly_male_right = pchip(x,male_dist_right,y);
poly_female_right = pchip(x,female_dist_right,y);

poly_new_a_left = pchip(x,new_a_dist_left,y);
poly_new_b_left = pchip(x,new_b_dist_left,y);
poly_new_a_right = pchip(x,new_a_dist_right,y);
poly_new_b_right = pchip(x,new_b_dist_right,y);
poly_new_c_left = pchip(x,new_c_dist_left,y);
poly_new_d_left = pchip(x,new_d_dist_left,y);
poly_new_c_right = pchip(x,new_c_dist_right,y);
poly_new_d_right = pchip(x,new_d_dist_right,y);

% initial width of glottal slit in m -------------------
val = Infold.shape;

if MAXM > 1
    for j = 1:2 % for left and right?
        for i = 1:MAXM   
            switch val
               case 1                       % for linear restposition
                   if j == 1
                      w0g(j,i) = linear_left(i);
                   elseif j == 2
                      w0g(j,i) = linear_right(i);
                   end
                   %w0g(j,i) = w0(j) + (wmax(j)-w0(j))/(MAXM-1)*(i-1);
               case 2                       % for female restposition
                   if j == 1
                       w0g(j,i) = poly_female_left(i);
                   elseif j == 2
                       w0g(j,i) = poly_female_right(i);
                   end
               case 3                       % for male restposition
                   if j == 1
                       w0g(j,i) = poly_male_left(i);
                   elseif j == 2
                       w0g(j,i) = poly_male_right(i);
                   end
                case 4
                    if j == 1
                        w0g(j,i) = poly_new_a_left(i);
                    elseif j ==2
                        w0g(j,i) = poly_new_a_right(i);
                    end
                case 5
                    if j == 1
                        w0g(j,i) = poly_new_b_left(i);
                    elseif j == 2
                        w0g(j,i) = poly_new_b_right(i);
                    end
                case 6
                    if j == 1
                        w0g(j,i) = poly_new_c_left(i);
                    elseif j == 2
                        w0g(j,i) = poly_new_c_right(i);
                    end
                case 7
                    if j == 1
                        w0g(j,i) = poly_new_d_left(i);
                    elseif j == 2
                        w0g(j,i) = poly_new_d_right(i);
                    end
            sususu = w0(j) + (wmax(j)-w0(j))/(MAXM-1)*(i-1);
            end
        end
    end
else
    w0g = w0;
end

