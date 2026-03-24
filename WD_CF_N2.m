function X_corr = WD_CF_N2(X)
% Spectrum intensity correction by estimated working distance (WD) via 
% Nitrogen Raman band  -------------------------------------------------
%
% The spectra are assumed to have the same preprocessing as the one used
% to obtain the calibration table "WD_cf_table.mat".
% 
% See DataAnalysis_MainScript for how to obtain the WD_cf_table.mat.
%
%   INPUTS:
%       X               SAISIR data structure containing:
%                           X.d : spectral matrix (nSamples × nVariables)
%                           X.v : vector of spectral axis values (char)
%
%       wd              Vector of known working distances
%
%   OUTPUT:
%       X_corr          SAISIR structure with corrected spectra:
%                           X_corr.d(i,:) = X.d(i,:) * CF
%                       where CF is the best‑matching correction factor
%                       from the calibration table.
% -------------------------------------------------------------------------
load('WD_cf_table.mat',"WD_cf_table")

CF_table = WD_cf_table;

[~, N2int] = saisir_getSignalIntensity(X,2329,'Mode','derivative');

X_corr = X;
for i = 1:size(X.d,1)
    [y,i1] = min(abs(N2int(i)-CF_table(:, 1))); 
    X_corr.d(i,:) = X.d(i,:)*CF_table(i1,3); % Multiply spectrum with best fit correction factor
end

end


