# Simulador de dinamica del sistema para el problema de spectrum auction 
#
#
#  Script para realizar multiples simulaciones sobre un mismo plan de eventos. 
#  Basicamente considera N reglas de tipo LBE (lineas rectas parametricas) y 
#  para cada una de ellas realiza una simulación completa e independiente, 
#  registrando estado y ganancia sin utilizar ningun mecanismos de predicción.
#
#  Este programa permite implementar las simulaciones del metodo `FULLEXPERT'' 
#  en la evaluación de $C=50$.
#
#  - Espera recibir el plan de eventos en la variable ev_sched.
#  - Si recibe un conjutno de expertos lo utiliza, y sino los crea de acuerdo 
#    a lo especificado en variables de entorno "variante", "A", "a", "b"
#  - Lleva registro del estado de cada arribo aceptado en la matriz ev_curr, con 
#    una columna para cada experto (la priemra es el id del usuario y la segunda 
#    corresponde al mecanismo ensayado) donde se indica con un 1 o un 0 si se esta 
#    atendiendo al usuario o no.
#  - Lleva registro de la cantidad de PU (en el vector fila "x") y de SU (en el 
#    vector fila "y") para cada uno de los N sistemas definidos por el "experto" 
#    correspondiente.
#  - Al finalizar deja disponibles 
#    -mh: vector fila con payoff de cada "experto" (el primero elemento debe despreciarse)
#    -midh: tabla con los correspondientes vectores mh cada 10% de progreso en la simulacion
#
#
#   juan vanerio, 2015-2017





mfilename

### Ya tienen que estar definidos en scripts de inicializacion 
if ( exist("track_trayectorias") == 0 || exist("graficas") == 0 )
    error("No inicializado: No esta definida alguna de las opciones de simulador y/o visualizacion.");
endif

if ( exist("fparam") == 0 )
    disp("Advertencia: fparam no estaba inicializado, se inicializa en cero.\n");
    fparam=0
endif
    


#metodo=["exponentially-weighted-average-forecaster"]    #metodo de forecast
if (delay_tolerance)
    pena=K-R;
    recompensa_arribo=0;
    recompensa_partida=R;
else
    pena=K;
    recompensa_arribo=R;
    recompensa_partida=0;
endif

#Verificar existencia y formato del schedule de eventos
if ( exist("ev_sched") == 0)  #si no existe ev_sched
    printf("ERROR: Imposible encontrar el schedule de eventos ev_sched. Se genero correctamente el schedule de eventos?\n");
    return
elseif ( columns(ev_sched) != 4 || rows(ev_sched) < 1)
    printf("ERROR: Formato incorrecto del schedule de eventos. Se genero correctamente el schedule de eventos?\n");   
    return             
