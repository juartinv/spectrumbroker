%  Este procedimiento levanta una matriz q de parametros [l1,l2,mu1,mu2] 
%  desde comparacion/param.mat, agrega C y T y calcula en paralelo la politica MDP 
%  optima usando policyIterator_script_adaptado. 
%  Con esas politicas construye una matriz policies. 
%
%  Guarda tanto q como las policies en comparacion/param_resultado.mat
%  dicho archivo tipicamente se utiliza desde master_contramdp.m

%  Se apoya fuertemnte en el uso de policyIterator_script_adaptado.m
    

clear global
clear all
clc

disp('Iniciando sistema...')     
init
if (exist("pkg") > 0)
    pkg load all
endif
Rz=R; Kz=K;
global R=Rz;
global K=Kz;
clear Rz, Kz;
global alpha=alfa;


load /home/jvanerio/Escritorio/tesis/comparacion/param.mat


target_n2=5000;
%global P=[ 20*ones(rows(q),1), 1000*ones(rows(q),1), q];   %completo los params: C=20, T=1000 y los (l1,l2,mu1,mu2) que cargue del archivo
global P=[ 20*ones(rows(q),1), round(min([ target_n2./q(:,1) , 1000*ones(rows(q),1)  ]'))'  , q];   
%completo los params: C=20, T=1000 y los (l1,l2,mu1,mu2) que cargue del archivo
%     C   T l1 l2 mu1 mu2 


#funcion auxiliar
function [datos] = calcular(iter)

    global P R K alpha
    C=P(iter,1);
    T=P(iter,2);
    l1=P(iter,3);
    l2=P(iter,4);
    mu1=P(iter,5);
    mu2=P(iter,6);
    
    m1=mu1; m2=mu2; 


    policyIterator_script_adaptado;
    datos=policy;
    
endfunction

procesamiento="paralelo"    # paralelo o secuencial
#paralelo es para ejecucion masiva, secuencial solo deberia usarse para debbugging.
procesos=nproc;
if (procesos < 8 )
   procesos=3
else
   procesos=7
endif


policies=[];


#aprox780s (13 minutos)
#los maximales los resolvio en 140seg
#los saturados en aprox una hora o mas --y solo cortaba porque no convergía.

if (  strcmpi( procesamiento, "paralelo" ) )
    policies = pararrayfun(procesos, @calcular, [1:rows(P)]);
elseif  (  strcmpi( procesamiento, "secuencial" ) )  
    for iter=1:rows(P)
        policy=calcular(iter);
        policies=[policies, policy];
    endfor
endif


save("/home/jvanerio/Escritorio/tesis/comparacion/param_resultado.mat","q","policies")

