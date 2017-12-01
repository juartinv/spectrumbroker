function AA=calc_expertos_diagonales(revS)

    %
    % Inputs:
    %  revS;     matriz reversa de S: Es una matriz C+1 x C+1 donde 
    %            dados "x" e "y" nos dice el indice de dicho estado 
    %            en la matriz de estados S 
    %
    % Output: 
    % Matriz AA= Matriz Scard x C donde se generan todos los mapas 
    %            de decision difentes posibles incrementando el 
    %            margen de decisión segun los bordes x+y=z. Tipica-
    %            mente esto se usa como expertos en casos especiales.
    %            (desde spectrum_auction_si.m)
    %        
    % Nota: Scard es la cantidad de estados posibles, y se calcula a partir de revS.
    %
    % 2016- juan vanerio

    # primero determino la cantidad de estados Scard
    C=rows(revS)-1;
    Scard=(C+1)*(C/2+1);
    
    AA=ones(Scard,C);  %inicializo C expertos, todos identicos aceptando siempre los secundarios
    
    auxRS=fliplr(revS); % va a ser mas facil trabajar con la matriz revS espejada horizontalmente
    
    #ahora voy actualizando todos los expertos
    for z=0:C-1                       # z es la constante tal que y+x=z, indica el borde y haremos que no se actualice
        diag(auxRS,z);                 # obtengo los estados que verifican x+y=z
        AA(diag(auxRS,z),1:C-z)=0;    # para todos los expertos entre 1 y C-z hago que se rechacen los secundarios si el estado verifica x+y=z
    endfor
    
    #El resultado final es que el primer experto es el más restrictivo de todos (casi no acepta secundarios) y el ultimo el más permisivo (los acepta siempre)
    
    #sugerencia de visualizacion:
    #  for z=1:C
    #      plot_experto(z,AA,S)
    #      pause
    #      close
    # endfor


end
