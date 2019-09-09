function [T1out,M0out] = dotheT1fit_yzdim(input,mask,fa,tr)

% performs the T2 map fitting for 1 slice

[~,dimy,dimz] = size(input);
T1map = zeros(dimy,dimz,1);
M0map = zeros(dimy,dimz,1);

    function [F,J] = FJfun(x, xdata)
        % Fitting function
        F = x(1).*sin(pi*xdata/180).*(1 - exp(-tr./x(2)))./(1 - (cos(pi*xdata/180) * exp(-tr./x(2))));
        if nargout > 1
            % Jacobian
            J = [ (sin((pi*xdata)/180).*(exp(-tr./x(2)) - 1))./(exp(-tr./x(2)).*cos((pi*xdata)/180) - 1), (tr.*x(1).*exp(-tr./x(2)).*sin((pi*xdata)/180))./(x(2).^2.*(exp(-tr./x(2)).*cos((pi*xdata)/180) - 1)) - (tr.*x(1).*exp(-tr./x(2)).*cos((pi*xdata)/180).*sin((pi*xdata)/180).*(exp(-tr./x(2)) - 1))./(x(2).^2.*(exp(-tr./x(2)).*cos((xdata.*pi)/180) - 1).^2)];
        end
    end

    function H = Hfun(x, xdata)
        % Fitting function
        H = x(1).*sin(pi*xdata/180).*(1 - exp(-tr./x(2)))./(1 - (cos(pi*xdata/180) * exp(-tr./x(2))));
        
    end

fitfun = @Hfun;        % or FJfun for fitting with Jacobian

% starting value
x0 = [max(input(:)) 500];

% flip angles
fa = [0,fa]';

% no display output, fitting with 'true' or without 'false' Jacobian
opt = optimoptions('lsqcurvefit','SpecifyObjectiveGradient',false,'Diagnostics','off','Display','off','MaxIterations',50);

for j=1:dimy
    
    parfor k=1:dimz
        % for all z-coordinates
        
        if mask(k) == 1
            % only fit when mask value indicates valid data point
            
            % pixel value as function of alpha
            ydata = double([0;squeeze(input(:,j,k))]);
            
            % do the fit
            x = lsqcurvefit(fitfun,x0,fa,ydata,[0 0],[Inf 4000],opt);
            
            % make the maps
            T1map(j,k)=x(2);
            M0map(j,k)=x(1);
            
        end
        
    end
    
end

T1out = T1map;
M0out = M0map;    

end