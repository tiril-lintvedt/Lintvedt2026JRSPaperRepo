function [x_fixed,spikes] = lincorr_spikes(x, spikes, plotcheck)
% ------------------- Spike detection for Raman spectra -------------------  
%     Removes previously detected spikes by interpolation. 
%
%   INPUT:
%                       x       -  single spectrum
%                       spikes  -  spike positions (col numbers)
%                          plot -  0 or 1, whether to make inspection plots
% 
%   OUTPUT:
%                x_fixed - Spectrum without spikes
% 
% -------------------------------------------------------------------------

x_fixed = x;

 for i = 1:length(spikes)
     if spikes(i) ~= 0            % if we have a spike at position i
 
        % Find first point on each side of the spike, which is not a spike.
        jright = 1; jleft = 1;
        while spikes(i-jleft) == 1  % Can be unfortunate to get spike in position 1. Indexing not possible below 1.            
            jleft = jleft +1;
        end
        
        while spikes(i+jright) == 1
           jright = jright+1; 
        end
        
        w = (i-jleft):(i+jright); % Use this interval for spike correction
        x_fixed = replace_by_line(x_fixed, w);  % replace spike  with fitted line   
        i = i + jright; % Skip points which was fitted in this iteration

     end
    

 end
 
% Inspection plots:
if plotcheck
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)/3 50 scrsz(3)/2 scrsz(4)-150])
    subplot(3,1,1); plot(x); ylabel('original')
    subplot(3,1,2); plot(spikes); ylabel('selected spikes')
    subplot(3,1,3); plot(x_fixed); ylabel('fixed')

end
end
