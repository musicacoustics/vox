% generate vocal fold signal
%	Infold		-		struct with inputparameters and flags
%	Parfold		-		struct with Parameters and constants
%-------------------------------------------------------------------------
function [out_vf_voc, out_vf_trach, minarea, Parfold, figdata] = foldsig(Parfold)

global rho c Fs BRK MAXM GRONF GRON SURFS MOV Infold Hndl

%if SURFS == 0
%    figdata = [];
%end

% SIGnal Generator (Iterativ) ---------------

siggi;

% ------------------------------
if ALONE
   out_vf_voc   = y;
   out_vf_trach = ysub;
   Parfold      = [];
   if ~isempty(foldcontrol)   % batch/control file: back to vox('foldcalc') with the trace (#74)
      Parfold = struct('timecontrol', foldcontrol);
   end
else
   out_vf_voc   = pinak;   % statt pin!
   out_vf_trach = ps;
end
minarea = sum_amin;
