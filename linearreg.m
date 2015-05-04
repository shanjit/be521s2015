function [predicted_dg, weights, pho] = linearreg(config, patient,numpredictions)

weights = getLinWeights(patient);

[predicted_dg,pho] =  getLinPredictions(config,weights,patient,numpredictions);

end
