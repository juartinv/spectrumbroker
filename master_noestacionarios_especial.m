# Simulador para el problema del spectrum broker
#   juan vanerio, 2017
#
# Este script se usa para la etapa final, para evaluar entre sí los mecanismos seleccionados 
# en un caso particular (aun cuando se usan diferntes tipos de oponentes segun se indica como 
# argumento de entrada "tipo") donde tipicamente los tiempos de servicio de los usuarios son 
# claramente diferentes y las soluciones triviales (siempre acepto, siempre rechazo) no resultan 
# las mejores.
#
# El flujo de trabajo a seguir para esta simulación es:
#    1 - ejecutar generar_schedules_alternativos_especial.m Este script genera varios ev_schedules 
#        generar 21 planes de eventos a partir de parametros  que buscan que las medianas de los 
#        tiempos de servicio entre los dos usuarios sean claramente difernetes.
%        Con los planes de eventos se determinan los parametros MLE que se estiman como procesos 
%        poisson/exponencial de los comportamientos de los usuarios. 
#        Crea un archivo "noestacionarios/param_resultado_especial[1-5].mat" con una variable "q" con 
#        parametros estimados por MLE para Poisson/exp en cada fila y una variable "M_sched_sel" 
#        con los 21 planes de evento para cada tipo de oponente.
#    3 - se ejecuta este script para realizar todas las simulaciones y se guardan los resultados en
#        el archivo que se indique como argumento de entrada.
#    4 - los resultados se procesan para obtener graficas y estadisticas con "post_proc_noestacionario.m"
#

#Este script se usa para la etapa final, para evaluar los mecanismos seleccionados y la politica calculada por MDP para cada caso

disp('Iniciando sistema...')     #esto lo dejo al inicio para que octave no interprete que este archivo es una funcion


#######################################################################################
###  inicializo sistemas
init

tipo=2
archivomat="/home/jvanerio/Escritorio/tesis/noestacionarios/param_resultado_especial2.mat"

if (exist("pkg") > 0)
    pkg load all
endif

par_verbose=0

procesamiento="paralelo"    # paralelo o secuencial
#paralelo es para ejecucion masiva, secuencial solo deberia usarse par adebbugging.
procesos=nproc;
if (procesos < 8 )
   procesos=3
else
   procesos=6
endif


repeticiones=10

target_n2=5000

epsilon=0.4
T=500



global              programas=[ 1  13 21  32 ];   #todos los programas con parametro
global          fparam_global=[ 0 0.1  2   2 ];
global delay_tolerance_global=[ones(size(programas))];  #tolerance


# me cargo los parametros, policies y ev_scheds ya calculados
load /home/jvanerio/Escritorio/tesis/noestacionarios/param_resultado_prueba2.mat




#tipo=1
colec_ev_sched=M_sched_sel{tipo};
theta=q{tipo};
iteraciones=rows(theta) 

#declaro las variabes que init no declara
global mh ev_sched

global policy_map=policies{tipo};


#######################################################################################


