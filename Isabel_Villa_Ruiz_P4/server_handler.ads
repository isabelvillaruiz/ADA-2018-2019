with Ada.Strings.Unbounded;
with Ada.Calendar;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Strings.Maps;
with Server_Args_Control;
with Hash_Maps_G;
with Ordened_Maps_G;

package Server_Handler is


package LLU renames Lower_Layer_UDP;
package ASU renames Ada.Strings.Unbounded;
package ACL renames Ada.Command_Line;
package ATIO renames ADA.Text_IO;
package CM renames Chat_Messages;
package SAC renames Server_Args_Control;


Num_Args: constant Positive := 2;
Num_Min_AC: constant Positive := 2;
Num_Max_AC: constant Positive := 50;
Num_Max_IC: constant Positive := 150;

Max_Length_Clients: Natural := SAC.Get_Max_Length_Maps(Num_Args, Num_Min_AC, Num_Max_AC);

--NEW IN P4

HASH_SIZE: constant := 9;
type Hash_Range is mod HASH_SIZE;

function Unb_Mod_Hash ( Unbounded_In : ASU.Unbounded_String ) return Hash_Range;

type Active_Client_Record_Type is record
    Client_EP_Handler: LLU.End_Point_Type;
    Last_Connection: Ada.Calendar.Time;
end record;

package Active_Clients_Package is new Hash_Maps_G(Key_Type => ASU.Unbounded_String,
    Value_Type => Active_Client_Record_Type,
    "=" => ASU."=",
    Hash_Range => Hash_Range,
    Hash => Unb_Mod_Hash,
    Max =>  Max_Length_Clients);

package ACP renames Active_Clients_Package;


package Inactive_Clients_Package is new Ordened_Maps_G(Key_Type => ASU.Unbounded_String,
    Value_Type => Ada.Calendar.Time,
    "=" => ASU."=",
    "<" => ASU."<",
    Max => Num_Max_IC);

package ICP renames Inactive_Clients_Package;

--NEW in P4  Chat

procedure Chat_Handler (From: in LLU.End_Point_Type;
                          To: in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type);


procedure Print_All_Active_Clients;
procedure Print_All_Inactive_Clients;

end Server_Handler;
