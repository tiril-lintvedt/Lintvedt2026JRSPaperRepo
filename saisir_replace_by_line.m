function Xsaisir = saisir_replace_by_line(Xsaisir, wn_regions)
%   
%   Replace spectral regions in a SAISIR data structure using linear
%   interpolation across specified wavenumber intervals.
%
%   Xsaisir = saisir_replace_by_line(Xsaisir, wn_regions)
%
%   This function replaces one or more spectral regions in Xsaisir.d by
%   interpolating linearly between the boundary points of each region.
%   The replacement is performed independently for every spectrum (row).
%
%   INPUTS:
%       Xsaisir         SAISIR data structure containing:
%                           Xsaisir.d : spectral matrix (nSamples × nVariables)
%                           Xsaisir.v : vector of spectral axis values (char)
%
%       wn_regions      Matrix defining the wavenumber intervals to replace.
%                       Each row corresponds to one region:
%                           [WN_start   WN_end]
%                       The function identifies the closest indices in
%                       Xsaisir.v and replaces all points between them.
%
%   OUTPUT:
%       Xsaisir         Updated SAISIR structure with modified spectra.
%                       For each region, values between WN_start and WN_end
%                       are replaced using:
%                           replace_by_line(spectrum, indexRange)
%
%   NOTES:
%       • The function supports multiple replacement regions, processed
%         sequentially in the order provided.
%       • replace_by_line must be available in the MATLAB path; it performs
%         the actual linear interpolation across the specified index range.
%       • Wavenumber matching is performed by nearest‑index search using
%         abs(str2num(Xsaisir.v) – WN).
%
% -------------------------------------------------------------------------
for i = 1:height(wn_regions)
    
    WN1 = wn_regions(i,1);
    WN2 = wn_regions(i,end);
    
    [~,i1] = min(abs(str2num(Xsaisir.v)-WN1));
    [~,i2] = min(abs(str2num(Xsaisir.v)-WN2));
    
    for j = 1:height(Xsaisir.d)
        Xsaisir.d(j,:) = replace_by_line(Xsaisir.d(j,:),i1:i2);
    end
end



end