#funcion auxiliar
function [datos, payoff_evol] = spectrum_auction(indice)
    # Funcion para determinar el mecanismo a utilizar de acuerdo al codigo/indice de mecanismo. Se espera que reciba ev_sched.
    
    global track_trayectorias graficas generar_eventos C M T l1 l2 mu1 mu2 R K alfa betha ev_sched mh par_verbose
    global programas fparam_global delay_tolerance_global MM policy_map


    algind=programas(indice);
    printf("\nIniciando programa %d\n",algind);
    fparam=fparam_global(indice);
    delay_tolerance=delay_tolerance_global(indice);
        
    na2=sum(ev_sched(:,2)==2)/2;      #cantidad de arribos de SU 
    na1=rows(ev_sched)/2-na2;         #cantidad de arribos de PU 
    printf("Cantidad de arribos de PU: %i, Cantidad de Arribos SU: %i \n", na1,na2)

    steps=8;
    b=0.5+(C-1)*[0:steps-1]/(steps-1);
    a=ones(size(b));
   
    #estados
    Scard=(C+1)*(C/2+1);   # cantidad de estados
    S=[];                 # Matriz de estados del juego. Matriz Scard x 2 donde cada fila representa las coordenadas de un estado. 
    ind=1;       # revS es la matriz reversa de S: Es una matriz C+1 x C+1 donde dados x e y nos dice el indice de dicho estado en la matriz S 
    for yy=0:C,           # Computo las matrices S y revS
        for xx=0:C-yy,
           S=[S;[xx,yy]];
           ind++;
        endfor  
    endfor  
    A=calc_expertos_recta(S,a,b);

   
    
    switch (algind)
      case 1
        #inicio algoritmo particular
        #A=(policy_map(:,MM)==2);  % adapto el mapa de acción, que venia con 1: aceptar, 2:rechazar, mientras el resto de este script usa 0 para rechazar.

        #parametros de prediccion
        metodo=["none"]    #metodo de forecast
        variante="regular"    #AME
        tipo="none"
            
        #ejecuto
        
        #proceso resultados     
        bestprofit=0;
        bestexperts=[1 1];
        bestexpert=1;

        payoff_evol= [algind algind;ones(10,1) zeros(10,1)];  %dummy
        payoff_evol_dec= payoff_evol; %dummy

        mh=[1,2,3,4,5];        
        elapsed_time=1;
        N=1;
        
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
global MM


for MM=1:iteraciones,

    # T, l1,l2,mu1 y mu2 ya deben haber sido inicializados pero puedo sobreescribirlos si lo deseo (por ejemplo para aleatorizarlos)
    T=1000              #aproximated system elapsed time (in same units as lambda)
    l1=theta(MM,1)    # l1: tasa de arribos Poisson para los usuarios primarios
    l2=theta(MM,2)    # l2: tasa de arribos Poisson para los usuarios secundarios
    mu1=theta(MM,3)   # media de tiempo de servicio para los usuarios primarios
    mu2=theta(MM,4)   # media de tiempo de servicio para los usuarios secundarios

    printf("Iniciando iteracion %d \n", MM)
        
    printf("parametros del sistema para esta simulación: \n  C=%i Estados:%i T=%i l1=%4.2f l2=%4.2f mu1=%4.2f mu2=%4.2f \n", C,(C+1)*(C/2+1),T,l1,l2,mu1,mu2 )
    parametros=[parametros;[MM C T l1 l2 mu1 mu2]];

    %%%%  ev_sched=event_schedule(T, l1, l2, mu1, mu2);    # genero
    ev_sched=M_sched_sel{1}{MM};

    %M  %simulacros sobre cada plan de eventos
    
    for M=1:repeticiones,

        if (  strcmpi( procesamiento, "paralelo" ) )
            #paralelo
            [datos,pe] = pararrayfun(procesos, @spectrum_auction, [1:length(programas)], "VerboseLevel",par_verbose);
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


relevant_payoff_evol=payoff_evol(find(payoff_evol(:,2)>0),:); %selecciono de payoff_evol solo el subconjunto de pruebas interesantes (excluyo registros de algoritmos 0)
indices=relevant_payoff_evol([2:2:end], [1 2]);  %selecciono numero de iteracion y de algoritmo
vect_payoff=relevant_payoff_evol([2:2:end], end); 
vect_finSU=relevant_payoff_evol([1:2:end], end);  
m=[ indices vect_payoff./vect_finSU];   

complete_elapsed_time=time()-init_time;


numparams=length(programas);
l=numparams/2;


m_aug=m,
[loIdeC,upIdeC]=median_idec(repeticiones);

estadistica_summ=[];
for i=1:iteraciones,
    for p=1:numparams,
        indices = find ( (m_aug(:,1)==i).*m_aug(:,2)==programas(p)) ;
        
        [medidas,ind] = sort( m_aug(indices,3));
        datos = [medidas(1) medidas(loIdeC) median(medidas) medidas(upIdeC)];   %las columnas quedan todos los minimos primeros, luego los cotas inf, luego medianas
        estadistica_summ=[estadistica_summ; [i  programas(p)  datos] ];  
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


save(archivomat,"tipo", "parciales","parametros","payoff_evol","m","colec_ev_sched", "estadistica_summ", "theta");

