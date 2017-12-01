# Simulador de dinamica del sistema para el problema de spectrum auction 
#
#
#  Script para clases de expertos estáticos tipo CBE.
#
#
#  Este programa computa el estado del mecanismo de predicción empleado, así 
#  como el payoff observado por el mismo y por cada experto en cada estado.
#
#  Este programa permite implementar las simulaciones de CBE-FTL, CBE-FTPL y 
#  CBE-PAPE.
#
#  - Espera recibir el plan de eventos en la variable ev_sched.
#  - Lleva registro del estado de cada arribo aceptado en la matriz ev_curr donde
#    se registra para cada SU el índice del estado en que estaba el sistema 
#    cuando se lo acepto.
#  - Al finalizar deja disponibles 
#    -mh: vector fila donde todos son ceros excepto el primer elemento que 
#         contiene el payoff del mecanismo ensayado.
#    -midh: tabla con los correspondientes vectores mh cada 10% de progreso en la simulacion
#
#
#   juan vanerio, 2015-2017



if par_verbose 
    mfilename
endif

### Ya tienen que estar definidos en scripts de inicializacion 
if ( exist("track_trayectorias") == 0 || exist("graficas") == 0 )
    error("No inicializado: No esta definida alguna de las opciones de simulador y/o visualizacion.");
endif

if ( exist("fparam") == 0 )
    disp("Advertencia: fparam no estaba inicializado, se inicializa en cero.\n");
    fparam=0
endif


if (strcmp(variante, "por_estado") == 0)
    error("Error al ejecutar el script de expert bystate: metodo no es de tipo CBE")
    return
endif

if (strcmp(tipo, "select") == 0)
    error("Error al ejecutar el script de expert bystate: metodo no es de tipo CBE")
    return
