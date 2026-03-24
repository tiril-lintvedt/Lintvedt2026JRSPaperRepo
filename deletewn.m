function [saisir] = deletewn(saisir1,wn_region)

%   This function removes all spectral variables (columns) in a given
%   wavenumber interval from a saisir data structure. The interval is
%   defined by the first and last values in `wn_region`, and the function
%   automatically identifies the closest matching wavenumbers in
%   saisir1.v. The corresponding columns in the data matrix and the
%   associated wavenumber labels are deleted.
%
%   INPUTS:
%       saisir1     A saisir structure with fields:
%                       - d : data matrix (observations × variables)
%                       - v : wavenumber vector (as char)
%                       - i : sample identifiers
%
%       wn_region   A vector specifying the wavenumber interval to remove.
%                   Only the first and last values are used to define the
%                   region.
%
%   OUTPUT:
%       saisir      A new saisir structure containing the updated data
%                   matrix, wavenumber vector, and sample identifiers after
%                   removal of the selected wavenumber region.
%
%   NOTES:
%       - The function finds the closest matching wavenumbers in saisir1.v
%         using absolute distance.
%       - All columns between the identified bounds (inclusive) are removed.
%
% -------------------------------------------------------------------------

WN1 = wn_region(1);
WN2 = wn_region(end);

[~,i1] = min(abs(str2num(saisir1.v)-WN1));
[~,i2] = min(abs(str2num(saisir1.v)-WN2));

saisir1.d(:,i1:i2)=[];
saisir1.v(i1:i2,:)=[];

saisir.d=saisir1.d;
saisir.i=saisir1.i;
saisir.v=saisir1.v;