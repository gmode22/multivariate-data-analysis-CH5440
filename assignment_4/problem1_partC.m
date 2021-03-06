clear all
clc

% Question 1 part C
%--- Not finished --. Function FPCA has to be written

% Load data
load 'data1.mat'
load 'absorbances_missing.mat'

% PART A -----averaging the rows
% Assign mean to all the missing data cells
for row=1:size(absorbances,1)    % iterate throgh rows
	meanRow = absorbances(row,:); % store each row for calculating the mean
	meanRow(meanRow == -9999) = [];  % remove the entries having -9999 before calculating mean
	absorbancesRow = absorbances(row,:);  % store each row.
	absorbancesRow(absorbancesRow == -9999) = mean(meanRow);  % assign mean of corresponding row to cell missing data
	absorbances(row,:) = absorbancesRow;   % finally store 
end
% Now absorbance has data after assigning mean to cells

clear('row', 'absorbancesRow', 'absorbancesTemp');

% Now we apply PCA to get the pureSpectra
absorbances = transpose(absorbances);
absorbancesNormalised = zscore(absorbances);
[PCs,score,eigenVals] = FPCA(absorbancesNormalised); %PCA
disp('variance captured with 3 PCs')
sum(eigenVals(1:3,:))/sum(eigenVals)*100

PCs = PCs(:,1:3);  %chose 3 PCs
pureSpectra = absorbancesNormalised*PCs;   %scores/ predicted absorbances
% Now we apply a OLS to this and observed spectra
conc = [PureNi; PureCr; PureCo]';
for i=1:size(PureNi,2)
	pureSpectraReduced = removerows(pureSpectra,i);
	concReduced = removerows(conc,i);
	mixingMat = inv(pureSpectraReduced'*pureSpectraReduced)*pureSpectraReduced'*concReduced;

	predictedConc = mixingMat*pureSpectra(i,:)';
	rmse(i) = rms(predictedConc' - conc(i));
end

disp('average error at predicting concentration of one component at a particular 2mm interval')
rmseAvg = sum(rmse)/(151*3)
plot(rmse)




