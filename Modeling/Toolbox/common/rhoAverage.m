function [loss, grad_mu] = rhoAverage(param, X, Y, n, model)

idxB    = sample(X, model.sp);
idxB    = sort(idxB);

XBatch  = X(idxB, :);
YBatch  = Y(idxB, :);

modelIter = model;

modelIter.X      = XBatch;
modelIter.Y      = YBatch;
modelIter.params = exp(param);

loss = 0;

KBatch           = kernelRBF(modelIter);

weightsBatch = kernelFit2(extractdata(KBatch), extractdata(YBatch), model.regrType, model.dim, model);

[~, dimy]       = size(YBatch);
if dimy > 1
    for j = 1:dimy
        fn(j) = weightsBatch(:,j)' * KBatch * weightsBatch(:,j);
    end
else
    fullNorm    = weightsBatch' * KBatch * weightsBatch;
end


for i = 1:n

    idxS = sample(XBatch, model.sp);
    idxS = sort(idxS);

    YSam = YBatch(idxS, :);
    XSam = XBatch(idxS, :);

    modelIterSam        = model;
    modelIterSam.X      = XSam;
    modelIterSam.Y      = YSam;

    modelIterSam.params = exp(param);

    KSam = kernelRBF(modelIterSam);
    KCross = KBatch(:,idxS);

    weightsSam = kernelFit2(extractdata(KSam), extractdata(YSam), model.regrType, model.dim, model);

    if dimy > 1
        for j = 1:dimy
            sn(j) = weightsSam(:,j)'   * KSam   * weightsSam(:,j);
            lossj(j) = abs(1 - sn(j)./fn(j));
        end
        lossi = sum(abs(lossj));
    else

        sampleNorm  = weightsSam' * KSam * weightsSam;

        lossi       = 1 + (sampleNorm - 2 * (weightsBatch' * KCross * weightsSam))/fullNorm;
    end

    loss        = loss + lossi;

end

lossA          = loss./n;
grad_mu        = dlgradient(lossA, param);

end