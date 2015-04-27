function [predicted_dg, pho] = linearreg(config, patient,numpredictions)

weights = getLinWeights(patient);

[predicted_dg,pho] =  getLinPredictions(config,weights,patient,numpredictions);

end
