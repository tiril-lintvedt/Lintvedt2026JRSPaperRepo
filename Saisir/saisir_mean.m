function[moyenne]=saisir_mean(saisir,dim)
%saisir_mean  	- computes the mean of the columns(default) or rows(dim), 
% following the saisir format
% 
%function[moyenne]=saisir_mean(saisir)
%
% Last edit: 07.08.23, Tiril Lintvedt


if ~exist('dim','var') || isempty(dim)
    dim = 2;
end


m=mean(saisir.d,dim);
moyenne.d=m;
moyenne.v=saisir.v;
moyenne.i='average';

