function estado=devolverEstado(x1,x2,s)
%devuelve el estado de la cadena de markov asociada, esto sirve cuando se
%desea establecer cierta condicion inicial.

%requerido por policyIterator_script.m

a=find(s(:,2)==x1);
b=find(s(:,3)==x2);

i=1;
n=length(a);
m=length(b);

while (i<=n)
    j=1;
    while (j<m) && (a(i)~=b(j))
        j=j+1;
    end
    if a(i)==b(j) 
        estado=b(j);
        break
    end
    i=i+1;
end


