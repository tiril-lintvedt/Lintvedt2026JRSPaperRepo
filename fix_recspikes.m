function   X = fix_recspikes(X, wn_regs)
% ------- Replace spectral spike regions with linear interpolation --------
%
%   This function corrects spike artefacts in a spectral data structure by
%   replacing specified wavenumber intervals with linear interpolations.
%   Each row of `wn_regs` defines a wavenumber range to be corrected, and
%   the function iteratively applies `saisir_replace_by_line` to each
%   interval.
%
%   INPUTS:
%       X         A saisir structure containing at least:
%                     - d : data matrix (observations × variables)
%                     - v : wavenumber vector
%                     - i : sample identifiers
%
%       wn_regs   An N×2 matrix where each row specifies the start and end
%                 indices of a wavenumber region to be replaced by a
%                 straight-line interpolation.
%
%   OUTPUT:
%       X         The updated saisir structure with all specified spike
%                 regions replaced by linear interpolations.
%
%   NOTES:
%       - Each region in `wn_regs` is processed independently.
%       - Interpolation is performed by the helper function
%         `saisir_replace_by_line`.
%
% -------------------------------------------------------------------------

for i = 1:size(wn_regs,1)
    wnrange = wn_regs(i,:);
    X  = saisir_replace_by_line(X,wnrange(1):wnrange(2));
end

end