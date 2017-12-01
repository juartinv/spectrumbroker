%  Script que genera gráficas y estadísticas a partir de 
%  los resultados obtenidos de ejecutar master_noestacionarios_m_cli.m
%  o alternativamente master_noestacionarios_especial.m
%  (o desde los .mat que generen), para estudiar los resultados 
%  obtenidos por los diferentes mecanismos de prediccion (y opcionalemnte 
%  de alguna politica MDP calculada externamente) frente a un 
%  determinado tipo de oponente no Poisson.
%  
%
% juan vanerio, 2017


more off

%asumo que tipo ya esta en memoria!


if tipo==1
    titulo="Oponentes Uniformes";
elseif tipo==2
    titulo="Oponentes Colas Pesadas";
elseif tipo==3
    titulo="Oponentes Intensidades Estacionales";
elseif tipo==4
    titulo="Oponentes Intensidades ON-OFF";
elseif tipo==5
    titulo="Oponentes Intensidades Aleatorias";
endif






progcode=[1,13,21,32]
progname={'MDP','AME-PMPE','LBE-FTPL','CBE-PAPE'}
l=length(progcode);

palette = jet (length(progcode));
#palette = summer(length(progcode));

iteraciones=rows(theta)     %debe ser un multilpo de tres por construccion. El priemr tercio de elementos son clase A, luego B, luego C


if ( exist("categoria") == 0)  #si no existe la variable categoria
    disp("Variable 'categoria' no definida. Se crea y se asigna valor 'todas' por defecto.")
    categoria="todas"    % A, B, C, todas
endif
if strcmp(categoria,"todas")
    seleccionadas=1:iteraciones;  %todos
elseif strcmp(categoria,"A")
    seleccionadas=1:iteraciones/3;  %categoria A
elseif strcmp(categoria,"B")
    seleccionadas=iteraciones/3+1:iteraciones*2/3;  %categoria B
elseif strcmp(categoria,"C")
    seleccionadas=iteraciones*2/3+1:iteraciones;  %categoria C
else
    disp("Valor invalido para variable categora. Debe ser 'A', 'B', 'C' o 'todas' ")
    return
endif


estadistica_summ_sub=estadistica_summ(seleccionadas,:);
aux=estadistica_summ;


estadistica_summ_min=[];
estadistica_summ_med=[];
estadistica_summ_p95=[];
for p=progcode,
    indices=find( (estadistica_summ(:,2)==p) );
    estadistica_summ_min=[estadistica_summ_min, estadistica_summ(indices,3) ];
    
    estadistica_summ_med=[estadistica_summ_med, estadistica_summ(indices,5) ];
    estadistica_summ_p95=[estadistica_summ_p95, estadistica_summ(indices,6) ];
endfor

estadistica_summ_min=estadistica_summ_min(seleccionadas,:);
estadistica_summ_med=estadistica_summ_med(seleccionadas,:);
estadistica_summ_p95=estadistica_summ_p95(seleccionadas,:);


#Grafico los minimos
figure
hold on
ylabel("m")
xlabel("iteracion")
title([titulo, " - Minimos obtenidos en cada iteracion"])
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
title([titulo, " - Medianas obtenidas en cada iteracion"])
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
title([titulo, " - minimos de cada iteracion"])

figure
bar(estadistica_summ_min')
ylabel("m")
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title([titulo, " - minimos de cada algoritmo"])
grid



figure
bar(estadistica_summ_med)
ylabel("m")
xlabel("iteracion")
title([titulo, " - medianas de cada iteracion"])

figure
bar(estadistica_summ_med')
ylabel("m")
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title([titulo, " - medianas de cada algoritmo"])
grid


figure
bar(estadistica_summ_p95)
ylabel("m")
xlabel("iteracion")
title([titulo, " - p95 de cada iteracion"])

figure
bar(estadistica_summ_p95')
ylabel("m")
xlabel("alg")
set(gca,'XTick',1:length(progcode),'XTickLabel',progname)
title([titulo, " - p95 de cada algoritmo"])
grid

disp(" ==== ESTADISTICAS ====")

disp([titulo, " - medianas de los minimos obtenidos por cada mecanismo en cada punto de operacion"])
median(estadistica_summ_min)

disp([titulo, " - minimos de los minimos obtenidos por cada mecanismo en cada punto de operacion"])
min(estadistica_summ_min)


disp([titulo, " - medianas de las medianas obtenidas por cada mecanismo en cada punto de operacion"])
median(estadistica_summ_med)

disp([titulo, " - minimos de las medianas obtenidas por cada mecanismo en cada punto de operacion"])
min(estadistica_summ_med)


disp([titulo, " - medianas de los p95 obtenidos por cada mecanismo en cada punto de operacion"])
median(estadistica_summ_p95)

disp([titulo, " - minimos de los p95 obtenidos por cada mecanismo en cada punto de operacion"])
min(estadistica_summ_p95)


