function u = mirbagheri(t)


E=70e9;
rho = 2700;
A = 0.02*0.03;
L=20;
F_0 = 1000;
I=0.03*0.02^3/12;
c_0 = sqrt(E/rho);

%factor = 8*F_0*L/(pi*pi*E*I);

factor = 4*F_0/(pi*A*rho*c_0);

x = 0.5;

u=0;
for n=1:1000000
   
    omega_n = ((2*n-1)*pi*x)/(2*L);
   
    a = (1-cos(omega_n*t))/(2*n-1)^2;
    b = cos(((2*n-1)*pi*x)/(2*L));
    summand = (-1)^n*a*b;
    
    u = u + summand;
    
end

u = u*factor;