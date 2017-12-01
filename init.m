# Script de inicialización de parametros para emplear en todas 
# las simulaciones del trabajo (todos los script master_*.m)
#
# juan vanerio, 2015-2017





# limpieza y aleatorizacion
clear -x alg archivomat arg_list
clc
close all
rand('state',floor(10000000*rand(1)))


# Opciones de simulador y/o visualizacion
more off

  #declaro todas las variables globales para que las utilicen los demas scripts
global track_trayectorias graficas generar_eventos C M T l1 l2 mu1 mu2 R K alfa betha

track_trayectorias=0;     # Aumenta los tiempos significativamente (de o(MT) a o(MT^(5/3)) ). Usar solo para debugging.
                         # Valor: -1: historia completa, 0: desactivado, N (mayor a 1): guardar unicamente los ultimos N estados. 
graficas=0;               # Mostrar graficas (1) o no (0)

generar_eventos=0;       # Con cualquier valor distinto de 0 el sistema generara su propio schedule de eventos.
                         # Si vale cero, espera encontrar en memoria las siguientes variables: ev_sched, l1, l2, mu1 y mu2.(explicados mas adelante)

# Parametros del sistema
C=20; # C: Capacidad del sistema
# x: cantidad de usuarios primarios en el sistema. 0<=x<=C 
# y: cantidad de usuarios secundarios en el sistema. 0<=y<=C .   0<=x+y<=C
    
    
%T=500;        #aproximated system elapsed time (in same units as lambda)
%l1=20;        # l1: tasa de arribos Poisson para los usuarios primarios
%l2=24;        # l2: tasa de arribos Poisson para los usuarios secundarios
%mu1=2;        # media de tiempo de servicio para los usuarios primarios
%mu2=2;        # media de tiempo de servicio para los usuarios secundarios    
    
R=1;          # R: Reward básico por aceptar un nuevo usuario secundario
K=3;          # K: penalidad básica por echar a un usuario secundario mientras estaba en servicio.
alfa=0;       #factor de descuento del pay-off
betha=1e-06;  #criterio de parada por imposibilidad de cambio significativo



