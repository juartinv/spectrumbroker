%  Script que genera gráficas y estadísticas a partir de 
%  los resultados de obtenidos de ejecutar master_expertos_m_cli.m
%  (o alternativamente desde los .mat que generen), para estudiar 
%  impacto de variar la cantidad de expertos considerados.
%  
%
% juan vanerio, 2017




more off

%size(m)=(iteraciones x repeticiones x params) x 3
progcode=[11,12,13,21,22,23,31,32]
progname={'AME-FTPL','AME-PAPE','AME-PMPE','LBE-FTPL','LBE-PAPE','LBE-PMPE','CBE-FTPL','CBE-PAPE'}
l=length(progcode);

palette = jet (l);

%cuantas=iteraciones
cuantas=0

for elegido =1:cuantas

    sleep(2)
    figure
    hold on
    title('Ganancia obtenida en funcion de la cantidad de expertos considerados')
    ylabel("m")
    xlabel("N")
    labels={};
    for p=1:6,
        indices=find((estadistica_summ(:,1)==elegido).*(estadistica_summ(:,2)==progcode(p)));

        h=errorbar(estadistica_summ(indices,3), estadistica_summ(indices,6), estadistica_summ(indices,6)-estadistica_summ(indices,5), estadistica_summ(indices,7)-estadistica_summ(indices,6));
        
        set(h,'markersize',10,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));
        
        labels = {labels{:}, progname{p}  };
    endfor
    legend(labels,"location", "northeastoutside")
    axis([3 21])
    grid
    hold off

endfor



rango=ceil(iteraciones/2)
estadistica_summ2=[]
for p=1:6,
    for v=4:4:20,
        indices=find(    (estadistica_summ(:,2)==progcode(p)).*(estadistica_summ(:,3)==v)    );
        [s,ind]=sort( estadistica_summ(indices,4) );
        estadistica_summ2=[estadistica_summ2; [ progcode(p) v estadistica_summ(indices(ind(rango)),4:end)   ]];
    endfor
endfor
estadistica_summ2

figure
hold on
title('Ganancia de media obtenida en funcion de la cantidad de expertos considerados')
ylabel("m")
xlabel("N")
labels={};
for p=1:6,

    indices=find(estadistica_summ2(:,1)==progcode(p));

    h=errorbar(estadistica_summ2(indices,2), estadistica_summ2(indices,5), estadistica_summ2(indices,5)-estadistica_summ2(indices,4), estadistica_summ2(indices,6)-estadistica_summ2(indices,5));

    set(h,'markersize',10,'marker','x','linestyle','-','linewidth',2,'color',palette(p,:));

    labels = {labels{:}, progname{p}  };
endfor


labels
legend(labels,"location", "northeastoutside")
axis([3 21])
grid
hold off

