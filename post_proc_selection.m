%  Script que genera gráficas y estadísticas a partir de 
%  los resultados obtenidos de ejecutar master_selection_m_cli.m
%  (o desde los .mat que genere), para estudiar los resultados 
%  obtenidos por los diferentes mecanismos de prediccion ante 
%  varios comportamientos Poisson/exponenciales de los usuarios 
%  que conducen al sistema a puntos de trabajo muy diferentes.
%  
%  Comparando los resultados obtenidos con este script se determina
%  la seleccion de los mejores mecanismos de prediccion, los cuales
%  son los utilizados en las pruebas restantes de este trabajo.
%
% juan vanerio, 2017


more off

aux=estadistica_summ;

l=length(programas);
estadistica_summ=[];

j=0;
for i=[1: rows(aux)/l],
    indices=[1+l*(i-1):l*i];
    %if (max(aux(indices,3 ))<0.5 && mean(aux(indices,3 )) > -1 )
    %if (max(aux(indices,3 ))<0.9 && mean(aux(indices,3 )) > 0 )
    if (max(aux(indices,3 ))<2 && mean(aux(indices,3 )) > -2 )
        j++;
        [medidas,ranking] = sort( aux(indices,3));
        estadistica_summ=[estadistica_summ; [ j*ones(l,1)  aux(indices,2:end) ranking ]];
    endif
endfor
iteraciones=rows(estadistica_summ)/l;

puntaje=[];
for p=1:l,
    indices= find (estadistica_summ(:,2)==programas(p)) ;
    puntaje=[puntaje; [programas(p) sum(estadistica_summ(indices,end))/iteraciones ]];
endfor
puntaje




progcode=[11,12,13,21,22,23,31,32]
progname={'AME-FTPL','AME-PAPE','AME-PMPE','LBE-FTPL','LBE-PAPE','LBE-PMPE','CBE-FTPL','CBE-PAPE'}
l=length(progcode);

palette = jet (l);

seleccionadas=1:iteraciones;
%seleccionadas=[4 5 8 9 11 18 21 25 26 27 29 31];
%seleccionadas=[1 3:5 8:29 ];
%cuantas=10

graficar=0;
if graficar
    for elegido = seleccionadas,
        %elegido=1   #iteracion elegida para graficar
        sleep(1)
        figure
        hold on
        title('Ganancia obtenida en funcion de la cantidad de expertos considerados')
        ylabel("m")
        %xlabel("")
        labels={};
        for p=1:l,
            indices=find((estadistica_summ(:,1)==elegido).*(estadistica_summ(:,2)==progcode(p)))

            h=plot(estadistica_summ(indices,2), estadistica_summ(indices,4) );
            set(h,'markersize',10,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));
            
            labels = {labels{:}, progname{p}  };
        endfor
        legend(labels,"location", "northeastoutside")
        grid
        hold off
    endfor
endif

figure
hold on
ylabel("m")
xlabel("iteracion")
labels={};

for p=1:l,
    indices=find(estadistica_summ(:,2)==progcode(p));

    h=plot(estadistica_summ(indices,1), estadistica_summ(indices,4) );
        
    set(h,'markersize',7,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));

    labels = {labels{:}, progname{p}  };
endfor
legend(labels,"location", "northeastoutside")

grid
hold off


figure
hold on
ylabel("m")
xlabel("iteracion")
labels={};

for p=1:l,
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
estadistica_summ_ucb=[];
for p=progcode,
    indices=find( (estadistica_summ(:,2)==p) );
    estadistica_summ_min=[estadistica_summ_min, estadistica_summ(indices,3) ];
    
    estadistica_summ_med=[estadistica_summ_med, estadistica_summ(indices,5) ];
    
    estadistica_summ_ucb=[estadistica_summ_ucb, estadistica_summ(indices,6) ];
endfor

estadistica_summ_min=estadistica_summ_min(seleccionadas,:);
estadistica_summ_med=estadistica_summ_med(seleccionadas,:);
estadistica_summ_ucb=estadistica_summ_ucb(seleccionadas,:);    %p95

figure
bar(estadistica_summ_min)
ylabel("m")
xlabel("iteracion")
title("minimos de cada iteracion")

figure
bar(estadistica_summ_min')
ylabel("m")
xlabel("alg")
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
title("medianas de cada algoritmo")


figure
bar(estadistica_summ_ucb)
ylabel("m")
xlabel("iteracion")
title("perc95 de cada iteracion")

figure
bar(estadistica_summ_ucb')
ylabel("m")
xlabel("alg")
title("perc95 de cada algoritmo")




disp("medianas de los mininimos/medianas/p95 obtenidos por cada mecanimos en cad apunto de operacion")
median(estadistica_summ_min)
median(estadistica_summ_med)
median(estadistica_summ_ucb)

