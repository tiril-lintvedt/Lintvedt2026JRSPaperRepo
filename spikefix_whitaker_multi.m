function [Xfixed, spike_summary] = spikefix_whitaker_multi(X, d, w, threshold, plotit, varargin)
% spikefix_whitaker_multi — Spike detection and removal with optional ignored regions
%
%   [Xfixed, spike_summary] = spikefix_whitaker_multi(X, d, w, threshold, plotit)
%   [Xfixed, spike_summary] = spikefix_whitaker_multi(..., 'IgnoreWN', ignore_wn)
%
%   Detects spikes in Raman spectra using the Whitaker & Hayes modified
%   Z‑score method, and removes them by interpolation. Optionally ignores
%   specified wavenumber regions during spike detection.
%
%   INPUTS:
%       X           saisir structure with fields:
%                       - d : data matrix (spectra × variables)
%                       - v : wavenumber vector (strings)
%                       - i : sample identifiers
%       d           derivative order used in spike detection
%       w           spike width buffer
%       threshold   modified z‑score threshold
%       plotit      boolean, whether to plot detected/corrected spikes
%
%   OPTIONAL NAME–VALUE PAIRS:
%       'IgnoreWN'  N×2 matrix of wavenumber regions to ignore
%
%   OUTPUTS:
%       Xfixed          saisir structure with corrected spectra
%       spike_summary   struct containing:
%                           - Xfixed
%                           - spike_spectra
%                           - spike_positions
%                           - nspecwithspike
%
% -------------------------------------------------------------------------

% --------------------- INPUT PARSING -------------------------------------
p = inputParser;
p.FunctionName = 'spikefix_whitaker_multi';

addRequired(p, 'X', @(x) isstruct(x) && isfield(x,'d'));
addRequired(p, 'd', @isscalar);
addRequired(p, 'w', @isscalar);
addRequired(p, 'threshold', @isscalar);
addRequired(p, 'plotit', @(x) islogical(x) || ismember(x,[0 1]));

addParameter(p, 'ignoreWN', [], @(x) isempty(x) || (isnumeric(x) && size(x,2)==2));

parse(p, X, d, w, threshold, plotit, varargin{:});

ignore_wn = p.Results.ignoreWN;
use_ignore = ~isempty(ignore_wn);

% --- Initialize summary structure ---------------------------------------
spike_summary.Xfixed = zeros(size(X.d));
spike_summary.spike_spectra = [];
spike_summary.spike_positions = [];
spike_summary.nspecwithspike = 0;

% --- Plot setup ----------------------------------------------------------
if plotit
    scrsz = get(0,'ScreenSize');
    figure('Position',[100 50 scrsz(3)/1.7 scrsz(4)/1.2])
    ylabel('Intensity','FontSize',16)
    xlabel('Raman Shift (cm^{-1})','FontSize',16)
    set(gcf,'Color',[1 1 1])
end

% --- Prepare ignored-region version if needed ----------------------------
if use_ignore
    X_for_detection = saisir_replace_by_line(X, ignore_wn);
else
    X_for_detection = X;
end

% --- Loop through spectra ------------------------------------------------
for ispec = 1:size(X.i,1)

    % Spike detection (possibly ignoring regions)
    [~, spike_pos] = spikefix_whitaker(X_for_detection.d(ispec,:), d, w, threshold, 0);

    % Correct spikes on original spectrum
    [xfixed, spike_pos] = lincorr_spikes(X.d(ispec,:), spike_pos, 0);
    spike_summary.Xfixed(ispec,:) = xfixed;

    % Log and plot if spikes detected
    if any(spike_pos)
        spike_summary.nspecwithspike = spike_summary.nspecwithspike + 1;
        spike_summary.spike_spectra(end+1) = ispec;
        spike_summary.spike_positions(end+1,:) = spike_pos;

        if plotit
            [~, sp_ind] = find(spike_pos);

            subplot(2,1,1)
            plot(str2num(X.v), X.d(ispec,:))
            text(str2num(X.v(sp_ind,:)), X.d(ispec, sp_ind), '<', 'color', 'r')
            hold on
            title('Original','FontSize',14)

            subplot(2,1,2)
            plot(str2num(X.v), spike_summary.Xfixed(ispec,:))
            text(str2num(X.v(sp_ind,:)), spike_summary.Xfixed(ispec, sp_ind), '<', 'color', 'r')
            hold on
            title('Corrected for spikes','FontSize',14)
        end
    end
end

%------------------- Final output structure -------------------------------
Xfixed.d = spike_summary.Xfixed;
Xfixed.i = X.i;
Xfixed.v = X.v;

if plotit && spike_summary.nspecwithspike == 0
    text(0.25, 0.5, 'NO SPECTRA WITH SPIKES DETECTED', ...
        'units','normalized','fontsize',20)
end

end