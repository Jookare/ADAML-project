function idxS = sample(X, sp)
[n, ~]  = size(X);
ns      = ceil(n*sp);
idx     = 1:n;
idx     = idx(randperm(n));
idxS    = idx(1:ns);
end