function num = voxnextnum(folder, prefix)
%VOXNEXTNUM Next number for numbered output files (movies, figures).
%   NUM = VOXNEXTNUM(FOLDER, PREFIX) returns, as '%03d' text, the number
%   one above the highest number of the files PREFIX<number>.<ext> in
%   FOLDER (any extension). Counting the files instead could return a
%   number in use: with foldmov_001 and foldmov_003 the count gave 003,
%   and that file was overwritten.
%
%   Example: voxnextnum(fullfile(WORKDIR, 'out'), 'combimov_')
f = dir(fullfile(folder, [prefix '*.*']));
tok = regexp({f.name}, ['^' regexptranslate('escape', prefix) '(\d+)\.'], 'tokens', 'once');
tok = tok(~cellfun(@isempty, tok));
n = cellfun(@(t) str2double(t{1}), tok);
num = sprintf('%03d', max([0, n(:)']) + 1);
end
