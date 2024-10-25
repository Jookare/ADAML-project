function [weightsK] = kernelFit2(K, Y, kvers, dim, model)

if model.classification ~= 1
    model.intercept = 1;
else
    model.intercept = 0;
end

pseudox     = K;
if kvers == 3
    weightsK  = linsolve(pseudox, Y);
else
   if model.intercept == 1
           weightsK = kpls(pseudox, Y - mean(Y), kvers, dim);
    else
        weightsK  = kpls(pseudox, Y, kvers, dim);
    end
end

end
