% func that draws deflection of masses part
function   testfill(xv, zv, dv, thv, xm, zm, dm, thm, a, MAXM, refresh, zmax, zmin, Infold);

% Perspective view of the masses of one fold (window "Deflection of
% masses", upper panel). Every mass is drawn with the three faces that the
% view shows: front (y = (i-1)*a), medial (smallest x) and top.
%
% Changes for #70 (drawing errors when the folds close):
% - The medial edges are not drawn beyond the midline x = 0. In a
%   collision the model lets the masses overlap the midline by a few
%   micrometres; the axes start at x = 0, so the medial faces were cut away
%   and the masses looked like loose plates.
% - The mucosa is drawn as the part of its box that lies outside the
%   vocalis box (front face up to an L shape, medial and top face
%   shortened). Before, the case was chosen with comparisons of all masses
%   of both folds (zm, zv instead of zm(j,i), zv(j,i)), and a mucosa lying
%   exactly on the vocalis switched by rounding between the cases, one of
%   them with a gap of 0.1 mm; one edge used the offset of the mucosa for
%   the vocalis.
% Every face has 6 vertices (rectangles repeat their last vertex).

global Hndl

j=2; % only one fold (1=left, 2=right)
tol = 1e-9;   % [m]: a mucosa lying on the vocalis does not overlap it

for i = 1:MAXM
   % edges [m]: medial edge with the offset, as in the top view, not beyond
   % the midline
   v1 = max(xv(j,i)-dv/2-(Infold.rvoffset(i)/10000), 0);   % vocalis medial
   v2 = max(xv(j,i)+dv/2, v1);                              % vocalis lateral
   m1 = max(xm(j,i)-dm/2-(Infold.rmoffset(i)/10000), 0);   % mucosa medial
   m2 = max(xm(j,i)+dm/2, m1);                              % mucosa lateral
   vz1 = zv(j,i)-thv/2;  vz2 = zv(j,i)+thv/2;
   mz1 = zm(j,i)-thm/2;  mz2 = zm(j,i)+thm/2;
   y0 = (i-1)*a;  y1 = i*a;

   % vocalis masses: front, medial, top
   [Xv, Yv, Zv] = faces([v1 vz1; v2 vz1; v2 vz2; v1 vz2], ...
      [y0 vz1; y1 vz1; y1 vz2; y0 vz2], [v1 y0; v1 y1; v2 y1; v2 y0], v1, y0, vz2);

   % mucosa masses: the part outside the vocalis
   overlap = (m1 < v2-tol) && (m2 > v1+tol) && (mz1 < vz2-tol) && (mz2 > vz1+tol);
   medpart = m1 < v1-tol;     % part medial of the vocalis
   uppart  = mz2 > vz2+tol;   % part above the vocalis
   if ~overlap                % whole box
      Pf = [m1 mz1; m2 mz1; m2 mz2; m1 mz2];
      zb = mz1;  xb = m2;
   elseif medpart && uppart   % L-shaped front face
      Pf = [m1 mz1; v1 mz1; v1 vz2; m2 vz2; m2 mz2; m1 mz2];
      zb = mz1;  xb = m2;
   elseif uppart              % on the vocalis: from its top
      Pf = [m1 vz2; m2 vz2; m2 mz2; m1 mz2];
      zb = vz2;  xb = m2;
   elseif medpart             % beside the vocalis: up to its medial edge
      Pf = [m1 mz1; v1 mz1; v1 mz2; m1 mz2];
      zb = mz1;  xb = v1;
   else                       % inside the vocalis: nothing to see
      Pf = [m1 mz2];
      zb = mz2;  xb = m1;
   end
   [Xm, Ym, Zm] = faces(Pf, [y0 zb; y1 zb; y1 mz2; y0 mz2], ...
      [m1 y0; m1 y1; xb y1; xb y0], m1, y0, mz2);

   tcolor(1,1,1:3) = [.5 .5 .5];
   if refresh
      for ii = 1:size(Xv,2)
         set(Hndl.plotmassrec21(i,ii), 'XData', Xv(:,ii));
         set(Hndl.plotmassrec21(i,ii), 'YData', Yv(:,ii));
         set(Hndl.plotmassrec21(i,ii), 'ZData', Zv(:,ii));
      end
   else
      %  	hold on
      Hndl.plotmassrec21(i,:) = fill3(Xv,Yv,Zv,tcolor);
   end
   tcolor(1,1,1:3) = [.7 .7 .7];
   if refresh
      for ii = 1:size(Xm,2) % for each face
         set(Hndl.plotmassrec22(i,ii), 'XData', Xm(:,ii));
         set(Hndl.plotmassrec22(i,ii), 'YData', Ym(:,ii));
         set(Hndl.plotmassrec22(i,ii), 'ZData', Zm(:,ii));
      end
   else
      Hndl.plotmassrec22(i,:) = fill3(Xm,Ym,Zm,tcolor);
      %		rectangle('Position',[-1/2*a*1000, zmin, ...
      %		1/2*a*1000, zmax-zmin], 'FaceColor', [0.4 0.4 0.4], ...
      %		'Parent', Hndl.plotmassax2);

      axis([0 3 0 15 -2 3]);
      view(3)
      xlabel('x [mm]')
      ylabel('y [mm]')
      zlabel('z [mm]')
      %    drawnow
      %    hold off
   end % of if refresh
end % of for i = 1:MAXM


function [X, Y, Z] = faces(front, medial, top, x0, y0, z0)
% vertex matrices [mm] of the three faces, one column per face, 6 rows:
% front [x z] at y = y0, medial [y z] at x = x0, top [x y] at z = z0 [m];
% a face without area (zb = mz2 or xb = m1) is not visible
pad = @(P) [P; repmat(P(end,:), 6-size(P,1), 1)];
front = pad(front);  medial = pad(medial);  top = pad(top);
X = 1000*[front(:,1), x0*ones(6,1), top(:,1)];
Y = 1000*[y0*ones(6,1), medial(:,1), top(:,2)];
Z = 1000*[front(:,2), medial(:,2), z0*ones(6,1)];
