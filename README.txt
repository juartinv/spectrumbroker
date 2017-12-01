------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--------                                                                ------------
--------                 LEER ANTES DE UTILIZAR LOS SCRIPTS             ------------
--------                                                                ------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

En esta carpeta se encuentran los scripts utilizados para realizar las simulaciones 
y ensayos de la tesis de Maestría de Juan Vanerio, 2017.


Acerca del Funcionamiento de Cada Script
----------------------------------------
Por una introduccion general al funcionamiento de cada script/funcion, referirse al 
apendice del documento de tesis. La descripción detallada de dicho funcionamiento se 
encuentra al comienzo del codigo fuente de cada script.

Las pruebas fueron realizadas en diferntes versiones de octave, la más reciente y 
recomendada es GNU Octave, version 4.0.3

Además se requiere utilizar el package  parallel 3.1.1  para el calculo paralelo






Flujos para reproducir los ensayos de la tesis
----------------------------------------------

[Optimizacion de parametros de los algoritmos]

  1. master_optim_cli.m : ejecucion externa  (desde cli del SO)
         Genera los archivos con los resultados de las simulaciones en optimizaciones/
          11-borde.mat    11-saturada.mat  12-maximal.mat   13-borde.mat    13-saturada.mat  31-maximal.mat  
          11-maximal.mat  12-borde.mat     12-saturada.mat  13-maximal.mat  31-borde.mat     31-saturada.mat 

  2. post_proc_optimizaciones.m
         Trabaja  a partir de uno de los .mat anteriores. 
         Genera graficas: optim-minimos.pdf , optim-promedios.pdf 

  
  
  
[Efecto de la demora]

  1. master_delay_cli.m : ejecucion externa  (desde cli del SO)
         Genera los archivos con los resultados de las simulaciones en delay/
            borde.mat     maximal.mat   saturada.mat
  
  2. post_proc_delay.m
         Trabaja  a partir de uno de los .mat anteriores. 
         Genera graficas: delay-diff-borde.pdf   delay-diff-maximal.pdf   delay-diff-saturada.pdf

 Alternativa con oponente olvidadizo deterministico pra resatla efecto
  1. master_delay_alt.m : No genera ningun .mat. Se debe ejecutar desde la octave-cli
  2. post_proc_delay.m :  Debe ejecutarse justo enseguida del anterior.
         Genera graficas: delay-diff-adversario.pdf

  
  
  
[Efectos de la cantidad de expertos]

 Evaluacion de complejidad algoritmica
  1. master_expertos_elapsed.m : Se ejecuta desde octave-cli, no genera .mat y genera graficas sin guardarlas.
         Se sugiere guardar la grafica manualemnte como "master_expertos_tiempo.pdf"
  
  
  1. master_expertos_m_cli.m : ejecucion externa  (desde cli del SO)
         Genera los archivos con los resultados de las simulaciones en expertos/
            borde.mat     maximal.mat   saturada.mat  
            (OBS: para 'borde' se cambio la cantidad de iteraciones, es decir, planes de eventos)
             
  2. post_proc_expertos.m : 
         Trabaja a partir de alguno de los .mat anteriores, genera graficas.
         Manualmente las guarde como: 
            master_expertos_m_borde.pdf    master_expertos_m_max.pdf    master_expertos_m_sat.pdf
  
    
  
  
[Seleccion de los mejores Algoritmos]

  1. master_selection_cli.m : ejecucion externa  (desde cli del SO)
         Genera los archivos con los resultados de las simulaciones en selection/
            borde.mat     maximal.mat   saturada.mat   
            (OBS: para 'borde' se cambio la cantidad de iteraciones, es decir, planes de eventos)
  
  
  2. post_proc_selection.m : 
         Trabaja a partir de alguno de los .mat anteriores, genera graficas.
         Manualmente las guarde como: 
            selection-borde.pdf   selection-maximales.pdf   selection-saturadas.pdf
         (NOTA: comentando la linea 27 y descomentando la 25 se obtiene la grafica 
                que guarde como selection-borde-sub0_5.pdf, subconjunto de bordes 
                con resultado < 0.5)




[Comparacion de desempeño entre MDP y algoritmos seleccionados]
 Pruebas de complejidad del algoritmo PolicyIterator
  Pruebas realizadas en forma manual, variando C e invocando "policiyIterator_script_adaptado.m" 
  con los siguientes valores: 
  l1 = 8.80513
  l2 = 6.29509
  m1 = 0.61936
  m2 = 0.69555
  R = 1 
  K = 3 
  alpha = 0.001

 Comparacion de desempeño entre MDP y algoritmos seleccionados]
  1. gen_param.m : Genera conjuntos de parametros Poisson para las simulaciones y los deja en comparacion/param.mat
  2. policyIterator_script_multiples.m : Toma el archivo anterior y calcula las reglas de decision optimas para cada juego.
                                         Guarda el resultado en comparacion/param_resultado.mat
  3. master_contramdp.m : Toma los parametros de juegos y las reglas de decision calculadas del archivo comparacion/param_resultado.mat
                            y realiza simulaciones con esos datos. Los resultados los guarda en comparacion/output.mat
  4. post_proc_comparacion.m : 
         Trabaja a partir del .mat anterior, genera graficas.
         Manualmente las guarde como: 
            comparacion-borde.pdf   comparacion-maximales.pdf   comparacion-saturadas.pdf


  
