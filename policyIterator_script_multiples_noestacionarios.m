% este script toma los datos del archivo del archivo "noestacionarios/ev_scheds.mat"
% (cellarrays de ev_scheds y hat_theta) calculados por "generar_schedules_noestacionarios.m" 
% y calcula las politicas optimas para los valores (hat_theta) estimados.
% Con esas politicas construye una matriz policies. 

% Finalemnte guarda los resultados "noestacionarios/param_resultado.mat":  
%  ("M_sched_sel" (un subconjunto de M_sched),"q" (identico a hat_theta),"policies" 
%  (los elementos calculados) y "selecciono" (los  indices de los sched escogidos).

clear global
clear all
clc

init
Rz=R; Kz=K;
global R=Rz;
global K=Kz;
clear Rz, Kz;
global alpha=alfa;

load /home/juan/Escritorio/tesis/noestacionarios/ev_scheds.mat  hat_theta
   #  M_sched     bestq       hat_theta   selecciono
   
   
selecciono=[1:rows(q{1})]

qq={ hat_theta{1}(selecciono) hat_theta{2}(selecciono) hat_theta{3}(selecciono) hat_theta{4}(selecciono) hat_theta{5}(selecciono)     };
q1=q2=q3=q4=q5=[]
for i=[1:length(selecciono)]  %paso el formato de celdas a matriz...
    q1=[q1; qq{1}{i}];
    q2=[q2; qq{2}{i}];
    q3=[q3; qq{3}{i}];
    q4=[q4; qq{4}{i}];
    q5=[q5; qq{5}{i}];
endfor
global q={q1 q2 q3 q4 q5};




clear hat_theta q1 q2 q3 q4 q5 qq


#funcion auxiliar
function [datos] = calcular(iter)

    global tipo q R K alpha
    
    C=20;
    T=1000;  %dummy var
    l1=q{tipo}(iter,1);
    l2=q{tipo}(iter,2);
    mu1=q{tipo}(iter,3);
    mu2=q{tipo}(iter,4);
       
    m1=mu1; m2=mu2; 


    policyIterator_script_adaptado;
    datos=policy;
    
endfunction

procesamiento="paralelo"    # paralelo o secuencial
#paralelo es para ejecucion masiva, secuencial solo deberia usarse par adebbugging.
procesos=nproc;
if (procesos < 8 )
   procesos=3
else
   procesos=7
endif


policies=[];


global tipo
policies={}
for tipo=1:5
    if (  strcmpi( procesamiento, "paralelo" ) )
        policies_tipo = pararrayfun(procesos, @calcular, [1:rows(q{tipo})]);
    elseif  (  strcmpi( procesamiento, "secuencial" ) )  
        for iter=1:rows(q{tipo})
            policy=calcular(iter);
            policies_tipo=[policies_tipo, policy];
        endfor
    endif
    policies{tipo}=policies_tipo;
endfor


load /home/juan/Escritorio/tesis/noestacionarios/ev_scheds.mat M_sched

M_sched_sel={ M_sched{1}(selecciono) M_sched{2}(selecciono)  M_sched{3}(selecciono)  M_sched{4}(selecciono)  M_sched{5}(selecciono)  };

save("/home/jvanerio/Escritorio/tesis/noestacionarios/param_resultado.mat","q","policies","selecciono","M_sched_sel")

