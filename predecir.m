function [output]=predecir(metodo,h,varargin)

    # Esta funcion se encarga de determinar la predicción del sistema objetivo para el siguiente paso.
    # puede utilizar diferentes metodos.
    #
    # Inputs:
    # metodo: el nombre del metodo
    # h: ganancia acumulada por cada experto hasta ahora.
    # Luego se admiten multiples variables de entrada adicionales según cada predictor (ver el codigo de cada uno)
    #
    #  Output: segun el metodo puede ser el indice de un experto, o directamente un nuevo mapa
    #
    # Se invoca desde los scripts spectrum_auction_*.m
        
    limite=1;
    if (nargin<2)
        disp("Faltan argumentos")
        return
    endif
    
    switch (metodo)

        case {"FTL","S_follow-the-best-expert"}  
            #Predictor tipo SELECT
            output=find(h==max(h));


        case {"FTPL","S_follow-the-perturbed-leader"}  
            #Predictor tipo SELECT
            l=varargin{1};    # nivel de ruido
            z=-log(rand(size(h))).*sign(rand(size(h))-0.5)/l;   #ruido de doble exponencial
            s=h+z;     # payoffs perturbados
            output=find(s==max(s));       


        case {"PMPE","C_exponentially-weighted-average-forecaster"}  
            #Predictor tipo COMBINE. PMPE
            #limite=2;
            nu=varargin{1};    # valor del parametro de la exponencial
            A=varargin{2};     # mapas de los expertos

            w=exp(nu*(h-max(h)));
            w=w/sum(w);
            output=A*w';
            limite=size(output);

        case {"CBE-PAPE", "S_binary_simple"}
            #Predictor tipo SELECTOR
            nu=varargin{1};    # valor del parametro de la exponencial
            output=( rand*(1+exp(nu*h(2))) > 1 )+1; %el +1 es solo por compatibilidad con el resto del codigo       


        case {"SEq","S_equiprobable"}  
            #output=randi(length(h));
            output= ceil(length(h)*rand);


        case {"PAPE","S_media-ponderada-exponencial"}  
            #Predictor tipo SELECT, ALEATORIO
            nu=varargin{1};    # valor del parametro de la exponencial
            p=exp(nu*(h-max(h)));    %tomo regret para ser numericamente un poco más estable. Al normalizar se llega a l mismo resultado.
            p=p/sum(p);
            output=samplefromp(p,1);


        case {"CEq","C_equiprobable"}  
            dummyparam=varargin{2};   #ignore param, just for compatibility
            A=varargin{2};     # mapas de los expertos
            output=mean(A,2);
            limite=size(output);


        case {"none"}  
            output=0;
  
        otherwise
            disp("ERROR: metodo no implementado")
            output=0;
            
    endswitch


    if (length(output)>limite)
        #output=output(randperm(length(output),limite));    #desempate
        auxv=randperm(length(output));
        output=output(auxv(1:limite));
    endif

end
