function voxtest_regression(voxdir, outfile)
%VOXTEST_REGRESSION  Fixed fold, tract and combi runs for the comparison
%   voxtest_regression(voxdir, outfile) starts VOX in voxdir (a copy of
%   VOX/matlab) with the default settings (vowel /a/, modal register,
%   stairs) and saves y, z and Fs of
%      fold   30 ms   (Fold -> Calc, no graphics)
%      tract  20 ms   (Tract -> Calc, stairs)
%      combi  30 ms   (Combi, stairs)
%   in outfile (struct R). runvoxtests compares two such files bitwise.
%   Run it hidden (see runvoxtests): VOX opens its windows.

global TMAX GRONF Hndl %#ok<GVMIS> VOX is driven through its globals
fprintf('MATLAB %s, regression runs in %s\n', version, voxdir);
cd(voxdir);
vox;
GRONF = 0;
set(Hndl.gronf, 'value', 0);
R = struct();
runs = {'fold', 30, 'foldcalc'; 'tract', 20, 'tractcalc'; 'combi', 30, 'combicalc'};
failed = {};
for k = 1:size(runs, 1)
    % the same duration on every version: global and field
    TMAX = runs{k,2};
    set(Hndl.DurationStr, 'string', num2str(TMAX));
    vox('refreshDuration', 'strsli');
    try
        vox(runs{k,3});
        d = get(Hndl.figureNumber, 'UserData');
        R.(runs{k,1}) = struct('y', d.y, 'Fs', d.Fs);
        if isfield(d, 'z')
            R.(runs{k,1}).z = d.z;
        end
        fprintf('%-6s %d samples at %d Hz\n', runs{k,1}, numel(d.y), d.Fs);
    catch err
        fprintf('%-6s failed: %s (%s line %d)\n', runs{k,1}, err.message, err.stack(1).name, err.stack(1).line);
        R.(runs{k,1}) = struct('error', err.message);
        failed{end+1} = runs{k,1}; %#ok<AGROW>
    end
end
vox('closevox');
save(outfile, 'R');
if isempty(failed)
    fprintf('RESULT PASS fold, tract, combi calculated\n');
else
    fprintf('RESULT FAIL %s failed\n', strjoin(failed, ', '));
    exit(1);
end
end
