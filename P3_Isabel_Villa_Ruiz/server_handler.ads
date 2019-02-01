with Ada.Strings.Unbounded;
with Ada.Calendar;
with Lower_Layer_UDP;
with Maps_G;
with Ada.Command_Line;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Strings.Maps;

package Server_Handler is


package LLU renames Lower_Layer_UDP;
package ASU renames Ada.Strings.Unbounded;
package ACL renames Ada.Command_Line;
package ATIO renames ADA.Text_IO;
package CM renames Chat_Messages;


-- Handler para utilizar como parámetro en LLU.Bind en el servidor
-- Muestra en pantalla la cadena de texto recibida y responde enviando
--la cadena "¡Bienvenido!"
-- Este procedimiento NO debe llamarse explícitamente

type Active_Client_Record_Type is record
    Client_EP_Handler: LLU.End_Point_Type;
    Last_Connection: Ada.Calendar.Time;
end record;

package Active_Clients_Package is new Maps_G(Key_Type => ASU.Unbounded_String,
    Value_Type => Active_Client_Record_Type,
    Max_Length => Integer'Value(ACL.Argument(2)), -- hace error en ejecucion como no haya.... cacafut
    "=" => ASU."=");

package ACP renames Active_Clients_Package;

package Inactive_Clients_Package is new Maps_G(Key_Type => ASU.Unbounded_String,
    Value_Type => Ada.Calendar.Time,
    Max_Length => 150,
    "=" => ASU."=");

package ICP renames Inactive_Clients_Package;

procedure Chat_Handler (From: in LLU.End_Point_Type;
                          To: in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type);


procedure Print_All_Active_Clients;
procedure Print_All_Inactive_Clients;

end Server_Handler;
