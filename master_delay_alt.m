# Simulador para el problema del spectrum broker
#   juan vanerio, 2017
#
# Este script se utiliza para simular planes de eventos de un caso adversario (olvidadizo) en 
# particular y con el comparar la diferecia que cada mecanismo de prediccion obtiene al emplear 
# y al prescindir de la adaptación de tolerancia a la demora de la obtención del resultado de 
# cada decision.
# 
# Los resultados se procesan para obtener graficas y estadisticas con post_proc_delay.m

disp("")  #esto lo dejo al inicio para que octave no interprete que este archivo es una funcion

clear all
clc


#######################################################################################

###  inicializo sistemas
init
disp('Iniciando sistema...')     
if (exist("pkg") > 0)
    pkg load all
endif

par_verbose=0
procesamiento="paralelo"    # paralelo o secuencial      #paralelo es para ejecucion masiva, secuencial solo deberia usarse para debbugging.
procesos=nproc-1            #Cantidad de procesos simultaneos en caso de ejecucion paralela

iteraciones=1   #100
repeticiones=10


region="total"  #maximal, saturada, borde, total
epsilon=0.45
T=400


global              programas = [11 12  13 21 22  23 31 32 ];   #todos los programas con parametro
global          fparam_global = [ 1  1 0.1  2  1 0.5  1  2 ];


v0=zeros(size(programas)); #no tolerance
v1=ones(size(programas));  #tolerance
global delay_tolerance_global = [v0 v1];
programas = [programas programas];
fparam_global= [fparam_global fparam_global];


