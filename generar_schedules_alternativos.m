%  Este script genera 21 planes de eventos de categoria A, 21 de cat.B y 
%  21 de cat.C , y con los planes de eventos determinar los parametros MLE 
%  que se estiman como procesos poisson/exponencial de los comportamientos 
%  de los usuarios. 
%
%  Crea un archivo "noestacionarios/ev_scheds.mat" con una variable "hat_theta" 
%  con parametros Poisson/exp en cada fila y una variable "M_sched" con 63 
%  planes de evento para cada tipo de oponente.
%
% Se usa en la ultima parte de la tesis, a ver como responden los algoritmos 
% en dichos escenarios.
% Su archivo de salida esta pensado para ser consumido por policiyIterator_script_multiples_noestacionarios.m


% simulacion de tipos (utiliza event_schedule_aternativos.m)
% 
% -1. Procesos de densidades uniformes
% -2. procesos de colas pesadas (similar cauchy)
% -3. poisson de intensidades estacionales
% -4. poisson on-off
% -5. poisson de intensidades aleatorias
%


clear all

target_n2=4000;

more off
theta=[];     %parametros del sistema para usar en los gneradores
M_sched={}; M1={}; M2={}; M3={}; M4={}; M5={};     %almaceno todos los ev_sched
hat_theta={}; hat_theta1={}; hat_theta2={}; hat_theta3={}; hat_theta4={}; hat_theta5={};   %estimaciones clasicas de parametros del sistema a partir de los ev_sched


tic
%reiteraciones=300;  %multiplo de 3   %esto va a crear una cantidad grande de parametros
reiteraciones=63;  %multiplo de 3   
for i = [1:reiteraciones]

    if (i <= reiteraciones/3)         #CATEGORIA A
        l1=2+10*rand; 
        l2=2+10*rand; 
        mu1=3+6*rand; 
        mu2=3+5*rand;
    elseif (i <= reiteraciones*2/3)   #CATEGORIA B
        l1=8+4*rand; 
        l2=11+10*rand; 
        mu1=1+1*rand; 
        mu2=0.1+0.4*rand;    
    else                              #CATEGORIA C
        l1=16+15*rand; 
        l2=2+13*rand; 
        mu1=0.1+0.8*rand; 
        mu2=0.5+1.5*rand;    
    endif
        
    theta(i,:)=[ l1 l2 mu1 mu2];

    T=round(min([target_n2/l2 , 1000] ) )

    %uniforme
    %genero schedule:
    ev_sched=event_schedule_alternativos(T,l1,l2,mu1,mu2, 1);
    M1{i}=ev_sched;

    %estimo parametros:
    inda1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==1));  losta1=diff(ev_sched(inda1,1)); hat_l1=1/mean(losta1);
    inda2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==1));  losta2=diff(ev_sched(inda2,1)); hat_l2=1/mean(losta2);
    indd1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==2));  lostd1=ev_sched(indd1,1)-ev_sched(inda1,1); hat_mu1=1/mean(lostd1);
    indd2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==2));  lostd2=ev_sched(indd2,1)-ev_sched(inda2,1); hat_mu2=1/mean(lostd2);
    hat_theta1{i}=[hat_l1 hat_l2 hat_mu1 hat_mu2];


    %cauchy
    %genero schedule:
    ev_sched=event_schedule_alternativos(T,l1,l2,mu1,mu2, 2);
    M2{i}=ev_sched;
    
    %estimo parametros:
    inda1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==1));  losta1=diff(ev_sched(inda1,1)); hat_l1=1/mean(losta1);
    inda2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==1));  losta2=diff(ev_sched(inda2,1)); hat_l2=1/mean(losta2);
    indd1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==2));  lostd1=ev_sched(indd1,1)-ev_sched(inda1,1); hat_mu1=1/mean(lostd1);
    indd2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==2));  lostd2=ev_sched(indd2,1)-ev_sched(inda2,1); hat_mu2=1/mean(lostd2);
    hat_theta2{i}=[hat_l1 hat_l2 hat_mu1 hat_mu2];

  
    %Estacionales
    %genero schedule:
    ev_sched=event_schedule_alternativos(T,l1,l2,mu1,mu2, 3);
    M3{i}=ev_sched;
    
    %estimo parametros:
    inda1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==1));  losta1=diff(ev_sched(inda1,1)); hat_l1=1/mean(losta1);
    inda2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==1));  losta2=diff(ev_sched(inda2,1)); hat_l2=1/mean(losta2);
    indd1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==2));  lostd1=ev_sched(indd1,1)-ev_sched(inda1,1); hat_mu1=1/mean(lostd1);
    indd2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==2));  lostd2=ev_sched(indd2,1)-ev_sched(inda2,1); hat_mu2=1/mean(lostd2);
    hat_theta3{i}=[hat_l1 hat_l2 hat_mu1 hat_mu2];



    %poisson on-off
    %genero schedule:
    ev_sched=event_schedule_alternativos(T,l1,l2,mu1,mu2, 4);
    M4{i}=ev_sched;
    
    %estimo parametros:
    inda1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==1));  losta1=diff(ev_sched(inda1,1)); hat_l1=1/mean(losta1);
    inda2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==1));  losta2=diff(ev_sched(inda2,1)); hat_l2=1/mean(losta2);
    indd1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==2));  lostd1=ev_sched(indd1,1)-ev_sched(inda1,1); hat_mu1=1/mean(lostd1);
    indd2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==2));  lostd2=ev_sched(indd2,1)-ev_sched(inda2,1); hat_mu2=1/mean(lostd2);
    hat_theta4{i}=[hat_l1 hat_l2 hat_mu1 hat_mu2];



    %random rates
    %genero schedule:
    ev_sched=event_schedule_alternativos(T,l1,l2,mu1,mu2, 5);
    M5{i}=ev_sched;
    
    %estimo parametros:
    inda1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==1));  losta1=diff(ev_sched(inda1,1)); hat_l1=1/mean(losta1);
    inda2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==1));  losta2=diff(ev_sched(inda2,1)); hat_l2=1/mean(losta2);
    indd1=find( (ev_sched(:,2)==1).*(ev_sched(:,3)==2));  lostd1=ev_sched(indd1,1)-ev_sched(inda1,1); hat_mu1=1/mean(lostd1);
    indd2=find( (ev_sched(:,2)==2).*(ev_sched(:,3)==2));  lostd2=ev_sched(indd2,1)-ev_sched(inda2,1); hat_mu2=1/mean(lostd2);
    hat_theta5{i}=[hat_l1 hat_l2 hat_mu1 hat_mu2];
    
endfor
toc


M_sched={M1, M2, M3, M4, M5};     %conjuntos de todos los ev_sched. Forma de acceso: M_sched{tipo}{indice}(t_ind,columna)
hat_theta={hat_theta1, hat_theta2, hat_theta3, hat_theta4, hat_theta5 };     % conjutno de todos los parametros estimados. Forma de acceso hat_theta{tipo}{indice}(indice_parametro)


save("/home/jvanerio/Escritorio/tesis/noestacionarios/ev_scheds.mat","M_sched","hat_theta")


% IMPORTANTE IMPORTATE IMPORTANTE IMPORTANTE
% Se guardan los event_schedules y los "hat_theta" (parametros estimados) a los efectos de alimentar al script "policyIterator_script_multiples_noestacionarios.m" que tomará esos datos para calcular nuevos conjuntos de politicas optimas.
%
