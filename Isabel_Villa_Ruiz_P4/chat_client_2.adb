with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Handler;


procedure Chat_Client_2 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ATIO renames ADA.Text_IO;
   package CM renames Chat_Messages;

   use type CM.Message_Type;

   Usage_Error : exception; --Error de uso tipo Exception

   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Puerto : Integer;
   IP : ASU.Unbounded_String;
   Nick: ASU.Unbounded_String;
   Maquina: ASU.Unbounded_String;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request:   ASU.Unbounded_String;
   Reply:     ASU.Unbounded_String;
   Expired : Boolean;

   Message : CM.Message_Type;
   Acogido : Boolean;


begin

    --Comprobacion de que los argumentos sean 3.
    if ACL.Argument_Count /= 3 then
    raise Usage_Error;
    end if;

    --Argumentos
    Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
    Puerto := Integer'Value(ACL.Argument(2));
    Nick := ASU.To_Unbounded_String(ACL.Argument(3));

    if ASU.To_String(Nick) = "server" then
        ATIO.Put_Line("Invalid nickname.");
    else


        --Cogo la direccion ip de la maquina y lo guardo en IP.
        IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));

        -- Construye el End_Point en el que está atado el servidor.
        -- Con la direccion de la maquina y el puerto que se le pasa por terminal
        Server_EP := LLU.Build( ASU.To_String(IP), Puerto);


        --comprobar si tiene sentido
        LLU.Bind_Any(Client_EP_Receive);
        LLU.Bind_Any(Client_EP_Handler, Client_Handler.Chat_Handler'Access);

        --MENSAJE DE INICIO PARA ENVIAR Y METER EN EL BUFFER
        LLU.Reset(Buffer);

        CM.Message_Type'Output(Buffer'Access,CM.Init);
        LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
        LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
        ASU.Unbounded_String'Output(Buffer'Access, Nick);
        LLU.Send(Server_EP, Buffer'Access);


        --RECEPCION EN LOS 10 PRIMEROS SEGUNDOS DE EL MENSAJE "WELCOME"
        -- reinicializa el buffer para empezar a utilizarlo
        LLU.Reset(Buffer);


        LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Expired);

        if not Expired then
            Message := CM.Message_Type'Input(Buffer'Access);
            --ATIO.Put_Line("HA ENTRADO");
            if Message = CM.Welcome then
                Acogido := Boolean'Input(Buffer'Access);
                --ATIO.Put_Line(Boolean'Image(Acogido));
                if Acogido = True then
                    ATIO.Put_Line("Mini-Chat v2.0 : Welcome " & ASU.To_String(Nick));
                else
                    ATIO.Put_Line("Mini-Chat v2.0 : IGNORED new user " & ASU.To_String(Nick) & ", nick already used");
                    LLU.Finalize;
                end if;
            end if;
        else
            ATIO.Put_Line("Server unreachable");
            LLU.Finalize;
        end if;



        if Acogido = True then
            --Bucle con Exit "Quit"

            loop
                --Ada.Text_IO.Put(">>");
                -- reinicializa el buffer para empezar a utilizarlo
                LLU.Reset(Buffer);

                --Esto de aqui abajo envia cosas nuevas.
                --ASU.Unbounded_String'Output(Buffer'Access, Request);

                Ada.Text_IO.Put(">> ");
                Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

                --Comprobacion sin es Quit
                if ASU.To_String(Request) = ".quit" then
                    Exit when ASU.To_String(Request) = ".quit";
                end if;

                --Ada.Text_IO.Put(">> Va a preparar el mensaje Writer");
                --Mensaje Writter
                CM.Message_Type'Output(Buffer'Access,CM.Writer);
                LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
                --nuevo
                ASU.Unbounded_String'Output(Buffer'Access, Nick);
                ASU.Unbounded_String'Output(Buffer'Access, Request);


                -- envía el contenido del Buffer
                LLU.Send(Server_EP, Buffer'Access);

                --Ada.Text_IO.Put(">> Ha enviado el mensaje Writer");

                -- reinicializa (vacía) el buffer para ahora recibir en él
                LLU.Reset(Buffer);

                -- termina Lower_Layer_UDP
                --Exit when ASU.To_String(Request) = "Quit";
            end loop;


            --MENSAJE LOGOUT
            CM.Message_Type'Output(Buffer'Access,CM.Logout);
            LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
            ASU.Unbounded_String'Output(Buffer'Access, Nick);
            LLU.Send(Server_EP, Buffer'Access);

            LLU.Finalize;

        end if;
    end if;
exception
    when Usage_Error =>
        ATIO.Put_Line("Use: ");
        ATIO.Put_Line("       " & ACL.Command_Name & " <host> <port> <nickname>");
        LLU.Finalize;

end Chat_Client_2;
