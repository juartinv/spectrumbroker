function [loIdeC,upIdeC]=median_idec(n)

    % devuelve los indices ordenados de las muestras para obtener 
    % intervalos de confianza al 95% para la mediana.

    conf_lvl =  0.95000
    p=0.5    %0.5 para la mediana

    upIdeC=binoinv((1+conf_lvl)/2,n,p)+1
    loIdeC=binoinv((1-conf_lvl)/2,n,p)
   
endfunction

