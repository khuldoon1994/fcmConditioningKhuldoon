

n=100;
t=linspace(0,5e-4,n);
u=t;
for i=1:n

    u(i)=mirbagheri(t(i));

end


plot(t,u);

hold on;