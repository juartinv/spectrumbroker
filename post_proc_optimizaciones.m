%  Script que genera gráficas y estadísticas a partir de 
%  los resultados obtenidos de ejecutar master_optim_cli.m.
%  De esta forma se puede evaluar el desempeño obtenido por 
%  cada mecanismo de prediccón al variar el valor de su 
%  parametro de ajuste dentro de un rango logaritmico.
%  Con estos datos se procede a determinar el mejor valor.
%  
%
% juan vanerio, 2017


more off

%size(m)=(iteraciones x repeticiones x params) x 3
l=length(fparam_global);


estadistica_full=[m(:,1:2)  repmat(fparam_global', iteraciones*repeticiones,1)  m(:,3)];
estadistica_summ=[];


for i=1:iteraciones,
    for p=1:l,
        indices=find( (estadistica_full(:,3)==fparam_global(p)).*(estadistica_full(:,1)==i)  );
        medidas=estadistica_full(indices,end);

        estadistica_summ=[estadistica_summ; [i fparam_global(p) min(medidas) quantile(medidas,0.1) median(medidas) quantile(medidas,0.9)  ]];
    endfor
   
endfor
disp('iter   param    min    perc10%   median  perc90%')
estadistica_summ


#graficos

palette = jet (l);

figure
hold on
#title("minimos")
ylabel("m")
xlabel("log(param)")
labels={};
for i=1:iteraciones,
    indices=find((estadistica_summ(:,1)==i));
    #plot( log10(fparam_global), estadistica_summ(indices,3),'-x','markersize',10,'linewidth',1,'color',palette(i,:))
    semilogx( fparam_global, estadistica_summ(indices,3),'-o','markersize',10,'linewidth',4,'color',palette(i,:))
    #legend(labels,"location", "northeastoutside")
    labels = {labels{:}, ["iter#", num2str(i)]};
endfor
axis([min(fparam_global) max(fparam_global)])
legend(labels,"location", "northeastoutside")
grid;
hold off



figure
hold on
#title("Promedios")
ylabel("m")
xlabel("log(param)")
labels={};
for i=1:iteraciones,
    indices=find((estadistica_summ(:,1)==i));
    #h=errorbar(log10(fparam_global), estadistica_summ(indices,5), estadistica_summ(indices,5)-estadistica_summ(indices,4), estadistica_summ(indices,6)-estadistica_summ(indices,5));
    h=semilogxerr(fparam_global, estadistica_summ(indices,5), estadistica_summ(indices,5)-estadistica_summ(indices,4), estadistica_summ(indices,6)-estadistica_summ(indices,5));
    set(h,'markersize',10,'linewidth',4,'color',palette(i,:));
    labels = {labels{:}, ["iter#", num2str(i)]};
endfor
axis([min(fparam_global) max(fparam_global)])
legend(labels,"location", "northeastoutside")
grid
hold off



