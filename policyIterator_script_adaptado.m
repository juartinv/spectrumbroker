% policy iterator by @claudina
%
% Este algoritmo implementa una version de Modified Policy Iterator
% especialmente orientado al problema del spectrum broker con dos 
% usuarios con arribos Poisson y servicios exponenciales.s
%
% Modificaciones adicionales realizadas por juan para adaptarse 
% al simulador de mi tesis (spectrum broker con algoritmos basados 
% en expertos). Debe invocarse solo desde policyIterator_script_multiples.m


more off

mfilename


### Requerimiento: Ya tienen que estar definidos en scripts de inicializacion 
if ( exist("C") == 0 || exist("T") == 0 || exist("l1") == 0 || exist("l2") == 0 || exist("m1") == 0 || exist("m2") == 0 || exist("R") == 0 || exist("K") == 0 || exist("alpha") == 0 )
    error("No inicializado: No esta definida alguna de las opciones de simulador.");
endif


tic

% parametros a setear
% C=20;
% l1=20;
% l2=50;
% m1=3;
% m2=0.5;
% R=1;
% K=2;
% alpha=0;

% cantidad de estados?
n=0;
for i=0:C
    n=n+C-i+1;
end


% lista de estados
i=1;
for k=1:C+1
    for j=1:C+1-k+1
        s(i,:)=[i j-1 k-1];
        i=i+1;
    end
end

%s
%n

iter=0;
eps = 0.000000001;

policyI = zeros(n,1);


den=l1+l2+C*m1+C*m2+alpha;
beta=(l1+l2+C*m1+C*m2)/(l1+l2+C*m1+C*m2+alpha)



Vi=ones(n,1);
Vf=zeros(n,1);
policyF=ones(n,1);
%se obtiene la funcion de valor asociada a la politica inicial.
%     for i=1:n
%         if (((sum(s(i,:))-i)<C))
%             policyF(i)=2;
%         else
%             if (((sum(s(i,:))-i)==C) && s(i,2)~=C)
%                 policyF(i)=1;
%             else
%                 if (((sum(s(i,:))-i)==C) && s(i,2)==C)
%                 policyF(i)=1;
%                 end
%             end     
%         end
%     end
    
iter2=0;
while ((isequal(policyI,policyF)==0) && iter2< 5) % no sean iguales las políticas
policyI=policyF;

    iter=0   #fix 2016/dic/27 - sugerencia Claudina
        
    while (max(abs(Vf-Vi))>=eps && iter<3000)
    Vi=Vf;
    for i=1:n
        if (((sum(s(i,:))-i)<C) && s(i,2)~=0 && s(i,3)~=0)
            if policyF(i)==2
                Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R)+m1*s(i,2)*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
            else
                Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3),s)))+m1*s(i,2)*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
            end
        else
            if (((sum(s(i,:))-i)<C) && s(i,2)~=0 && s(i,3)==0)
                if policyF(i)==2
                    Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R)+m1*s(i,2)*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                else
                    Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3),s)))+m1*s(i,2)*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                end
                    
            else
                if (((sum(s(i,:))-i)<C) && s(i,3)~=0 && s(i,2)==0)
                    if policyF(i)==2
                        Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R)+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                    else
                        Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3),s)))+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                    end
                else
                    if (((sum(s(i,:))-i)<C) && s(i,3)==0 && s(i,2)==0)
                        if policyF(i)==2
                            Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R)+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                        else
                            Vf(i)=(l1*Vi(devolverEstado(s(i,2)+1,s(i,3),s))+l2*(Vi(devolverEstado(s(i,2),s(i,3),s)))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                        end
                    else
                        if (((sum(s(i,:))-i)==C) && s(i,2)~=C && s(i,2)~=0)
                        Vf(i)=(l1*(Vi(devolverEstado(s(i,2)+1,s(i,3)-1,s))-K)+l2*Vi(devolverEstado(s(i,2),s(i,3),s))+m1*s(i,2)*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                    else
                        if (((sum(s(i,:))-i)==C) && s(i,2)==0) 
                            Vf(i)=(l1*(Vi(devolverEstado(s(i,2)+1,s(i,3)-1,s))-K)+l2*Vi(devolverEstado(s(i,2),s(i,3),s))+m2*s(i,3)*Vi(devolverEstado(s(i,2),s(i,3)-1,s))+(C*(m1+m2)-m1*s(i,2)-m2*s(i,3))*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                        else
                            if (((sum(s(i,:))-i)==C) && s(i,2)==C) 
                            Vf(i)=(l1*Vi(devolverEstado(s(i,2),s(i,3),s))+l2*Vi(devolverEstado(s(i,2),s(i,3),s))+m1*C*Vi(devolverEstado(s(i,2)-1,s(i,3),s))+m2*C*Vi(devolverEstado(s(i,2),s(i,3),s)))/den;
                            end
                        end
                        end
                    end
                end
            end
        end
    end
    iter=iter+1;
    %pause
    end
    
    
    for i=1:n
        if (((sum(s(i,:))-i)<C) && s(i,2)~=0 && s(i,3)~=0)
            [maximo,policyF(i)]=max([Vi(devolverEstado(s(i,2),s(i,3),s)),Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R]);
        else
            if (((sum(s(i,:))-i)<C) && s(i,2)~=0 && s(i,3)==0)
                [maximo,policyF(i)]=max([Vi(devolverEstado(s(i,2),s(i,3),s)),Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R]);
          else
                if (((sum(s(i,:))-i)<C) && s(i,3)~=0 && s(i,2)==0)
                    [maximo,policyF(i)]=max([Vi(devolverEstado(s(i,2),s(i,3),s)),Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R]);
                else
                    if (((sum(s(i,:))-i)<C) && s(i,3)==0 && s(i,2)==0)
                        [maximo,policyF(i)]=max([Vi(devolverEstado(s(i,2),s(i,3),s)),Vi(devolverEstado(s(i,2),s(i,3)+1,s))+R]);
                  else
                        if (((sum(s(i,:))-i)==C) && s(i,2)~=C && s(i,2)~=0)
                        policyF(i)=1;
                  else
                        if (((sum(s(i,:))-i)==C) && s(i,2)==0) 
                            policyF(i)=1;
                       else
                            if (((sum(s(i,:))-i)==C) && s(i,2)==C) 
                            policyF(i)=1;
                            end
                        end
                        end
                    end
                end
            end
        end
    end
    
    iter2=iter2+1;
end


policy=policyF
iter2
toc
