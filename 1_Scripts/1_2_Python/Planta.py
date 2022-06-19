import sys
import json

def Entradas():
    
    global SP,var1,U_1,U_2,NV_1,NV_2,CMD_start,CMD_PID_On,E_1,I_1,Kp,Ti,Td,var14,var15,var16,var17,var18,var19,var20,var21,var22,var23,var24,var25,var26,var27,var28,var29

    SP=float(sys.argv[1])
    var1=float(sys.argv[2])
    U_1=float(sys.argv[3])
    U_2=float(sys.argv[4])
    NV_1=float(sys.argv[5])
    NV_2=float(sys.argv[6])
    CMD_start=float(sys.argv[7])
    CMD_PID_On=float(sys.argv[8])
    E_1=float(sys.argv[9])
    I_1=float(sys.argv[10])
    Kp=float(sys.argv[11])
    Ti=float(sys.argv[12])
    Td=float(sys.argv[13])
    var14=float(sys.argv[14])
    var15=float(sys.argv[15])
    var16=float(sys.argv[16])
    var17=float(sys.argv[17])
    var18=float(sys.argv[18])
    var19=float(sys.argv[19])
    var20=float(sys.argv[20])
    var21=float(sys.argv[21])
    var22=float(sys.argv[22])
    var23=float(sys.argv[23])
    var24=float(sys.argv[24])
    var25=float(sys.argv[25])
    var26=float(sys.argv[26])
    var27=float(sys.argv[27])
    var28=float(sys.argv[28])
    var29=float(sys.argv[29])

def Parametros_Planta():
    global CA1,CA2,CA3,CB1,CB2,CB3
	if SP>=75:
        CA1=1
        CA2=-0.9815
        CA3=0.0038
        CB1=0
        CB2=0.452
        CB3=0.0215
    elif SP>=65:
        CA1=1
        CA2=-0.9772
        CA3=0.0018
        CB1=0
        CB2=0.0455
        CB3=0.0226
    elif SP>=55:
        CA1=1
        CA2=-0.9765
        CA3=0.0035
        CB1=0
        CB2=0.045
        CB3=0.0229
    elif SP>=45:
        CA1=1
        CA2=-0.9708
        CA3=0.0019
        CB1=0
        CB2=0.0445
        CB3=0.0248
    elif SP>=30:
        CA1=1
        CA2=-0.9601
        CA3=-0.0029
        CB1=0
        CB2=0.0444
        CB3=0.0261
    
def PID():
    global E,I_1,E_1,U,I

    if CMD_start==1 and CMD_PID_On==1:
        E=SP-NV_1
        I=I_1+(E_1+E)/2
        U=Kp*E+Kp*(Td/1)*(E-E_1)+Kp*(1/Ti)*I

        E_1=E
        I_1=I
    else:
        E=0
        E_1=0
        I=0
        I_1=0
        U=0

def Planta():
    global NV,U_1,U_2,NV_1,NV_2

    if CMD_start==1:
        U_B=U*CB1+CB2*U_1+CB3*U_2
        NV_A=CA2*NV_1+CA3*NV_2
        NV=(U_B-NV_A)/CA1

        if NV>100:
            NV=100
        elif NV<0:
            NV=0

        U_2=U_1
        U_1=U
        NV_2=NV_1
        NV_1=NV
    else:
        U_B=0
        NV_A=0
        NV=0
        U_2=0
        U_1=0
        NV_2=0
        NV_1=0


def Display_variador():
    if U>100:
        freq_variador=50
    elif U<0:
        freq_variador=0
    else:
        freq_variador=U/2
    return(freq_variador)

def to_json(x):
    y = json.dumps(x)

    return(y)


if __name__=="__main__":

    Entradas()
    Parametros_Planta()
    PID()
    Planta()   
    freq_variador=Display_variador()
    out={'PV':NV,'Freq':freq_variador,'E':E,'U_1':U_1,'U_2':U_2,'NV_1':NV_1,'NV_2':NV_2,'E_1':E_1,'I_1':I_1}
    out_parseado=to_json(out)
    print(out_parseado)



