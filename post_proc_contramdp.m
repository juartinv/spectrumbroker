%  Script que genera gráficas y estadísticas a partir de 
%  los resultados obtenidos de ejecutar master_contramdp.m
%  (o alternativamente cargado desde su correspondiente 
%   "comparacion/output.mat").
%
%  Esto permite comparar los resultados obtenidos por los 
%  mecanismos de prediccion seleccionados ante procesos de 
%  tipo Poisson/exponencial  contra la politica óptima 
%  correspondiente a cada caso, calculada mediante MDP 
%  (externamente).
%  
%
% juan vanerio, 2017


more off

l=length(programas)
%estadistica_summ=[];

progcode=[1,13,21,32]
prog_rel_pos=[1,4,5,9];
progname={'MDP','AME-PMPE','LBE-FTPL','CBE-PAPE'}
l=length(progcode);

palette = jet (length(progcode));
#palette = summer(length(progcode));

%seleccionadas=1:iteraciones;  %todos

%seleccionadas=[1:25,101:125]   %maximales
%seleccionadas=[26:75,126:175]   %borde
%seleccionadas=[76:100,176:200]   %saturaciones

%seleccionadas=[1:25]   %maximales 1
%seleccionadas=[26:75]   %borde 1
%seleccionadas=[76:100]   %saturaciones 1
%seleccionadas=[101:125]   %maximales 2
%seleccionadas=[126:175]   %borde 2
seleccionadas=[176:200]   %saturaciones 2



estadistica_summ_sub=estadistica_summ(seleccionadas,:);
aux=estadistica_summ;


estadistica_summ_min=[];
estadistica_summ_med=[];
for p=progcode,
    indices=find( (estadistica_summ(:,2)==p) );
    estadistica_summ_min=[estadistica_summ_min, estadistica_summ(indices,3) ];
    
    estadistica_summ_med=[estadistica_summ_med, estadistica_summ(indices,5) ];
endfor

estadistica_summ_min=estadistica_summ_min(seleccionadas,:);
estadistica_summ_med=estadistica_summ_med(seleccionadas,:);



#Grafico los minimos
figure
hold on
ylabel("m")
xlabel("iteracion")
title("Minimos obtenidos en cada iteracion")
labels={};

for p=1:length(progcode),
    indices=find(aux(:,2)==progcode(p));

    h=plot(aux(indices,1), aux(indices,3) );
        
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
    indices=find(aux(:,2)==progcode(p));

    h=errorbar(aux(indices,1), aux(indices,5), aux(indices,5)-aux(indices,4), aux(indices,6)-aux(indices,5));
       
    set(h,'markersize',7,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));

    labels = {labels{:}, progname{p}  };
endfor
legend(labels,"location", "northeastoutside")

grid
hold off







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




disp("medianas de los minimos obtenidos por cada mecanismo en cada punto de operacion")
median(estadistica_summ_min)

disp("medianas de las medianas obtenidas por cada mecanismo en cada punto de operacion")
median(estadistica_summ_med)

