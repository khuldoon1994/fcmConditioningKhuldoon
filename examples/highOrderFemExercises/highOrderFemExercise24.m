
clear all;
close all;

%% setup

X1=0;
X2=1;
a=1/5;

Q = @(xi) 0.5*(1-xi)*X1 + 0.5*(1+xi)*X2 + (xi.*xi-1)*a;

% a = 1/4
%invQ = @(x)  2*x.^(1/2) - 1;

% a = 0
%invQ = @(x)  2*x - 1;

% a ~= 0
invQ = @(x) (2*(4*a*x - 2*a + 4*a.^2 + 1/4).^(1/2) - 1)/(4*a);
             

%% computation
N1 = @(xi) 0.5*(1-xi);
N2 = @(xi) 0.5*(1+xi);

xis = linspace(-1,1,20);
figure(1)
hold on;
plot(xis, N1(xis));
plot(xis, N2(xis));
plot(xis, zeros(1,20),'*');
title('Shape functions in local coordinates');
xlabel('xi')
ylabel('N(xi)')

xs = linspace(0,1,20);
figure(2)
hold on;
plot(xs, N1(invQ(xs)));
plot(xs, N2(invQ(xs)));
plot(Q(xis),zeros(1,20),'*');
title('Shape functions in global coordinates');
xlabel('x')
ylabel('N(xi(x))')


%% How to get the inverse mapping
%syms a
%syms x;
%syms xi;
%syms Q;
%Q = 0.5*(1-xi)*X1 + 0.5*(1+xi)*X2 + (xi*xi-1)*a;
%sol = solve(Q==x,xi);
