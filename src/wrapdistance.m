function x = wrapdistance(x1,x2,N)
% compute distances keeping track of periodic boundary conditions
% note, this can take arrays just fine for x1,x2, must be the same size
% This function works for floating-point values of x1,x2, and N
x = min(N-abs(mod(x2,N)-mod(x1,N)), abs(mod(x1,N)-mod(x2,N)));
end