function [X_norm, peakval] = saisir_normsapph(X,peakWN, varargin)
%   Normalize spectra in a SAISIR data structure using the intensity of a
%   specified peak region.
%
%   [X_norm, peakval] = saisir_normsapph(X, peakWN, ...)
%
%   This function normalizes each spectrum (row) by the intensity of a
%   selected peak. The peak intensity can be obtained from a locally
%   baseline‑corrected signal, from the first derivative, or directly from
%   the raw spectrum. The function does not perform global baseline
%   correction or mean‑centering; such preprocessing may be required prior
%   to normalization.
%
%   INPUTS:
%       X               SAISIR data structure containing:
%                           X.d : spectral matrix (nSamples × nVariables)
%                           X.v : vector of spectral axis values
%
%       peakWN          Target peak position (wavenumber/Raman shift) used
%                       as the normalization reference. Default = 750.
%
%   OPTIONAL NAME–VALUE PAIRS:
%       'peakWidth'     Half‑width (in points) of the region around peakWN
%                       used for local baseline correction. Default = 40.
%
%       'Mode'          Method for extracting peak intensity:
%                           'normal'     – baseline‑corrected peak height
%                           'derivative' – first‑derivative max–min amplitude
%                           'direct'     – raw intensity at peakWN
%                       Default = 'normal'.
%
%   OUTPUTS:
%       X_norm          SAISIR structure with normalized spectra:
%                           X_norm.d(i,:) = X.d(i,:) / peakval(i)
%
%       peakval         Peak intensity values used for normalization,
%                       computed according to the selected mode.
%
%   NOTES:
%       • Local baseline correction uses asymmetric least squares (ALS).
%       • Derivative mode uses saisir_derivative with parameters (2, 9, 1), 
%         i.e. Savisky-Golay.
%       • The function identifies the closest spectral index to peakWN.
%       • Normalization is applied spectrum‑wise; each row is scaled by its
%         own peak intensity.
%
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% INPUT PARSING
% -------------------------------------------------------------------------

defaultPeakWn = 750 ; 
defaultPeakWidth = 40; % Include +- 40 point besides the peak during baseline correction
defaultMode  = 'normal'; % normal = only baseline and aboslute intensity of peak, derivative 

p = inputParser;
   expectedModes = {'normal','derivative','direct'}; 

   addRequired(p,'X'); % positional arg
   addOptional(p,'peakWN',defaultPeakWn); % Name Value pair  
   addParameter(p,'peakWidth',defaultPeakWidth)
   addParameter(p,'Mode',defaultMode, @(x) any(validatestring(x,expectedModes)))
   parse(p,X,peakWN, varargin{:});

   pwidth = p.Results.peakWidth;
   mode = p.Results.Mode;

% -------------------------------------------------------------------------


[nrow ncol]=size(X.d);
peakval = [];

[~,ipeak] = min(abs(str2num(X.v)- peakWN));
peakRegion = [ipeak-pwidth : ipeak+ pwidth];

% % Plot and check chosen region
% figure;plot(str2num(X.v(peakRegion,:)), X.d(:,peakRegion))

NormBand = selectcol(X,peakRegion);

Deriv1Signal = saisir_derivative(X,2,9,1);
Deriv1Signal = selectcol(Deriv1Signal,peakRegion);


if strcmp(mode, 'normal')
    X_norm.d=zeros(nrow,ncol);
    for row= 1:nrow
       if(mod(row,10000)==0)
           disp(num2str([row nrow]));
       end
       NormBandi = NormBand.d(row,:);
       % Local baseline correction on normalisation band
       [NormBandCorr,baseline,wgts] = als(NormBandi,5,0.001);
       peakval(row,:) = NormBandCorr(1,pwidth+1);
    
    
       X_norm.d(row,:)=X.d(row,:)./NormBandCorr(1,pwidth+1);
    
    end
    X_norm.v=X.v;
    X_norm.i=X.i;

elseif strcmp(mode,'derivative')
       X_norm.d=zeros(nrow,ncol);
       for row= 1:nrow
           if(mod(row,10000)==0)
               disp(num2str([row nrow]));
           end
            Deriv1Bandi = Deriv1Signal.d(row,:);          
            
            [MaxSapph]=max(Deriv1Bandi,[],2);
            [MinSapph]=min(Deriv1Bandi,[],2);      
            peakval(row,:) = MaxSapph-MinSapph;

            X_norm.d(row,:)=X.d(row,:)./peakval(row,:);
       end
       X_norm.v=X.v;
       X_norm.i=X.i;
else

    [~,ipeak] = min(abs(str2num(X.v)- peakWN));

    X_norm.d=zeros(nrow,ncol);
    for row= 1:nrow
       if(mod(row,10000)==0)
           disp(num2str([row nrow]));
       end
       peakval(row,:) = X.d(row,ipeak);
       X_norm.d(row,:)=X.d(row,:)/X.d(row,ipeak);

    end
    X_norm.v=X.v;
    X_norm.i=X.i;
    
end
    


end