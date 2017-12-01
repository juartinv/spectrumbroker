function ev_sched=event_schedule_alternativos(T, l1, l2, mu1, mu2, generador_eventos)

    % Funcion para construir (precalcular) el plan de eventos para una simulacion,
    % en particular para planes cuya dinamica ersponde a un modelo de oponente 
    % olvidadizo en general.
    %
    % Inputs:
    % T     aproximated system elapsed time (in same units as lambda)
    % l1    Parametro base de arribos de PU
    % l2    Parametro base de arribos de SU
    % mu1   Parametro base de tiempso de servicio de PU
    % mu2   Parametro base de tiempso de servicio de SU
    % generador_eventos: indica el modelo de oponente a emplear para generar el plan:
    %        1. Procesos de densidades uniformes
    %        2. procesos de colas pesadas (similar cauchy)
    %        3. poisson de intensidades estacionales
    %        4. poisson on-off
    %        5. poisson de intensidades aleatorias
    %
    % Output:
    % Matriz ev_sched= [event_time, user (Pri or Sec), event (1: Arrival or 2:departure), event_id]
    % 
    % 2017- juan vanerio
    
    
    
    if (nargin!=6) %control de entradas
        error ("event_schedule: deben ser seis argumentos de entrada: (T, l1, l2, mu1, mu2, generador_eventos)");
    endif   
    
    %se inicia aleatorizacion
    rand('state',floor(10000000*rand(1)));
    
    
    
    switch (generador_eventos)
      case 1
   
        %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
        disp("uniforme")
        normalizar_duraciones=false;
        NN1=feval(@poissrnd,T*l1)
        NN2=feval(@poissrnd,T*l2)

        X1=[ (0.5+rand(NN1,1))/l1  (0.5+rand(NN1,1))/mu1 ];
        X2=[ (0.5+rand(NN2,1))/l2  (0.5+rand(NN2,1))/mu2 ];

        #Determiino los instantes de tiempo en que ocurre cada evento:
        PA=cumsum(X1(:,1));    #Primary Arrivals
        PD=PA+X1(:,2);         #Primary Departures
        SA=cumsum(X2(:,1));    #Secondary Arrivals
        SD=SA+X2(:,2);         #Secondary Departures


      case 2   
        %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
        disp("colas pesadas")
        normalizar_duraciones=true;
        NN1=feval(@poissrnd,T*l1)
        NN2=feval(@poissrnd,T*l2)

        X1=[ abs(cauchy_rnd(0,1/l1,NN1,1))  abs(cauchy_rnd(0,1/mu1,NN1,1))   ];
        X2=[ abs(cauchy_rnd(0,1/l2,NN2,1))  abs(cauchy_rnd(0,1/mu2,NN2,1))  ];

        #Determiino los instantes de tiempo en que ocurre cada evento:
        PA=cumsum(X1(:,1));    #Primary Arrivals
        PD=PA+X1(:,2);         #Primary Departures
        SA=cumsum(X2(:,1));    #Secondary Arrivals
        SD=SA+X2(:,2);         #Secondary Departures


      case 3
        %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
        disp("poisson seasonal")
        normalizar_duraciones=false;
        NN1=T*l1
        NN2=T*l2

        A=0.5+0.45*rand(1,4);            %sorteo amplitudes de oscilacion entre 0.05 y 0.95
        omega=(2*pi/T).*(2+2*rand);    %sorte una unica frecuencia entre 2 y 4 revoluciones en tiempo T para todos los procesos.
        phi=2*pi*rand(1,4);              %sorte fases en [0, 2*pi]

        preX1=-log(rand(NN1,2));
        preX2=-log(rand(NN2,2));
        
        t=0; X1=[];
        auxt=[]; auxf=[];
        for tind=[1:NN1]         
            l1t=l1*(1+A(1)*sin(t*omega+phi(1)));
            mu1t=mu1*(1+A(2)*sin(t*omega+phi(2)));
            X1=[X1; [preX1(tind,1)/l1t  preX1(tind,2)/mu1t ] ];
            t=t+preX1(tind,1)/l1t;
            
            auxt=[auxt; t];
            auxf=[auxf; l1t];
        endfor

        t=0; X2=[];
        for tind=[1:NN2]
            l2t=l2*(1+A(3)*sin(t*omega+phi(3)));
            mu2t=mu2*(1+A(4)*sin(t*omega+phi(4)));
            X2=[X2; [preX2(tind,1)/l2t  preX2(tind,2)/mu2t ] ];
            t=t+preX2(tind,1)/l2t;
        endfor

        #Determino los instantes de tiempo en que ocurre cada evento:
        PA=cumsum(X1(:,1));    #Primary Arrivals
        PD=PA+X1(:,2);         #Primary Departures
        SA=cumsum(X2(:,1));    #Secondary Arrivals
        SD=SA+X2(:,2);         #Secondary Departures



      case 4
        %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
        disp("poisson on-off")
        normalizar_duraciones=false;
        NN1=feval(@poissrnd,T*l1)
        NN2=feval(@poissrnd,T*l2)

        nt1=cumsum(rand(3+2*randi(4),1));  
        nt1=nt1*T/nt1(end);  %tiempos de cambios de estado
        nt1=reshape([0; nt1]',2,(length(nt1)+1)/2)';

        preX1=-log(rand(NN1,2));
        X1=preX1./(ones(NN1,1)*[l1,mu1]); #(la columna uno tiene los arribos, la segunda los tiempos de servicio) 
        
        #Determino los instantes de tiempo en que ocurre cada evento:
        PA=cumsum(X1(:,1));    #Primary Arrivals
        PD=PA+X1(:,2);         #Primary Departures

        ind_on=[];
        for i=[1:rows(nt1)]
            ind_on=[ind_on;  find( (PA>=nt1(i,1)).*(PA<nt1(i,2))  )];
        endfor
        
        PA=PA(ind_on); PD=PD(ind_on);
        NN1=length(ind_on)   %ajusto el nuevo valor
        
        
        % Determino inter-arrival times para usuarios secundarios
        nt2=cumsum(rand(3+2*randi(4),1));  
        nt2=nt2*T/nt2(end);  %tiempos de cambios de estado
        nt2=reshape([0; nt2]',2,(length(nt2)+1)/2)';

        preX2=-log(rand(NN2,2));
        X2=preX2./(ones(NN2,1)*[l2,mu2]);
        
        #Determino los instantes de tiempo en que ocurre cada evento:
        SA=cumsum(X2(:,1));    #Secondary Arrivals
        SD=SA+X2(:,2);         #Secondary Departures

        ind_on=[];
        for i=[1:rows(nt2)]
            ind_on=[ind_on ; find( (SA>=nt2(i,1)).*(SA<nt2(i,2))  )];
        endfor
        
        SA=SA(ind_on); SD=SD(ind_on);
        NN2=length(ind_on)



      case 5
        %Determino la cantidad de eventos de arribo para cada usuario que se observarán en el tiempo estimado (que funcionará como aproximación)
        disp("Intensidades aleatorias")
        normalizar_duraciones=true;

        Delta=0.75;

        NN1=round(T*l1)
        NN2=round(T*l2)
        
        rho1=l1/mu1;
        rho2=l2/mu2;

        preX1=-log(rand(NN1,2));          % exponenciales de base, con parametro=1
        preX2=-log(rand(NN2,2));
        
        X1=[];
        for tind=[1:NN1]         
            rho1t = rho1*( 1+Delta*(2*rand-1) );
            mu1t = mu1*( 1+Delta*(2*rand-1) );
            
            l1t  = rho1t*mu1t;
            X1=[X1; [preX1(tind,1)/l1t  preX1(tind,2)/mu1t ] ];  
        endfor

        
        X2=[];
        for tind=[1:NN2]
            rho2t = rho2*( 1+Delta*(2*rand-1) );
            mu2t = mu2*( 1+Delta*(2*rand-1) );
            
            l2t  = rho2t*mu2t;
            X2=[X2; [preX2(tind,1)/l2t  preX2(tind,2)/mu2t ] ];
        endfor

        #Determino los instantes de tiempo en que ocurre cada evento:
        PA=cumsum(X1(:,1));    #Primary Arrivals
        PD=PA+X1(:,2);         #Primary Departures
        SA=cumsum(X2(:,1));    #Secondary Arrivals
        SD=SA+X2(:,2);         #Secondary Departures
        
    endswitch

    

    # Construyo una unica tabla con todos los eventos
    #      estructura: [event_time, user (Pri or Sec), event (1: Arrival or 2:departure), event_id]
    ev_sched=[PA, ones(NN1,1), ones(NN1,1), [1:NN1]' ;
              PD, ones(NN1,1), 2*ones(NN1,1), [1:NN1]' ;
              SA, 2*ones(NN2,1), ones(NN2,1), NN1+[1:NN2]' ;
              SD, 2*ones(NN2,1), 2*ones(NN2,1), NN1+[1:NN2]' ];

    #Finalmente ordeno la tabla para que los eventos queden ordenados cronologicamente.
    ev_sched= sortrows(ev_sched);

    if (normalizar_duraciones)
        coef=0.995;
        TT=quantile(ev_sched(:,1),coef);   %voy a normalizar hasta este punto
        ev_sched=[(coef*T/TT)*ev_sched(:,1) ev_sched(:,2:4)];
    endif
    

end
