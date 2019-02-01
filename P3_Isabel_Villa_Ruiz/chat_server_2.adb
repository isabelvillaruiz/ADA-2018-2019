with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Server_Handler;

procedure Chat_Server_2 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package ATIO renames ADA.Text_IO;
   package CM renames Chat_Messages;


   Usage_Error : exception;

   Server_EP: LLU.End_Point_Type;
   Puerto : Integer;
   Maquina : ASU.Unbounded_String;
   IP : ASU.Unbounded_String;
   Nick_Name : ASU.Unbounded_String;
   Max_Client : Integer;

   Request: ASU.Unbounded_String;
   Letter : Character;

   --P_Writers : CC.Collection_Type;
   --P_Readers: CC.Collection_Type;

   --Reply: ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   --Expired : Boolean;

begin

    if ACL.Argument_Count /= 2 then
        raise Usage_Error;
    end if;

	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);

	Ip := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));

	Puerto := Integer'Value(ACL.Argument(1));
    Max_Client := Integer'Value(ACL.Argument(2));

    if Max_Client < 2 or Max_Client > 50 then
        raise Usage_Error;
    end if;


    --END POINT DEL SERVIDOR
    Server_EP := LLU.Build ( ASU.To_String(IP), Puerto);
    LLU.Bind(Server_EP, Server_Handler.Chat_Handler'Access);

   loop
       ATIO.Get_Immediate(Letter);
       case Letter is
           when 'l' | 'L' =>
               ATIO.Put_Line("ACTIVE CLIENTS");
               ATIO.Put_Line("==============");
               Server_Handler.Print_All_Active_Clients;
               ATIO.New_Line;

           when 'o' | 'O' =>
               ATIO.Put_Line("OLD CLIENTS");
               ATIO.Put_Line("==============");
               Server_Handler.Print_All_Inactive_Clients;
               ATIO.New_Line;
           when others =>
               null;
       end case;
   end loop;


exception
    when Usage_Error =>
        ATIO.Put_Line("Use: ");
        ATIO.Put_Line("       " & ACL.Command_Name & "  <port> " & "  < max_client(2-50) > ");
        LLU.Finalize;

--    when Ex:others =>
--        Ada.Text_IO.Put_Line ("Excepción imprevista: " &
--                           Ada.Exceptions.Exception_Name(Ex) & " en: " &
--                          Ada.Exceptions.Exception_Message(Ex));
--        LLU.Finalize;
end Chat_Server_2;
