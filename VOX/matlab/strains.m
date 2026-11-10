% calculation of strains caused by different displacements of neigbour masses
%------------------------------------------------------------------------
% strains.m
%
%
%
% input:
%
%
%	from nndist.m
%
%		rm			:			distance between neighbour mucosamasses
%		rv			:			distance between neighbour vocalismasses
%
%	from params.m
%
%		r0v			:			initial distances between nearest vocalis neighbours
%		r0m			:			initial distances between nearest mucosa neighbours
%		slmax		:			maximum ligamentum strain
%
%
% output:
%
%		sm			:		strain of mucosamasses
%		sv			:		strain of vocalismasses
%		sl			:		strain of ligamentum (same as sv)
%
%
% used files:
%
%		--
%
%------------------------------------------------------------------------

sm = (rm - r0m) ./ r0m;
sv = (rv - r0v) ./ r0v;
sl = sv;

if MAXM > 1
   for i=1:MAXM+1
      if abs(sl(1,i)) >= slmax | abs(sl(2,i)) >= slmax
         error(['Die Simulation ist ungültig, da die Stimmbänder gerissen sind (Sl >= Slmax) sl: ' sprintf('%7.3f', sl(1,i))])
      end
   end
else
   if abs(sl(1,i)) >= slmax | abs(sl(1,i)) >= slmax
      error(['Die Simulation ist ungültig, da die Stimmbänder gerissen sind (Sl >= Slmax) sl: ' sprintf('%7.3f', sl(1,i))])
   end
end