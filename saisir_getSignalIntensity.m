function [Signal_corr, peakval] = saisir_getSignalIntensity(X,peakWN, varargin)
% saisir_getSignalIntensity
% -------------------------------------------------------------------------
%   Estimate the signal intensity of a specified spectral peak.
%
%   [Signal_corr, peakval] = saisir_getSignalIntensity(X, peakWN, ...)
%
%   This function extracts and quantifies the intensity of a spectral peak
%   at a given wavenumber (peakWN) from a SAISIR data structure. Depending
%   on the selected mode, the function performs local baseline correction,
%   first‑derivative peak evaluation, or direct raw‑value extraction.
%
%   INPUTS:
%       X               SAISIR data structure containing:
%                           X.d : spectral matrix (nSamples × nVariables)
%                           X.v : vector of spectral axis values (char)
%
%       peakWN          Target peak position (wavenumber or Raman shift).
%                       If omitted, a default of 750 is used.
%
%   OPTIONAL NAME–VALUE PAIRS:
%       'peakWidth'     Half‑width (in points) of the region around peakWN
%                       used for baseline correction. Default = 30.
%
%       'Mode'          Peak‑evaluation method:
%                           'normal'     – baseline‑corrected peak height
%                           'derivative' – first‑derivative peak amplitude
%                           'direct'     – raw intensity at peakWN
%                       Default = 'normal'.
%
%       'plotit'        If 1, plots the corrected and raw peak regions.
%                       Default = 0.
%
%   OUTPUTS:
%       Signal_corr     Baseline‑corrected (or derivative/raw) signal
%                       extracted from the peak region for each sample.
%
%       peakval         Final peak intensity metric for each sample:
%                           Mode 'normal'     → corrected peak height
%                           Mode 'derivative' → max–min derivative amplitude
%                           Mode 'direct'     → raw intensity at peakWN
%
%   NOTES:
%       • Baseline correction uses asymmetric least squares (ALS).
%       • Derivative mode uses a first‑derivative spectrum computed via
%         saisir_derivative with parameters (2, 9, 1), i.e. Savitsky-Golay.
%       • The function automatically identifies the closest spectral index
%         to peakWN.
%
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% INPUT PARSING
% -------------------------------------------------------------------------

defaultPeakWn = 750 ; 
defaultPeakWidth = 30; % Include +- 30 point besides the peak during baseline correction
defaultMode  = 'normal'; % normal = only baseline and aboslute intensity of peak, derivative = 1st derivative 
defaultPlot = 0; % No plot

p = inputParser;
   expectedModes = {'normal','derivative','direct'}; 

   addRequired(p,'X'); % positional arg
   addOptional(p,'peakWN',defaultPeakWn); % Name Value pair  
   addParameter(p,'peakWidth',defaultPeakWidth)
   addParameter(p,'Mode',defaultMode, @(x) any(validatestring(x,expectedModes)))
   addParameter(p,'plotit',defaultPlot)
   parse(p,X,peakWN, varargin{:});

   pwidth = p.Results.peakWidth;
   mode = p.Results.Mode;
   plotit = p.Results.plotit;

% -------------------------------------------------------------------------


[nrow ncol]=size(X.d);
peakval = [];

[~,ipeak] = min(abs(str2num(X.v)- peakWN));
peakRegion = [ipeak-pwidth : ipeak+ pwidth];

% % Plot and check chosen region
% figure;plot(str2num(X.v(peakRegion,:)), X.d(:,peakRegion))

Signal = selectcol(X,peakRegion);
Deriv1Signal = saisir_derivative(X,2,9,1);
Deriv1Signal = selectcol(Deriv1Signal,peakRegion);

Baselines = [];
if strcmp(mode, 'normal') % Ra
    for row= 1:nrow
       if(mod(row,10000)==0)
           disp(num2str([row nrow]));
       end
        NormBandi = Signal.d(row,:);
        % Local baseline correction on normalisation band
        [SignalCorr,baseline,wgts] = als(NormBandi,5,0.005); % 0.001 (+)
        Signal_corr(row,:) = SignalCorr;
        peakval(row,:) = SignalCorr(1,pwidth+1);
        Baselines(row,:) = baseline;
        
        %figure;plot(str2num(X.v(peakRegion,:)), SignalCorr);yline(0)
    
    end

elseif strcmp(mode,'derivative')
       for row= 1:nrow
           if(mod(row,10000)==0)
               disp(num2str([row nrow]));
           end
            Deriv1Bandi = Deriv1Signal.d(row,:);          
            Signal_corr(row,:) = Deriv1Bandi;
            
            [MaxN2]=max(Deriv1Bandi,[],2);
            [MinN2]=min(Deriv1Bandi,[],2);      
            peakval(row,:) = MaxN2-MinN2;
            
            %figure;plot(str2num(Deriv1Signal.v), Deriv1Signal.d(row,:));yline(0)
    
        end

else
    % Raw intensity value returned
    [~,ipeak] = min(abs(str2num(X.v)- peakWN));

    for row= 1:nrow
       if(mod(row,10000)==0)
           disp(num2str([row nrow]));
       end
       peakval(row,:) = X.d(row,ipeak);
       Signal_corr(row,:) = X.d(row,ipeak); % No correction

    end
    
end

if plotit 
    % Check baseline correction:
    plot_Raman(str2num(X.v(peakRegion,:)), Signal_corr);
    plot_Raman(str2num(X.v(peakRegion,:)),Signal.d); hold on
end
end