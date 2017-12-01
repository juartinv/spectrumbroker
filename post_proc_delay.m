%  Script que genera gráficas y estadísticas a partir de 
%  los resultados de obtenidos de ejecutar master_delay_cli.m
%  o master_delay_alt.m (o alternativamente desde los .mat que 
%  generen), para estudiar impacto de tolerancia a la demora 
%  en los mecanismos de prediccion.
%  
%
% juan vanerio, 2017


more off

%size(m)=(iteraciones x repeticiones x params) x 3
l=length(programas)/2;


progcode=[11,12,13,21,22,23,31,32]
progname={'AME-FTPL','AME-PAPE','AME-PMPE','LBE-FTPL','LBE-PAPE','LBE-PMPE','CBE-FTPL','CBE-PAPE'}



estadistica_full=[m(:,1:2), repmat(delay_tolerance_global', iteraciones*repeticiones,1) m(:,3) ];
m_aug=estadistica_full;
[loIdeC,upIdeC]=median_idec(repeticiones);

estadistica_summ=[];
for i=1:iteraciones,
    for p=1:l,
        indices_tol = find ( (m_aug(:,3)==1).*(m_aug(:,1)==i).*(m_aug(:,2)==programas(p)) );
        indices_notol = find ( (m_aug(:,3)==0).*(m_aug(:,1)==i).*(m_aug(:,2)==programas(p)) );
        [medidas,ind] = sort( [m(indices_tol,3), m(indices_notol,3), m(indices_tol,3)-m(indices_notol,3)]);
        datos = [medidas(1,:) medidas(loIdeC,:) median(medidas) medidas(upIdeC,:)];   %las columnas quedan todos lso minimos primeros, luego los cotas inf, luego medianas
        estadistica_summ=[estadistica_summ; [i programas(p) datos([1 4 7 10 2 5 8 11 3 6 9 12]) ] ];  %reordeno los datos par uqe quede priemro tol, luego notol, luego diff
    endfor
endfor


%grafico Estadisticas agregando las iteraciones
disp("estadisticas agregando las iteraciones")
disp('iter alg   min_tol |- med_tol -|   min_notol |- med_notol -|   min_diff |- med_diff -|')
estadistica_summ

palette = jet (l);



hold off; close all
figure
title("Medianas de las diferencias")
labels={};
hold on
for p=1:l,
    indices=find((estadistica_summ(:,2)==programas(p)));
    h=errorbar(estadistica_summ(indices,1)+p*0.05, estadistica_summ(indices,13), 
               estadistica_summ(indices,13)-estadistica_summ(indices,12)+eps, 
               estadistica_summ(indices,14)-estadistica_summ(indices,13)+eps);
    set(h,'markersize',10,'marker','x','linestyle','none','linewidth',2,'color',palette(p,:));
    #set(h,'markersize',10,'linewidth',2,'color',palette(p,:));
    %labels = {labels{:}, progname{progcode==programas(p)}  };
    labels = {labels{:}, progname{p}  };    
endfor
grid
labels
legend(labels,"location", "northeastoutside")
ylabel("m")
xlabel("iteracion")
hold off






