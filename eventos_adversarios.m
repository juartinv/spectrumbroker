% Este script se utiliza para construir (precalcular) el plan de eventos para la simulacion
% llevada a cabo por master_delay_alt.m
%
% Este plan de eventos se genera en forma deterministica (por lo tanto compatible con el modelo
% de oponente olvidadizo) con la intención de resaltar las diferencias en los resultados que 
% obtienen los mecanismos de prediccón al emplear # y al prescindir de la adaptación de tolerancia
% a la demora de la obtención del resultado de cada decision.
%
% El plan de eventos simulados es periodico. Cada periodo esencialemente consta de dos regimenes:
%
%    1 - primer regimen: Arribo constante de SU con tiempos de servicio muy prolongados. 
%    2 - segundo regimen: Aparece una rafaga muy intensa de de usuarios primarios que rapidamente 
%        provoca la expulsión de todos los SU del sistema y luego se van antes que llegue el 
%        siguiente secundario.
%
% Este comportamiento provoca que ningun secundario genere ganancia neta.
%
%
% Output:
% Matriz ev_sched= [event_time, user (Pri or Sec), event (1: Arrival or 2:departure), event_id]
% 
% 2017- juan vanerio



mu2 = 1/1000
l2 = 1
mu1 = 2000*mu2
l1  = 1000*l2

NN1 = floor(C)
NN2 = floor(C)



%primer regimen: rafaga de secundarios lentos
X2 = ones(NN2,1)* [1/l2, 1/mu2];           % Agrego una rafaga  de secundarios de servicios lentos
dr_2 = sum(X2(:,1) ) %duracion regimen


%segundo regimen: Agrego una rafaga de primarios de servicios comunes
X1 = ones(NN1,1)* [1/l1, 1/mu1];             
dr_1 = sum(X1(:,1) ) %duracion regimen

z=1.2;
X1(1,1) += (dr_2-dr_1)*z;                         % offset para que los primarios lleguen justo al final


for i = [1:5],   %ojo que el aumento de casos es exponencial!
    X1=[X1;X1;];
    X2=[X2;X2;];    
endfor


#Determiino los instantes de tiempo en que ocurre cada evento:
PA=cumsum(X1(:,1));    #Primary Arrivals
PD=PA+X1(:,2);         #Primary Departures
SA=cumsum(X2(:,1));    #Secondary Arrivals
SD=SA+X2(:,2);         #Secondary Departures

ev_sched=[PA, ones(rows(X1),1), ones(rows(X1),1), [1:rows(X1)]' ;
          PD, ones(rows(X1),1), 2*ones(rows(X1),1), [1:rows(X1)]' ;
          SA, 2*ones(rows(X2),1), ones(rows(X2),1), rows(X1)+[1:rows(X2)]' ;
          SD, 2*ones(rows(X2),1), 2*ones(rows(X2),1), rows(X1)+[1:rows(X2)]' ];

#Finalmente ordeno la tabla para que los eventos queden ordenados cronologicamente.
ev_sched= sortrows(ev_sched);

%clear mu1 l1 mu2 l2 NN1 NN2 X1_1 X1_2 X2_1 X2_2 X1 X2 PA PD SA SD
