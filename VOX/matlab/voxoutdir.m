function p = voxoutdir(varargin)
%VOXOUTDIR Folder out/ of VOX, where VOX writes all its files.
%   P = VOXOUTDIR returns the folder out/ next to vox.m and creates it if
%   it does not exist. P = VOXOUTDIR(NAME) returns the path of the file
%   NAME in out/ (fullfile(out, NAME)).
%
%   VOX writes all its files into out/ and reads them back from there
%   (#29): results (out_*.mat), session files (last_filename, recorded,
%   background, parameters.mat of the parameter mode), WAV exports, movies
%   and CSV files of the external forces. The save dialogs start there.
%   VOX itself stays in its folder (WORKDIR): it is not on the MATLAB path
%   and finds its functions only from there. git ignores out/.
%
%   The folder is derived from the location of this file, so it also
%   works when MATLAB's current folder is another one, and on copies of
%   VOX (tests).
%
%   Example: save(voxoutdir('out_vf_n10000'), 'data')
%
%   See also vox, voxmoveoutput.

p = fullfile(fileparts(mfilename('fullpath')), 'out');
if ~isfolder(p)
    [ok, msg] = mkdir(p);
    if ~ok
        error('vox:outdir', 'Could not create the folder "%s": %s', p, msg);
    end
end
if nargin > 0
    p = fullfile(p, varargin{:});
end
end