[Evaluación de desempeño de algoritmos seleccionados para $C=50$]
  1. master_c50_cli.m : ejecucion externa  (desde cli del SO)
         Genera los archivos con los resultados de las simulaciones en c50/
            borde_fullexpert.mat    maximal_fullexpert.mat   saturada_fullexpert.mat   
            (OBS: para 'borde' se cambio la cantidad de iteraciones, es decir, planes de eventos)  
  
  2. post_proc_c50.m : 
         Trabaja a partir del .mat anterior, genera graficas.
         Manualmente las guarde como: 
            c50-borde.pdf   c50-maximal.pdf   c50-saturada.pdf




[Evaluación de desempeño frente a oponentes olvidadizos]
  1. generar_schedules_alternativos.m: genera planes de eventos para los oponentes olvidadizos,
       los deja en noestacionarios/ev_scheds.mat

  2. policyIterator_script_multiples_noestacionarios.m : Toma el archivo anterior y calcula las reglas de decision optimas para cada juego.
             Guarda los parametros de juego, los planes de eventos y las politicas calculadas en noestacionarios/param_resultado.mat

  3. master_noestacionarios_cli.m : ejecucion externa  (desde cli del SO).
         Toma los parametros de los comportamientos y las reglas de decision calculadas del archivo noestacionarios/param_resultado.mat y realiza simulaciones con esos datos. Los resultados se guardan en noestacionarios/resultados_tipo<tipo>.mat
         con     tipo=2 : para oponente estocastico de colas pesadas
                 tipo=3 : para oponente olvidadizo estacional
                 tipo=4 : para oponente ON-OFF
                 tipo=5 : para oponente de intensidad aleatoria

  4. post_proc_noestacionario.m : Trabaja a partir de los .mat anteriores (asume que existe la variable tipo), generando estadisticas y graficas. Manualmente las guarde en la carpeta figuras/noestacionarios-nuevo


 Comparacion ante nueva categoria para contraste de resultados (sin MDP)  
      
  1. generar_schedules_alternativos_especial.m : genera planes de eventos en puntos de operacion que buscan que los diferentes tipos de usuarios 
  tengan tiempos de servicio claramente diferentes. Los planes que genera los deja en los deja en noestacionarios/ev_scheds_especial.mat

  2. policyIterator_script_multiples_noestacionarios.m : Toma el archivo anterior y calcula las reglas de decision optimas para cada juego.
       Guarda los planes de eventos en noestacionarios/param_resultado.mat
       Guarda los parametros de juego, los planes de eventos y las politicas de decision calculadas en noestacionarios/param_resultado_especial.mat
  
  2. master_noestacionarios_especial.m : jecucion externa  (desde cli del SO).
         Toma los parametros de los comportamientos y las reglas de decision calculadas del archivo noestacionarios/param_resultado_especial.mat y realiza simulaciones con esos datos. Los resultados se guardan en noestacionarios/resultados_tipo<tipo>_especial.mat
         con     tipo=2 : para oponente estocastico de colas pesadas
                 tipo=3 : para oponente olvidadizo estacional
                 tipo=4 : para oponente ON-OFF
                 tipo=5 : para oponente de intensidad aleatoria

  3. post_proc_noestacionario.m : para construir estadisticas y graficas.








Listado completo de scripts octave
----------------------------------

calc_expertos_diagonales.m
calc_expertos_recta.m
devolverEstado.m
eventos_adversarios.m
event_schedule_alternativos.m
event_schedule.m
generar_schedules_alternativos_especial.m
generar_schedules_alternativos.m
gen_param.m
init.m
master_c50_cli.m
master_contramdp.m
master_delay_alt.m
master_delay_cli.m
master_expertos_elapsed.m
master_expertos_m_cli.m
master_noestacionarios_cli.m
master_noestacionarios_especial.m
master_optim_cli.m
master_selection_cli.m
median_idec.m
policyIterator_script_adaptado.m
policyIterator_script_multiples.m
policyIterator_script_multiples_noestacionarios.m
post_proc_c50.m
post_proc_contramdp.m
post_proc_delay.m
post_proc_expertos_m.m
post_proc_noestacionarios.m
post_proc_optimizaciones.m
post_proc_selection.m
predecir.m
samplefromp.m
spectrum_auction_mi_rectas.m
spectrum_auction_si.m
spectrum_auction_si_porestado.m
 
