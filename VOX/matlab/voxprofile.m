function datas = voxprofile()
%VOXPROFILE Parameter profile of the current VOX state.
%   DATAS = VOXPROFILE() returns one profile for the parameter mode, with
%   the same fields that combicalc stored in PROFILE mode, and the control
%   file chosen in the main window (field control, '' without; #74).
%   parametermode used to load the template parameters.mat for this, which
%   is not in the repository (#15). voxapplyprofile sets VOX to a profile.
%
%   See also parametermode, voxapplyprofile, voxcontrolfile.

global Hndl Infold MODFOLD PARA BATCH TRACH FOLD TRACT NOISE TMAX Fs ...
    MAXSEGMENTS MAXDEVLIMIT XI Xi0 MAXM GRON %#ok<GVMIS>

data     = get(Hndl.figureNumber, 'UserData');
iniinput = get(Hndl.INPUT, 'Value');
vowel    = get(Hndl.VOWEL, 'Value');
TVAKT    = get(Hndl.tvakt, 'Value');
PTG      = get(Hndl.ptg, 'Value');
datas    = struct('data',data,'Infold',Infold,'MODFOLD',MODFOLD,'PARA',PARA, ...
    'BATCH',BATCH,'TRACH',TRACH,'FOLD',FOLD,'TRACT',TRACT,'NOISE',NOISE, ...
    'vowel',vowel,'iniinput',iniinput,'TVAKT',TVAKT,'PTG',PTG,'TMAX',TMAX, ...
    'Fs',Fs,'MAXSEGMENTS',MAXSEGMENTS,'MAXDEVLIMIT',MAXDEVLIMIT,'XI',XI, ...
    'Xi0',Xi0,'MAXM',MAXM,'GRON',GRON,'control',voxcontrolfile());
end
