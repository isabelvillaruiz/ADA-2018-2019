IVR__________README P4 ISABEL VILLA RUIZ_________________________________________________________


La práctica se ha probado con otros archivos de prueba donde la funcion Hash solo resolvía numeros naturales
y ha funcionado correctamente.
Además se ha comprobado el orden de los clientes activos e incactivos y mantiene el orden que debería
según la resolución de la función Hash para las claves de los clientes.


La práctica cuenta con dos ficheros no especificados en el enunciado, al igual que en la P3:

    -Server_Args_Control.adb
    -Server_Args_Control.ads

Lo que hacen estos ficheros es una comprobación de los argumentos del programa desde un archivo aparte, ya que
al compilar los ficheros, el server_handler se compila antes que el programa principal y si debe leer
del terminal un argumento y es incorrecto el programa "colapsa" antes de poder comprobar los argumentos en el
chat_server_2 como se venía acostumbrando en las practicas anteriores. De esta manera nos ahorramos futuros fallos
de ejecucion.

Los ficheros nuevos realizan las siguientes comprobaciones:

-Comprobar el numero de argumenos de la línea de comandos.

		if ACL.Argument_Count /= Num_Args then
			return 0;
		end if;

-Leer del terminal el argumento dos que será el numero maximo que tendrá la lista de clientes activos

		Max_Active_Clients := Integer'Value(ACL.Argument(2));

-Comprobar que esta entre 2 y 50. 

        *Variables declaradas en el server_handler.ads 
            Num_Args: constant Positive := 2;
            Num_Min_AC: constant Positive := 2; 
            Num_Max_AC: constant Positive := 50;
            Num_Max_IC: constant Positive := 150;

	if Max_Active_Clients < Num_Min_AC or Max_Active_Clients > Num_Max_AC then
		return 0;
	end if;

--Devolver un Natural que representa el numero maximo que tendrá a lista de clientes activos
		--Ada.Text_IO.Put_Line(Natural'Image(Max_Active_Clients));
		return Max_Active_Clients;

