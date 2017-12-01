function AA=calc_expertos_recta(S,a,b)

    % Este script genera expertos (reglas de decision) tales que rechazan arribos secundarios sii y > -ax + b
    %
    % Inputs:
    %   S        # Matriz de estados del juego. Matriz Scard x 2 donde cada fila representa las coordenadas de un estado. 
    %   a        # Vector fila [1 x EE] con las pendientes (opuestas) de las rectas de borde que define cada experto 
    %   b        # Vector fila [1 x EE] con los terminos independietespendientes (opuestas) de las rectas de borde que define cada experto  
    %
    % Output: 
    % Matriz AA= Matriz Scard x EE donde se generan mapas de decision de expertos incrementando el margen de decisión segun los bordes x+y=z
    %      Nota: Scard es la cantidad de estados posibles, y se calcula a partir de revS.
    % juan vanerio - 2016

    # El calculo es directo


    AA= ( S * [a;ones(size(a))] <= ones(rows(S),1)*b );

    #sugerencia de visualizacion:
    #  for z=1:C
    #      plot_experto(z,AA,S)
    #      pause
    #      close
    # endfor

end
