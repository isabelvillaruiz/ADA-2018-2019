--Isabel Villa Ruiz
-- Version EXTENSION
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;


procedure Chat_Client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ATIO renames ADA.Text_IO;
   package CM renames Chat_Messages;

   use type CM.Message_Type;

   Usage_Error : exception; --Error de uso tipo Exception

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Puerto : Integer;
   IP : ASU.Unbounded_String;
   Nick: ASU.Unbounded_String;
   Maquina: ASU.Unbounded_String;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request:   ASU.Unbounded_String;
   Reply:     ASU.Unbounded_String;
   Expired : Boolean;

   Message : CM.Message_Type;


begin

    --Comprobacion de que los argumentos sean 3.
    if ACL.Argument_Count /= 3 then
        raise Usage_Error;
    end if;

    --Argumentos
  	Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
    Puerto := Integer'Value(ACL.Argument(2));
    Nick := ASU.To_Unbounded_String(ACL.Argument(3));

    --Cogo la direccion ip de la maquina y lo guardo en IP.
  	IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));

     -- Construye el End_Point en el que está atado el servidor.
     -- Con la direccion de la maquina y el puerto que se le pasa por terminal
     Server_EP := LLU.Build( ASU.To_String(IP), Puerto);

     LLU.Bind_Any(Client_EP);


     --MENSAJE DE INICIO PARA ENVIAR Y METER EN EL BUFFER

     LLU.Reset(Buffer);

     CM.Message_Type'Output(Buffer'Access,CM.Init);
     LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
     ASU.Unbounded_String'Output(Buffer'Access, Nick);
     LLU.Send(Server_EP, Buffer'Access);

     --Modo Lector
     if ASU.To_String(Nick) = "reader" then
         --Bucle Infinito
        loop
        -- reinicializa el buffer para empezar a utilizarlo
            LLU.Reset(Buffer);

            LLU.Receive(Client_EP, Buffer'Access, 2.0, Expired);

            if not Expired then
                Message := CM.Message_Type'Input(Buffer'Access);
                if Message = CM.Server then
                    Nick := ASU.Unbounded_String'Input(Buffer'Access);
                    Request := ASU.Unbounded_String'Input(Buffer'Access);
                    ATIO.Put_Line(ASU.To_String(Nick) &  ": " & ASU.To_String(Request));
                end if;
            end if;
        end loop;
    --Modo Escritor
    else
        --Bucle con Exit "Quit"
        loop
        -- reinicializa el buffer para empezar a utilizarlo
        LLU.Reset(Buffer);

        --Esto de aqui abajo envia cosas nuevas.
        --ASU.Unbounded_String'Output(Buffer'Access, Request);

        Ada.Text_IO.Put("Message: ");
        Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

        --Comprobacion sin es Quit
        if ASU.To_String(Request) = "Quit" then
            Exit when ASU.To_String(Request) = "Quit";
        end if;

        --Mensaje Writter
        CM.Message_Type'Output(Buffer'Access,CM.Writer);
        LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
        ASU.Unbounded_String'Output(Buffer'Access, Request);


        -- envía el contenido del Buffer
        LLU.Send(Server_EP, Buffer'Access);

        end loop;
        LLU.Finalize;
    end if;

exception
    when Usage_Error =>
        ATIO.Put_Line("Use: ");
        ATIO.Put_Line("       " & ACL.Command_Name & " <host> <port> <nickname>");
        LLU.Finalize;
--    when Ex:others =>
--        Ada.Text_IO.Put_Line ("Excepción imprevista: " &
--                           Ada.Exceptions.Exception_Name(Ex) & " en: " &
--                          Ada.Exceptions.Exception_Message(Ex));
--        LLU.Finalize;
end Chat_Client;