if (  strcmpi( region, "maximal" ) )
    parametros_lowb= [T              0.02*C         0.02*C   -0.6  1 ];
    parametros_upb = [T  (1-epsilon-0.02)*C  (1-epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica!!
elseif (  strcmpi( region, "saturada" ) )
    parametros_lowb= [T               0.9*C          0.1*C   -0.6  1 ];
    parametros_upb = [T                 2*C            2*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
elseif (  strcmpi( region, "borde" ) )
    parametros_lowb= [T               0.1*C          0.1*C   -0.6  1 ];
    parametros_upb = [T               0.9*C  (1+epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
elseif (  strcmpi( region, "total" ) )
    parametros_lowb= [T              0.02*C         0.02*C   -0.6  1 ];
    parametros_upb = [T                 2*C            2*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!

endif

#
parametros_lowb=repmat(parametros_lowb,iteraciones,1);
parametros_upb=repmat(parametros_upb,iteraciones,1);

excepcion=1
if excepcion
    parametros_lowb = [ T  25  400 0.5 1e-3 ];
    parametros_upb=parametros_lowb;
endif



function [datos, payoff_evol] = spectrum_auction(indice)
    # Funcion para determinar el mecanismo a utilizar de acuerdo al codigo/indice de mecanismo. Se espera que reciba ev_sched.
    
    global track_trayectorias graficas generar_eventos C M T l1 l2 mu1 mu2 R K alfa betha ev_sched mh par_verbose
    global programas fparam_global delay_tolerance_global

    algind=programas(indice);
    printf("\nIniciando programa %d\n",algind);
    fparam=fparam_global(indice);
    delay_tolerance=delay_tolerance_global(indice);
        
    na2=sum(ev_sched(:,2)==2)/2;      #cantidad de arribos de SU 
    na1=rows(ev_sched)/2-na2;         #cantidad de arribos de PU 
    printf("Cantidad de arribos de PU: %i, Cantidad de Arribos SU: %i \n", na1,na2)
       
    switch (algind)


      case 11
        #parametros de prediccion
        variante="regular"    #AME
        tipo="select"         #select o combine 
        metodo="FTPL"         #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 12
        #inicio algoritmo particular      
        variante="regular"    #AME
        tipo="select"         #select o combine 
        metodo=["PAPE"]       #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
        
      case 13
        #parametros de prediccion
        variante="regular"    #AME
        tipo="combine"        #select o combine 
        metodo="PMPE"         #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 14
        #parametros de prediccion
        variante="regular"    #AME
        tipo="select"         #select o combine 
        metodo="FTL"          #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 15
        #inicio algoritmo particular      
        variante="regular"    #AME
        tipo="select"         #select o combine 
        metodo="SEq"          #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
      
      case 16
        #inicio algoritmo particular      
        variante="regular"    #AME
        tipo="combine"        #select o combine 
        metodo="CEq"          #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
        

      case 21
        #parametros de prediccion
        variante="rectas"    #LBE
        tipo="select"        #select o combine 
        metodo="FTPL"        #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 22
        #inicio algoritmo particular      
        variante="rectas"    #LBE
        tipo="select"        #select o combine 
        metodo=["PAPE"]      #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
        
      case 23
        #parametros de prediccion
        variante="rectas"    #LBE
        tipo="combine"       #select o combine 
        metodo="PMPE"        #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 24
        #parametros de prediccion
        variante="rectas"    #LBE
        tipo="select"        #select o combine 
        metodo="FTL"         #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si

      case 25
        #inicio algoritmo particular      
        variante="rectas"    #LBE
        tipo="select"        #select o combine 
        metodo="SEq"         #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
      
      case 26
        #inicio algoritmo particular      
        variante="rectas"    #LBE
        tipo="combine"       #select o combine 
        metodo="CEq"         #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si
        
      case 31
        #inicio algoritmo particular      
        variante="por_estado" #CBE
        tipo="select"         #select o combine 
        metodo="FTPL"     #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si_porestado

      case 32
        #inicio algoritmo particular      
        variante="por_estado" #CBE
        tipo="select"         #select o combine 
        metodo="CBE-PAPE"     #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si_porestado
  
      case 34
        #parametros de prediccion
        variante="por_estado" #CBE
        tipo="select"         #select o combine 
        metodo="FTL"          #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si_porestado

      case 35
        #inicio algoritmo particular      
        variante="por_estado" #CBE
        tipo="select"         #select o combine 
        metodo="SEq"          #metodo de forecast            
            
        #ejecuto
        spectrum_auction_si_porestado
                        
    endswitch

    #proceso resultados
    if (algind!=1)
        payoff_evol_dec= [algind algind;mid_h(:,3) mid_h(:,4)];   #ind 3 son las decisiones tomadas por mi forecaster ,ind4  es payoff de mi forecaster
        payoff_evol= [algind algind;mid_h(:,2) mid_h(:,4)];   #ind 2 son los SU finalizados, ind4  es payoff de mi forecaster
    endif
    
    bestprofit=max(mh(2:end));                       
    bestexperts=find(mh(2:end)==max(mh(2:end)));
    bestexpert=bestexperts(end);
    myprofit=mh(1);
    mypayoffrate=myprofit/payoff_evol(end,1);
    mypayoffrate_dec=myprofit/payoff_evol_dec(end,1);
    avgelapsedtime=elapsed_time;
    
    datos=[algind; bestprofit; bestexpert; myprofit; mypayoffrate; mypayoffrate_dec; avgelapsedtime; N; na1; na2; na1+na2];
    
endfunction


init_time=time();

#declaro las variabes que init no declara
global mh ev_sched


## realeatorizo por las dudas
rand('state',floor(10000000*rand(1)))


parciales=[];
payoff_evol=[];
parametros=[];
matavgelapsedtime=[];


if (length(programas) != length(fparam_global))
    error("El largo del vector de programas a ejecutar (algoritmos) y el de evectorde parametros de los mismos ('fparam_global') no coincide!")
endif


# MAIN LOOP

for MM=1:iteraciones,

    printf("\n\nIniciando iteracion %d \n", MM)

    T  =parametros_lowb(MM,1)+(parametros_upb(MM,1)-parametros_lowb(MM,1))*rand;     #aproximated system elapsed time (in same units as lambda)
   
    if (  strcmpi( region, "maximal" ) )
        rho1=parametros_lowb(MM,2)+(parametros_upb(MM,2)-parametros_lowb(MM,2))*rand;     # rho1: relacion tasa de arribos/tasa de servicio para PU (Poisson)
        rho2=parametros_lowb(MM,3)+(min(parametros_upb(MM,3),C*(1-epsilon)-rho1)-parametros_lowb(MM,3))*rand;     # rho2: relacion tasa de arribos/tasa de servicio para SU (Poisson)
        
    elseif (  strcmpi( region, "saturada" ) )
        rho1=parametros_lowb(MM,2)+(parametros_upb(MM,2)-parametros_lowb(MM,2))*rand;     # rho1: relacion tasa de arribos/tasa de servicio para PU (Poisson)
        rho2=parametros_lowb(MM,3)+(parametros_upb(MM,3)-parametros_lowb(MM,3))*rand;     # rho2: relacion tasa de arribos/tasa de servicio para SU (Poisson)
        
    elseif (  strcmpi( region, "borde" ) )
        rho1=parametros_lowb(MM,2)+(parametros_upb(MM,2)-parametros_lowb(MM,2))*rand;     # rho1: relacion tasa de arribos/tasa de servicio para PU (Poisson)

        rho2=parametros_lowb(MM,3)+(parametros_upb(MM,3)-parametros_lowb(MM,3))*rand;     # rho2: relacion tasa de arribos/tasa de servicio para SU (Poisson)
        lowb=max(parametros_lowb(MM,3),C*(1-epsilon)-rho1)
        rho2=lowb+(min(parametros_upb(MM,3), C*(1+epsilon)-rho1 )-lowb)*rand;

    elseif (  strcmpi( region, "total" ) )
        rho1=parametros_lowb(MM,2)+(parametros_upb(MM,2)-parametros_lowb(MM,2))*rand;     # rho1: relacion tasa de arribos/tasa de servicio para PU (Poisson)
        rho2=parametros_lowb(MM,3)+(parametros_upb(MM,3)-parametros_lowb(MM,3))*rand;     # rho2: relacion tasa de arribos/tasa de servicio para SU (Poisson)
        
    endif

    mu1 =10^(parametros_lowb(MM,4)+(parametros_upb(MM,4)-parametros_lowb(MM,4))*rand);     # media de tiempo de servicio para los usuarios primarios
    mu2 =parametros_lowb(MM,5)+(parametros_upb(MM,5)-parametros_lowb(MM,5))*rand;     # media de tiempo de servicio para los usuarios secundarios

    l1  =rho1*mu1;                                                                    # l1: tasa de arribos Poisson para los usuarios primarios
    l2  =rho2*mu2;                                                                    # l2: tasa de arribos Poisson para los usuarios secundarios


    %T=round(10000/(l1+l2))
    printf("parametros del sistema para esta simulación: \n  C=%i Estados:%i T=%i l1=%4.2f l2=%4.2f mu1=%4.2f mu2=%4.2f rho1=%4.2f rho2=%4.2f\n", C,(C+1)*(C/2+1),T,l1,l2,mu1,mu2,rho1,rho2 )
    parametros=[parametros;[MM C T l1 l2 mu1 mu2]];

    #ev_sched=event_schedule(T, l1, l2, mu1, mu2);    # genero
    eventos_adversarios     #genero una secuencia particular para probar


    %M  %simulacros sobre cada plan de eventos

    for M=1:repeticiones,

        if (  strcmpi( procesamiento, "paralelo" ) )
            #paralelo
            [datos,pe] = pararrayfun(procesos, @spectrum_auction, [1:length(programas)],"VerboseLevel",par_verbose);
            parciales=[parciales,[ repmat(MM,1,columns(datos));datos]];
            payoff_evol=[payoff_evol, [ repmat(MM,1,columns(pe));pe]];
        elseif  (  strcmpi( procesamiento, "secuencial" ) )  
            #secuencial  (para debugging)
            for indexec=1:length(programas)
                [datos,pe]=spectrum_auction(indexec);
                parciales=[parciales,[ repmat(MM,1,columns(datos));datos]];
                payoff_evol=[payoff_evol, [ repmat(MM,1,columns(pe));pe]];
            endfor
        endif

    endfor
    printf("Completado: %4.1f %% , tiempo restante estimado: %4.2f \n\n\n\n\n", floor(100*MM/iteraciones) , (time()-init_time)*(iteraciones/MM-1)  );

endfor




# ANALISIS DE RESULTADOS

#despliego los resultados
disp("\n\n\n\n\n\n\n\n")
clc

disp("PARAMETROS")
disp("iteracion C T l1 l2 mu1 mu2")
parametros

disp("\n\nRESULTADOS")
#    datos=[bestprofit; bestexpert; myprofit; mypayoffrate; avgelapsedtime];

printf("     %s %s %s  %s  %s  %s  %s %s  %s  %s \n", "iteracion", "algoritmo", "bestprofit", "bestexpert", "myprofit", "mypayoffrate","mypayoffrate(d)", "avgelapsedtime", "cant. expertos", "N1", "N2", "N")
parciales=parciales'

disp("")
disp(" Iteracion Algoritmo 10% 20% 30% 40% 50% 60% 70% 80% 90% 100%\n")
%disp("Algoritmo 0: Primera fila arribos SU. Otros algoritmos: primera fila decisiones tomadas, segunda fila payoff")
disp("Algoritmo 0: Primera fila arribos SU. Otros algoritmos: primera fila SU finalizados, segunda fila payoff")
payoff_evol=payoff_evol'

relevant_payoff_evol=payoff_evol(find(payoff_evol(:,2)>1),:); %selecciono de payoff_evol solo el subconjunto de pruebas interesantes (excluyo registros de algoritmos 0 y 1)
indices=relevant_payoff_evol([2:2:end], [1 2]);  %selecciono numero de iteracion y de algoritmo
vect_payoff=relevant_payoff_evol([2:2:end], end); 
vect_finSU=relevant_payoff_evol([1:2:end], end);  
m=[ indices vect_payoff./vect_finSU];   

complete_elapsed_time=time()-init_time;


numparams=length(fparam_global);
l=numparams/2;


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


#evolucion de los payoffs
z=payoff_evol(find(payoff_evol(:,2)>1),:); %selecciono de payoff_evol solo el subconjunto de pruebas interesantes (excluyo registros de algoritmo 0 y 1)
evol=z([2:2:end], 3:end)./z([1:2:end], 3:end);     %vector con los payoff de cada simulacion
%disp("Evolucion")
%zz=[z([1:2:end], 1:2) evol];
figure
plot(evol(:,1:end-1)','-x')
grid
title("Evolucion de Payoffs")
ylabel("m")
xlabel("elapsed time")

printf("Full Master script elapsed time: %6.1f s\n", complete_elapsed_time );
clear -x C fparam_global parametros parciales payoff_evol m estadistica_full estadistica_summ iteraciones repeticiones delay_tolerance_global programas