endif

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


    # h: pay-off function acumulada , hh: vector de los h (sumariza distintos juegos)
    # t_index: indice temporal, iteracion
    # trayectoria: Matriz ? x num.expertos con camino recorrido por cada experto en cada columna, realizacion de trayectoria
    # obs: no estoy incluyendo factores de descuento...

    #inicializaciones:
    hh=[];                #vector de tamaño M donde cada elemento indica la ganancia obtenida para una simulacion.
    mid_h=[];             #

    #estados
    Scard=(C+1)*(C/2+1);   # cantidad de estados
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

    # En este caso se considera la existencia de dos expertos para cada estado posible: un experto estatico para la accion de "aceptar" y otro para la de "rechazar"
    # El experto de rechazar es completamente predecible: tendra pay-off cero ya que al nunca aceptar, no puede ganar ni perder.
    # 
    # Por lo tanto, Los expertos no requieren la configuracion estatica en un vector ni similar, ya que existen solo una posibilidad por estado y por lo tanto
    # solo Scard expertos
  
    
    
    
    
    
    
    
    N=Scard   #Cantidad de expertos.

    ev_curr=[];
    # la matriz ev_curr [ ? x 3 ] permite hacer un seguimiento de cuales eventos han arribado pero aún no han sido completados, 
    # y del estado del sistema cuando se acepto el arribo.
    # La primer columna es el ev_id y la segunda es el tipo de usuario, y la tercera es el indice del estado del sistema cuando se arribo y fue aceptado ( valores 1 a Scard)
    # o bien cero (0) si arribo y no fue aceptado.

    ### Fin configuracion expertos estaticos
    
    frec=zeros(Scard,1);       #frec va contando el tiempo que el sistema se encuentra en cada estado, por lo tanto es una matriz de tamaño Scard x 1
    visitas=zeros(Scard,1);
    arribosSU=0;
    decisiones=0;
    decisiones_estado=zeros(Scard,1);
    aceptaciones_estado=zeros(Scard,1);
    elapsed_time=0;
    
        tic

        ev_curr=[];            
        #defino estado inicial
        x=zeros(1,1);
        y=zeros(1,1);
        trayectoria=revS(x+1,y+1);     #inicializo trayectorias
        h=zeros(1,N);                  #inicializo mi funcion de pay-off de mis estados/experto
        hsys=0;                        #inicializo la funcion de pay-off de mi propio sistema

        # agendo los eventos de arribos y las partidas
        if ( generar_eventos != 0 )
            ev_sched=event_schedule(T, l1, l2, mu1, mu2);
        endif
        
        n=length(ev_sched(:,1));         #cantidad de eventos agendados   (n = 2*na1+2*na2)
        na2=sum(ev_sched(:,2)==2)/2;     #cantidad de arribos de SU 
        na1=rows(ev_sched)/2-na2;        #cantidad de arribos de PU 
        
        # simulo cada paso
        disc_factor=1;

        t=0;           #inicializo el tiempo  

        
        report_times=round(linspace(n/10,n,10));
        if par_verbose
            report_times
        endif
                
        for t_index=1:n,
            #proceso cada evento según las reglas del juego
            

            t_ant=t;                       # instante en que ocurrio el evento anterior.
            t=ev_sched(t_index,1);         # t indica el tiempo que esta siendo procesado
            ev_user=ev_sched(t_index,2);   # indica si el nuevo evento corresponde a un usuario primario (1) o secundario (2)
            ev_type=ev_sched(t_index,3);   # indica si el nuevo evento es una arribo (1) o una partida (2)
            ev_id=ev_sched(t_index,4);     # identificador unico del evento
            

            #procesamiento de sistema
            if (ev_type==1)   #si hay un arribo
                ev_curr=[ev_curr; ev_id ev_user 0];    #por defecto asumo que el arribo no será aceptado
                disc_factor=exp(-alfa*t);
            elseif (ev_type==2)    #si hay una partida
                fila=find( ev_curr(:,1)==ev_id );    # identifico el evento correspondiente en la matriz de eventos en curso
                ev_status=ev_curr( fila ,3);         # identifico si dicho evento esta siendo procesado o no
            endif



            s0=revS(x+1,y+1);       #estado inmediatamente previo al evento
            frec(s0)+=t-t_ant;      #sumo tiempo que estuve en el estado que voy a abandonar. No se computa el ultimo evento.   
            visitas(s0)++;
                                                 

            if (ev_type==1 && ev_user==1 )
                ## Llega un usuario primario (PU)
                if (x<C) 
                    if (x+y==C)
                        
                        #hay que encontrar un evento de secundario para echarlo...
                        #curr_sec=find( ev_curr(:,2)==2 ); #busco los usuarios secundarios que estan siendo atendidos por mi forecaster.
                        #for aux=1:length(curr_sec)     #tomo el mas antiguo y lo marco como que ya no lo estoy atendiendo. <--usar diferentes estrategias
                        #    if (ev_curr(curr_sec(aux),3) > 0)
                        #        break
                        #    endif
                        #endfor
                        curr_sec=find((ev_curr(:,2)==2).*(ev_curr(:,3)>0));
                        aux=samplefromp(ones(1,length(curr_sec))/length(curr_sec),1);  #elijo aleatoriamente a cual expulsar.
                        %aux=1   %expulso al más viejo.
                        %aux=length(curr_sec)   %expulso al más nuevo.
                    
                        #en la variable aux me quedo el evento que voy a echar.
                        y--;                    #hay que echar un secundario, y computar que pago R y se le reembolso K

                        h(ev_curr(curr_sec(aux),3))-=pena*disc_factor;
                        hsys-=pena*disc_factor;
                        ev_curr(curr_sec(aux),3)=0;
                        ev_curr(curr_sec(aux),:)=[];

                    endif

                    x++;    ##tenemos un nuevo PU
                    ev_curr(end,3)=s0;
                endif
                                    
            elseif (ev_type==1 && ev_user==2 )
                arribosSU+=1;
                ## Llega un usuario secundario (SU)                
                if (x+y<C)
                
                    accion=predecir(metodo,[0 h(s0)],fparam,decisiones_estado(s0),aceptaciones_estado(s0))-1;
                    if ( decisiones_estado(s0)==0 )   %si es la primer decision, debo aceptar
                        accion = 1;
                    endif
                    %ultra-debugging:
                    %printf("Estado: (x=%i, y=%i), decisiones: %i, payoff: %f, accion tomada: %i \n ", S(s0,1),S(s0,2), decisiones_estado(s0),h(s0),accion);

                    if ( accion == 1)
                        ##se toma la accion de aceptar
                        ev_curr(end,3)=s0;
                        y++;    ## tenemos un nuevo SU
                        h(s0)+=recompensa_arribo*disc_factor;                    
                        hsys+=recompensa_arribo*disc_factor;   ## cobramos $$$
                        aceptaciones_estado(s0)+=1;

                    endif
                    decisiones+=1;
                    decisiones_estado(s0)+=1;
                endif

                                        
            elseif (ev_type==2 && ev_user==1)
                if (ev_status > 0) 
                    if (x==0) 
                        error("Se esta procesando la partida de un primario pero no teniamos ninguno registrado.")
                    else
                        ## Se va un usuario primario (PU)             
                        x--;
                        ev_curr(fila,:)=[];
                    endif
                    
                endif
                    
            elseif (ev_type==2 && ev_user==2)
                if (ev_status > 0)                 
                    if (y==0) 
                        error("Se esta procesando la partida de un secundario pero no teniamos ninguno registrado.")
                    else
                        ## Se va un usuario secundario (SU)
                        y--;
                        h(ev_status)+=recompensa_partida*disc_factor;
                        hsys+=recompensa_partida*disc_factor;
                        ev_curr(fila,:)=[];
                    endif
                endif
               
            else
                disp("Error: caso no contemplado?")
                continue; 
            endif
                

            if (track_trayectorias!=0)
                trayectoria=[trayectoria;revS(x+1,y+1)];               #agrego el estado a la trayectoria
                if (track_trayectorias > 0 && rows(trayectoria) > track_trayectorias )
                    trayectoria(1,:)=[];   #borro el registro más antiguo
                endif
            endif


            if (sum(t_index==report_times)>0)   #periodicamente voy reportando el estado de la simulacion            
                %mid_h=[mid_h;[t arribosSU-y decisiones hsys]];
                if (delay_tolerance)
                    mid_h=[mid_h;[t arribosSU-y decisiones hsys]];
                else
                    mid_h=[mid_h;[t arribosSU-y decisiones hsys-y*recompensa_arribo]];
                endif                
                printf("... %d%%",round(100*t_index/n));
            endif

        endfor  #siguiente tiempo

        hh=[hh;h];
        %dhh=[dhh;h/na2];         
        
        elapsed_time=toc

    ##EVOLUCION DE RESULTADOS
    if (graficas==1 &&  track_trayectorias!=0 && rows(hh)>1 )
        plot(S(trayectoria,1),S(trayectoria,2),'r')
        hold off
    endif
    
    if (graficas==1 && rows(hh)>1 )
        figure
        plot(hh(:,1),'k',"linewidth",2)   #grafico los resultados de los M juegos simulados.
        title("resultados obtenidos")
        xlabel ("simulacion");
        ylabel ("pay-off");
        leyenda=["mi forecaster"];
        legend(leyenda)
    endif


#### Analisis de la "bondad" de la simulación: el primario debe seguir una distribucion estilo erlang-B (lo estudio para el priemr experto)
PIdist=zeros(C+1);   # en esta matriz C+1 x C+1 estimo la probabilidad estacionaria

# calculo probabilidad empirica del primario
Py=[];
W=sum(frec);
for i=1:Scard,
    PIdist(1+S(i,1),1+S(i,2))=frec(i)/W;
endfor
Px=sum(PIdist');   #distribucion marginal de los usuarios primarios (deberia ser una Erlang-B), indepte de los SU
Py=sum(PIdist);    #distribucion marginal de los usuarios secundarios


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
    title("Probabilidad del secundario")
    xlabel("y")
    ylabel("prob")
    leyenda=[sprintf("Erlang-B (rho=%4.2f)",rho2);"mi forecaster"];
    legend(leyenda)

    plot_experto_h(h',S)
endif

# analizo las ganancias medias de los distintos expertos
mh=[ hsys zeros(1,length(h))];


printf("Pay-off medio de mi forecaster: %4.2f , pay-off/n_arribos_SU: %4.2f \n", hsys , hsys /na2 );
