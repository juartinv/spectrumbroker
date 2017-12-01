%  Script que genera gráficas y estadísticas a partir de 
%  los resultados obtenidos de ejecutar master_c50_cli.m
%  (o alternativamente cargado desde sus .mat).
%  Con estos datos puede estudiarse el desempeño de los 
%  mecanismos de prediccion seleccionados frente al mejor 
%  de un conjunto extenso de reglas de decision estaticas 
% ("FULLEXPERT") en escenarios de capacidad C=50 donde MDP 
%  resulta impractico.
%
% juan vanerio, 2017



more off

aux=estadistica_summ;


l=length(programas)
%estadistica_summ=[];

progcode=[1,13,21,32]
prog_rel_pos=[1,4,5,9];
progname={'FULLEXPERT','AME-PMPE','LBE-FTPL','CBE-PAPE'}
l=length(progcode);

palette = jet (length(progcode));
#palette = summer(length(progcode));

seleccionadas=1:iteraciones;

estadistica_summ2=[];
for i=seleccionadas,
    aux2=aux(1+(i-1)*l:i*l,:);
    estadistica_summ2=[estadistica_summ2; aux(prog_rel_pos,:)];
endfor
%al llegar a este punto deberia tener un estadisitica_summ2 que solo contenga los programas candidatos


#Grafico los minimos
figure
hold on
ylabel("m")
xlabel("iteracion")
title("Minimos obtenidos en cada iteracion")
labels={};

for p=1:length(progcode),
    indices=find(estadistica_summ(:,2)==progcode(p));

    h=plot(estadistica_summ(indices,1), estadistica_summ(indices,4) );
        
    set(h,'markersize',7,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));

    labels = {labels{:}, progname{p}  };
endfor
legend(labels,"location", "northeastoutside")
grid
hold off

#Grafico las medianas
figure
hold on
ylabel("m")
xlabel("iteracion")
title("Medianas obtenidas en cada iteracion")
labels={};

for p=1:length(progcode),
    indices=find(estadistica_summ(:,2)==progcode(p));

    h=errorbar(estadistica_summ(indices,1), estadistica_summ(indices,5), estadistica_summ(indices,5)-estadistica_summ(indices,4), estadistica_summ(indices,6)-estadistica_summ(indices,5));
       
    set(h,'markersize',7,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));

    labels = {labels{:}, progname{p}  };
endfor
legend(labels,"location", "northeastoutside")

grid
hold off


estadistica_summ_min=[];
estadistica_summ_med=[];
for p=progcode,
    indices=find( (estadistica_summ(:,2)==p) );
    estadistica_summ_min=[estadistica_summ_min, estadistica_summ(indices,3) ];
    
    estadistica_summ_med=[estadistica_summ_med, estadistica_summ(indices,5) ];
endfor

estadistica_summ_min=estadistica_summ_min(seleccionadas,:);
estadistica_summ_med=estadistica_summ_med(seleccionadas,:);

figure
bar(estadistica_summ_min)
ylabel("m")
xlabel("iteracion")
title("minimos de cada iteracion")

figure
bar(estadistica_summ_min')
ylabel("m")
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title("minimos de cada algoritmo")

figure
bar(  (estadistica_summ_min ./ (estadistica_summ_min(:,1 )*ones(1,columns(estadistica_summ_min)))  )')
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title("minimos de cada algoritmo relativo a FULLEXPERT")




figure
bar(estadistica_summ_med)
ylabel("m")
xlabel("iteracion")
title("medianas de cada iteracion")

figure
bar(estadistica_summ_med')
ylabel("m")
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title("medianas de cada algoritmo")


figure
bar(  (estadistica_summ_med ./ (estadistica_summ_med(:,1 )*ones(1,columns(estadistica_summ_med)))  )')
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title("medianas de cada algoritmo relativo a FULLEXPERT")



disp("medianas de los minimos obtenidos por cada mecanismo en cada punto de operacion")
median(estadistica_summ_min)

disp("medianas de las medianas obtenidas por cada mecanismo en cada punto de operacion")
median(estadistica_summ_med)


