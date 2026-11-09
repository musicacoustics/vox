function voxaxis(lim)
%VOXAXIS Set axis limits of the current axes if they are valid.
%   VOXAXIS(LIM) works like axis(LIM) with LIM = [xmin xmax ymin ymax],
%   but sets each pair only if both values are finite and increasing;
%   otherwise that axis keeps automatic limits. A silent or constant
%   signal (e.g. a muted recording) gives equal or infinite limits
%   (10*log10(0) = -Inf), which axis rejects with an error.
%
%   See also axis, xlim, ylim.

ax    = gca;
names = {'XLim', 'YLim', 'ZLim'};
for k = 1:numel(lim)/2
    pair = lim(2*k-1:2*k);
    if all(isfinite(pair)) && pair(2) > pair(1)
        set(ax, names{k}, pair);
    else
        set(ax, [names{k} 'Mode'], 'auto');
    end
end
end
