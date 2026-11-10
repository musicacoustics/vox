function ms = voxduration(inputvalue)
% VOXDURATION  Default duration [ms] for an entry of the Input popup
%   ms = voxduration(inputvalue) returns the duration that the Duration
%   field (upper left) gets when Input is switched to this entry:
%      1 Fold   200 ms
%      2 Tract   20 ms  (the impulse responses have decayed after 20 ms)
%      4 Combi  200 ms
%   For the other entries (VF*VT, files) it returns [] and the field keeps
%   its value. A value typed into the field applies until the next switch;
%   loading a file does not change the field.

switch inputvalue
   case {1, 4}
      ms = 200;
   case 2
      ms = 20;
   otherwise
      ms = [];
end
