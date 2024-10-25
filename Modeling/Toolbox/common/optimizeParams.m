function model = optimizeParams(model)

    model = gradRho(model);
    
    model.runningLoss   = movmean(model.history(1).rhoHist, 10);
    [~, model.bestloss] = min(abs(model.runningLoss));


    for i = 1:length(model.initialParam)
        model.bestparam(i) = model.history(i).paraHist(model.bestloss);
    end

end