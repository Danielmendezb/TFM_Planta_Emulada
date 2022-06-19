%Se inicializa el workspace
clear;
clc;

%Se inicializa la comunicaci�n con la DAQ
DAQ_Start();

%Se declaran e inicializan las variables
sp=70;
Hist=5;

T=1;
Kp=1.25;
Ti=15;

u=0;
integral=0;
integral_ant=0;
error=0;
error_ant=0;

pv=0;
pv_ant=0;

Original_PRBS=idinput(3600); 
Signal_PRBS=5*Original_PRBS;
Size_PRBS=size(Signal_PRBS);
datos_PRBS=zeros([2,1]);
datos_PRBS_aux=zeros([2,1]);

t_estable=120;
t_save=600;
cont_save=0;

ruta='C:\Users\alumno\Desktop\TFM_08_06_2021\Definitivo\70\ruta.mat';

save ruta datos_PRBS_aux

%Se realiza el bucle for
for i=1:1:(Size_PRBS(1)+t_estable)
    
    tic
    
    pv_ant=pv;
    integral_ant=integral;
    error_ant=error;
    
    pv=DAQ_Read();
    
    error=sp-pv;
    
    %Se realiza el regulador PID
    if i==1
        u=0;
        integral=error/2;
    end
    if i>1
        integral=integral_ant+(error_ant+error)/2;
        u=Kp*error+Kp*(T/Ti)*integral;
    end
    
    %Si el sistema es estable, se le suma a la consigna el valor de la PRBS
    if i>t_estable
        
        cont_save=cont_save+1;
        
        cont_PRBS=cont_PRBS+1;
        u=u+Signal_PRBS(cont_PRBS);
        
        datos_PRBS(1,cont_save)=u;
        datos_PRBS(2,cont_save)=pv;
        
        if cont_save>t_save
            aux_archivo=load(ruta);
            
            datos_PRBS_aux=[aux_archivo.datos_PRBS_aux datos_PRBS];
            
            save ruta datos_PRBS_aux ;
            
            cont_save=0;
            datos_PRBS=zeros([2,1]);
            datos_PRBS_aux=zeros([2,1]);
            
        end
        
    else
        cont_PRBS=0;
    end

    DAQ_Write(u,0); %Se escribe la salida
    
    pause(1-toc);
    
    fprintf('%i\n', i)
    
end

aux_archivo=load(ruta);          
datos_PRBS_aux=[aux_archivo.datos_PRBS_aux datos_PRBS];           
save ruta datos_PRBS_aux ;

DAQ_Write(0,0);
DAQ_Stop();
    
