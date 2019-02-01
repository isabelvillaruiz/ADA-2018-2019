with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;

procedure Server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ATIO renames ADA.Text_IO;
   package CM renames Chat_Messages;
   package CC renames Client_Collections;

   Usage_Error : exception;

   Server_EP: LLU.End_Point_Type;
   Client_EP: LLU.End_Point_Type;
   Puerto : Integer;
   Maquina : ASU.Unbounded_String;
   IP : ASU.Unbounded_String;
   Nick_Name : ASU.Unbounded_String;

   Message : CM.Message_Type;
   Buffer:  aliased LLU.Buffer_Type(1024);
   Request: ASU.Unbounded_String;

   P_Writers : CC.Collection_Type;
   P_Readers: CC.Collection_Type;

   --Reply: ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   Expired : Boolean;

begin

    if ACL.Argument_Count /= 1 then
        raise Usage_Error;
    end if;

	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);

	Ip := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));

	Puerto := Integer'Value(ACL.Argument(1));


   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build ( ASU.To_String(IP), Puerto);


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
                        ATIO.Put_Line("INIT received from " & ASU.To_String(Nick_Name) &
                        ". IGNORED, nick already used");
                end;


                -- reinicializa (vacía) el buffer
                LLU.Reset (Buffer);


            when CM.Writer =>

                --Si es Writter:
                --Client_EP
                Client_EP := LLU.End_Point_Type'Input (Buffer'Access);
                --Comentario
                Request := ASU.Unbounded_String'Input (Buffer'Access);

                ATIO.Put("WRITER received from ");

                begin
                    Nick_Name := CC.Search_Client(P_Writers,Client_EP);
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
                        ATIO.Put_Line("unknown client. IGNORED");
                end;

            when others =>
                ATIO.Put_Line("Error in the selection");
            end case;
      end if;
   end loop;

   -- nunca se alcanza este punto
   -- si se alcanzara, habría que llamar a LLU.Finalize;

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
end Server;
