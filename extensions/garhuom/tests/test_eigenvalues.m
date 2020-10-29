
%% clear variables, close figures
clear all %#ok
clc
close all

format longE;

%A = gallery(3)

A = [6     4     3
     4     6     4
     3     4     6]
[m,n] = size(A)

% C = lapack('dgesvd', 'A', 'A', m, n, A, m, zeros(n,1), zeros(m), m, zeros(n), n, zeros(5*m,1), 5*m, 0);
% 
% [s,U,VT] = C{[7,8,10]}
% 
% 
% [s2, U2, VT2] = svd(A)


%% eigenvalues
KD = n-1;
AB = triu(A);
w = zeros(n,1);
z = zeros(n);
work = zeros(5*m,m);
lwork = size(work,1);
% D = lapack('ssbev', 'V', 'U', n, KD, AB, n, w, z, n, work, 0);
% D = lapack('dsyev', 'V', 'U', n, A, n, w, work, lwork, 0);  % for symmetric
%D = lapack('dgeev', 'V','V', n, A, n, w, zeros(n,1), work, lwork, zeros(m,m), lwork, work, lwork, 0); 
%[V,D,info] = D{[8,6,14]}

%% for symmetric
D = lapack('ssyev', 'V', 'U', n, AB, n, w, work, lwork, 0); % this works real
[V,D,info] = D{[4,6,9]}

[V2, D2] = eig(A)


%%

ke = [ 4.945054945054944e-01     1.785714285714285e-01    -3.021978021978021e-01    -1.373626373626374e-02     5.494505494505492e-02     1.373626373626373e-02    -2.472527472527472e-01    -1.785714285714285e-01
     1.785714285714285e-01     4.945054945054944e-01     1.373626373626373e-02     5.494505494505492e-02    -1.373626373626374e-02    -3.021978021978021e-01    -1.785714285714285e-01    -2.472527472527472e-01
    -3.021978021978021e-01     1.373626373626372e-02     4.945054945054944e-01    -1.785714285714285e-01    -2.472527472527472e-01     1.785714285714285e-01     5.494505494505493e-02    -1.373626373626373e-02
    -1.373626373626374e-02     5.494505494505492e-02    -1.785714285714285e-01     4.945054945054944e-01     1.785714285714285e-01    -2.472527472527472e-01     1.373626373626374e-02    -3.021978021978021e-01
     5.494505494505492e-02    -1.373626373626373e-02    -2.472527472527472e-01     1.785714285714285e-01     4.945054945054944e-01    -1.785714285714285e-01    -3.021978021978021e-01     1.373626373626374e-02
     1.373626373626372e-02    -3.021978021978021e-01     1.785714285714285e-01    -2.472527472527472e-01    -1.785714285714285e-01     4.945054945054944e-01    -1.373626373626373e-02     5.494505494505493e-02
    -2.472527472527472e-01    -1.785714285714285e-01     5.494505494505493e-02     1.373626373626373e-02    -3.021978021978021e-01    -1.373626373626372e-02     4.945054945054944e-01     1.785714285714285e-01
    -1.785714285714285e-01    -2.472527472527472e-01    -1.373626373626372e-02    -3.021978021978021e-01     1.373626373626373e-02     5.494505494505493e-02     1.785714285714285e-01     4.945054945054944e-01]

[m,n] = size(ke)
KD = n-1;
AB = triu(ke);
w = zeros(n,1);
z = zeros(n);
work = zeros(5*m,m);
lwork = size(work,1);

%D = lapack('ssyev', 'V', 'U', n, AB, n, w, work, lwork, 0);
D = lapack('dsyev', 'V', 'U', n, AB, n, w, work, lwork, 0);
[V,D,info] = D{[4,6,9]}

%[V2, D2] = svd(ke)

% vec1 = (V(1:2,1))
% vec2 = (V(3:4,1))
% vec3 = (V(5:6,1))
% vec4 = (V(7:8,1))

%(V(1:2,1)) + (V(3:4,1)) - (V(5:6,1)) - (V(7:8,1))

%% some crap
    %eigenvalues = eig(Ke)
    %singularValues = svd(Ke)
    
  %  [V,D] = eig(Ke)
  % [V, D] = sortem(V, D)
  
%     [m,n] = size(Ke)
% KD = n-1;
% AB = triu(Ke);
% w = zeros(n,1);
% z = zeros(n);
% work = zeros(5*m,m);
% lwork = size(work,1);
% 
% %D = lapack('ssyev', 'V', 'U', n, AB, n, w, work, lwork, 0);
% D = lapack('dsyev', 'V', 'U', n, AB, n, w, work, lwork, 0);
% [V,D,info] = D{[4,6,9]};


%    V6 = V(:,6)/norm(V(:,6))
%    V7 = V(:,7)/norm(V(:,7))
%    V8 = V(:,8)/norm(V(:,8))
    
    % norm_V1 = norm(V(:,1))
    % dot(V(:,7), V(:,8))
    %V(:,1)norm(V(:,1))
    %eigenvalues = diag(D)
    
   % if(elementIndex==2)
   %     plot(D)
   % end
    %V
    %plot(D,'*', 'MarkerSize',20)
    %hold on
    
    %hold off
    %legend('eigenvalues')
    %xlabel('Real axis')
    %ylabel('Imaginary axis')
    
    %sigma = 1.0e-6;
    %smallestabs = eigs(Ke,4,sigma, 'Tolerance',1e-12)
    %bei = eigs(Ke,8,'bothendsimag')
    
    %[U, sigma]=svd(Ke);
    %checkOrthognality_svd = norm(inv(U)-U')
    %checkOrthognality_svd_2 = norm(U*U')
    
    %checkOrthognality = norm(inv(V)-V')
    %checkOrthognality2 = norm(V*V')
    %Ke_ = V*diag(D)*V';
    %error_symmetry = norm(Ke-Ke')
    %error_decomposition = norm(Ke-Ke_)