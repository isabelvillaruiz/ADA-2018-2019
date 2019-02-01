--Isabel Villa Ruiz
-- Version EXTENSION
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;

procedure Chat_Server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ATIO renames ADA.Text_IO;
   package CM renames Chat_Messages;
   package CC renames Client_Collections;

   Usage_Error : exception;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Admin_EP: LLU.End_Point_Type;

   Puerto : Integer;
   Maquina : ASU.Unbounded_String;
   IP : ASU.Unbounded_String;
   Nick_Name : ASU.Unbounded_String;

   Data : ASU.Unbounded_String;

   Password : ASU.Unbounded_String;
   Password_Admin :ASU.Unbounded_String;

   Message : CM.Message_Type;
   Buffer:  aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;

   P_Writers : CC.Collection_Type;
   P_Readers: CC.Collection_Type;

   --Reply: ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   Expired : Boolean;

begin

    if ACL.Argument_Count /= 2 then
        raise Usage_Error;
    end if;

	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);

	Ip := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));

	Puerto := Integer'Value(ACL.Argument(1));
    Password := ASU.To_Unbounded_String(ACL.Argument(2));


   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build ( ASU.To_String(IP), Puerto);

   -- se ata al End_Point para poder recibir en él
   --Si usaramos Bind_Any se ataria a un end point a un puerto aleatorio.
   --Bind asocia el end point creado con el server

   LLU.Bind (Server_EP);

   loop
   -- bucle infinito

      -- reinicializa (vacía) el buffer para ahora recibir en él
      LLU.Reset(Buffer);

      LLU.Receive (Server_EP, Buffer'Access, 2.0, Expired);

      if not Expired then
          Message := CM.Message_Type'Input(Buffer'Access);
          case Message is
            when CM.Init =>
                --Si es Init:

                --Client_EP
                Client_EP := LLU.End_Point_Type'Input (Buffer'Access);

                --NickName
                Nick_Name := ASU.Unbounded_String'Input (Buffer'Access);


                --Debemos ver si es Escritor o Lector para saber en que lista meterlo.
                begin
                    if ASU.To_String(Nick_Name) = "reader" then
                        CC.Add_Client(P_Readers,Client_EP,Nick_Name,False);
                    else
                        CC.Add_Client(P_Writers,Client_EP,Nick_Name,True);
                    end if;

                    ATIO.Put_Line("INIT received from " & ASU.To_String(Nick_Name));
                    --Mensaje tipo Server para comunicar a los readers del nuevo usuario.

                    LLU.Reset (Buffer);

                    if ASU.To_String(Nick_Name) /= "reader" then
                        CM.Message_Type'Output(Buffer'Access,CM.Server);
                        ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("server"));
                        ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String(ASU.To_String(Nick_Name) & " joins the chat"));
                        CC.Send_To_All(P_Readers,Buffer'Access);
                    end if;



                exception
                    when CC.Client_Collection_Error =>
                        ATIO.Put_Line( "INIT received from " & ASU.To_String(Nick_Name) &
                            ". IGNORED, nick already used");
                end;

                LLU.Reset (Buffer);


            when CM.Writer =>

                --Si es Writter:
                --Client_EP
                Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
                --Comentario
                Request := ASU.Unbounded_String'Input (Buffer'Access);



                begin
                    Nick_Name := CC.Search_Client(P_Writers,Client_EP);

                    ATIO.Put("WRITER received from ");
                    ATIO.Put_Line(ASU.To_String(Nick_Name) & ": " & ASU.To_String(Request));

                    --MENSAJE TIPO SERVER
                    --Preparamos envio a todos los readers
                    LLU.Reset (Buffer);

                    CM.Message_Type'Output(Buffer'Access,CM.Server);
                    ASU.Unbounded_String'Output(Buffer'Access, Nick_Name);
                    ASU.Unbounded_String'Output(Buffer'Access, Request);
                    CC.Send_To_All(P_Readers,Buffer'Access);

                exception
                    when CC.Client_Collection_Error =>
                        ATIO.Put_Line("WRITER received from " &
                        ASU.To_String(Nick_Name) &
                        " unknown client. IGNORED");
                end;


            when CM.Collection_Request =>
                Admin_EP := LLU.End_Point_Type'Input (Buffer'Access);
                --Password
                Password_Admin := ASU.Unbounded_String'Input (Buffer'Access);

                ATIO.Put("LIST_REQUEST received.");

                if ASU.To_String(Password) = ASU.To_String(Password_Admin) then

                    Data := ASU.To_Unbounded_String(CC.Collection_Image(P_Writers));

                    --Creamos mensaje Collection Data

                    LLU.Reset (Buffer);
                    CM.Message_Type'Output(Buffer'Access, CM.Collection_Data);
                    ASU.Unbounded_String'Output(Buffer'Access, Data);
                    LLU.Send(Admin_EP, Buffer'Access);

                else
                    ATIO.Put_Line(" IGNORED, incorrect password");
                end if;

            when CM.Shutdown =>

                ATIO.Put("SHUTDOWN received");
                --Debo hacer que mande un mensaje tipo Shutdown para que el servidor salga de ejecucion
                Password_Admin := ASU.Unbounded_String'Input (Buffer'Access);

                if ASU.To_String(Password) = ASU.To_String(Password_Admin) then
                    Exit;
                else
                    ATIO.Put_Line(". IGNORED, incorrect password");
                end if;

            when CM.Ban =>

                --Password
                Password_Admin := ASU.Unbounded_String'Input (Buffer'Access);
                Nick_Name := ASU.Unbounded_String'Input (Buffer'Access);

                ATIO.Put("BAN received for " & ASU.To_String(Nick_Name) & ".");

                begin

                if ASU.To_String(Password) = ASU.To_String(Password_Admin) then
                    --Aqui continuaremos con la parte de llamar al Delete_Client
                    --ATIO.Put_Line("Llegamos");
                    CC.Delete_Client(P_Writers, Nick_Name);

                end if;

                exception
                    when CC.Client_Collection_Error =>
                        ATIO.Put(" IGNORED, nick not found");
                end;

                ATIO.New_Line;

            when others =>
                ATIO.Put_Line("Error in the selection");
            end case;
      end if;
   end loop;

   LLU.Finalize;

exception
    when Usage_Error =>
        ATIO.Put_Line("Use: ");
        ATIO.Put_Line("       " & ACL.Command_Name & "  <port> ");
        LLU.Finalize;

--    when Ex:others =>
--        Ada.Text_IO.Put_Line ("Excepción imprevista: " &
--                           Ada.Exceptions.Exception_Name(Ex) & " en: " &
--                          Ada.Exceptions.Exception_Message(Ex));
--        LLU.Finalize;
end Chat_Server;
