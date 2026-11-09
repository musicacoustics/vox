% calculation of glottal flow
%-------------------------------------------------------------------------
%flow.m
%
%
% input:
%
%		VOC			:		Flag indicating if vocal tract is considered in calculation
%		SUB			:		Flag indicating if subglottal resonator is considered in calculation
%		ps0			:		subglottal pressure (lungpressure)
%		rho			: 		density of air
%
%	from glotpar.m
%
%		amin			:		minimum area of glottal channel
%		as				:		area of first subglottal resonator segment
%
%	from params.m
%
%		z_voc_1		:		input impedance of first vocal tract segment
%		z_sub_1		:		input impedance of first subglottal resonator segment
%		u_min_voc	:		reflected flow from vocal tract into the glottis
%		u_plus_sub	:		reflected flow from subglottal resonator into the glottis
%
%
% output:
%
%		u_plus_voc	:		flow into the vocal tract
%		u_min_sub	:		flow back into the subglottal resonator
%
%
% used files:
%
%		--
%
%----------------------------------------------------------------------

sum_amin = sum(amin);
ke       = 2*sum_amin/sum_avoc * (1-sum_amin/sum_avoc); % total sum
amin0    = amin(1,:);
psub     = SUB*(ps_gl_ac) + ps;
%psub    = SUB*(ps_gl_ac) + ps/2; in PhD
psup     = VOC*(pin_gl_ac) + pin;

if sum_amin > 0
   avoc  = sum_avoc*amin0./sum_amin;
   as    = sum_as*amin0./sum_amin;
   amin0 = amin0(find(amin0~=0));
   avoc  = avoc(find(avoc~=0));
   as0   = as;
   as    = as(find(as~=0));

   % calculation with separate flows
   %
   % pressure recovery coefficient (each mass)----------------------------
   %  ke = 2*amin./avoc .* (1-amin./avoc);  % single
   %ke = 2*amin./sum_avoc .* (1-amin./sum_avoc); % sum
   %  ke=0;
   kt = 1 - ke - ((amin0.^2)./as.^2); % single
   %kt = 1 - ke - (amin.^2./sum_as.^2); % sum
   %kt = 1 - ke - (sum_amin.^2./sum_as.^2); % total sum

   At = 1./(1./as + 1./avoc); % single
   %At = 1./(1./sum_as + 1./sum_avoc); % sum or total sum

   %	pin_gl_ac = -pin_gl_ac;  % ist positiv definiert
   %	ps_in = ps_gl_ac;% + ps0;
   %%%	psub = ps;
   %%%	psup = pin;

   %  radikant = amin.^2./At.^2 ...
   %    + 2*kt/(rho*c^2)*(2*ps_gl_ac + ps0 - 2*pin_gl_ac); % single and sum
   %  radikant = amin.^2./At.^2 ...
   %    + 4*kt/(rho*c^2)*(ps_gl_ac - pin_gl_ac); % single and sum
   %  radikant = amin.^2./At.^2 ...
   %    + 4*kt/(rho*c^2)*(ps_in - pin_gl_ac); % single and sum
   radikant = amin0.^2./At.^2 ...
      + 4*kt/(rho*c^2)*(psub - psup); % single and sum
   %radikant = sum_amin.^2./At.^2 + 2*kt/(rho*c^2)*(2*ps_gl_ac + ps0 - 2*pin_gl_ac); % total sum

   % calculation with sum of all flows
   %
   % pressure recovery coefficient --------------------------------------
   %sum_ke = 2*sum_amin/avoc * (1-sum_amin/sum_avoc);
   %kt = 1 - sum_ke - (sum_amin^2/sum_as^2);
   %At = 1/(1/sum_as + 1/sum_avoc);
   %radikant = sum_amin^2/At^2 + 2*kt/(rho*c^2)*(2*ps_gl_ac + ps0 - 2*pin_gl_ac);
   %if radikant >= 0
   %  u = c * sum_amin/kt * (-sum_amin/At + sqrt(radikant) );
   %else
   %  u = 0;
   %  warning('Fluß wurde negativ');
   %end;

   %  for i = 1:MAXM % single and sum
   u = [];
   for i = 1:length(amin0) % single and sum
      %if radikant(i) >= 0 % single and sum
      %      if ps_gl_ac >= pin_gl_ac
      if psub >= psup
         %				if radikant(i) >= 0
         u(i) = c * amin0(i)./kt(i) .* (-amin0(i)./At(i) + sqrt(radikant(i)) ); % single and sum
         %				else
         %					warning('Radikant below zero!');
         %					u = zeros(length(amin),1);
         %					u(i) = 0;
         %				end
      else
         %				if radikant(i) < 0
         %        	u = c * amin./kt .* (-amin./At - sqrt(radikant) ); % single and sum
         u(i) = c * amin0(i)./kt(i) .* (-amin0(i)./At(i) - sqrt(-radikant(i)) ); % single and sum
         %				else
         %					warning('Radikant above zero!');
         %					u = zeros(length(amin),1);
         %					u(i) = 0;
         %				end
      end
      %			u(i) = (ps - pin) * amin(i) / ( rho * c);
      %if radikant >= 0 % total sum
      %  u = c * sum_amin./kt .* (-sum_amin./At + sqrt(radikant) ); % total sum
      %     else
      %       u = zeros(length(amin),1);
      %       warning('Radikant below zero!');
      %     end;
   end % single and sum
   % code written by Nils Alhäuser
   %
   % u_plus_voc =  u + VOC * u_min_voc;
   % u_min_sub  = -u + SUB * u_plus_sub;
   % alpha = VOC * z_voc_1 + SUB * z_sub_1;
   % beta = 1 - amin.^2./as.^2;
   % gamma = ( VOC * 2*z_voc_1*u_min_voc - SUB * 2*z_sub_1*u_plus_sub - ps0); % original
   % %gamma = ( VOC * 2*z_voc_1*u_min_voc - SUB * 2*z_sub_1*u_plus_sub - ps0);
   % delta = alpha^2 * amin.^2 - 2*rho * beta .* gamma; % original
   % %delta = alpha^2 * amin.^2 + 2*rho * beta .* gamma;
   %
   % for i = 1:MAXM
   %    if delta(i)>=0
   %       u(i) = amin(i)/(rho*beta(i)) * (-alpha * amin(i) + sqrt(delta(i)));
   %    else
   %       u(i) = 0;
   %       %      u(i) = amin(i)/(rho*beta(i)) * (-alpha * amin(i) - sqrt(abs(delta(i))));
   %       warning('Fluß wurde negativ');
   %    end
   % end
   %
   % u_plus_voc = VOC * (u_min_voc + u);
   % u_min_sub = SUB * (u_plus_sub - u);

   % u_plus_voc = VOC * (u_min_voc + u);
   % %u_plus_voc = VOC * (-u_min_voc + u);
   % u_min_sub = SUB * (u_plus_sub - u);
   % %u_min_sub = SUB * (-u_plus_sub - u);

   sum_u = sum(u); % for separately calculated flows

   %u_plus_voc =  sum_u;
   %u_min_sub  = -sum_u;
   %	disp(['sum_u:' num2str(round(1e9*sum_u)) ...
   %			  ' ui:' num2str(round(1e9*u))]);
else
   sum_u = 0;
   for i = 1:MAXM
      as0(i) = 0;
   end
end