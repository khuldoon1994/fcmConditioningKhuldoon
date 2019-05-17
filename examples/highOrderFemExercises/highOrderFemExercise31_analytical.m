
clear all;
close all;

h=2;
R=2;


%% nodes
X1 = h/2;
X2 = R/sqrt(2);
X3 = R/sqrt(2);
X4 = h/2;

Y1 = -h/2;
Y2 = -R/sqrt(2);
Y3 = R/sqrt(2);
Y4 = h/2;

plot([X1 X2 X3 X4],[Y1 Y2 Y3 Y4],'*')
axis equal


%% shape functions
N1 = @(xi,eta) 0.5*(1-xi).*(1-eta);
N2 = @(xi,eta) 0.5*(1+xi).*(1-eta);
N3 = @(xi,eta) 0.5*(1+xi).*(1+eta);
N4 = @(xi,eta) 0.5*(1-xi).*(1+eta);

dN1dxi = @(xi,eta) -0.5*(1-eta);
dN1deta = @(xi,eta) -0.5*(1-xi);

dN2dxi = @(xi,eta)  0.5*(1-eta);
dN2deta = @(xi,eta) -0.5*(1+xi);

dN3dxi = @(xi,eta) 0.5*(1+eta);
dN3deta = @(xi,eta) 0.5*(1+xi);

dN4dxi = @(xi,eta) -0.5*(1+eta);
dN4deta = @(xi,eta) 0.5*(1-xi);

%% function
eX = @(eta) R*cos(pi*eta/4);
eY = @(eta) R*sin(pi*eta/4);

linX = @(xi,eta) N1(xi,eta)*X1 + N2(xi,eta)*X2 + N3(xi,eta)*X3 + N4(xi,eta)*X4;
linY = @(xi,eta) N1(xi,eta)*Y1 + N2(xi,eta)*Y2 + N3(xi,eta)*Y3 + N4(xi,eta)*Y4;

x = @(xi,eta) linX(xi,eta) + ( eX(eta) - ( (eta-1)/2*X2 + (eta+1)/2*X3 ) ).*(1+xi)/2;
y = @(xi,eta) linY(xi,eta) + ( eY(eta) - ( (eta-1)/2*Y2 + (eta+1)/2*Y3 ) ).*(1+xi)/2;

etas = linspace(-1,1,20);
xis=ones(size(etas));

xs=x(xis,etas);
ys=y(xis,etas);

hold on;
plot(xs,ys)


%% jacobian
deXdeta = @(eta) -pi/4*R*sin(pi*eta/4);
deYdeta = @(eta) pi/4*R*cos(pi*eta/4);

dlinXdxi = @(xi,eta) dN1dxi(xi,eta)*X1 + dN2dxi(xi,eta)*X2 + dN3dxi(xi,eta)*X3 + dN4dxi(xi,eta)*X4;
dlinXdeta = @(xi,eta) dN1deta(xi,eta)*X1 + dN2deta(xi,eta)*X2 + dN3deta(xi,eta)*X3 + dN4deta(xi,eta)*X4;
dlinYdxi = @(xi,eta) dN1dxi(xi,eta)*Y1 + dN2dxi(xi,eta)*Y2 + dN3dxi(xi,eta)*Y3 + dN4dxi(xi,eta)*Y4;
dlinYdeta = @(xi,eta) dN1deta(xi,eta)*Y1 + dN2deta(xi,eta)*Y2 + dN3deta(xi,eta)*Y3 + dN4deta(xi,eta)*Y4;

dxdxi = @(xi,eta) dlinXdxi(xi,eta) + eX(eta)/2;

J = @(xi,eta) [ dxdxi(xi,eta) dydxi(xi,eta);
                dxdeta(xi,eta) dydeta(xi,eta) ];
detJ = @(xi,eta) dxdxi(xi,eta).*dydeta(xi,eta) - dxdeta(xi,eta).*dydxi(xi,eta);

areaQuad = integral2(detJ,-1,1,-1,1);

areaCircle = pi*R*R;

reference = (areaCircle - h*h)/4;

