function voxtest_plotmass3d(voxdir)
%VOXTEST_PLOTMASS3D  3D view of the window "Deflection of masses" (#70)
%   voxtest_plotmass3d(voxdir) checks testfill.m in voxdir (a copy of
%   VOX/matlab), the perspective view of the masses of one fold:
%   1. Seven positions of mucosa and vocalis, drawn new and then as an
%      update of existing faces: open; closed at the midline; overlapping
%      the midline by 30 micrometres (as in a collision of the model); mucosa
%      sunk into the vocalis (medial and upper part visible); mucosa sunk
%      into the top of the vocalis; mucosa beside the vocalis; with the
%      offsets of the fold editor. Pass: no vertex at x < 0 (the axes start
%      at x = 0 and cut such parts away), the medial faces of both masses
%      have their full area, the front faces of mucosa and vocalis do not
%      overlap, the visible front area of the mucosa is the part of its box
%      outside the vocalis.
%   2. Fold Calc (10 ms) with graphics in VOX: no error.
%   Run it hidden (see runvoxtests): VOX opens its windows.

global Hndl GRONF %#ok<GVMIS> testfill and VOX use the globals
fprintf('MATLAB %s, 3D view of the masses in %s\n', version, voxdir);
cd(voxdir);
nfail = 0;
warning('off', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:polyshape:boolOperationFailed');

% geometry of the default fold model [m]
MAXM = 11; a = 14e-3/MAXM;
dv = 2.5e-3; dm = 1e-3; thv = 2.5e-3; thm = 0.5e-3;
z0 = zeros(2, MAXM);
ontop = thv/2 + thm/2;                      % mucosa lying on the vocalis
cases = { ...   name, vocalis medial edge, mucosa medial edge, zm, offsets [m]
    'open',                     0.3e-3,  0.2e-3, ontop,        0; ...
    'closed at the midline',    0,       0,      ontop,        0; ...
    'over the midline',        -0.03e-3, -0.03e-3, ontop,      0; ...
    'mucosa sunk, L shape',     0.3e-3,  0.1e-3, ontop - 0.2e-3, 0; ...
    'mucosa sunk into the top', 0.1e-3,  0.3e-3, ontop - 0.2e-3, 0; ...
    'mucosa beside the vocalis', 0.6e-3, 0,      thv/2 - 0.3e-3, 0; ...
    'with offsets',             0.2e-3,  0.1e-3, ontop,        0.5e-3};

Hndl = struct();
modes = {'new', 'update'};
f = figure('Visible', 'off');
Hndl.plotmassax2 = axes('Parent', f, 'NextPlot', 'add');
for refresh = [0 1]
    for k = 1:size(cases, 1)
        if refresh == 0 && k > 1, break, end   % create once, then update
        [ev, em, zmv, off] = cases{k, 2:5};
        Infold = struct('rvoffset', off*1e4*ones(1, MAXM), 'rmoffset', off*1e4*ones(1, MAXM));
        xv = (ev + dv/2 + off)*ones(2, MAXM);
        xm = (em + dm/2 + off)*ones(2, MAXM);
        zv = z0;  zm = zmv*ones(2, MAXM);
        testfill(xv, zv, dv, thv, xm, zm, dm, thm, a, MAXM, refresh, 3, -2, Infold);
        [ok, msg] = checkfaces(Hndl, MAXM, a, max(ev, 0), ev + dv + off, ...
            max(em, 0), em + dm + off, -thv/2, thv/2, zmv - thm/2, zmv + thm/2);
        check(sprintf('%-26s (%s): %s', cases{k, 1}, modes{refresh + 1}, msg), ok);
    end
end
close(f);

% Fold Calc with graphics
try
    vox;
    set(Hndl.gronf, 'value', 1); vox('gronf');
    set(Hndl.DurationStr, 'string', '10'); vox('refreshDuration', 'string');
    vox('foldcalc');
    nfaces = numel(Hndl.plotmassrec21) + numel(Hndl.plotmassrec22);
    check(sprintf('Fold Calc 10 ms with graphics: no error, %d faces in the 3D view', nfaces), nfaces == 6*MAXM);
    GRONF = 0;
    vox('closevox');
catch err
    fprintf('FAILED Fold Calc with graphics: %s (%s line %d)\n', err.message, err.stack(1).name, err.stack(1).line);
    nfail = nfail + 1;
end

if nfail == 0
    fprintf('RESULT PASS 3D view of the masses: 7 positions (new and update), Fold Calc with graphics\n');
else
    fprintf('RESULT FAIL %d checks failed\n', nfail);
    exit(1);
end

    function check(label, ok)
        if ok
            fprintf('%-100s ok\n', label);
        else
            fprintf('%-100s FAILED\n', label);
            nfail = nfail + 1;
        end
    end
end

function [ok, msg] = checkfaces(H, MAXM, a, v1, v2, m1, m2, vz1, vz2, mz1, mz2)
% faces of every mass against the expected geometry [m]; patches in mm
ok = true;  minx = inf;  dmed = 0;  ovl = 0;  dfront = 0;
for i = 1:MAXM
    pv = H.plotmassrec21(i,:);  pm = H.plotmassrec22(i,:);
    X = [cell2mat(get(pv, 'XData')'), cell2mat(get(pm, 'XData')')];
    minx = min(minx, min(X(:)));
    % medial faces: full area a*height
    dmed = max(dmed, abs(facearea(pv(2), 'YData', 'ZData') - 1e6*a*(vz2 - vz1)));
    % front faces: no overlap; mucosa = its box minus the vocalis box
    fv = shape(pv(1));  fm = shape(pm(1));
    ovl = max(ovl, area(intersect(fv, fm)));
    box = polyshape(1e3*[m1 m2 m2 m1], 1e3*[mz1 mz1 mz2 mz2]);
    vbox = polyshape(1e3*[v1 v2 v2 v1], 1e3*[vz1 vz1 vz2 vz2]);
    dfront = max(dfront, abs(area(fm) - area(subtract(box, vbox))));
end
ok = ok && minx >= 0 && dmed < 1e-9 && ovl < 1e-9 && dfront < 1e-9;
msg = sprintf('min x %.3g mm, medial face of the vocalis %.2g mm^2 off, front overlap %.2g mm^2, mucosa front %.2g mm^2 off', ...
    minx, dmed, ovl, dfront);
end

function s = shape(p)
s = polyshape(get(p, 'XData'), get(p, 'ZData'));
end

function A = facearea(p, c1, c2)
% area of a face in the plane of the coordinates c1, c2 [mm^2]
A = area(polyshape(get(p, c1), get(p, c2)));
end
