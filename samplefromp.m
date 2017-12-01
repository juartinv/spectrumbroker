function x=samplefromp(p,n)
%Inputs: 
% - p vector de probabilidades de largo k.
% - n cantidad de valores enteros a devolver
%
%Output 
% - vector fila de largo n con entradas tomadas del 
% conjunto {1, 2, ..., k} de acuerdo a las probabilidades
% especificadas por p.

k=size(p,2);
u=rand(1,n);
x=zeros(1,n);
for i=1:k
x=x+i*(sum(p(1:i))-p(i) <=u & u<sum(p(1:i)));
end