endif



    # h: vector con pay-off function acumulada de cada juego para cada experto, hh: matriz de los h (sumariza distintos juegos)
    # t_index: indice temporal, iteracion
    # trayectoria: Matriz ? x num.expertos con camino recorrido por cada experto en cada columna, realizacion de trayectoria
    # obs: no estoy incluyendo factores de descuento...

    #inicializaciones:
    hh=[];                #matriz de tamaño M x num.expertos donde cada fila indica la ganancia obtenida por cada experto para una misma simulacion.
    dhh=[];               #matriz de tamaño M x num.expertos donde cada fila indica la ganancia obtenida por unidad de tiempo por cada experto para una misma simulacion.

    #estados
    Scard=(C+1)*(C/2+1)   # cantidad de estados
    S=[];                 # Matriz de estados del juego. Matriz Scard x 2 donde cada fila representa las coordenadas de un estado. 
    revS=[]; ind=1;       # revS es la matriz reversa de S: Es una matriz C+1 x C+1 donde dados x e y nos dice el indice de dicho estado en la matriz S 
    for yy=0:C,           # Computo las matrices S y revS
        for xx=0:C-yy,
           S=[S;[xx,yy]];
           revS(xx+1,yy+1)=ind;   #observese que debo desplazar los indices 
           ind++;
        endfor  
    endfor  
    clear xx yy
    Sindexado=[[1:Scard]',S];    #Es la matriz S con una columna adicional indicando explicitamente el indice


    if (graficas==1 && track_trayectorias==1)
       plot(S(:,1),S(:,2),'o',"markersize",10)   # muestro graficamente los estados posibles del juego
       title("Estados del juego");
       xlabel('primarios')
       ylabel('secundarios')               
       hold on    
    endif

    ### Configuracion de expertos estaticos
    # podriamos mas adelante usar una funcion que los construya. Por ahora se prototipea aqui.
    # los expertos son estaticos y se designan de 1 a N
    # la matriz A [Scard x N] determina las politicas de aceptación de cada experto en sus columnas, para el estado indicado en su fila.



    
    
    
    if ( exist("b") == 0 )
        b=[0.5 (C-1)/3+0.5 (C-1)*2/3+0.5 C-0.5]
    endif
    if ( exist("a") == 0 )
        a=ones(size(b));
    endif 

    A=calc_expertos_recta(S,a,b);
    A=[ones(Scard,1),A];      #el primer experto en realidad es mi forecaster. El ultimo el que me sugiere hacer lo ultimo que hizo mi forecaster

    N=columns(A)     #cantidad de expertos

    ev_curr=[];
    # la matriz ev_curr [ ? x N+2 ] permite hacer un seguimiento de cuales eventos han arribado 
    # pero aún no han sido completados, y de si cada experto esta atendiendo la solictud (1)o no(0). 
    # La primer columna es el ev_id y la segunda es el tipo de usuario


    ### Fin configuracion expertos estaticos
    
    frec=zeros(Scard,N);      #frec va contando el tiempo que el sistema se encuentra en cada estado para cada experto, por lo tanto es una matriz de tamaño Scard x EE
    visitas=zeros(Scard,1);
    arribosSU=0;
    decisiones=zeros(1,N);
    
    elegido=N;
    elegidos=[];
    aceptaciones=zeros(1,N);
    elapsed_time=[];
    param=[1 C/2];
    mid_h=[];
    
        tic

        ev_curr=[];            
        #defino estado inicial
        x=zeros(1,N);
        y=zeros(1,N);
        trayectoria=revS(x(1)+1,y(1)+1)*ones(1,N);     #inicializo trayectorias
        h=zeros(1,N);                            #inicializo mi funcion de pay-off 
        
        # agendo los eventos de arribos y las partidas
        if ( generar_eventos != 0 )
            ev_sched=event_schedule(T, l1, l2, mu1, mu2);
        endif
        
        n=length(ev_sched(:,1))         #cantidad de eventos agendados   (n = 2*na1+2*na2)
        na2=sum(ev_sched(:,2)==2)/2     #cantidad de arribos de SU 
        na1=rows(ev_sched)/2-na2        #cantidad de arribos de PU 

        # simulo cada paso
        disc_factor=1;
        t_ant=0;                        #instante en que ocurrio el evento anterior.
        h_ant=h;                        #ganancia de cada experto al tiempo anterior
        report_times=round(linspace(n/10,n,10))
                
        for t_index=1:n,
            #proceso cada evento según las reglas del juego
            

            t=ev_sched(t_index,1);         #t indica el tiempo que esta siendo procesado
            ev_user=ev_sched(t_index,2);
            ev_type=ev_sched(t_index,3);
            ev_id=ev_sched(t_index,4);

            #procesamiento de sistema (experto o mio)   
            if (ev_type==1)   #si hay un arribo
                ev_curr=[ev_curr; ev_id ev_user zeros(1,N)];
                disc_factor=exp(-alfa*t);
            elseif (ev_type==2)    #si hay una partida
                fila=find( ev_curr(:,1)==ev_id );    # identifico el evento correspondiente en la matriz de eventos en curso
                ev_status=ev_curr( fila ,3:end);         # identifico si dicho evento esta siendo procesado o no
            endif
            
            if ( sum(h_ant!=h) >0 || t_index==1 )
                #calculo mi prediccion (actualizo mi forecaster)

                if (  strncmp( metodo, "C_", 2 ) )
                    param = predecir(metodo,h(2:end),fparam,[a;b]);
                    A(:,1)=calc_expertos_recta(S,param(1),param(2));
                    
                else
                    param = predecir(metodo,h(2:end),fparam,decisiones(2:end),aceptaciones(2:end));
                    A(:,1)=A(:,param(1)+1);
                    
                endif
              
              
 
            endif                        

            h_ant=h;   # recuerdo el ultimo valor de ganancias de cada experto.
        
            for ee=1:N,      #analizo para cada experto
                frec( revS(x(ee)+1,y(ee)+1),ee )+=t-t_ant;      #sumo tiempo que estuve en el estado que voy a abandonar. No se computa el ultimo evento.   
                                                 
                if (ev_type==1 && ev_user==1 )
                    ## Llega un usuario primario (PU)
                    if (x(ee)<C) 
                        #continue;  ##no hay capacidad suficiente para el nuevo primario

                        if (x(ee)+y(ee)==C)
                        
                            #hay que encontrar un evento de secundario para echarlo...
                            curr_sec=find( ev_curr(:,2)==2 ); #busco los usuarios secundarios que estan siendo atendidos

                            for aux=1:length(curr_sec)
                                if (ev_curr(curr_sec(aux),ee+2) == 1)
                                    ev_curr(curr_sec(aux),ee+2)=0;        #tomo el mas antiguo y lo marco como que ya no lo estoy atendiendo.
                                    break
                                endif
                            endfor

                            clear aux

                            y(ee)--;                    #hay que echar un secundario, y reembolsarle K
                            h(ee)-=pena*disc_factor;
                            #printf("echamos al secundario %d respecto del experto %d", curr_sec(1),ee);

                        endif

                        x(ee)++;    ##tenemos un nuevo PU
                        ev_curr(end,ee+2)=1;
                    #else
                    #    printf("NOP: ee=%d no podemos aceptar al primario por estar a plena capacidad", ee)
                    endif
                    
                elseif (ev_type==1 && ev_user==2 )
                    if ee==1 
                        arribosSU+=1;
                    endif
                    #if (x(ee)+y(ee)==C) 
                    #    #printf("NOP: ee=%d no podemos aceptar al secundario por estar a plena capacidad", ee)
                    #    continue; ##no hay capacidad suficiente
                    #endif
                    if (x(ee)+y(ee)<C) 
                    ## Llega un usuario secundario (SU)
                        if (A(revS(x(ee)+1,y(ee)+1),ee) == 1)
                            ##se toma la accion de aceptar
                            y(ee)++;    ## tenemos un nuevo SU
                            h(ee)+=recompensa_arribo*disc_factor;   ## cobramos $$$
                            ev_curr(end,ee+2)=1;
                            aceptaciones(ee)+=1;
                            #disp("tenemos un nuevo secundario")
                        endif
                    decisiones(ee)=decisiones(ee)+1;
                    #else
                    #    printf("NOP: ee=%d no podemos aceptar al secundario por estar a plena capacidad", ee)
                    endif
                    
                elseif (ev_type==2 && ev_user==1)
                    if (ev_status(ee)==1) 
                        if (x(ee)==0) 
                            #printf("NOP: ee=%d no se puede liberar a ningun primario porque ya no hay", ee)
                            #continue; ##no hay nadie para irse
                            error("Se esta procesando la partida de un primario pero no teniamos ninguno registrado.")
                        else
                            ## Se va un usuario primario (PU)             
                            x(ee)--;
                            #disp("se fue un primario")
                        endif
                        ev_status(ee)=0;         #señalo que se dejo de usar este
                        ev_curr(fila,2+ee)=0;
                    endif

                    
                elseif (ev_type==2 && ev_user==2)
                    if (ev_status(ee)==1)                 
                        if (y(ee)==0) 
                            #printf("NOP: ee=%d no se puede ir ningun secundario porque no hay", ee)
                            #continue; ##no hay nadie para irse
                            error("Se esta procesando la partida de un secundario pero no teniamos ninguno registrado.")
                        else
                            ## Se va un usuario secundario (SU)
                            y(ee)--;
                            #disp("se fue un secundario")
                        endif
                        h(ee)+=recompensa_partida*disc_factor;   ## cobramos $$$
                        ev_status(ee)=0;         #señalo que se dejo de usar este
                        ev_curr(fila,2+ee)=0;

                    endif

                    
                else
                    error("Error: caso no contemplado?")
                    continue; 
                endif
                
            endfor   #siguiente experto

            if (ev_type==2 && sum(ev_status)==0)
               #disp("procesando partida")
               ev_curr(fila,:)=[];
            endif

            if (track_trayectorias!=0)
                trayectoria=[trayectoria;revS(x(1:N)+1,y(1:N)+1)];               #agrego el estado a la trayectoria
                if (track_trayectorias > 0 && rows(trayectoria) > track_trayectorias )
                    trayectoria(1,:)=[];   #borro el registro más antiguo
                endif
            endif
            t_ant=t;
            

            if (sum(t_index==report_times)>0)   #periodicamente voy reportando el estado de la simulacion
                mid_h=[mid_h;[t arribosSU decisiones(1) h]];
                printf("... %d%%",round(100*t_index/n));
            endif

        endfor  #siguiente tiempo


        hh=[hh;h];
        dhh=[dhh;h/na2];         

        elapsed_time=toc;



    ##EVOLUCION DE RESULTADOS
    if (graficas==1 &&  track_trayectorias==1 && rows(hh)>1 )
        plot(S(trayectoria,1),S(trayectoria,2),'r')   # muestro graficamente los estados posibles del juego
        hold off
    endif
    
    if (graficas==1 && rows(hh)>1 )
        figure
        plot(hh(:,1),'k',"linewidth",2)   #grafico los resultados de los M juegos simulados.
        hold on
        plot(hh(:,2:end))   #grafico los resultados de los M juegos simulados.
        title("resultados obtenidos")
        xlabel ("simulacion");
        ylabel ("pay-off");
        #text (3, 0.05, "arbitrary text");
        leyenda=["mi forecaster"];
        for aux=2:columns(A)
            leyenda=[leyenda; sprintf("experto%d",aux-1)];
        endfor
        legend(leyenda)
        hold off
    endif


#### Analisis de la "bondad" de la simulación: el primario debe seguir una distribucion estilo erlang-B (lo estudio para el priemr experto)

PIdist=zeros(C+1);   # en esta matriz C+1 x C+1 estimo la probabilidad estacionaria

# calculo probabilidad empirica del primario
Py=[];
for ee=1:N
    #ee=1;
    W=sum(frec(:,N));
    for i=1:Scard,
        PIdist(1+S(i,1),1+S(i,2))=frec(i,ee)/W;
    endfor

    Px=sum(PIdist');   #distribucion marginal de los usuarios primarios (deberia ser una Erlang-B), indepte de los SU
    Py(ee,:)=sum(PIdist);    #distribucion marginal de los usuarios secundarios

endfor

x_axisj=[0:C];
rho1=l1/mu1
erlaj=(rho1.^x_axisj)./factorial(x_axisj);
erlaj=erlaj./sum(erlaj);

rho2=l2/mu2
erlajy=(rho2.^x_axisj)./factorial(x_axisj);
erlajy=erlajy./sum(erlajy);

if (graficas==1)
    # grafico probabilidad empirica del primario
    figure
    plot(x_axisj, erlaj,'r' )
    hold on
    grid
    plot(x_axisj, Px)
    hold off
    title("Probabilidad del primario")
    xlabel("x")
    ylabel("prob")
    legend ([sprintf("Erlang-B (rho=%4.2f)",rho1);"Empirica"]);

    # grafico probabilidad empirica del secundario
    figure
    plot(x_axisj, erlajy,'-.r',"linewidth",3 )
    hold on
    grid
    plot(x_axisj, Py(1,:), 'k' , "linewidth",2)
    plot(x_axisj, Py(2:end,:))
    hold off
    title("Probabilidad del secundario")
    xlabel("y")
    ylabel("prob")
    leyenda=[sprintf("Erlang-B (rho=%4.2f)",rho2);"mi forecaster"];
    for aux=2:columns(A)
        leyenda=[leyenda; sprintf("Empir. experto%d",aux-1)];
    endfor
    legend(leyenda)
endif

# analizo las ganancias medias de los distintos expertos
if (rows(hh) == 1 )
    mh=hh;
   dmh=dhh;
else
    mh=mean(hh);
   dmh=mean(dhh);
endif

for aux=2:columns(A)
    printf("Pay-off medio experto %d: %4.2f , pay-off/tiempo: %4.2f \n", aux-1, mh(aux), dmh(aux)  );
endfor
printf("Pay-off medio de mi forecaster: %4.2f , pay-off/n_arribos_SU: %4.2f \n", mh(1) , dmh(1) );

