%  Este procedimiento genera una cantidad predefinida de nuevos 
%  vectores de cada clase de dinamica en una matriz "q" (25 maximales, 
%  50 de borde y 25 saturdos)
%  El resultado se guarda en un archivo comparacion/param.mat
%  Ese archivo típicamente se usa en policyIterator_script_multiples.m
%  y forma parte de la comparacion de mecanismos seleccionados contra MDP


clear global
clear all
clc
q=[];
C=20
epsilon=0.45
T=50
region="maximal"  #maximal, saturada, borde, total
iteraciones=25

if (  strcmpi( region, "maximal" ) )
    parametros_lowb= [T              0.02*C         0.02*C   -0.6  1 ];
    parametros_upb = [T  (1-epsilon-0.02)*C  (1-epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica!!
elseif (  strcmpi( region, "saturada" ) )
    parametros_lowb= [T               0.9*C          0.1*C   -0.6  1 ];
    parametros_upb = [T                 2*C            2*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magnitud!!
elseif (  strcmpi( region, "borde" ) )
    parametros_lowb= [T               0.1*C          0.1*C   -0.6  1 ];
    parametros_upb = [T               0.9*C  (1+epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magnitud!!
endif

parametros_lowb=repmat(parametros_lowb,iteraciones,1);
parametros_upb=repmat(parametros_upb,iteraciones,1);
parametros=[];
for MM=1:iteraciones,
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
    endif
    mu1 =10^(parametros_lowb(MM,4)+(parametros_upb(MM,4)-parametros_lowb(MM,4))*rand);     # media de tiempo de servicio para los usuarios primarios
    mu2 =parametros_lowb(MM,5)+(parametros_upb(MM,5)-parametros_lowb(MM,5))*rand;     # media de tiempo de servicio para los usuarios secundarios
    l1  =rho1*mu1;                                                                    # l1: tasa de arribos Poisson para los usuarios primarios
    l2  =rho2*mu2;                                                                    # l2: tasa de arribos Poisson para los usuarios secundarios
    parametros=[parametros;[MM C T l1 l2 mu1 mu2]];
endfor
q=[q; parametros(:,4:7)];

  
   
region="borde"  #maximal, saturada, borde, total
iteraciones=50

if (  strcmpi( region, "maximal" ) )
    parametros_lowb= [T              0.02*C         0.02*C   -0.6  1 ];
    parametros_upb = [T  (1-epsilon-0.02)*C  (1-epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica!!
elseif (  strcmpi( region, "saturada" ) )
    parametros_lowb= [T               0.9*C          0.1*C   -0.6  1 ];
    parametros_upb = [T                 2*C            2*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
elseif (  strcmpi( region, "borde" ) )
    parametros_lowb= [T               0.1*C          0.1*C   -0.6  1 ];
    parametros_upb = [T               0.9*C  (1+epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
endif

parametros_lowb=repmat(parametros_lowb,iteraciones,1);
parametros_upb=repmat(parametros_upb,iteraciones,1);
parametros=[];
for MM=1:iteraciones,
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
    endif
    mu1 =10^(parametros_lowb(MM,4)+(parametros_upb(MM,4)-parametros_lowb(MM,4))*rand);     # media de tiempo de servicio para los usuarios primarios
    mu2 =parametros_lowb(MM,5)+(parametros_upb(MM,5)-parametros_lowb(MM,5))*rand;     # media de tiempo de servicio para los usuarios secundarios
    l1  =rho1*mu1;                                                                    # l1: tasa de arribos Poisson para los usuarios primarios
    l2  =rho2*mu2;                                                                    # l2: tasa de arribos Poisson para los usuarios secundarios
    parametros=[parametros;[MM C T l1 l2 mu1 mu2]];
endfor
q=[q; parametros(:,4:7)];



region="saturada"  #maximal, saturada, borde, total
iteraciones=25

if (  strcmpi( region, "maximal" ) )
    parametros_lowb= [T              0.02*C         0.02*C   -0.6  1 ];
    parametros_upb = [T  (1-epsilon-0.02)*C  (1-epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica!!
elseif (  strcmpi( region, "saturada" ) )
    parametros_lowb= [T               0.9*C          0.1*C   -0.6  1 ];
    parametros_upb = [T                 2*C            2*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
elseif (  strcmpi( region, "borde" ) )
    parametros_lowb= [T               0.1*C          0.1*C   -0.6  1 ];
    parametros_upb = [T               0.9*C  (1+epsilon)*C    0.6  1 ];  %mu1 aqui esta limitado en forma logaritmica, se le permite varia en poco mas de un orden de magntud!!
endif

parametros_lowb=repmat(parametros_lowb,iteraciones,1);
parametros_upb=repmat(parametros_upb,iteraciones,1);
parametros=[];
for MM=1:iteraciones,
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
    endif
    mu1 =10^(parametros_lowb(MM,4)+(parametros_upb(MM,4)-parametros_lowb(MM,4))*rand);     # media de tiempo de servicio para los usuarios primarios
    mu2 =parametros_lowb(MM,5)+(parametros_upb(MM,5)-parametros_lowb(MM,5))*rand;     # media de tiempo de servicio para los usuarios secundarios
    l1  =rho1*mu1;                                                                    # l1: tasa de arribos Poisson para los usuarios primarios
    l2  =rho2*mu2;                                                                    # l2: tasa de arribos Poisson para los usuarios secundarios
    parametros=[parametros;[MM C T l1 l2 mu1 mu2]];
endfor
q=[q; parametros(:,4:7)];

clear -x q
save("/home/jvanerio/Escritorio/tesis/comparacion/param.mat","q")


