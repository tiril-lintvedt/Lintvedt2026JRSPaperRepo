function [Xfixed, spike_summary] = spikefix_whitaker_multi(X, d, w, threshold, plotit)
% ------------------- Spike detection and removal -------------------------     
%     Detects spikes based on the modified Z score, and removes the detected 
%     spikes by interpolation. Whitaker and Hayes propose to make advantage 
%     of the high intensity and small width of spikes and therefore use the 
%     difference between consecutive spectrum points ∇x(i) = x(i)-x(i-1) 
%     to calculate the z-scores, where x(1), …, x(n) are the values of a
%     single Raman spectrum. This function is generalized to iterate
%     through all spectra inn the  X data block
%
% INPUT:         X          -   Spectra, saisir struct
%                m          -   integer, defines that we use 2m + 1 points around  
%                               the spike to compute and average which replaces 
%                               spike (NOT USED IN THIS VERSION)
%                d          -   integer, degree of derivative to apply
%                w          -   integer, buffer for spike width
%                threshold  -   Modified zscore threshold for spike detection
%                plotit     -   boolean, 0/1 (whether or not to show control plots) 
%
%
% Suggested parameters for Raman spectra: d = 2, w = 1, threshold must be
% tuned for application (e.g. between 5 - 30 in many applications)
%
%   Reference: Adapted from
%                   A Simple Algorithm for Despiking Raman Spectra, Whitaker & Hayes, 2018 
%                   https://doi.org/10.1016/j.chemolab.2018.06.009 
%                   python code: https://towardsdatascience.com/removing-spikes-from-raman-spectra-8a9fdda0ac22
%
%   Modifications: Use 2nd derivative in stead of 1st derivative (e.g lipid
%                  Raman bands are very strong/steep and comparable to spikes in 
%                  1st diff)
%
% -------------------------------------------------------------------------
% Go through all spectra and remove spikes
spike_summary.Xfixed = zeros(size(X.d));
spike_summary.spike_spectra = []; % Log the row number of spectra with spikes
spike_summary.spike_positions = []; % Corresponing RS positions of spikes of the spike_spectra 
spike_summary.nspecwithspike = 0; % Number of spectra with spikes

% Plot spectra with detected spikes
if plotit
    scrsz = get(0,'ScreenSize');
    figure('Position',[100 50 scrsz(3)/1.7 scrsz(4)/1.2])
    ylabel('Intensity','FontSize',16)
    xlabel('Raman Shift (cm^{-1})', 'FontSize',16)
    set(gcf,'Color',[1 1 1])
end

for ispec = 1:size(X.i,1)
    [xfixed, spike_pos] = spikefix_whitaker(X.d(ispec,:), d, w,threshold,0);   % x, m, d, w, threshold, plotcheck
    spike_summary.Xfixed(ispec,:) = xfixed; % Update adata matrix with corrected spectrum
    
    if (sum(spike_pos) ~= 0) 
       
       % Log how many spectra have spikes
       spike_summary.nspecwithspike = spike_summary.nspecwithspike + 1;
       
       % Log which spectra have one or more spikes
       spike_summary.spike_spectra(end+1) = ispec;
       
       % Log which positions the spectra have spikes 
       spike_summary.spike_positions(end+1,:) = spike_pos;     
       
       if (plotit == 1)
           % Plot spctra with spike positions indicated
           subplot(2,1,1)
           plot(str2num(X.v),X.d(spike_summary.spike_spectra(end,:),:)) 
           [~, sp_ind] = find(spike_pos);
           text(str2num(X.v(sp_ind,:)),X.d(spike_summary.spike_spectra(end), sp_ind),'<', 'color', 'r')
           hold on
           title('Original','FontSize', 14)
           
           % Plot corrected spectra for comparison
           subplot(2,1,2)
           plot(str2num(X.v),spike_summary.Xfixed(spike_summary.spike_spectra(end),:))
           text(str2num(X.v(sp_ind,:)),spike_summary.Xfixed(spike_summary.spike_spectra(end), sp_ind),'<', 'color', 'r')
           hold on
           title('Corrected for spikes','FontSize', 14)
       end
    end
    
    
end


% Update data matrix with corrected spectra
Xfixed.d = spike_summary.Xfixed;
Xfixed.i = X.i;
Xfixed.v = X.v;

if plotit && (spike_summary.nspecwithspike ==0)
    text(0.25, 0.5,'NO SPECTRA WITH SPIKES DETECTED','units', 'normalized', 'fontsize',20)
end

end