function [ok, summary] = voxtest_codeanalyzer(src, base, files)
%VOXTEST_CODEANALYZER  Code Analyzer messages of changed files vs. baseline
%   [ok, summary] = voxtest_codeanalyzer(src, base, files) runs checkcode
%   on the files (names in the folder src) and on the same files in the
%   folder base. A message ID that occurs more often than on the baseline
%   is reported and fails the test; new files are compared with nothing.
%   With base = '' only the counts are reported.

ok = true;
nnew = 0;
if isempty(files)
    summary = 'no changed .m files';
    return
end
for k = 1:numel(files)
    fnew = fullfile(src, files{k});
    if ~isfile(fnew)
        fprintf('%-16s deleted\n', files{k});
        continue
    end
    inew = checkcode(fnew, '-id');
    idn  = {inew.id};
    ido  = {};
    if ~isempty(base) && isfile(fullfile(base, files{k}))
        iold = checkcode(fullfile(base, files{k}), '-id');
        ido  = {iold.id};
    end
    fprintf('%-16s %3d messages (baseline %3d)\n', files{k}, numel(idn), numel(ido));
    if isempty(base)
        continue
    end
    % a row: for a file without messages unique gives a 0x1 cell, and
    % "for id = <0x1>" runs once with an empty id
    for id = reshape(unique(idn), 1, [])
        a = sum(strcmp(idn, id{1}));
        b = sum(strcmp(ido, id{1}));
        if a > b
            m = inew(find(strcmp(idn, id{1}), 1, 'last'));
            fprintf('    +%d %s (line %d: %s)\n', a-b, id{1}, m.line, m.message);
            nnew = nnew + a - b;
        end
    end
end
ok = nnew == 0;
summary = sprintf('%d files, %d new messages', numel(files), nnew);
end
