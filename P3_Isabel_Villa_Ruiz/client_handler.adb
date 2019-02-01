with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;


package body Client_Handler is

    package ATIO renames Ada.Text_IO;
    package ASU renames Ada.Strings.Unbounded;
    --package ACL renames Ada.Command_Line;
    package CM renames Chat_Messages;



procedure Chat_Handler (From: in LLU.End_Point_Type;
                          To: in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type) is

    Reply: ASU.Unbounded_String;
    Nick: ASU.Unbounded_String;
    Message: CM.Message_Type;
begin

    --RECEPCION DEL MENSAJE SERVER
    --CM.Server
    Message:= CM.Message_Type'Input(P_Buffer);

    --Nick
    Nick := ASU.Unbounded_String'Input(P_Buffer);
    --Comentario
    Reply := ASU.Unbounded_String'Input(P_Buffer);
    --Ada.Text_IO.Put(">> Ha llegado al handler!");
    ATIO.New_Line;
    ATIO.Put(ASU.To_String(Nick) & ": ");
    ATIO.Put_Line(ASU.To_String(Reply));
    ATIO.Put(">>");
    --Ada.Text_IO.Put(">> Sale del Handler!!!!!");
end Chat_Handler;

end Client_Handler;
