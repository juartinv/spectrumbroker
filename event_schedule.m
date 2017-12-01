function ev_sched=event_schedule(T, l1, l2, mu1, mu2, generador_eventos=@poissrnd ,generador_duraciones=@exprnd)

    % Funcion para construir (precalcular) el plan de eventos para una simulacion.
    % Esto es compatible con el modelo de opnente olvidadizo pero solo se usa para 
    % generar planes de tipo estocastico Poissno/exponencial.
    %
    % Inputs:
    % T     #aproximated system elapsed time (in same units as lambda)
    % Primary users arrival rate: l1
    % Secondary users arrival rate: l2  
    % Primary users service (departure) rate: mu1
    % Secondary users service (departure) rate: mu2 
    %
    % Output:
    % Matriz ev_sched= [event_time, user (Pri or Sec), event (1: Arrival or 2:departure), event_id]
    % 
    % 2016- juan vanerio
    
    
    if (nargin<5) %control de entradas
        error ("event_schedule: parametros de entrada insuficientes");
    elseif (nargin>7)
        error ("event_schedule: demasiados parametros de entrada");
    endif   
    
    %se inicia aleatorizacion
    rand('state',floor(10000000*rand(1)));
      
    %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
    NN1=feval(generador_eventos,T*l1);
    NN2=feval(generador_eventos,T*l2);

    %imprimo los generadores a utilizar
    printf("Generador de Eventos: %s, Generador de duraciones: %s \n",  func2str(generador_eventos),  func2str(generador_duraciones))

    %Determino inter-arrival times para usuarios primarios
    #preX1=-log(rand(NN1,2));
    #X1=preX1./(ones(NN1,1)*[l1,mu1]); #(la columna uno tiene los arribos, la segunda los tiempos de servicio) 
    X1=[generador_duraciones(1/l1,NN1,1), generador_duraciones(1/mu1,NN1,1)];
    % Determino inter-arrival times para usuarios secundarios
    #preX2=-log(rand(NN2,2));
    #X2=preX2./(ones(NN2,1)*[l2,mu2]);
    X2=[generador_duraciones(1/l2,NN2,1), generador_duraciones(1/mu2,NN2,1)];

    #Determiino los instantes de tiempo en que ocurre cada evento:
    PA=cumsum(X1(:,1));    #Primary Arrivals
    PD=PA+X1(:,2);         #Primary Departures
    SA=cumsum(X2(:,1));    #Secondary Arrivals
    SD=SA+X2(:,2);         #Secondary Departures
     
    # Construyo una unica tabla con todos los eventos
    #      estructura: [event_time, user (Pri or Sec), event (1: Arrival or 2:departure), event_id]
    ev_sched=[PA, ones(NN1,1), ones(NN1,1), [1:NN1]' ;
              PD, ones(NN1,1), 2*ones(NN1,1), [1:NN1]' ;
              SA, 2*ones(NN2,1), ones(NN2,1), NN1+[1:NN2]' ;
              SD, 2*ones(NN2,1), 2*ones(NN2,1), NN1+[1:NN2]' ];

    #Finalmente ordeno la tabla para que los eventos queden ordenados cronologicamente.
    ev_sched= sortrows(ev_sched);

end
