%  Este script genera 21 planes de eventos a partir de valores de parametros 
%  elegidos para que las medianas de los tiempos de servicio entre los dos 
%  tipos de usuario sean claramente diferentes.
%  Con los planes de eventos se determinan los parametros MLE que se estiman como procesos 
%  poisson/exponencial de los comportamientos de los usuarios. 
%
%  Crea un archivo "noestacionarios/ev_scheds_especial.mat" con una variable "hat_theta" con parametros Poisson/exp
%  en cada fila y una variable "M_sched" con 63 los planes de evento para cada tipo de oponente.
%  Tambien crea el archivo  "noestacionarios/param_resultado_especial.mat", que contiene "M_sched_sel" (un 
%  subconjunto de M_sched),"q" (identico a hat_theta),"policies" (solo elementos nulos) y "selecciono" (los 
%  indices de los sched escogidos)

%  Se usa en la ultima parte de la tesis, a ver como responden los algoritmos en dichos escenarios.
%  Su segundo archivo de salida esta pensado para ser consumido directamente por master_noestacionarios_especial.m

% simulacion de tipos (usa event_schedule_alternativos.m)
% 
% -1. Procesos de densidades uniformes
% -2. procesos de colas pesadas (similar cauchy)
% -3. poisson de intensidades estacionales
% -4. poisson on-off
% -5. poisson de intensidades aleatorias
%
clear all

target_n2=5000;
C=20
epsilon=C/9
delta=C*2/9


more off
theta=[];     %parametros del sistema para usar en los gneradores
M_sched={}; M1={}; M2={}; M3={}; M4={}; M5={};     %almaceno todos los ev_sched
hat_theta={}; hat_theta1={}; hat_theta2={}; hat_theta3={}; hat_theta4={}; hat_theta5={};   %estimaciones clasicas de parametros del sistema a partir de los ev_sched


tic
%reiteraciones=300;  %multiplo de 3   %esto va a crear una cantidad grande de parametros
reiteraciones=21;  %multiplo de 3   
for i = [1:reiteraciones]

    mu1=0.7+0.6*rand;   mu1=mu1/3;  
    mu2=3; 

    u=(2*rand-1)*epsilon + C;
    v=(2*rand-1)*(u-delta);
    
    rho1=(u+v)/2;
    rho2=(u-v)/2; 
    
    l1=rho1*mu1;
    l2=rho2*mu2; 


    theta(i,:)=[ l1 l2 mu1 mu2];

    T=round(min([target_n2/l2 , 2000] ) )

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


save("/home/jvanerio/Escritorio/tesis/noestacionarios/ev_scheds_especial.mat","M_sched","hat_theta")
%en realidad este archivo no se usa.



selecciono=[1:reiteraciones];
qq={ hat_theta{1}(selecciono) hat_theta{2}(selecciono) hat_theta{3}(selecciono) hat_theta{4}(selecciono) hat_theta{5}(selecciono)   };
q1=q2=q3=q4=q5=[]
for i=[1:length(selecciono)]  %paso el formato de celdas a matriz...
    q1=[q1; qq{1}{i}];
    q2=[q2; qq{2}{i}];
    q3=[q3; qq{3}{i}];
    q4=[q4; qq{4}{i}];
    q5=[q5; qq{5}{i}];
endfor
global q={q1 q2 q3 q4 q5};
M_sched_sel=M_sched;
policies={ 0 0 0 0 0};

save("/home/jvanerio/Escritorio/tesis/noestacionarios/param_resultado_especial.mat","M_sched_sel","q","policies","selecciono")

