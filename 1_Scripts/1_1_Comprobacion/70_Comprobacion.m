%Declaración de variables
sp=70;
sp_cte=70;
lectura=zeros([3,1]);
error=lectura(3,:);
u=zeros([1,1]);
integral=zeros([1,1]);
derivada=zeros([1,1]);
error_sim=lectura(3,:);
u_sim=zeros([1,1]);
integral_sim=zeros([1,1]);
derivada_sim=zeros([1,1]);
sp_ar=zeros([1,1]);
T=1;
Kp=1.25;
Ti=15;
Td=3.75;
cont=0;
cont_escalon=0;
cont_es=0;

NV=zeros([1,1]);

U_B=0;
NV_A=0;

CA1=1;
CA2=-0.9772;
CA3=0.0018;
CA4=0;
CA5=0;
CB1=0;
CB2=0.0455;
CB3=0.0226;
CB4=0;

%Se inicia la comunicación con la DAQ
DAQ_Start();



for i=1:1:inf
    
    tic
    
    %Se genera escalon al 5% para el variador
if cont_escalon<6
    DAQ_Write(5,0)
    cont_escalon=cont_escalon+1;
else
    
    cont=cont+1;
    lectura(1,cont)=cont;
    lectura(2,cont)=DAQ_Read;
    error(1,cont)=sp-lectura(2,cont); %Se calcula el error
    if cont>2
        error_sim(1,cont)=sp-NV(1,cont-1);
    else
        error_sim(1,cont)=sp;
    end
    %A partir de 120 segundos se generan escalones de +-10 sp
    if cont>120
        if cont_es<39
            sp=sp_cte+5;
            cont_es=cont_es+1;
        elseif cont_es<79
            sp=sp_cte-5;
            cont_es=cont_es+1;
        else
            cont_es=0;
        end
        
    end
    
    %Se realiza el regulador PID
    if cont==1
        u(1,cont)=5;
        integral(1,cont)=error_sim(1,cont)/2;
        
        u_sim(1,cont)=5;
        integral_sim(1,cont)=error_sim(1,cont)/2;
    end
    if cont>1
        integral(1,cont)=integral(1,cont-1)+(error(1,cont-1)+ error(1,cont))/2;
        %u(1,cont)=Kp*error(1,cont)+Kp*(Td/T)*(error(1,cont)-error(1,cont-1))+Kp*(T/Ti)*integral(1,cont);
        u(1,cont)=Kp*error(1,cont)+Kp*(T/Ti)*integral(1,cont);
        %Se escribe la salida en el sistema simulado
        
        integral_sim(1,cont)=integral_sim(1,cont-1)+(error_sim(1,cont-1)+ error_sim(1,cont))/2;
        u_sim(1,cont)=Kp*error_sim(1,cont)+Kp*(T/Ti)*integral_sim(1,cont);
    end
    
    if cont==1
        U_B=u_sim(1,cont)*CB1;
        NV_A=0;
        NV(1,cont)=(U_B-NV_A)/CA1;
    end
    if cont==2
        U_B=u_sim(1,cont)*CB1+CB2*u_sim(1,cont-1);
        NV_A=CA2*NV(1,cont-1);
        NV(1,cont)=(U_B-NV_A)/CA1;
    end
    if cont==3
        U_B=u_sim(1,cont)*CB1+CB2*u_sim(1,cont-1)+CB3*u_sim(1,cont-2);
        NV_A=CA2*NV(1,cont-1)+CA3*NV(1,cont-2);
        NV(1,cont)=(U_B-NV_A)/CA1;
    end
    if cont==4
        U_B=u_sim(1,cont)*CB1+CB2*u_sim(1,cont-1)+CB3*u_sim(1,cont-2)+CB4*u_sim(1,cont-3);
        NV_A=CA2*NV(1,cont-1)+CA3*NV(1,cont-2)+CA4*NV(1,cont-3);
        NV(1,cont)=(U_B-NV_A)/CA1; 
    end
    if cont>=5 && lectura(2,cont)>=0
        U_B=u_sim(1,cont)*CB1+CB2*u_sim(1,cont-1)+CB3*u_sim(1,cont-2)+CB4*u_sim(1,cont-3);
        NV_A=CA2*NV(1,cont-1)+CA3*NV(1,cont-2)+CA4*NV(1,cont-3)+CA5*NV(1,cont-4);
        NV(1,cont)=(U_B-NV_A)/CA1;
    end
    
    if lectura(2,cont)<0
        NV(1,cont)=0;
    end
    
  
    DAQ_Write(u(1,cont),0); %Se escribe la salida en el sistema real
    
     %Representación
    sp_ar(1,cont)=sp;
    
    figure(1)
    plot(lectura(1,:),lectura(2,:),'-r')
    %xlim([0 180])
    ylim([0 100])
    xlabel('Tiempo (s)')
    ylabel('Nivel (%)')
    
    hold on
    
    plot(lectura(1,:),NV(1,:),'-b')
    
    hold on
    plot(lectura(1,:),sp_ar,'-k')

    
    %Salir por teclado
    key=get(gcf,'currentcharacter');
    if key=='q'
        DAQ_Write(0,0);
        DAQ_Stop;
    break
    end
    
    
    
end 
pause(1-toc);
end    
    